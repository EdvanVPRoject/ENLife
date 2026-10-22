import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../data/models/task_item.dart';
import '../data/services/storage_service.dart';

class TaskProvider extends ChangeNotifier {
  final StorageService _storage;
  List<TaskItem> _items = [];

  TaskProvider(this._storage);

  List<TaskItem> get items => List.unmodifiable(_items);

  List<TaskItem> get pendingTasks => _items.where((t) => !t.isCompleted).toList();
  List<TaskItem> get completedTasks => _items.where((t) => t.isCompleted).toList();

  Future<void> load() async {
    _items = await _storage.getTasks();
    notifyListeners();
  }

  Future<void> toggleTask(String id) async {
    final idx = _items.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    _items[idx].isCompleted = !_items[idx].isCompleted;
    await _storage.saveTasks(_items);
    notifyListeners();
  }

  Future<void> addTask({
    required String title,
    TaskPriority priority = TaskPriority.medium,
    String category = 'Umum',
    DateTime? dueDate,
  }) async {
    final newTask = TaskItem(
      id: const Uuid().v4(),
      title: title,
      priority: priority,
      category: category,
      dueDate: dueDate,
    );
    _items.insert(0, newTask);
    await _storage.saveTasks(_items);
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    _items.removeWhere((t) => t.id == id);
    await _storage.saveTasks(_items);
    notifyListeners();
  }
}
