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
          } else if (value is Map || value is List || value is String || value is num || value is bool || value == null) {
            boxData[key.toString()] = value;
          } else {
            // Fallback for settings_box which might have simple types
            boxData[key.toString()] = value.toString();
          }
        }
        backupData[boxName] = boxData;
      }

      final String jsonString = jsonEncode(backupData);

      final directory = await getTemporaryDirectory();
      final file = File("${directory.path}/hisab_backup_${DateTime.now().millisecondsSinceEpoch}.json");
      await file.writeAsString(jsonString);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Hisab Data Backup - ${DateTime.now().toIso8601String()}',
      );
    } catch (e) {
      if (kDebugMode) {
        print("Backup Error: $e");
      }
      rethrow;
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
      final Map<String, dynamic> backupData = jsonDecode(content);

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
}
