// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tax_calculator_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaxSlabAdapter extends TypeAdapter<TaxSlab> {
  @override
  final int typeId = 7;

  @override
  TaxSlab read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaxSlab(
      rate: fields[0] as double,
      lowerLimit: fields[1] as double,
      upperLimit: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, TaxSlab obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.rate)
      ..writeByte(1)
      ..write(obj.lowerLimit)
      ..writeByte(2)
      ..write(obj.upperLimit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaxSlabAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaxConfigurationAdapter extends TypeAdapter<TaxConfiguration> {
  @override
  final int typeId = 8;

  @override
  TaxConfiguration read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaxConfiguration(
      id: fields[0] as String,
      name: fields[1] as String,
      singleSlabs: (fields[2] as List).cast<TaxSlab>(),
      marriedSlabs: (fields[3] as List).cast<TaxSlab>(),
      isDefault: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TaxConfiguration obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.singleSlabs)
      ..writeByte(3)
      ..write(obj.marriedSlabs)
      ..writeByte(4)
      ..write(obj.isDefault);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaxConfigurationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
