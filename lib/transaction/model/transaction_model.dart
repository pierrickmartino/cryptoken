import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

class TransactionModel {
  TransactionModel({
    required this.walletId,
    required this.transactionType,
    required this.tokenMain,
    required this.tokenReference,
    required this.tokenFee,
    required this.tokenPrice,
    required this.amountMain,
    required this.amountReference,
    required this.amountFee,
    required this.price,
    required this.time,
    required this.withImpactOnSecondPosition,
  });

  factory TransactionModel.fromMap(Map<dynamic, dynamic> data) {
    return TransactionModel(
      walletId: data['walletId'] ?? '',
      transactionType: data['transactionType'] ?? 0,
      tokenMain: data['tokenMain'] ?? '',
      tokenReference: data['tokenReference'] ?? '',
      tokenFee: data['tokenFee'] ?? '',
      tokenPrice: data['tokenPrice'] ?? '',
      amountMain: data['amountMain'] ?? 0,
      amountReference: data['amountReference'] ?? 0,
      amountFee: data['amountFee'] ?? 0,
      price: data['price'] ?? 0,
      time: data['time'] ?? DateTime.now(),
      withImpactOnSecondPosition: data['withImpactOnSecondPosition'] ?? true,
    );
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      walletId: json['walletId'] as String,
      transactionType: json['transactionType'] as int,
      tokenMain: json['tokenMain'] as String,
      tokenReference: json['tokenReference'] as String,
      tokenFee: json['tokenFee'] as String,
      tokenPrice: json['tokenPrice'] as String,
      amountMain: (json['amountMain'] as num).toDouble(),
      amountReference: (json['amountReference'] as num).toDouble(),
      amountFee: (json['amountFee'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      time: _timestampToDateTime(json['time'] as Timestamp),
      withImpactOnSecondPosition: json['withImpactOnSecondPosition'] as bool,
    );
  }

  int transactionType;
  String walletId, tokenMain, tokenReference, tokenFee, tokenPrice;
  double amountMain, amountReference, amountFee, price;
  bool withImpactOnSecondPosition;

  @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
  DateTime time;

  @JsonKey(ignore: true)
  late String id;

  static DateTime _timestampToDateTime(Timestamp timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(
        timestamp.millisecondsSinceEpoch);
  }

  static Timestamp _dateTimeToTimestamp(DateTime dateTime) {
    return Timestamp.fromMillisecondsSinceEpoch(
        dateTime.millisecondsSinceEpoch);
  }

  Map<String, dynamic> toJson() => {
        'walletId': walletId,
        'transactionType': transactionType,
        'tokenMain': tokenMain,
        'tokenReference': tokenReference,
        'tokenFee': tokenFee,
        'tokenPrice': tokenPrice,
        'amountMain': amountMain,
        'amountReference': amountReference,
        'amountFee': amountFee,
        'price': price,
        'time': _dateTimeToTimestamp(time),
        'withImpactOnSecondPosition': withImpactOnSecondPosition,
      };
}
