class Task {
  Task({
    required this.title,
    required this.description,
    this.dueDate,
    this.isCompleted = false,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    final due = json['dueDate'] as String?;
    return Task(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      dueDate: due == null ? null : DateTime.tryParse(due),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  String title;
  String description;
  DateTime? dueDate;
  bool isCompleted;

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'dueDate': dueDate?.toIso8601String(),
    'isCompleted': isCompleted,
  };
}
