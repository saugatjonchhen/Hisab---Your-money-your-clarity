import 'package:finance_app/core/theme/app_theme.dart';
import 'package:finance_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:finance_app/features/splash/presentation/pages/splash_page.dart';
import 'package:finance_app/features/transactions/data/models/category_model.dart';
import 'package:finance_app/features/transactions/data/models/transaction_model.dart';
import 'package:finance_app/features/budget/data/models/budget_models.dart';
import 'package:finance_app/features/transactions/data/models/recurring_transaction_model.dart';
import 'package:finance_app/features/profile/data/models/user_profile_model.dart';
import 'package:finance_app/features/tax_calculator/domain/models/tax_calculator_models.dart';
import 'package:finance_app/features/budget/data/models/budget_snapshot.dart';
import 'package:finance_app/features/notifications/data/models/notification_model.dart';
import 'package:finance_app/core/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  
  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await NotificationService().init();
  await Hive.initFlutter();
  
  // Register all adapters
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(BudgetQuestionnaireAdapter());
  Hive.registerAdapter(BudgetPlanAdapter());
  Hive.registerAdapter(RecurringTransactionModelAdapter());
  Hive.registerAdapter(UserProfileAdapter());
  Hive.registerAdapter(TaxSlabAdapter());
  Hive.registerAdapter(TaxConfigurationAdapter());
  Hive.registerAdapter(BudgetMonthSnapshotAdapter());
  Hive.registerAdapter(NotificationTypeAdapter());
  Hive.registerAdapter(NotificationModelAdapter());
  
  // Open all boxes upfront for consistent persistence (especially on web)
  await Future.wait([
    Hive.openBox<TransactionModel>('transactions'),
    Hive.openBox<CategoryModel>('categories'),
    Hive.openBox('settings_box'),
    Hive.openBox<BudgetQuestionnaire>('budget_questionnaire'),
    Hive.openBox<BudgetPlan>('active_budget_plan'),
    Hive.openBox<RecurringTransactionModel>('recurring_transactions'),
    Hive.openBox<UserProfile>('user_profile'),
    Hive.openBox<TaxConfiguration>('tax_configs'),
    Hive.openBox<BudgetMonthSnapshot>('budget_snapshots'),
    Hive.openBox<NotificationModel>('notifications'),
  ]);
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final themeMode = settingsAsync.when(
      data: (settings) => settings.themeMode,
      loading: () => ThemeMode.system,
      error: (_, __) => ThemeMode.system,
    );

    return MaterialApp(
      title: 'Hisab',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      home: const SplashPage(),
    );
  }
}
