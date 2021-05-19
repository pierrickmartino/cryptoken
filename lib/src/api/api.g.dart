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

Transaction _$TransactionFromJson(Map<String, dynamic> json) {
  return Transaction(
    json['tokenCredit'] as String,
    json['tokenDebit'] as String,
    json['tokenFee'] as String,
    json['tokenPrice'] as String,
    (json['amountCredit'] as num).toDouble(),
    (json['amountDebit'] as num).toDouble(),
    (json['amountFee'] as num).toDouble(),
    (json['price'] as num).toDouble(),
    Transaction._timestampToDateTime(json['time'] as Timestamp),
  )..id = json['id'] as String;
}

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'tokenCredit': instance.tokenCredit,
      'tokenDebit': instance.tokenDebit,
      'tokenFee': instance.tokenFee,
      'tokenPrice': instance.tokenPrice,
      'amountCredit': instance.amountCredit,
      'amountDebit': instance.amountDebit,
      'amountFee': instance.amountFee,
      'price': instance.price,
      'time': Transaction._dateTimeToTimestamp(instance.time),
      'id': instance.id,
    };

Position _$PositionFromJson(Map<String, dynamic> json) {
  return Position(
    json['token'] as String,
    (json['amount'] as num).toDouble(),
    Position._timestampToDateTime(json['time'] as Timestamp),
  )..id = json['id'] as String;
}

Map<String, dynamic> _$PositionToJson(Position instance) => <String, dynamic>{
      'token': instance.token,
      'amount': instance.amount,
      'time': Position._dateTimeToTimestamp(instance.time),
      'id': instance.id,
    };
