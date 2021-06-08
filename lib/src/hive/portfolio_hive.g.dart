// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portfolio_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PortfolioHiveAdapter extends TypeAdapter<PortfolioHive> {
  @override
  final int typeId = 1;

  @override
  PortfolioHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PortfolioHive()
      ..id = fields[0] as String
      ..name = fields[1] as String
      ..valuation = fields[2] as double
      ..variation24 = fields[3] as double
      ..realizedGain = fields[4] as double
      ..unrealizedGain = fields[5] as double;
  }

  @override
  void write(BinaryWriter writer, PortfolioHive obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.valuation)
      ..writeByte(3)
      ..write(obj.variation24)
      ..writeByte(4)
      ..write(obj.realizedGain)
      ..writeByte(5)
      ..write(obj.unrealizedGain);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PortfolioHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
