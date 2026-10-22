import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/task_item.dart';
import '../../providers/habit_provider.dart';
import '../../providers/task_provider.dart';

class HabitsTasksTab extends StatefulWidget {
  const HabitsTasksTab({super.key});

  @override
  State<HabitsTasksTab> createState() => _HabitsTasksTabState();
}

class _HabitsTasksTabState extends State<HabitsTasksTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Pomodoro State
  int _pomodoroSeconds = 25 * 60;
  bool _isPomodoroRunning = false;
  Timer? _timer;
  int _activePomodoroMode = 0; // 0: Focus 25m, 1: Break 5m

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _togglePomodoroTimer() {
    if (_isPomodoroRunning) {
      _timer?.cancel();
      setState(() => _isPomodoroRunning = false);
    } else {
      setState(() => _isPomodoroRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_pomodoroSeconds > 0) {
          setState(() => _pomodoroSeconds--);
        } else {
          timer.cancel();
          setState(() => _isPomodoroRunning = false);
          _showPomodoroCompleteDialog();
        }
      });
    }
  }

  void _resetPomodoroTimer(int minutes, int mode) {
    _timer?.cancel();
    setState(() {
      _isPomodoroRunning = false;
      _activePomodoroMode = mode;
      _pomodoroSeconds = minutes * 60;
    });
  }

  void _showPomodoroCompleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Waktu Selesai! 🎉', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Sesi fokus telah selesai. Luangkan waktu sejenak untuk peregangan.', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK', style: TextStyle(color: AppColors.accentSky))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fokus & Produktivitas'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accentSky,
          indicatorWeight: 3,
          labelColor: AppColors.accentSky,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'Kebiasaan'),
            Tab(text: 'Daftar Tugas'),
            Tab(text: 'Pomodoro'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHabitsSection(),
          _buildTasksSection(),
          _buildPomodoroSection(),
        ],
      ),
    );
  }

  // --- HABITS SECTION ---
  Widget _buildHabitsSection() {
    final habit = context.watch<HabitProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHabitDialog(context),
        backgroundColor: AppColors.textPrimary,
        foregroundColor: AppColors.canvas,
        icon: const Icon(Icons.add, size: 20),
        label: const Text('Kebiasaan Baru', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: habit.completionRateToday,
                        backgroundColor: AppColors.canvas,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentSky),
                        strokeWidth: 6,
                      ),
                      Text('${(habit.completionRateToday * 100).toInt()}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Konsistensi Hari Ini', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        Text('${habit.completedTodayCount} dari ${habit.items.length} kebiasaan telah dicentang.', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: habit.items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final h = habit.items[index];
                final isDone = h.isCompletedToday();

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDone ? AppColors.accentSky.withValues(alpha: 0.4) : AppColors.border),
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => habit.toggleHabitToday(h.id),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDone ? AppColors.accentSky : AppColors.surfaceElevated,
                            shape: BoxShape.circle,
                            border: Border.all(color: isDone ? AppColors.accentSky : AppColors.border),
                          ),
                          child: Icon(
                            isDone ? Icons.check : Icons.circle_outlined,
                            size: 18,
                            color: isDone ? AppColors.canvas : AppColors.textMuted,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              h.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDone ? AppColors.textSecondary : AppColors.textPrimary,
                                decoration: isDone ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.local_fire_department, size: 13, color: AppColors.accentAmber),
                                const SizedBox(width: 2),
                                Text('${h.currentStreak} Hari Beruntun', style: const TextStyle(fontSize: 11, color: AppColors.accentAmber, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => habit.deleteHabit(h.id),
                        icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // --- TASKS SECTION ---
  Widget _buildTasksSection() {
    final task = context.watch<TaskProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskDialog(context),
        backgroundColor: AppColors.textPrimary,
        foregroundColor: AppColors.canvas,
        icon: const Icon(Icons.add, size: 20),
        label: const Text('Tugas Baru', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: task.items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final t = task.items[index];
                Color priorityColor = AppColors.textMuted;
                if (t.priority == TaskPriority.high) priorityColor = AppColors.accentRose;
                if (t.priority == TaskPriority.medium) priorityColor = AppColors.accentAmber;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: t.isCompleted,
                        activeColor: AppColors.accentSky,
                        checkColor: AppColors.canvas,
                        onChanged: (_) => task.toggleTask(t.id),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: t.isCompleted ? AppColors.textMuted : AppColors.textPrimary,
                                decoration: t.isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: priorityColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    t.priority.name.toUpperCase(),
                                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: priorityColor),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(t.category, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => task.deleteTask(t.id),
                        icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // --- POMODORO SECTION ---
  Widget _buildPomodoroSection() {
    final minutes = (_pomodoroSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_pomodoroSeconds % 60).toString().padLeft(2, '0');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mode Selectors
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _resetPomodoroTimer(25, 0),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _activePomodoroMode == 0 ? AppColors.accentSky : AppColors.surface,
                    foregroundColor: _activePomodoroMode == 0 ? AppColors.canvas : AppColors.textPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Fokus (25 Menit)'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _resetPomodoroTimer(5, 1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _activePomodoroMode == 1 ? AppColors.accentEmerald : AppColors.surface,
                    foregroundColor: _activePomodoroMode == 1 ? AppColors.canvas : AppColors.textPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Istirahat (5 Menit)'),
                ),
              ],
            ),

            const SizedBox(height: 48),

            // Big Circular Timer
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(color: _isPomodoroRunning ? AppColors.accentSky : AppColors.border, width: 4),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$minutes:$seconds',
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: -1),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isPomodoroRunning ? 'Sedang Berjalan...' : 'Tekan Mulai untuk Fokus',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // Control Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filled(
                  onPressed: _togglePomodoroTimer,
                  iconSize: 32,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.textPrimary,
                    foregroundColor: AppColors.canvas,
                    padding: const EdgeInsets.all(16),
                  ),
                  icon: Icon(_isPomodoroRunning ? Icons.pause : Icons.play_arrow),
                ),
                const SizedBox(width: 16),
                IconButton.outlined(
                  onPressed: () => _resetPomodoroTimer(_activePomodoroMode == 0 ? 25 : 5, _activePomodoroMode),
                  iconSize: 24,
                  style: IconButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    foregroundColor: AppColors.textSecondary,
                    padding: const EdgeInsets.all(12),
                  ),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Tambah Kebiasaan Baru', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
        content: TextField(
          controller: titleCtrl,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Contoh: Belajar Coding 30 Menit',
            hintStyle: const TextStyle(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.canvas,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal', style: TextStyle(color: AppColors.textMuted))),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.trim().isNotEmpty) {
                context.read<HabitProvider>().addHabit(title: titleCtrl.text.trim(), iconName: 'check');
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.textPrimary, foregroundColor: AppColors.canvas),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    TaskPriority priority = TaskPriority.medium;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Tambah Tugas Baru', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Deskripsi Tugas...',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.canvas,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TaskPriority>(
                initialValue: priority,
                dropdownColor: AppColors.surfaceElevated,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Prioritas',
                  labelStyle: const TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.canvas,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: TaskPriority.values
                    .map((p) => DropdownMenuItem(value: p, child: Text(p.name.toUpperCase())))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => priority = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal', style: TextStyle(color: AppColors.textMuted))),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.trim().isNotEmpty) {
                  context.read<TaskProvider>().addTask(title: titleCtrl.text.trim(), priority: priority);
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.textPrimary, foregroundColor: AppColors.canvas),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
