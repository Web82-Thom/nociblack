import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nociblack/features/items/domain/entities/catalog_item.dart';

import '../../../../core/formatters/price_formatter.dart';
import '../../../../core/formatters/slug_generator.dart';
import '../../../categories/domain/repositories/category_repository.dart';
import '../../../categories/presentation/controllers/active_categories_controller.dart';
import '../../domain/entities/item_draft.dart';
import '../../domain/repositories/item_image_repository.dart';
import '../../domain/repositories/item_repository.dart';
import '../../domain/services/item_image_creation_service.dart';
import '../../domain/services/item_image_display_service.dart';
import '../../domain/services/item_image_update_service.dart';
import '../controllers/item_form_controller.dart';
import '../controllers/item_images_controller.dart';
import '../widgets/item_image_picker_section.dart';
import 'package:image_picker/image_picker.dart';

/// Formulaire de création d'un article brouillon.
final class ItemFormPage extends StatefulWidget {
  const ItemFormPage({
    required this.categoryRepository,
    required this.itemRepository,
    required this.itemImageRepository,
    required this.itemImageCreationService,
    required this.itemImageUpdateService,
    required this.itemImageDisplayService,
    this.itemToEdit,
    super.key,
  });

  final CategoryRepository categoryRepository;
  final ItemRepository itemRepository;
  final ItemImageRepository itemImageRepository;
  final ItemImageCreationService itemImageCreationService;
  final ItemImageUpdateService itemImageUpdateService;
  final ItemImageDisplayService itemImageDisplayService;
  final CatalogItem? itemToEdit;

  bool get isEditing => itemToEdit != null;

  @override
  State<ItemFormPage> createState() => _ItemFormPageState();
}

final class _ItemFormPageState extends State<ItemFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _slugController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController(text: '0');
  final _skuController = TextEditingController();
  final _referenceFocusNode = FocusNode();
  final _displayOrderController = TextEditingController(text: '0');
  late final ActiveCategoriesController _categoriesController;
  late final ItemFormController _itemController;
  late final ItemImagesController _itemImagesController;
  final ImagePicker _imagePicker = ImagePicker();
  late final Listenable _formListenable;
  String? _selectedCategoryId;
  bool _slugManuallyEdited = false;
  bool _isLoadingExistingImages = false;
  String? _imageLoadErrorMessage;

  @override
  void initState() {
    super.initState();
    _categoriesController = ActiveCategoriesController(
      widget.categoryRepository,
    );
    _itemController = ItemFormController(
      repository: widget.itemRepository,
      imageCreationService: widget.itemImageCreationService,
      imageUpdateService: widget.itemImageUpdateService,
    );
    _itemImagesController = ItemImagesController();
    _itemImagesController.initialize(const []);
    if (widget.itemToEdit case final item?) {
      _selectedCategoryId = item.categoryId;
      _titleController.text = item.title;
      _descriptionController.text = item.description ?? '';
      _priceController.text = PriceFormatter.inEuros(
        item.priceCents,
      ).replaceAll('€', '').trim();
      _stockController.text = item.stockQuantity.toString();
      _skuController.text = item.sku;
      _displayOrderController.text = item.displayOrder.toString();
      _slugController.text = SlugGenerator.fromText(item.title);
    }
    _formListenable = Listenable.merge([
      _categoriesController,
      _itemController,
      _itemImagesController,
    ]);
    _categoriesController.load();
    if (widget.itemToEdit case final item?) {
      _loadExistingImages(item.id);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _slugController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _skuController.dispose();
    _referenceFocusNode.dispose();
    _displayOrderController.dispose();
    _categoriesController.dispose();
    _itemController.dispose();
    _itemImagesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (!_itemImagesController.canAddImage) {
      return;
    }

    final selectedImage = await _imagePicker.pickImage(source: source);

    if (selectedImage == null) {
      return;
    }

    _itemImagesController.addSelectedImage(File(selectedImage.path));
  }

  Future<void> _loadExistingImages(String itemId) async {
    setState(() {
      _isLoadingExistingImages = true;
      _imageLoadErrorMessage = null;
    });

    try {
      final images = await widget.itemImageRepository.getImagesByItemId(itemId);
      if (!mounted) return;
      _itemImagesController.initialize(images);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _imageLoadErrorMessage =
            'Impossible de charger les images de l’article.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingExistingImages = false);
      }
    }
  }

  Future<void> _showImageSourcePicker() async {
    final selectedSource = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Caméra'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Galerie'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Annuler'),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || selectedSource == null) {
      return;
    }

    await _pickImage(selectedSource);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final description = _descriptionController.text.trim();

    final draft = ItemDraft(
      categoryId: _selectedCategoryId!,
      title: _titleController.text.trim(),
      slug: _slugController.text.trim(),
      description: description.isEmpty ? null : description,
      priceCents: PriceFormatter.tryParseEuros(_priceController.text)!,
      stockQuantity: int.parse(_stockController.text.trim()),
      sku: _skuController.text.trim().toUpperCase(),
      displayOrder: int.parse(_displayOrderController.text.trim()),
    );

    final itemToEdit = widget.itemToEdit;

    final isSaved = itemToEdit == null
        ? await _itemController.create(
            draft,
            imageSourcePaths: _itemImagesController.newSelectedImages
                .map((image) => image.path)
                .toList(growable: false),
          )
        : await _itemController.update(
            itemId: itemToEdit.id,
            draft: draft,
            existingImages: _itemImagesController.existingImages,
            removedExistingImages: _itemImagesController.removedExistingImages,
            newImageSourcePaths: _itemImagesController.newSelectedImages
                .map((image) => image.path)
                .toList(growable: false),
          );

    if (isSaved && mounted) {
      Navigator.of(context).pop(true);
      return;
    }

    if (mounted) {
      _referenceFocusNode.requestFocus();
      _skuController.selection = TextSelection.collapsed(
        offset: _skuController.text.length,
      );
    }
  }

  Future<void> _confirmArchive() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Archivage'),
          content: const Text(
            'Êtes-vous sûr de vouloir archiver cet article ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Archiver'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final success = await _itemController.archive(widget.itemToEdit!.id);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Suppression'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer cet article ?\n\n'
            'Cette action est irréversible.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final success = await _itemController.delete(widget.itemToEdit!.id);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Modifier l’article' : 'Nouvel article'),
        actions: widget.isEditing
            ? [
                IconButton(
                  onPressed: _confirmArchive,
                  icon: Icon(Icons.archive),
                ),
                IconButton(
                  onPressed: _confirmDelete,
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ]
            : [],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _formListenable,
          builder: (context, child) {
            return switch (_categoriesController.status) {
              ActiveCategoriesStatus.initial ||
              ActiveCategoriesStatus.loading => const Center(
                child: CircularProgressIndicator(),
              ),
              ActiveCategoriesStatus.failure => _CategoriesFailureView(
                message: _categoriesController.errorMessage!,
                onRetry: _categoriesController.load,
              ),
              ActiveCategoriesStatus.success
                  when _categoriesController.categories.isEmpty =>
                const _NoActiveCategoryView(),
              ActiveCategoriesStatus.success => _buildForm(context),
            };
          },
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Informations générales',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              key: const Key('item_category_field'),
              initialValue: _selectedCategoryId,
              decoration: const InputDecoration(
                labelText: 'Catégorie',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: _categoriesController.categories
                  .map((category) {
                    return DropdownMenuItem(
                      value: category.id,
                      child: Text(category.name),
                    );
                  })
                  .toList(growable: false),
              onChanged: _itemController.isSubmitting
                  ? null
                  : (value) => setState(() => _selectedCategoryId = value),
              validator: (value) =>
                  value == null ? 'Sélectionnez une catégorie.' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('item_title_field'),
              controller: _titleController,
              readOnly: _itemController.isSubmitting,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Titre'),
              onChanged: (value) {
                if (!_slugManuallyEdited) {
                  _slugController.text = SlugGenerator.fromText(value);
                }
              },
              validator: _validateRequired,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('item_slug_field'),
              controller: _slugController,
              readOnly: _itemController.isSubmitting,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Slug'),
              onChanged: (_) => _slugManuallyEdited = true,
              validator: _validateSlug,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('item_description_field'),
              controller: _descriptionController,
              readOnly: _itemController.isSubmitting,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Description facultative',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),

            if (_isLoadingExistingImages) ...[
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 24),
            ] else ...[
              if (_imageLoadErrorMessage case final message?) ...[
                _ImageLoadFailureView(
                  message: message,
                  onRetry: widget.itemToEdit == null
                      ? null
                      : () => _loadExistingImages(widget.itemToEdit!.id),
                ),
                const SizedBox(height: 24),
              ],
              ItemImagePickerSection(
                imageCount: _itemImagesController.totalImageCount,
                existingImages: _itemImagesController.existingImages,
                removedExistingImages:
                    _itemImagesController.removedExistingImages,
                imageDisplayService: widget.itemImageDisplayService,
                selectedImages: _itemImagesController.newSelectedImages,
                onAddImagePressed:
                    _itemController.isSubmitting ||
                        _imageLoadErrorMessage != null
                    ? null
                    : _showImageSourcePicker,
                onRemoveExistingImage:
                    _itemController.isSubmitting ||
                        _imageLoadErrorMessage != null
                    ? null
                    : _itemImagesController.markExistingImageForRemoval,
                onRestoreExistingImage: _itemController.isSubmitting
                    ? null
                    : _itemImagesController.restoreExistingImage,
                onRemoveSelectedImage: _itemController.isSubmitting
                    ? null
                    : _itemImagesController.removeSelectedImage,
              ),
              const SizedBox(height: 24),
            ],
            TextFormField(
              key: const Key('item_price_field'),
              controller: _priceController,
              readOnly: _itemController.isSubmitting,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Prix en euros',
                suffixText: '€',
              ),
              validator: _validatePrice,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('item_stock_field'),
              controller: _stockController,
              readOnly: _itemController.isSubmitting,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Stock'),
              validator: (value) => _validateNonNegativeInteger(
                value,
                'Saisissez un stock positif ou nul.',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('item_sku_field'),
              controller: _skuController,
              focusNode: _referenceFocusNode,
              readOnly: _itemController.isSubmitting,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'REF'),
              validator: _validateRequired,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('item_order_field'),
              controller: _displayOrderController,
              readOnly: _itemController.isSubmitting,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(labelText: 'Ordre d’affichage'),
              validator: (value) => _validateNonNegativeInteger(
                value,
                'Saisissez un ordre positif ou nul.',
              ),
            ),
            if (_itemController.errorMessage case final message?) ...[
              const SizedBox(height: 16),
              Text(
                message,
                key: const Key('item_form_error'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('item_submit_button'),
              onPressed: _itemController.isSubmitting ? null : _submit,
              child: _itemController.isSubmitting
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      widget.isEditing
                          ? 'Enregistrer les modifications'
                          : 'Enregistrer',
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateRequired(String? value) {
    return value == null || value.trim().isEmpty
        ? 'Ce champ est obligatoire.'
        : null;
  }

  String? _validateSlug(String? value) {
    final slug = value?.trim() ?? '';
    if (slug.isEmpty) return 'Le slug est obligatoire.';
    if (!RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(slug)) {
      return 'Utilisez uniquement des minuscules, chiffres et tirets.';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    return PriceFormatter.tryParseEuros(value ?? '') == null
        ? 'Saisissez un prix valide avec deux décimales maximum.'
        : null;
  }

  String? _validateNonNegativeInteger(String? value, String message) {
    final number = int.tryParse(value?.trim() ?? '');
    return number == null || number < 0 ? message : null;
  }
}

final class _CategoriesFailureView extends StatelessWidget {
  const _CategoriesFailureView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: onRetry,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}

final class _NoActiveCategoryView extends StatelessWidget {
  const _NoActiveCategoryView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Aucune catégorie active. Une catégorie est nécessaire avant de '
          'créer un article.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

final class _ImageLoadFailureView extends StatelessWidget {
  const _ImageLoadFailureView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              message,
              key: const Key('item_images_load_error'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: onRetry,
                child: const Text('Réessayer les images'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
