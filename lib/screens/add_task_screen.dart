import 'package:flutter/material.dart';

import '../models/task.dart';
import '../theme/app_colors.dart';
import '../widgets/category_picker.dart';

class AddTaskResult {
  const AddTaskResult({
    required this.title,
    required this.description,
    this.dueDate,
    this.category = TaskCategory.personal,
  });

  final String title;
  final String description;
  final DateTime? dueDate;
  final TaskCategory category;
}

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _showDateError = false;
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  TaskCategory _category = TaskCategory.personal;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      initialDate: _dueDate ?? DateTime.now(),
    );
    if (selectedDate != null) {
      setState(() {
        _dueDate = selectedDate;
        _showDateError = false;
      });
    }
  }

  Future<void> _selectDueTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
    );
    if (selected != null) setState(() => _dueTime = selected);
  }

  DateTime _combinedDueDate() {
    final date = _dueDate!;
    final time = _dueTime;
    return DateTime(
      date.year,
      date.month,
      date.day,
      time?.hour ?? 0,
      time?.minute ?? 0,
    );
  }

  void _createTask() {
    final isValid = _formKey.currentState!.validate();
    if (_dueDate == null) setState(() => _showDateError = true);
    if (!isValid || _dueDate == null) return;
    Navigator.pop(
      context,
      AddTaskResult(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: _combinedDueDate(),
        category: _category,
      ),
    );
  }

  String _formatDate(DateTime date) {
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Scaffold(
      backgroundColor: context.colors.card,
      appBar: AppBar(
        backgroundColor: context.colors.card,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'Add New Task',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottomInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stay on top of what matters.',
                  style: TextStyle(
                    color: context.colors.muted,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),
                const _FieldLabel(label: 'Task title', required: true),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  maxLength: 80,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Plan the team meeting',
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a task title'
                      : null,
                ),
                const SizedBox(height: 24),
                const _FieldLabel(label: 'Description'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.newline,
                  maxLines: 5,
                  minLines: 1,
                  decoration: const InputDecoration(
                    hintText: 'Add details to help you complete this task',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24),
                const _FieldLabel(label: 'Category'),
                const SizedBox(height: 8),
                CategoryPicker(
                  selected: _category,
                  onSelected: (value) => setState(() => _category = value),
                ),
                const SizedBox(height: 24),
                const _FieldLabel(label: 'Due date', required: true),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _selectDueDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      suffixIcon: const Icon(
                        Icons.calendar_today_outlined,
                        size: 19,
                      ),
                      errorText: _showDateError ? 'Choose a due date' : null,
                    ),
                    child: Text(
                      _dueDate == null
                          ? 'Choose a date'
                          : _formatDate(_dueDate!),
                      style: TextStyle(
                        color: _dueDate == null
                            ? context.colors.muted
                            : context.colors.text,
                        fontSize: 14,
                        fontWeight: _dueDate == null
                            ? FontWeight.w400
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const _FieldLabel(label: 'Time (optional)'),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _selectDueTime,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      suffixIcon: _dueTime == null
                          ? const Icon(Icons.schedule_rounded, size: 19)
                          : IconButton(
                              onPressed: () => setState(() => _dueTime = null),
                              tooltip: 'Clear time',
                              icon: const Icon(Icons.close_rounded, size: 19),
                            ),
                    ),
                    child: Text(
                      _dueTime == null
                          ? 'Add a time'
                          : _dueTime!.format(context),
                      style: TextStyle(
                        color: _dueTime == null
                            ? context.colors.muted
                            : context.colors.text,
                        fontSize: 14,
                        fontWeight: _dueTime == null
                            ? FontWeight.w400
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _createTask,
                    style: FilledButton.styleFrom(
                      backgroundColor: context.colors.accent,
                      foregroundColor: context.colors.onAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Create Task',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: context.colors.text,
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, this.required = false});

  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: context.colors.text,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (required)
          Text(
            ' *',
            style: TextStyle(
              color: context.colors.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}
