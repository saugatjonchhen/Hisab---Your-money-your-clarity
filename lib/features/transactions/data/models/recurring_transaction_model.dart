import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'recurring_transaction_model.g.dart';

@HiveType(typeId: 4)
class RecurringTransactionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String note;

  @HiveField(3)
  final String type; // 'income' or 'expense'

  @HiveField(4)
  final String categoryId;

  @HiveField(5)
  final String frequency; // 'daily', 'weekly', 'monthly', 'yearly'

  @HiveField(6)
  final DateTime startDate;

  @HiveField(7)
  final DateTime? lastGeneratedDate;

  @HiveField(8)
  final bool isActive;

  RecurringTransactionModel({
    required this.id,
    required this.amount,
    required this.note,
    required this.type,
    required this.categoryId,
    required this.frequency,
    required this.startDate,
    this.lastGeneratedDate,
    this.isActive = true,
  });

  factory RecurringTransactionModel.create({
    required double amount,
    required String note,
    required String type,
    required String categoryId,
    required String frequency,
    required DateTime startDate,
  }) {
    return RecurringTransactionModel(
      id: const Uuid().v4(),
      amount: amount,
      note: note,
      type: type,
      categoryId: categoryId,
      frequency: frequency,
      startDate: startDate,
      isActive: true,
    );
  }

  RecurringTransactionModel copyWith({
    double? amount,
    String? note,
    String? type,
    String? categoryId,
    String? frequency,
    DateTime? startDate,
    DateTime? lastGeneratedDate,
    bool? isActive,
  }) {
    return RecurringTransactionModel(
      id: id,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      lastGeneratedDate: lastGeneratedDate ?? this.lastGeneratedDate,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'note': note,
      'type': type,
      'categoryId': categoryId,
      'frequency': frequency,
      'startDate': startDate.toIso8601String(),
      'lastGeneratedDate': lastGeneratedDate?.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory RecurringTransactionModel.fromMap(Map<String, dynamic> map) {
    return RecurringTransactionModel(
      id: map['id'],
      amount: map['amount'],
      note: map['note'],
      type: map['type'],
      categoryId: map['categoryId'],
      frequency: map['frequency'],
      startDate: DateTime.parse(map['startDate']),
      lastGeneratedDate: map['lastGeneratedDate'] != null ? DateTime.parse(map['lastGeneratedDate']) : null,
      isActive: map['isActive'] ?? true,
    );
  }
}
