// Copyright 2020, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'api.g.dart';

/// Manipulates app data,
abstract class DashboardApi {
  CategoryApi get categories;
  EntryApi get entries;
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

/// Manipulates [Category] data.
abstract class CategoryApi {
  Future<Category> delete(String id);

  Future<Category> get(String id);

  Future<Category> insert(Category category);

  Future<List<Category>> list();

  Future<Category> update(Category category, String id);

  Stream<List<Category>> subscribe();
}

/// Manipulates [Entry] data.
abstract class EntryApi {
  Future<Entry> delete(String categoryId, String id);

  Future<Entry> get(String categoryId, String id);

  Future<Entry> insert(String categoryId, Entry entry);

  Future<List<Entry>> list(String categoryId);

  Future<Entry> update(String categoryId, String id, Entry entry);

  Stream<List<Entry>> subscribe(String categoryId);
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

  String name;

  @JsonKey(ignore: true)
  String id;

  factory Portfolio.fromJson(Map<String, dynamic> json) =>
      _$PortfolioFromJson(json);

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

/// Something that's being tracked, e.g. Hours Slept, Cups of water, etc.
@JsonSerializable()
class Category {
  String name;

  @JsonKey(ignore: true)
  String id;

  Category(this.name);

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);

  @override
  operator ==(Object other) => other is Category && other.id == id;
  @override
  int get hashCode => id.hashCode;
  @override
  String toString() {
    return '<Category id=$id>';
  }
}

/// A number tracked at a point in time.
@JsonSerializable()
class Entry {
  int value;
  @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
  DateTime time;

  @JsonKey(ignore: true)
  String id;

  Entry(this.value, this.time);

  factory Entry.fromJson(Map<String, dynamic> json) => _$EntryFromJson(json);

  Map<String, dynamic> toJson() => _$EntryToJson(this);

  static DateTime _timestampToDateTime(Timestamp timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(
        timestamp.millisecondsSinceEpoch);
  }

  static Timestamp _dateTimeToTimestamp(DateTime dateTime) {
    return Timestamp.fromMillisecondsSinceEpoch(
        dateTime.millisecondsSinceEpoch);
  }

  @override
  operator ==(Object other) => other is Entry && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return '<Entry id=$id>';
  }
}

/// A transaction ...
@JsonSerializable()
class Transaction {
  Transaction(this.value, this.time);

  int value;

  @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
  DateTime time;

  @JsonKey(ignore: true)
  String id;

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);

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

/// A position ...
@JsonSerializable()
class Position {
  int value;

  @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
  DateTime time;

  @JsonKey(ignore: true)
  String id;

  Position(this.value, this.time);

  factory Position.fromJson(Map<String, dynamic> json) =>
      _$PositionFromJson(json);

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
