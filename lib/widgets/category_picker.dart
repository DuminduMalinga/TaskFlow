import 'package:flutter/material.dart';

import '../models/task.dart';
import '../theme/app_colors.dart';

IconData categoryIcon(TaskCategory category) => switch (category) {
  TaskCategory.personal => Icons.person_outline_rounded,
  TaskCategory.work => Icons.work_outline_rounded,
  TaskCategory.financial => Icons.account_balance_wallet_outlined,
  TaskCategory.other => Icons.label_outline_rounded,
};

/// Single-choice chips for picking which category a task belongs to.
class CategoryPicker extends StatelessWidget {
  const CategoryPicker({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final TaskCategory selected;
  final ValueChanged<TaskCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final category in TaskCategory.values)
          _CategoryChip(
            category: category,
            selected: category == selected,
            onTap: () => onSelected(category),
          ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final TaskCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: selected ? navy : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? navy : border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                categoryIcon(category),
                size: 18,
                color: selected ? Colors.white : muted,
              ),
              const SizedBox(width: 8),
              Text(
                category.label,
                style: TextStyle(
                  color: selected ? Colors.white : navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
