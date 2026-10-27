class Task {
  Task({
    required this.title,
    required this.description,
    this.dueDate,
    this.isCompleted = false,
  });

  String title;
  String description;
  DateTime? dueDate;
  bool isCompleted;
}
