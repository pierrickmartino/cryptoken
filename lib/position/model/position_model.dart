import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

class PositionModel {
  PositionModel({
    required this.walletId,
    required this.token,
    required this.amount,
    required this.averageCost,
    required this.purchaseAmount,
    required this.sellAmount,
    required this.realizedPnL,
    required this.cost,
    required this.time,
    required this.color,
  });

  factory PositionModel.fromMap(Map<dynamic, dynamic> data) {
    return PositionModel(
      walletId: data['walletId'] ?? '',
      token: data['token'] ?? '',
      amount: data['amount'] ?? 0,
      averageCost: data['averageCost'] ?? 0,
      purchaseAmount: data['purchaseAmount'] ?? 0,
      sellAmount: data['sellAmount'] ?? 0,
      realizedPnL: data['realizedPnL'] ?? 0,
      cost: data['cost'] ?? 0,
      time: data['time'] ?? DateTime.now(),
      color: data['color'] ?? 0xFF2697FF,
    );
  }

  factory PositionModel.fromJson(Map<String, dynamic> json) {
    return PositionModel(
      walletId: json['walletId'] as String,
      token: json['token'] as String,
      amount: (json['amount'] as num).toDouble(),
      averageCost: (json['averageCost'] as num).toDouble(),
      purchaseAmount: (json['purchaseAmount'] as num).toDouble(),
      sellAmount: (json['sellAmount'] as num).toDouble(),
      realizedPnL: (json['realizedPnL'] as num).toDouble(),
      cost: (json['cost'] as num).toDouble(),
      time: _timestampToDateTime(json['time'] as Timestamp),
      color: (json['color'] as num).toInt(),
    );
  }

  String walletId, token;
  double amount, averageCost, purchaseAmount, sellAmount, realizedPnL, cost;
  int color;

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
        'token': token,
        'amount': amount,
        'averageCost': averageCost,
        'purchaseAmount': purchaseAmount,
        'sellAmount': sellAmount,
        'realizedPnL': realizedPnL,
        'cost': cost,
        'time': _dateTimeToTimestamp(time),
        'color': color,
      };
}
