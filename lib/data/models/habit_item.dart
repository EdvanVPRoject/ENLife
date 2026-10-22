class HabitItem {
  final String id;
  final String title;
  final String iconName;
  final int targetPerWeek;
  final List<String> completedDateStrings; // Format 'YYYY-MM-DD'
  final ColorCategory colorCategory;

  HabitItem({
    required this.id,
    required this.title,
    this.iconName = 'check',
    this.targetPerWeek = 7,
    List<String>? completedDateStrings,
    this.colorCategory = ColorCategory.sky,
  }) : completedDateStrings = completedDateStrings ?? [];

  bool isCompletedToday() {
    final today = _dateKey(DateTime.now());
    return completedDateStrings.contains(today);
  }

  int get currentStreak {
    if (completedDateStrings.isEmpty) return 0;
    int streak = 0;
    DateTime checkDate = DateTime.now();

    // If today is completed, start from today, else start from yesterday
    final todayKey = _dateKey(checkDate);
    if (!completedDateStrings.contains(todayKey)) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (completedDateStrings.contains(_dateKey(checkDate))) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  static String _dateKey(DateTime d) {
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'iconName': iconName,
    'targetPerWeek': targetPerWeek,
    'completedDateStrings': completedDateStrings,
    'colorCategory': colorCategory.name,
  };

  factory HabitItem.fromJson(Map<String, dynamic> json) => HabitItem(
    id: json['id'],
    title: json['title'],
    iconName: json['iconName'] ?? 'check',
    targetPerWeek: json['targetPerWeek'] ?? 7,
    completedDateStrings: List<String>.from(json['completedDateStrings'] ?? []),
    colorCategory: ColorCategory.values.byName(json['colorCategory'] ?? 'sky'),
  );
}

enum ColorCategory { sky, emerald, amber, rose, purple }
