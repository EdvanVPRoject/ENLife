import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../data/models/habit_item.dart';
import '../data/services/storage_service.dart';

class HabitProvider extends ChangeNotifier {
  final StorageService _storage;
  List<HabitItem> _items = [];

  HabitProvider(this._storage);

  List<HabitItem> get items => List.unmodifiable(_items);

  int get completedTodayCount => _items.where((h) => h.isCompletedToday()).length;

  double get completionRateToday {
    if (_items.isEmpty) return 0.0;
    return completedTodayCount / _items.length;
  }

  Future<void> load() async {
    _items = await _storage.getHabits();
    notifyListeners();
  }

  Future<void> toggleHabitToday(String id) async {
    final idx = _items.indexWhere((h) => h.id == id);
    if (idx == -1) return;

    final habit = _items[idx];
    final todayKey = "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";

    final updatedDates = List<String>.from(habit.completedDateStrings);
    if (updatedDates.contains(todayKey)) {
      updatedDates.remove(todayKey);
    } else {
      updatedDates.add(todayKey);
    }

    _items[idx] = HabitItem(
      id: habit.id,
      title: habit.title,
      iconName: habit.iconName,
      targetPerWeek: habit.targetPerWeek,
      completedDateStrings: updatedDates,
      colorCategory: habit.colorCategory,
    );

    await _storage.saveHabits(_items);
    notifyListeners();
  }

  Future<void> addHabit({
    required String title,
    required String iconName,
    int targetPerWeek = 7,
    ColorCategory colorCategory = ColorCategory.sky,
  }) async {
    final newHabit = HabitItem(
      id: const Uuid().v4(),
      title: title,
      iconName: iconName,
      targetPerWeek: targetPerWeek,
      colorCategory: colorCategory,
    );
    _items.add(newHabit);
    await _storage.saveHabits(_items);
    notifyListeners();
  }

  Future<void> deleteHabit(String id) async {
    _items.removeWhere((h) => h.id == id);
    await _storage.saveHabits(_items);
    notifyListeners();
  }
}
