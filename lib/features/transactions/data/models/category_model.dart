import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 1)
class CategoryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String iconParams; // Storing icon data as string/map if needed, simpler for now

  @HiveField(3)
  final int colorValue;

  @HiveField(4)
  final String type; // 'income' or 'expense'

  @HiveField(5)
  final double budgetLimit;

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconParams,
    required this.colorValue,
    required this.type,
    this.budgetLimit = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconParams': iconParams,
      'colorValue': colorValue,
      'type': type,
      'budgetLimit': budgetLimit,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      iconParams: map['iconParams'],
      colorValue: map['colorValue'],
      type: map['type'],
      budgetLimit: map['budgetLimit']?.toDouble() ?? 0.0,
    );
  }
}
