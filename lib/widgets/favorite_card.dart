import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A saved post with its personal note, an edit button and a delete button.
class FavoriteCard extends StatelessWidget {
  const FavoriteCard({
    super.key,
    required this.favorite,
    required this.onTap,
    required this.onEditNote,
    required this.onDelete,
  });

  /// The Map stored in Hive: {id, title, body, note}.
  final Map<String, dynamic> favorite;
  final VoidCallback onTap;
  final VoidCallback onEditNote;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final id = favorite['id'];
    final title = _capitalize('${favorite['title'] ?? ''}');
    final note = '${favorite['note'] ?? ''}'.trim();

    return Material(
      color: AppColors.card(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.border(context)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 4, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withAlpha(35),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'POST #$id',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Edit note',
                    icon: const Icon(Icons.edit_note_rounded),
                    onPressed: onEditNote,
                  ),
                  IconButton(
                    tooltip: 'Remove from favorites',
                    icon: Icon(Icons.delete_outline_rounded,
                        color: theme.colorScheme.error),
                    onPressed: onDelete,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.sticky_note_2_outlined,
                          size: 18, color: AppColors.muted(context)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          note.isEmpty
                              ? 'No note yet. Tap the pencil to add one.'
                              : note,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: note.isEmpty
                                ? AppColors.muted(context)
                                : theme.colorScheme.onSurface,
                            fontStyle: note.isEmpty
                                ? FontStyle.italic
                                : FontStyle.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _capitalize(String text) =>
      text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
}
