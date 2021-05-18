// Copyright 2020, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'api.g.dart';

/// Manipulates app data,
abstract class DashboardApi {
  PortfolioApi get portfolios;
  PositionApi get positions;
  TransactionApi get transactions;
}

/// Manipulates [Portfolio] data.
abstract class PortfolioApi {
  Future<Portfolio> delete(String id);

  Future<Portfolio> get(String id);

  Future<Portfolio> insert(Portfolio portfolio);

  Future<List<Portfolio>> list();

  Future<Portfolio> update(Portfolio portfolio, String id);

  Stream<List<Portfolio>> subscribe();
}

/// Manipulates [Position] data.
abstract class PositionApi {
  Future<Position> delete(String portfolioId, String id);

  Future<Position> get(String portfolioId, String id);

  Future<Position> insert(String portfolioId, Position position);

  Future<List<Position>> list(String portfolioId);

  Future<Position> update(String portfolioId, String id, Position position);

  Stream<List<Position>> subscribe(String portfolioId);
}

/// Manipulates [Transaction] data.
abstract class TransactionApi {
  Future<Transaction> delete(String positionId, String id);

  Future<Transaction> get(String positionId, String id);

  Future<Transaction> insert(String positionId, Transaction transaction);

  Future<List<Transaction>> list(String positionId);

  Future<Transaction> update(
      String positionId, String id, Transaction transaction);

  Stream<List<Transaction>> subscribe(String positionId);
}

/// A portfolio aggregated positions for example Binance
@JsonSerializable()
class Portfolio {
  Portfolio(this.name);

  factory Portfolio.fromJson(Map<String, dynamic> json) =>
      _$PortfolioFromJson(json);

  String name;

  @JsonKey(ignore: true)
  late String id;

  Map<String, dynamic> toJson() => _$PortfolioToJson(this);

  @override
  operator ==(Object other) => other is Portfolio && other.id == id;
  @override
  int get hashCode => id.hashCode;
  @override
  String toString() {
    return '<Portfolio id=$id>';
  }
}

/// A transaction ...
@JsonSerializable()
class Transaction {
  Transaction(this.tokenCredit, this.tokenDebit, this.amountCredit,
      this.amountDebit, this.time);

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);

  String tokenCredit, tokenDebit;
  double amountCredit, amountDebit;

  @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
  DateTime time;

  //@JsonKey(ignore: true)
  late String id;

  Map<String, dynamic> toJson() => _$TransactionToJson(this);

  static DateTime _timestampToDateTime(Timestamp timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(
        timestamp.millisecondsSinceEpoch);
  }

  static Timestamp _dateTimeToTimestamp(DateTime dateTime) {
    return Timestamp.fromMillisecondsSinceEpoch(
        dateTime.millisecondsSinceEpoch);
  }

  @override
  operator ==(Object other) => other is Transaction && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return '<Transaction id=$id>';
  }
}

/// todo : modify the definition of the position (token, amount, etc..)
@JsonSerializable()
class Position {
  Position(this.token, this.amount, this.time);
  factory Position.fromJson(Map<String, dynamic> json) =>
      _$PositionFromJson(json);

  String token;
  double amount;

  @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
  DateTime time;

  //@JsonKey(ignore: true)
  late String id;

  Map<String, dynamic> toJson() => _$PositionToJson(this);

  static DateTime _timestampToDateTime(Timestamp timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(
        timestamp.millisecondsSinceEpoch);
  }

  static Timestamp _dateTimeToTimestamp(DateTime dateTime) {
    return Timestamp.fromMillisecondsSinceEpoch(
        dateTime.millisecondsSinceEpoch);
  }

  @override
  operator ==(Object other) => other is Position && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return '<Position id=$id>';
  }
}
