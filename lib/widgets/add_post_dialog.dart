import 'package:flutter/material.dart';

import '../services/post_service.dart';

/// Dialog with title + body fields. Sends the post with HTTP POST.
/// Closes with {'title', 'body'} when the server answers 201,
/// or with null if the user cancels.
class AddPostDialog extends StatefulWidget {
  const AddPostDialog({super.key, required this.service});

  final PostService service;

  @override
  State<AddPostDialog> createState() => _AddPostDialogState();
}

class _AddPostDialogState extends State<AddPostDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return; // blocks double taps
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await widget.service.createPost(title: title, body: body);
      if (!mounted) return;
      Navigator.pop(context, {'title': title, 'body': body});
    } on PostException catch (e) {
      _showFailure(e.message);
    } catch (_) {
      _showFailure('Something went wrong while sending the post.');
    }
  }

  void _showFailure(String message) {
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _error = message;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Post failed: $message')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: !_submitting,
      child: AlertDialog(
        title: const Text('New post'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  enabled: !_submitting,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Give your post a title',
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Please enter a title.'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _bodyController,
                  enabled: !_submitting,
                  minLines: 3,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Body',
                    hintText: 'Write your post here',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Please write something in the body.'
                      : null,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error_outline,
                          size: 18, color: theme.colorScheme.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: theme.colorScheme.error),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _submitting ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
