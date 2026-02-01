import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:finance_app/core/services/notification_service.dart';
import 'package:finance_app/features/budget/data/models/budget_models.dart';
import 'package:finance_app/features/profile/data/models/user_profile_model.dart';
import 'package:finance_app/features/tax_calculator/domain/models/tax_calculator_models.dart';
import 'package:finance_app/features/transactions/data/models/category_model.dart';
import 'package:finance_app/features/transactions/data/models/recurring_transaction_model.dart';
import 'package:finance_app/features/transactions/data/models/transaction_model.dart';
import 'package:finance_app/features/budget/data/models/budget_snapshot.dart';
import 'package:finance_app/features/notifications/data/models/notification_model.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:finance_app/features/settings/data/repositories/settings_repository.dart';

class BackupService {
  static const List<String> _boxNames = [
    'transactions',
    'categories',
    'settings_box',
    'budget_questionnaire',
    'active_budget_plan',
    'recurring_transactions',
    'user_profile',
    'tax_configs',
    'budget_snapshots',
    'notifications',
  ];

  static Box _getBox(String boxName) {
    if (!Hive.isBoxOpen(boxName)) {
      throw HiveError('Box "$boxName" is not open.');
    }

    switch (boxName) {
      case 'transactions':
        return Hive.box<TransactionModel>(boxName);
      case 'categories':
        return Hive.box<CategoryModel>(boxName);
      case 'budget_questionnaire':
        return Hive.box<BudgetQuestionnaire>(boxName);
      case 'active_budget_plan':
        return Hive.box<BudgetPlan>(boxName);
      case 'recurring_transactions':
        return Hive.box<RecurringTransactionModel>(boxName);
      case 'user_profile':
        return Hive.box<UserProfile>(boxName);
      case 'tax_configs':
        return Hive.box<TaxConfiguration>(boxName);
      case 'budget_snapshots':
        return Hive.box<BudgetMonthSnapshot>(boxName);
      case 'notifications':
        return Hive.box<NotificationModel>(boxName);
      default:
        return Hive.box(boxName);
    }
  }

  static Future<void> createBackup() async {
    try {
      final Map<String, dynamic> backupData = {};

      for (var boxName in _boxNames) {
        final box = _getBox(boxName);
        final boxData = <String, dynamic>{};

        for (var key in box.keys) {
          final value = box.get(key);

          if (value is TransactionModel) {
            boxData[key.toString()] = value.toMap();
          } else if (value is CategoryModel) {
            boxData[key.toString()] = value.toMap();
          } else if (value is BudgetQuestionnaire) {
            boxData[key.toString()] = value.toMap();
          } else if (value is BudgetPlan) {
            boxData[key.toString()] = value.toMap();
          } else if (value is RecurringTransactionModel) {
            boxData[key.toString()] = value.toMap();
          } else if (value is UserProfile) {
            boxData[key.toString()] = value.toMap();
          } else if (value is TaxConfiguration) {
            boxData[key.toString()] = value.toMap();
          } else if (value is BudgetMonthSnapshot) {
            boxData[key.toString()] = value.toMap();
          } else if (value is NotificationModel) {
            boxData[key.toString()] = value.toMap();
          } else if (value is Map ||
              value is List ||
              value is String ||
              value is num ||
              value is bool ||
              value == null) {
            boxData[key.toString()] = value;
          } else {
            // Fallback for settings_box which might have simple types
            boxData[key.toString()] = value.toString();
          }
        }
        backupData[boxName] = boxData;
      }

      final String jsonString = jsonEncode(_sanitizeForJson(backupData));

      final directory = await getTemporaryDirectory();
      final file = File(
          "${directory.path}/hisab_backup_${DateTime.now().millisecondsSinceEpoch}.json");
      await file.writeAsString(jsonString);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Hisava Data Backup - ${DateTime.now().toIso8601String()}',
      );
    } catch (e) {
      if (kDebugMode) {
        print("Backup Error: $e");
      }
      rethrow;
    }
  }

  /// Creates a backup and saves it to a persistent location on the device
  /// This file is overwritten on each successful backup to sync with new data.
  static Future<File> createPersistentBackup() async {
    try {
      final Map<String, dynamic> backupData = {};

      for (var boxName in _boxNames) {
        final box = _getBox(boxName);
        final boxData = <String, dynamic>{};

        for (var key in box.keys) {
          final value = box.get(key);

          if (value is TransactionModel) {
            boxData[key.toString()] = value.toMap();
          } else if (value is CategoryModel) {
            boxData[key.toString()] = value.toMap();
          } else if (value is BudgetQuestionnaire) {
            boxData[key.toString()] = value.toMap();
          } else if (value is BudgetPlan) {
            boxData[key.toString()] = value.toMap();
          } else if (value is RecurringTransactionModel) {
            boxData[key.toString()] = value.toMap();
          } else if (value is UserProfile) {
            boxData[key.toString()] = value.toMap();
          } else if (value is TaxConfiguration) {
            boxData[key.toString()] = value.toMap();
          } else if (value is BudgetMonthSnapshot) {
            boxData[key.toString()] = value.toMap();
          } else if (value is NotificationModel) {
            boxData[key.toString()] = value.toMap();
          } else if (value is Map ||
              value is List ||
              value is String ||
              value is num ||
              value is bool ||
              value == null) {
            boxData[key.toString()] = value;
          } else {
            boxData[key.toString()] = value.toString();
          }
        }
        backupData[boxName] = boxData;
      }

      final String jsonString = jsonEncode(_sanitizeForJson(backupData));

      // Strategy to find a user-visible directory (especially on Android)
      Directory? directory;

      if (Platform.isAndroid) {
        // 1. Try common system Download path directly
        final publicDownload = Directory('/storage/emulated/0/Download');
        if (await publicDownload.exists()) {
          directory = publicDownload;
        }
      }

      // 2. Fallback to path_provider's Download directory
      directory ??= await getDownloadsDirectory();

      // 3. Fallback to External Storage (user-visible in Android/data/...)
      directory ??= await getExternalStorageDirectory();

      // 4. Final fallback to private app docs
      directory ??= await getApplicationDocumentsDirectory();

      final file = File("${directory.path}/hisab_auto_backup.json");
      await file.writeAsString(jsonString);

      debugPrint('BackupService: Persistent backup saved to ${file.path}');
      return file;
    } catch (e) {
      if (kDebugMode) {
        print("Persistent Backup Error: $e");
      }
      rethrow;
    }
  }

  /// Shares the persistent backup file
  static Future<void> sharePersistentBackup() async {
    try {
      Directory? directory;
      if (Platform.isAndroid) {
        final publicDownload = Directory('/storage/emulated/0/Download');
        if (await publicDownload.exists()) directory = publicDownload;
      }
      directory ??= await getDownloadsDirectory();
      directory ??= await getExternalStorageDirectory();
      directory ??= await getApplicationDocumentsDirectory();

      final file = File("${directory.path}/hisab_auto_backup.json");

      if (await file.exists()) {
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Hisava Auto-Backup Export',
        );
      } else {
        throw Exception('Auto-backup file not found. Perform a sync first.');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Share Persistent Backup Error: $e");
      }
      rethrow;
    }
  }

  /// Checks if an auto-backup is due (every 24 hours) and performs it if so.
  static Future<void> checkAndPerformAutoBackup() async {
    // Skip on web as it requires user interaction for file saving
    if (kIsWeb) return;

    try {
      final settingsRepo = SettingsRepository();

      // 1. Check if feature is enabled
      final isEnabled = await settingsRepo.getAutoBackupEnabled();
      if (!isEnabled) return;

      // 2. Check if 24 hours have passed since last backup
      final lastBackup = await settingsRepo.getLastBackupTime();
      final now = DateTime.now();

      if (lastBackup == null || now.difference(lastBackup).inHours >= 24) {
        // Perform backup
        debugPrint('BackupService: Starting auto-backup...');
        await createPersistentBackup();

        // Update last backup time and reset failure status
        await settingsRepo.saveLastBackupTime(now);
        await settingsRepo.saveLastBackupFailed(false);

        // Show success notification
        await NotificationService().showNotification(
          id: 200,
          title: 'Backup Complete',
          body: 'Your data has been backed up successfully.',
          payload: 'backup_success',
        );
        debugPrint('BackupService: Auto-backup complete.');
      }
    } catch (e) {
      debugPrint('BackupService: Auto-backup failed: $e');
      final settingsRepo = SettingsRepository();
      await settingsRepo.saveLastBackupFailed(true);

      // Show failure notification
      await NotificationService().showNotification(
        id: 201,
        title: 'Backup Failed',
        body: 'Automatic backup failed. Please check your storage.',
        payload: 'backup_failed',
      );
    }
  }

  static Future<bool> restoreBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) return false;

      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final Map<String, dynamic> rawData = jsonDecode(content);
      final Map<String, dynamic> backupData = _desanitizeFromJson(rawData);

      for (var boxName in _boxNames) {
        if (!backupData.containsKey(boxName)) continue;

        final box = _getBox(boxName);
        await box.clear();

        final Map<String, dynamic> boxData = backupData[boxName];
        for (var entry in boxData.entries) {
          final key = _parseKey(entry.key);
          final value = entry.value;

          dynamic hiveValue;
          switch (boxName) {
            case 'transactions':
              hiveValue = TransactionModel.fromMap(value);
              break;
            case 'categories':
              hiveValue = CategoryModel.fromMap(value);
              break;
            case 'budget_questionnaire':
              hiveValue = BudgetQuestionnaire.fromMap(value);
              break;
            case 'active_budget_plan':
              hiveValue = BudgetPlan.fromMap(value);
              break;
            case 'recurring_transactions':
              hiveValue = RecurringTransactionModel.fromMap(value);
              break;
            case 'user_profile':
              hiveValue = UserProfile.fromMap(value);
              break;
            case 'tax_configs':
              hiveValue = TaxConfiguration.fromMap(value);
              break;
            case 'budget_snapshots':
              hiveValue = BudgetMonthSnapshot.fromMap(value);
              break;
            case 'notifications':
              hiveValue = NotificationModel.fromMap(value);
              break;
            default:
              hiveValue = value;
          }
          await box.put(key, hiveValue);
        }
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print("Restore Error: $e");
      }
      rethrow;
    }
  }

  static dynamic _parseKey(String key) {
    if (int.tryParse(key) != null) return int.parse(key);
    return key;
  }

  static Future<void> clearAllData() async {
    try {
      // 1. Clear all Hive boxes
      for (var boxName in _boxNames) {
        if (Hive.isBoxOpen(boxName)) {
          await _getBox(boxName).clear();
        }
      }

      // 2. Clear all scheduled notifications
      await NotificationService().cancelAll();
    } catch (e) {
      if (kDebugMode) {
        print("Clear Data Error: $e");
      }
      rethrow;
    }
  }

  /// Recursively sanitizes data to ensure it is JSON-encodable.
  /// Handles double.infinity, double.negativeInfinity, and double.nan.
  static dynamic _sanitizeForJson(dynamic value) {
    if (value is double) {
      if (value.isInfinite || value.isNaN) {
        return value
            .toString(); // Convert to string "Infinity", "-Infinity", or "NaN"
      }
      return value;
    } else if (value is Map) {
      return value
          .map((key, val) => MapEntry(key.toString(), _sanitizeForJson(val)));
    } else if (value is List) {
      return value.map((item) => _sanitizeForJson(item)).toList();
    }
    return value;
  }

  /// Recursively desanitizes data from JSON to restore double.infinity, etc.
  static dynamic _desanitizeFromJson(dynamic value) {
    if (value is String) {
      if (value == 'Infinity') return double.infinity;
      if (value == '-Infinity') return double.negativeInfinity;
      if (value == 'NaN') return double.nan;
      return value;
    } else if (value is Map) {
      return value.map((key, val) => MapEntry(key, _desanitizeFromJson(val)));
    } else if (value is List) {
      return value.map((item) => _desanitizeFromJson(item)).toList();
    }
    return value;
  }
}
