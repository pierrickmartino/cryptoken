// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crypto_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CryptoHiveAdapter extends TypeAdapter<CryptoHive> {
  @override
  final int typeId = 0;

  @override
  CryptoHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CryptoHive()
      ..symbol = fields[0] as String
      ..id = fields[1] as String
      ..name = fields[2] as String
      ..category = fields[3] as String
      ..slug = fields[4] as String
      ..logo = fields[5] as String;
  }

  @override
  void write(BinaryWriter writer, CryptoHive obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.symbol)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.slug)
      ..writeByte(5)
      ..write(obj.logo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CryptoHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
