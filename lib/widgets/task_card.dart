import 'package:flutter/material.dart';

import '../models/task.dart';
import '../theme/app_colors.dart';
import 'category_picker.dart';

enum _TaskAction { edit, delete }

class TaskCard extends StatelessWidget {
  const TaskCard({
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static String _dueLabel(BuildContext context, DateTime due) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final date = '${months[due.month - 1]} ${due.day}';
    // Midnight means "no time set".
    if (due.hour == 0 && due.minute == 0) return date;
    final time = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(due));
    return '$date, $time';
  }

  @override
  Widget build(BuildContext context) {
    final done = task.isCompleted;
    final due = task.dueDate;
    final overdue = task.bucketAt(DateTime.now()) == TaskBucket.overdue;
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TaskCheckbox(value: done, onTap: onToggle),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      color: done ? context.colors.muted : context.colors.text,
                      fontSize: 16,
                      height: 1.5,
                      fontWeight: FontWeight.w700,
                      decoration: done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (task.description.isNotEmpty)
                    Text(
                      task.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.colors.muted,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      _MetaLabel(
                        icon: categoryIcon(task.category),
                        text: task.category.label,
                      ),
                      if (due != null)
                        _MetaLabel(
                          icon: Icons.schedule_rounded,
                          text: _dueLabel(context, due),
                          color: overdue
                              ? context.colors.danger
                              : context.colors.muted,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          PopupMenuButton<_TaskAction>(
            tooltip: 'More actions',
            icon: Icon(Icons.more_vert_rounded, color: context.colors.muted),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            onSelected: (action) => switch (action) {
              _TaskAction.edit => onEdit(),
              _TaskAction.delete => onDelete(),
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: _TaskAction.edit,
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: context.colors.text,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Edit',
                      style: TextStyle(
                        color: context.colors.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: _TaskAction.delete,
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: context.colors.danger,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Delete',
                      style: TextStyle(
                        color: context.colors.danger,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskCheckbox extends StatelessWidget {
  const _TaskCheckbox({required this.value, required this.onTap});

  final bool value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: value ? 'Mark task as active' : 'Mark task as completed',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: value ? context.colors.accent : context.colors.card,
                border: Border.all(
                  color: value ? context.colors.accent : context.colors.muted,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: value
                  ? Icon(
                      Icons.check_rounded,
                      color: context.colors.onAccent,
                      size: 16,
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaLabel extends StatelessWidget {
  const _MetaLabel({required this.icon, required this.text, this.color});

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? context.colors.muted;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
