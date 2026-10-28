import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class DeleteTaskDialog extends StatelessWidget {
  const DeleteTaskDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withAlpha(150),
      builder: (_) => const DeleteTaskDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: context.colors.dangerTint,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: context.colors.danger,
                size: 26,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Delete this task?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.text,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You can undo this right after deleting.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.muted,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: ButtonStyle(
                      minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
                      foregroundColor: WidgetStatePropertyAll(
                        context.colors.text,
                      ),
                      overlayColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.pressed)
                            ? context.colors.border
                            : null,
                      ),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(color: context.colors.border),
                        ),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ButtonStyle(
                      minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
                      backgroundColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.pressed)
                            ? Color.alphaBlend(
                                Colors.black.withAlpha(40),
                                context.colors.danger,
                              )
                            : context.colors.danger,
                      ),
                      foregroundColor: WidgetStatePropertyAll(
                        context.colors.onAccent,
                      ),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    child: const Text(
                      'Delete',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
