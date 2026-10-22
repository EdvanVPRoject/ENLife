import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/services/storage_service.dart';
import 'providers/finance_provider.dart';
import 'providers/habit_provider.dart';
import 'providers/task_provider.dart';
import 'providers/vault_provider.dart';
import 'ui/screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize offline-first persistent storage
  final storageService = StorageService();
  await storageService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FinanceProvider(storageService)..load()),
        ChangeNotifierProvider(create: (_) => HabitProvider(storageService)..load()),
        ChangeNotifierProvider(create: (_) => TaskProvider(storageService)..load()),
        ChangeNotifierProvider(create: (_) => VaultProvider(storageService)..load()),
      ],
      child: const ENLifeApp(),
    ),
  );
}

class ENLifeApp extends StatelessWidget {
  const ENLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ENLife - All-in-One Life Hub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigationScreen(),
    );
  }
}
