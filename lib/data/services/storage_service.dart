import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_item.dart';
import '../models/habit_item.dart';
import '../models/task_item.dart';
import '../models/vault_item.dart';

class StorageService {
  static const String _keyTransactions = 'enlife_transactions';
  static const String _keyHabits = 'enlife_habits';
  static const String _keyTasks = 'enlife_tasks';
  static const String _keyVault = 'enlife_vault';
  static const String _keyFirstLaunch = 'enlife_first_launch_v1';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    if (!_prefs.containsKey(_keyFirstLaunch)) {
      await _seedInitialData();
      await _prefs.setBool(_keyFirstLaunch, true);
    }
  }

  // --- Transactions ---
  Future<List<TransactionItem>> getTransactions() async {
    final raw = _prefs.getString(_keyTransactions);
    if (raw == null) return [];
    final List decoded = jsonDecode(raw);
    return decoded.map((e) => TransactionItem.fromJson(e)).toList();
  }

  Future<void> saveTransactions(List<TransactionItem> items) async {
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await _prefs.setString(_keyTransactions, encoded);
  }

  // --- Habits ---
  Future<List<HabitItem>> getHabits() async {
    final raw = _prefs.getString(_keyHabits);
    if (raw == null) return [];
    final List decoded = jsonDecode(raw);
    return decoded.map((e) => HabitItem.fromJson(e)).toList();
  }

  Future<void> saveHabits(List<HabitItem> items) async {
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await _prefs.setString(_keyHabits, encoded);
  }

  // --- Tasks ---
  Future<List<TaskItem>> getTasks() async {
    final raw = _prefs.getString(_keyTasks);
    if (raw == null) return [];
    final List decoded = jsonDecode(raw);
    return decoded.map((e) => TaskItem.fromJson(e)).toList();
  }

  Future<void> saveTasks(List<TaskItem> items) async {
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await _prefs.setString(_keyTasks, encoded);
  }

  // --- Vault ---
  Future<List<VaultItem>> getVaultItems() async {
    final raw = _prefs.getString(_keyVault);
    if (raw == null) return [];
    final List decoded = jsonDecode(raw);
    return decoded.map((e) => VaultItem.fromJson(e)).toList();
  }

  Future<void> saveVaultItems(List<VaultItem> items) async {
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await _prefs.setString(_keyVault, encoded);
  }

  // --- Seeder ---
  Future<void> _seedInitialData() async {
    final now = DateTime.now();

    // Seed Transactions
    final initialTx = [
      TransactionItem(
        id: '1',
        title: 'Gaji Bulanan',
        amount: 8500000,
        type: TransactionType.income,
        category: 'Gaji',
        date: now.subtract(const Duration(days: 3)),
      ),
      TransactionItem(
        id: '2',
        title: 'Belanja Mingguan Supermarket',
        amount: 320000,
        type: TransactionType.expense,
        category: 'Makan & Belanja',
        date: now.subtract(const Duration(days: 1)),
        note: 'Struk terverifikasi',
      ),
      TransactionItem(
        id: '3',
        title: 'Kopi & Snack Kerja',
        amount: 45000,
        type: TransactionType.expense,
        category: 'Makan & Belanja',
        date: now,
      ),
      TransactionItem(
        id: '4',
        title: 'Bensin Motor / Transport',
        amount: 50000,
        type: TransactionType.expense,
        category: 'Transportasi',
        date: now,
      ),
    ];
    await saveTransactions(initialTx);

    // Seed Habits
    final yesterday = now.subtract(const Duration(days: 1));
    final twoDaysAgo = now.subtract(const Duration(days: 2));
    String dKey(DateTime d) => "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

    final initialHabits = [
      HabitItem(
        id: 'h1',
        title: 'Minum 2 Liter Air',
        iconName: 'water_drop',
        targetPerWeek: 7,
        completedDateStrings: [dKey(twoDaysAgo), dKey(yesterday), dKey(now)],
        colorCategory: ColorCategory.sky,
      ),
      HabitItem(
        id: 'h2',
        title: 'Membaca Buku 15 Menit',
        iconName: 'book',
        targetPerWeek: 5,
        completedDateStrings: [dKey(yesterday), dKey(now)],
        colorCategory: ColorCategory.emerald,
      ),
      HabitItem(
        id: 'h3',
        title: 'Olahraga / Jalan 30 Menit',
        iconName: 'fitness_center',
        targetPerWeek: 4,
        completedDateStrings: [dKey(yesterday)],
        colorCategory: ColorCategory.amber,
      ),
    ];
    await saveHabits(initialHabits);

    // Seed Tasks
    final initialTasks = [
      TaskItem(
        id: 't1',
        title: 'Selesaikan laporan evaluasi mingguan',
        priority: TaskPriority.high,
        category: 'Kerja',
        dueDate: now.add(const Duration(days: 1)),
      ),
      TaskItem(
        id: 't2',
        title: 'Bayar tagihan listrik & WiFi rumah',
        priority: TaskPriority.high,
        category: 'Pribadi',
        dueDate: now.add(const Duration(days: 2)),
      ),
      TaskItem(
        id: 't3',
        title: 'Beli vitamin & kebutuhan bulanan',
        isCompleted: true,
        priority: TaskPriority.medium,
        category: 'Belanja',
        dueDate: now,
      ),
    ];
    await saveTasks(initialTasks);

    // Seed Vault
    final initialVault = [
      VaultItem(
        id: 'v1',
        title: 'KTP Elektronik',
        numberOrCode: '3273012345670001',
        holderName: 'Edvan',
        category: VaultCategory.ktp,
        notes: 'Berlaku Seumur Hidup',
      ),
      VaultItem(
        id: 'v2',
        title: 'SIM C Motor',
        numberOrCode: '9812-2345-678901',
        holderName: 'Edvan',
        category: VaultCategory.sim,
        expiryDate: now.add(const Duration(days: 24)), // Expiring soon indicator!
        notes: 'Perpanjang di SIM Keliling',
      ),
      VaultItem(
        id: 'v3',
        title: 'Rekening Bank Utama',
        numberOrCode: '123-00-9876543-2',
        holderName: 'Edvan',
        category: VaultCategory.bank,
        notes: 'KCP Pusat',
      ),
    ];
    await saveVaultItems(initialVault);
  }
}
