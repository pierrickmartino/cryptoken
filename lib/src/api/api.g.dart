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
    json['tokenMain'] as String,
    json['tokenReference'] as String,
    json['tokenFee'] as String,
    json['tokenPrice'] as String,
    (json['amountMain'] as num).toDouble(),
    (json['amountReference'] as num).toDouble(),
    (json['amountFee'] as num).toDouble(),
    (json['price'] as num).toDouble(),
    Transaction._timestampToDateTime(json['time'] as Timestamp),
    json['withImpactOnSecondPosition'] as bool,
  );
}

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'tokenMain': instance.tokenMain,
      'tokenReference': instance.tokenReference,
      'tokenFee': instance.tokenFee,
      'tokenPrice': instance.tokenPrice,
      'amountMain': instance.amountMain,
      'amountReference': instance.amountReference,
      'amountFee': instance.amountFee,
      'price': instance.price,
      'withImpactOnSecondPosition': instance.withImpactOnSecondPosition,
      'time': Transaction._dateTimeToTimestamp(instance.time),
    };

Position _$PositionFromJson(Map<String, dynamic> json) {
  return Position(
    json['token'] as String,
    (json['amount'] as num).toDouble(),
    Position._timestampToDateTime(json['time'] as Timestamp),
  );
}

Map<String, dynamic> _$PositionToJson(Position instance) => <String, dynamic>{
      'token': instance.token,
      'amount': instance.amount,
      'time': Position._dateTimeToTimestamp(instance.time),
    };
