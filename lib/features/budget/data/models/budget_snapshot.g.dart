// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_snapshot.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BudgetMonthSnapshotAdapter extends TypeAdapter<BudgetMonthSnapshot> {
  @override
  final int typeId = 10;

  @override
  BudgetMonthSnapshot read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BudgetMonthSnapshot(
      id: fields[0] as String,
      month: fields[1] as DateTime,
      activePlanId: fields[2] as String?,
      activePlanName: fields[3] as String?,
      plannedAllocations: (fields[4] as Map).cast<String, double>(),
      actualSpending: (fields[5] as Map).cast<String, double>(),
      totalIncome: fields[6] as double,
      totalExpenses: fields[7] as double,
      totalSavings: fields[8] as double,
      totalInvestments: fields[9] as double,
      periodStart: fields[10] as DateTime,
      periodEnd: fields[11] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, BudgetMonthSnapshot obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.month)
      ..writeByte(2)
      ..write(obj.activePlanId)
      ..writeByte(3)
      ..write(obj.activePlanName)
      ..writeByte(4)
      ..write(obj.plannedAllocations)
      ..writeByte(5)
      ..write(obj.actualSpending)
      ..writeByte(6)
      ..write(obj.totalIncome)
      ..writeByte(7)
      ..write(obj.totalExpenses)
      ..writeByte(8)
      ..write(obj.totalSavings)
      ..writeByte(9)
      ..write(obj.totalInvestments)
      ..writeByte(10)
      ..write(obj.periodStart)
      ..writeByte(11)
      ..write(obj.periodEnd);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetMonthSnapshotAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
