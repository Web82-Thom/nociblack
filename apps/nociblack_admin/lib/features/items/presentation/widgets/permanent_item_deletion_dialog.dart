import 'package:flutter/material.dart';

/// Confirmation renforcée pour une action irréversible.
final class PermanentItemDeletionDialog extends StatefulWidget {
  const PermanentItemDeletionDialog({required this.itemTitle, super.key});

  static const confirmationWord = 'SUPPRIMER';

  final String itemTitle;

  @override
  State<PermanentItemDeletionDialog> createState() =>
      _PermanentItemDeletionDialogState();
}

final class _PermanentItemDeletionDialogState
    extends State<PermanentItemDeletionDialog> {
  final _confirmationController = TextEditingController();
  bool _isConfirmed = false;

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  void _validateConfirmation(String value) {
    final isConfirmed =
        value.trim().toUpperCase() ==
        PermanentItemDeletionDialog.confirmationWord;
    if (isConfirmed == _isConfirmed) return;

    setState(() => _isConfirmed = isConfirmed);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Suppression définitive'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'L’article « ${widget.itemTitle} » et toutes ses images seront '
              'supprimés définitivement. Cette action est irréversible.',
            ),
            const SizedBox(height: 16),
            const Text('Saisissez SUPPRIMER pour confirmer.'),
            const SizedBox(height: 8),
            TextField(
              key: const Key('permanent_delete_confirmation_field'),
              controller: _confirmationController,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              onChanged: _validateConfirmation,
              decoration: const InputDecoration(labelText: 'Confirmation'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        FilledButton(
          key: const Key('permanent_delete_button'),
          onPressed: _isConfirmed
              ? () => Navigator.of(context).pop(true)
              : null,
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Supprimer définitivement'),
        ),
      ],
    );
  }
}
