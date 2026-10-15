import 'package:flutter/material.dart';

/// Dialog for editing a favorite's personal note.
/// Closes with the new note text, or null if cancelled.
class EditNoteDialog extends StatefulWidget {
  const EditNoteDialog({super.key, required this.initialNote});

  final String initialNote;

  @override
  State<EditNoteDialog> createState() => _EditNoteDialogState();
}

class _EditNoteDialogState extends State<EditNoteDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialNote);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Personal note'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 140, // keeps the note short
        minLines: 2,
        maxLines: 4,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          hintText: 'Why do you like this post?',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Save note'),
        ),
      ],
    );
  }
}
