// Copyright 2020, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';

import 'package:web_dashboard/src/api/api.dart';
import 'package:web_dashboard/src/api/mock.dart';

void main() {
  group('mock dashboard API', () {
    DashboardApi api;

    setUp(() {
      api = MockDashboardApi();
    });

    group('items', () {
      test('insert', () async {
        var portfolio = await api.portfolios.insert(Portfolio('Coffees Drank'));
        expect(portfolio.name, 'Coffees Drank');
      });

      test('delete', () async {
        await api.portfolios.insert(Portfolio('Coffees Drank'));
        var portfolio = await api.portfolios.insert(Portfolio('Miles Ran'));
        var removed = await api.portfolios.delete(portfolio.id);

        expect(removed.name, 'Miles Ran');

        var portfolios = await api.portfolios.list();
        expect(portfolios, hasLength(1));
      });

      test('update', () async {
        var portfolio = await api.portfolios.insert(Portfolio('Coffees Drank'));
        await api.portfolios.update(Portfolio('Bagels Consumed'), portfolio.id);

        var latest = await api.portfolios.get(portfolio.id);
        expect(latest.name, equals('Bagels Consumed'));
      });
      test('subscribe', () async {
        var stream = api.portfolios.subscribe();

        stream.listen(expectAsync1((x) {
          expect(x, hasLength(1));
          expect(x.first.name, equals('Coffees Drank'));
        }, count: 1));
        await api.portfolios.insert(Portfolio('Coffees Drank'));
      });
    });

    group('entry service', () {
      Portfolio portfolio;
      DateTime dateTime = DateTime(2020, 1, 1, 30, 45);

      setUp(() async {
        portfolio =
            await api.portfolios.insert(Portfolio('Lines of code committed'));
      });

      test('insert', () async {
        var transaction = await api.transactions
            .insert(portfolio.id, Transaction(1, dateTime));

        expect(transaction.value, 1);
        expect(transaction.time, dateTime);
      });

      test('delete', () async {
        await api.transactions.insert(portfolio.id, Transaction(1, dateTime));
        var transaction2 = await api.transactions
            .insert(portfolio.id, Transaction(2, dateTime));

        await api.transactions.delete(portfolio.id, transaction2.id);

        var transactions = await api.transactions.list(portfolio.id);
        expect(transactions, hasLength(1));
      });

      test('update', () async {
        var transaction = await api.transactions
            .insert(portfolio.id, Transaction(1, dateTime));
        var updated = await api.transactions
            .update(portfolio.id, transaction.id, Transaction(2, dateTime));
        expect(updated.value, 2);
      });

      test('subscribe', () async {
        var stream = api.transactions.subscribe(portfolio.id);

        stream.listen(expectAsync1((x) {
          expect(x, hasLength(1));
          expect(x.first.value, equals(1));
        }, count: 1));

        await api.transactions.insert(portfolio.id, Transaction(1, dateTime));
      });
    });
  });
}
