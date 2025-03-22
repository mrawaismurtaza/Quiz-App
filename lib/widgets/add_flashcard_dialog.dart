import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:dreamflow/models/flashcard_model.dart';
import 'package:dreamflow/services/user_service.dart';

class AddFlashcardDialog extends StatefulWidget {
  const AddFlashcardDialog({super.key});

  @override
  State<AddFlashcardDialog> createState() => _AddFlashcardDialogState();
}

class _AddFlashcardDialogState extends State<AddFlashcardDialog> {
  final _formKey = GlobalKey<FormState>();
  final _termController = TextEditingController();
  final _definitionController = TextEditingController();
  final _exampleController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _termController.dispose();
    _definitionController.dispose();
    _exampleController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      final userService = Provider.of<UserService>(context, listen: false);
      
      final newFlashcard = Flashcard(
        id: const Uuid().v4(),
        languageId: userService.selectedLanguageId,
        term: _termController.text.trim(),
        definition: _definitionController.text.trim(),
        example: _exampleController.text.trim().isNotEmpty 
            ? _exampleController.text.trim() 
            : null,
        lastReviewed: DateTime.now(),
      );

      Navigator.of(context).pop(newFlashcard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Add New Flashcard'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _termController,
                decoration: const InputDecoration(
                  labelText: 'Term',
                  hintText: 'Enter the word or phrase',
                  prefixIcon: Icon(Icons.text_fields),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a term';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _definitionController,
                decoration: const InputDecoration(
                  labelText: 'Definition',
                  hintText: 'Enter the meaning',
                  prefixIcon: Icon(Icons.translate),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a definition';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _exampleController,
                decoration: const InputDecoration(
                  labelText: 'Example (Optional)',
                  hintText: 'Enter an example sentence',
                  prefixIcon: Icon(Icons.format_quote),
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitForm,
          child: _isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add Flashcard'),
        ),
      ],
    );
  }
}