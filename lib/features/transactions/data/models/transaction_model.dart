import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String note;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String type; // 'income' or 'expense'

  @HiveField(5)
  final String categoryId;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.note,
    required this.date,
    required this.type,
    required this.categoryId,
  });

  factory TransactionModel.create({
    required double amount,
    required String note,
    required DateTime date,
    required String type,
    required String categoryId,
  }) {
    return TransactionModel(
      id: const Uuid().v4(),
      amount: amount,
      note: note,
      date: date,
      type: type,
      categoryId: categoryId,
    );
  }

  TransactionModel copyWith({
    double? amount,
    String? note,
    DateTime? date,
    String? type,
    String? categoryId,
  }) {
    return TransactionModel(
      id: id,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      date: date ?? this.date,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'note': note,
      'date': date.toIso8601String(),
      'type': type,
      'categoryId': categoryId,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      amount: map['amount'],
      note: map['note'],
      date: DateTime.parse(map['date']),
      type: map['type'],
      categoryId: map['categoryId'],
    );
  }
}
