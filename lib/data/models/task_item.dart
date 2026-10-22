enum TaskPriority { low, medium, high }

class TaskItem {
  final String id;
  final String title;
  bool isCompleted;
  final TaskPriority priority;
  final String category; // 'Kerja', 'Pribadi', 'Belanja', 'Kesehatan'
  final DateTime? dueDate;

  TaskItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    this.category = 'Umum',
    this.dueDate,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'isCompleted': isCompleted,
    'priority': priority.name,
    'category': category,
    'dueDate': dueDate?.toIso8601String(),
  };

  factory TaskItem.fromJson(Map<String, dynamic> json) => TaskItem(
    id: json['id'],
    title: json['title'],
    isCompleted: json['isCompleted'] ?? false,
    priority: TaskPriority.values.byName(json['priority'] ?? 'medium'),
    category: json['category'] ?? 'Umum',
    dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
  );
}
