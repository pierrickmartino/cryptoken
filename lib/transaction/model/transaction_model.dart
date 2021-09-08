import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

class TransactionModel {
  TransactionModel({
    required this.walletId,
    required this.transactionType,
    required this.tokenMain,
    required this.tokenMainName,
    required this.tokenReference,
    required this.tokenReferenceName,
    required this.tokenFee,
    required this.tokenFeeName,
    required this.tokenPrice,
    required this.tokenPriceName,
    required this.amountMain,
    required this.amountReference,
    required this.amountFee,
    required this.price,
    required this.time,
    required this.withImpactOnSecondPosition,
    required this.transactionRefId,
  });

  factory TransactionModel.fromMap(Map<dynamic, dynamic> data) {
    return TransactionModel(
      walletId: data['walletId'] ?? '',
      transactionType: data['transactionType'] ?? 0,
      tokenMain: data['tokenMain'] ?? '',
      tokenMainName: data['tokenMainName'] ?? '',
      tokenReference: data['tokenReference'] ?? '',
      tokenReferenceName: data['tokenReferenceName'] ?? '',
      tokenFee: data['tokenFee'] ?? '',
      tokenFeeName: data['tokenFeeName'] ?? '',
      tokenPrice: data['tokenPrice'] ?? '',
      tokenPriceName: data['tokenPriceName'] ?? '',
      amountMain: data['amountMain'] ?? 0,
      amountReference: data['amountReference'] ?? 0,
      amountFee: data['amountFee'] ?? 0,
      price: data['price'] ?? 0,
      time: data['time'] ?? DateTime.now(),
      withImpactOnSecondPosition: data['withImpactOnSecondPosition'] ?? true,
      transactionRefId: data['transactionRefId'] ?? '',
    );
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      walletId: json['walletId'] as String,
      transactionType: json['transactionType'] as int,
      tokenMain: json['tokenMain'] as String,
      tokenMainName: json['tokenMainName'] as String,
      tokenReference: json['tokenReference'] as String,
      tokenReferenceName: json['tokenReferenceName'] as String,
      tokenFee: json['tokenFee'] as String,
      tokenFeeName: json['tokenFeeName'] as String,
      tokenPrice: json['tokenPrice'] as String,
      tokenPriceName: json['tokenPriceName'] as String,
      amountMain: (json['amountMain'] as num).toDouble(),
      amountReference: (json['amountReference'] as num).toDouble(),
      amountFee: (json['amountFee'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      time: _timestampToDateTime(json['time'] as Timestamp),
      withImpactOnSecondPosition: json['withImpactOnSecondPosition'] as bool,
      transactionRefId: json['transactionRefId'] as String,
    );
  }

  int transactionType;
  String walletId,
      tokenMain,
      tokenMainName,
      tokenReference,
      tokenReferenceName,
      tokenFee,
      tokenFeeName,
      tokenPrice,
      tokenPriceName,
      transactionRefId;
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
        'tokenMainName': tokenMainName,
        'tokenReference': tokenReference,
        'tokenReferenceName': tokenReferenceName,
        'tokenFee': tokenFee,
        'tokenFeeName': tokenFeeName,
        'tokenPrice': tokenPrice,
        'tokenPriceName': tokenPriceName,
        'amountMain': amountMain,
        'amountReference': amountReference,
        'amountFee': amountFee,
        'price': price,
        'time': _dateTimeToTimestamp(time),
        'withImpactOnSecondPosition': withImpactOnSecondPosition,
        'transactionRefId': transactionRefId,
      };
}
