enum TaskCategory {
  personal('Personal'),
  work('Work'),
  financial('Financial'),
  other('Other');

  const TaskCategory(this.label);

  final String label;

  static TaskCategory fromName(String? name) => TaskCategory.values.firstWhere(
    (category) => category.name == name,
    orElse: () => TaskCategory.personal,
  );
}

/// Where a task sits relative to today, used to group and filter the list.
enum TaskBucket {
  overdue('Overdue'),
  today('Today'),
  tomorrow('Tomorrow'),
  upcoming('Upcoming'),
  completed('Completed');

  const TaskBucket(this.label);

  final String label;
}

class Task {
  Task({
    required this.title,
    required this.description,
    this.dueDate,
    this.isCompleted = false,
    this.category = TaskCategory.personal,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    final due = json['dueDate'] as String?;
    return Task(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      dueDate: due == null ? null : DateTime.tryParse(due),
      isCompleted: json['isCompleted'] as bool? ?? false,
      category: TaskCategory.fromName(json['category'] as String?),
    );
  }

  String title;
  String description;
  DateTime? dueDate;
  bool isCompleted;
  TaskCategory category;

  /// A due time of exactly midnight means no time was chosen.
  bool get hasDueTime =>
      dueDate != null && (dueDate!.hour != 0 || dueDate!.minute != 0);

  TaskBucket bucketAt(DateTime now) {
    if (isCompleted) return TaskBucket.completed;
    final due = dueDate;
    if (due == null) return TaskBucket.upcoming;
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(due.year, due.month, due.day);
    final days = dueDay.difference(today).inDays;
    if (days < 0) return TaskBucket.overdue;
    if (days == 0) {
      return hasDueTime && due.isBefore(now)
          ? TaskBucket.overdue
          : TaskBucket.today;
    }
    return days == 1 ? TaskBucket.tomorrow : TaskBucket.upcoming;
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'dueDate': dueDate?.toIso8601String(),
    'isCompleted': isCompleted,
    'category': category.name,
  };
}
