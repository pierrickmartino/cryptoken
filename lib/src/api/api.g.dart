// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Portfolio _$PortfolioFromJson(Map<String, dynamic> json) {
  return Portfolio(
    json['name'] as String,
  );
}

Map<String, dynamic> _$PortfolioToJson(Portfolio instance) => <String, dynamic>{
      'name': instance.name,
    };

Category _$CategoryFromJson(Map<String, dynamic> json) {
  return Category(
    json['name'] as String,
  );
}

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      'name': instance.name,
    };

Entry _$EntryFromJson(Map<String, dynamic> json) {
  return Entry(
    json['value'] as int,
    Entry._timestampToDateTime(json['time'] as Timestamp),
  );
}

Map<String, dynamic> _$EntryToJson(Entry instance) => <String, dynamic>{
      'value': instance.value,
      'time': Entry._dateTimeToTimestamp(instance.time),
    };

Transaction _$TransactionFromJson(Map<String, dynamic> json) {
  return Transaction(
    json['value'] as int,
    Transaction._timestampToDateTime(json['time'] as Timestamp),
  );
}

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'value': instance.value,
      'time': Transaction._dateTimeToTimestamp(instance.time),
    };

Position _$PositionFromJson(Map<String, dynamic> json) {
  return Position(
    json['value'] as int,
    Position._timestampToDateTime(json['time'] as Timestamp),
  );
}

Map<String, dynamic> _$PositionToJson(Position instance) => <String, dynamic>{
      'value': instance.value,
      'time': Position._dateTimeToTimestamp(instance.time),
    };
