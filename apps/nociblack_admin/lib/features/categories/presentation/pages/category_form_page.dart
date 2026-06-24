import 'package:flutter/material.dart';

import '../../../../core/formatters/slug_generator.dart';
import '../../domain/entities/category_draft.dart';
import '../../domain/repositories/category_repository.dart';
import '../controllers/category_form_controller.dart';

final class CategoryFormPage extends StatefulWidget {
  const CategoryFormPage({required this.repository, super.key});

  final CategoryRepository repository;

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

final class _CategoryFormPageState extends State<CategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _slugController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _displayOrderController = TextEditingController(text: '0');
  late final CategoryFormController _controller;
  bool _slugManuallyEdited = false;

  @override
  void initState() {
    super.initState();
    _controller = CategoryFormController(widget.repository);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    _descriptionController.dispose();
    _displayOrderController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final description = _descriptionController.text.trim();
    final isCreated = await _controller.create(
      CategoryDraft(
        name: _nameController.text.trim(),
        slug: _slugController.text.trim(),
        description: description.isEmpty ? null : description,
        displayOrder: int.parse(_displayOrderController.text.trim()),
      ),
    );

    if (isCreated && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle catégorie')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      key: const Key('category_name_field'),
                      controller: _nameController,
                      readOnly: _controller.isSubmitting,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Nom',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      onChanged: (value) {
                        if (!_slugManuallyEdited) {
                          _slugController.text = SlugGenerator.fromText(value);
                        }
                      },
                      validator: _validateRequired,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('category_slug_field'),
                      controller: _slugController,
                      readOnly: _controller.isSubmitting,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Slug',
                        prefixIcon: Icon(Icons.link),
                      ),
                      onChanged: (_) => _slugManuallyEdited = true,
                      validator: _validateSlug,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('category_description_field'),
                      controller: _descriptionController,
                      readOnly: _controller.isSubmitting,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Description facultative',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('category_order_field'),
                      controller: _displayOrderController,
                      readOnly: _controller.isSubmitting,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Ordre d’affichage',
                        prefixIcon: Icon(Icons.sort),
                      ),
                      validator: _validateDisplayOrder,
                    ),
                    if (_controller.errorMessage case final message?) ...[
                      const SizedBox(height: 16),
                      Text(
                        message,
                        key: const Key('category_form_error'),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      key: const Key('category_submit_button'),
                      onPressed: _controller.isSubmitting ? null : _submit,
                      child: _controller.isSubmitting
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Créer la catégorie'),
                    ),
                  ],
                ),
              ),
            );
          },
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

  String? _validateDisplayOrder(String? value) {
    final order = int.tryParse(value?.trim() ?? '');
    return order == null || order < 0
        ? 'Saisissez un entier positif ou nul.'
        : null;
  }
}
