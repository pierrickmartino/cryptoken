// Copyright 2020, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:core';
import 'dart:math';

import 'package:uuid/uuid.dart' as uuid;

import 'api.dart';

const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

String randomString(int strlen) {
  final Random rnd = Random(DateTime.now().millisecondsSinceEpoch);
  final result = StringBuffer();
  for (var i = 0; i < strlen; i++) {
    result.write(chars[rnd.nextInt(chars.length)]);
  }
  return result.toString();
}

class MockDashboardApi implements DashboardApi {
  MockDashboardApi();

  @override
  final PortfolioApi portfolios = MockPortfolioApi();

  @override
  final PositionApi positions = MockPositionApi();

  @override
  final TransactionApi transactions = MockTransactionApi();

  /// Creates a [MockDashboardApi] filled with mock data for the last 30 days.
  Future<void> fillWithMockData() async {
    await Future<void>.delayed(const Duration(seconds: 1));

    // PORTFOLIO BENCHMARK
    final portfolio0 = await portfolios.insert(Portfolio('Benchmark'));

    // POSITION BTC
    final dateBTC = DateTime.utc(2021, 4);
    const valueMainBTC = 1;
    const valueReferenceBTC = 58740;
    const valueFeeBTC = 0;
    const tokenMainBTC = 'BTC';
    const tokenReferenceBTC = 'USDT';

    await positions.insert(portfolio0.id,
        Position(tokenMainBTC, valueMainBTC.toDouble(), dateBTC));
    // await positions.insert(portfolio0.id,
    //     Position(tokenReferenceBTC, valueReferenceBTC.toDouble(), dateBTC));
    await transactions.insert(
        portfolio0.id,
        Transaction(
            tokenMainBTC,
            tokenReferenceBTC,
            tokenReferenceBTC,
            tokenReferenceBTC,
            valueMainBTC.toDouble(),
            valueReferenceBTC.toDouble(),
            valueFeeBTC.toDouble(),
            valueReferenceBTC.toDouble() / valueMainBTC.toDouble(),
            dateBTC,
            false));

    // POSITION ETH
    final dateETH = DateTime.utc(2021, 4);
    const valueMainETH = 1;
    const valueReferenceETH = 1968;
    const valueFeeETH = 0;
    const tokenMainETH = 'ETH';
    const tokenReferenceETH = 'USDT';

    await positions.insert(portfolio0.id,
        Position(tokenMainETH, valueMainETH.toDouble(), dateETH));
    // await positions.insert(portfolio0.id,
    //     Position(tokenReferenceETH, valueReferenceETH.toDouble(), dateETH));
    await transactions.insert(
        portfolio0.id,
        Transaction(
            tokenMainETH,
            tokenReferenceETH,
            tokenReferenceETH,
            tokenReferenceETH,
            valueMainETH.toDouble(),
            valueReferenceETH.toDouble(),
            valueFeeETH.toDouble(),
            valueReferenceETH.toDouble() / valueMainETH.toDouble(),
            dateETH,
            false));

    // Other examples
    final portfolio1 =
        await portfolios.insert(Portfolio('PTF ${randomString(7)}'));
    final portfolio2 =
        await portfolios.insert(Portfolio('PTF ${randomString(9)}'));
    final portfolio3 =
        await portfolios.insert(Portfolio('PTF ${randomString(9)}'));
    final monthAgo = DateTime.now().subtract(const Duration(days: 30));

    for (final portfolio in [portfolio1, portfolio2, portfolio3]) {
      for (var i = 0; i < 3; i++) {
        final date = monthAgo.add(const Duration(days: 1));
        final valueMain = Random().nextInt(100);
        final valueReference = Random().nextInt(100);
        final valueFee = Random().nextInt(9);
        final tokenMain = randomString(3);
        final tokenReference = randomString(4);

        // first regarding the Main part of the transaction
        try {
          // try to find if the position already exists
          final oldPositionMain = await positions.get(portfolio.id, tokenMain);
          final newPositionMain = Position(oldPositionMain.token,
              oldPositionMain.amount + valueMain, oldPositionMain.time);

          // if we find the position, we need to update it
          await positions.update(portfolio.id, tokenMain, newPositionMain);
        } catch (e) {
          // if not, we should get an error then insert the new position
          await positions.insert(
              portfolio.id, Position(tokenMain, valueMain.toDouble(), date));
        }

        // then regarding the Reference part of the transaction
        try {
          // try to find if the position already exists
          final oldPositionReference =
              await positions.get(portfolio.id, tokenReference);
          final newPositionReference = Position(
              oldPositionReference.token,
              oldPositionReference.amount - valueReference,
              oldPositionReference.time);

          // if we find the position, we need to update it
          await positions.update(
              portfolio.id, tokenReference, newPositionReference);
        } catch (e) {
          // if not, we should get an error then insert the new position
          await positions.insert(portfolio.id,
              Position(tokenReference, valueReference.toDouble(), date));
        }

        // finally insert the transaction linked to the portfolio
        await transactions.insert(
            portfolio.id,
            Transaction(
                tokenMain,
                tokenReference,
                tokenReference,
                tokenReference,
                valueMain.toDouble(),
                valueReference.toDouble(),
                valueFee.toDouble(),
                valueReference.toDouble() / valueMain.toDouble(),
                date,
                true));
      }
    }
  }
}

class MockPortfolioApi implements PortfolioApi {
  final Map<String, Portfolio> _storage = {};
  final StreamController<List<Portfolio>> _streamController =
      StreamController<List<Portfolio>>.broadcast();

  @override
  Future<Portfolio> delete(String id) async {
    final removed = _storage.remove(id);
    _emit();
    return removed!;
  }

  @override
  Future<Portfolio> get(String id) async {
    return _storage[id]!;
  }

  @override
  Future<Portfolio> insert(Portfolio portfolio) async {
    final id = const uuid.Uuid().v4();
    final newPortfolio = Portfolio(portfolio.name)..id = id;
    _storage[id] = newPortfolio;
    _emit();
    return newPortfolio;
  }

  @override
  Future<List<Portfolio>> list() async {
    return _storage.values.toList();
  }

  @override
  Future<Portfolio> update(Portfolio portfolio, String id) async {
    _storage[id] = portfolio;
    _emit();
    return portfolio..id = id;
  }

  @override
  Stream<List<Portfolio>> subscribe() => _streamController.stream;

  void _emit() {
    _streamController.add(_storage.values.toList());
  }
}

class MockPositionApi implements PositionApi {
  final Map<String, Position> _storage = {};
  final StreamController<_PositionsEvent> _streamController =
      StreamController.broadcast();

  @override
  Future<Position> delete(String portfolioId, String id) async {
    _emit(portfolioId);
    return _storage.remove('$portfolioId-$id')!;
  }

  @override
  Future<Position> insert(String portfolioId, Position position) async {
    //final id = const uuid.Uuid().v4();
    final newPosition = Position(position.token, position.amount, position.time)
      ..id = position.token;
    //..id = id;

    if (_storage['$portfolioId-${position.token}'] != null) {
      return newPosition;
    }
    //_storage['$portfolioId-$id'] = newPosition;
    _storage['$portfolioId-${position.token}'] = newPosition;

    _emit(portfolioId);
    return newPosition;
  }

  @override
  Future<List<Position>> list(String portfolioId) async {
    return _storage.keys
        .where((k) => k.startsWith(portfolioId))
        .map((k) => _storage[k]!)
        .toList();
  }

  @override
  Future<Position> update(
      String portfolioId, String id, Position position) async {
    _storage['$portfolioId-$id'] = position;
    _emit(portfolioId);
    return position..id = id;
  }

  @override
  Stream<List<Position>> subscribe(String portfolioId) {
    return _streamController.stream
        .where((event) => event.portfolioId == portfolioId)
        .map((event) => event.positions);
  }

  void _emit(String portfolioId) {
    final positions = _storage.keys
        .where((k) => k.startsWith(portfolioId))
        .map((k) => _storage[k]!)
        .toList();

    _streamController.add(_PositionsEvent(portfolioId, positions));
  }

  @override
  Future<Position> get(String portfolioId, String id) async {
    return _storage['$portfolioId-$id']!;
  }
}

class MockTransactionApi implements TransactionApi {
  final Map<String, Transaction> _storage = {};
  final StreamController<_TransactionsEvent> _streamController =
      StreamController.broadcast();

  @override
  Future<Transaction> delete(String positionId, String id) async {
    _emit(positionId);
    return _storage.remove('$positionId-$id')!;
  }

  @override
  Future<Transaction> insert(String positionId, Transaction transaction) async {
    final id = const uuid.Uuid().v4();
    final newTransaction = Transaction(
        transaction.tokenMain,
        transaction.tokenReference,
        transaction.tokenFee,
        transaction.tokenPrice,
        transaction.amountMain,
        transaction.amountReference,
        transaction.amountFee,
        transaction.price,
        transaction.time,
        transaction.withImpactOnSecondPosition)
      ..id = id;

    _storage['$positionId-$id'] = newTransaction;
    _emit(positionId);
    return newTransaction;
  }

  @override
  Future<List<Transaction>> list(String positionId) async {
    return _storage.keys
        .where((k) => k.startsWith(positionId))
        .map((k) => _storage[k]!)
        .toList();
  }

  @override
  Future<Transaction> update(
      String positionId, String id, Transaction transaction) async {
    _storage['$positionId-$id'] = transaction;
    _emit(positionId);
    return transaction..id = id;
  }

  @override
  Stream<List<Transaction>> subscribe(String positionId) {
    return _streamController.stream
        .where((event) => event.positionId == positionId)
        .map((event) => event.transactions);
  }

  void _emit(String positionId) {
    final transactions = _storage.keys
        .where((k) => k.startsWith(positionId))
        .map((k) => _storage[k]!)
        .toList();

    _streamController.add(_TransactionsEvent(positionId, transactions));
  }

  @override
  Future<Transaction> get(String positionId, String id) async {
    return _storage['$positionId-$id']!;
  }
}

class _PositionsEvent {
  _PositionsEvent(this.portfolioId, this.positions);

  final String portfolioId;
  final List<Position> positions;
}

class _TransactionsEvent {
  _TransactionsEvent(this.positionId, this.transactions);

  final String positionId;
  final List<Transaction> transactions;
}
