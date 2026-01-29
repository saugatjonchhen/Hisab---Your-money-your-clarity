// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BudgetQuestionnaireAdapter extends TypeAdapter<BudgetQuestionnaire> {
  @override
  final int typeId = 2;

  @override
  BudgetQuestionnaire read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BudgetQuestionnaire(
      primaryIncome: fields[0] as double,
      secondaryIncome: fields[1] as double,
      incomeFrequency: fields[2] as String,
      fixedExpenses: (fields[3] as Map).cast<String, double>(),
      variableExpenses: (fields[4] as Map).cast<String, double>(),
      savesMoney: fields[5] as bool,
      desiredSavings: fields[6] as double,
      emergencyFundGoalMonths: fields[7] as int,
      investsMoney: fields[8] as bool,
      preferredInvestments: (fields[9] as List).cast<String>(),
      riskPreference: fields[10] as String,
      priorityOrder: (fields[11] as List).cast<String>(),
      lifestyleFlexibility: fields[12] as String,
    );
  }

  @override
  void write(BinaryWriter writer, BudgetQuestionnaire obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.primaryIncome)
      ..writeByte(1)
      ..write(obj.secondaryIncome)
      ..writeByte(2)
      ..write(obj.incomeFrequency)
      ..writeByte(3)
      ..write(obj.fixedExpenses)
      ..writeByte(4)
      ..write(obj.variableExpenses)
      ..writeByte(5)
      ..write(obj.savesMoney)
      ..writeByte(6)
      ..write(obj.desiredSavings)
      ..writeByte(7)
      ..write(obj.emergencyFundGoalMonths)
      ..writeByte(8)
      ..write(obj.investsMoney)
      ..writeByte(9)
      ..write(obj.preferredInvestments)
      ..writeByte(10)
      ..write(obj.riskPreference)
      ..writeByte(11)
      ..write(obj.priorityOrder)
      ..writeByte(12)
      ..write(obj.lifestyleFlexibility);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetQuestionnaireAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BudgetPlanAdapter extends TypeAdapter<BudgetPlan> {
  @override
  final int typeId = 3;

  @override
  BudgetPlan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BudgetPlan(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      bestFor: fields[3] as String,
      allocations: (fields[4] as Map).cast<String, double>(),
      pros: (fields[5] as List).cast<String>(),
      tradeOffs: (fields[6] as List).cast<String>(),
      score: fields[7] as double,
    );
  }

  @override
  void write(BinaryWriter writer, BudgetPlan obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.bestFor)
      ..writeByte(4)
      ..write(obj.allocations)
      ..writeByte(5)
      ..write(obj.pros)
      ..writeByte(6)
      ..write(obj.tradeOffs)
      ..writeByte(7)
      ..write(obj.score);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetPlanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
