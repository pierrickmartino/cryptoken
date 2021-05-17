// // Copyright 2020, the Flutter project authors. Please see the AUTHORS file
// // for details. All rights reserved. Use of this source code is governed by a
// // BSD-style license that can be found in the LICENSE file.

// import 'package:test/test.dart';

// import 'package:web_dashboard/src/api/api.dart';
// import 'package:web_dashboard/src/api/mock.dart';

// void main() {
//   group('mock dashboard API', () {
//     DashboardApi api;

//     setUp(() {
//       api = MockDashboardApi();
//     });

//     group('items', () {
//       test('insert', () async {
//         final portfolio =
//             await api.portfolios.insert(Portfolio('Coffees Drank'));
//         expect(portfolio.name, 'Coffees Drank');
//       });

//       test('delete', () async {
//         await api.portfolios.insert(Portfolio('Coffees Drank'));
//         final portfolio = await api.portfolios.insert(Portfolio('Miles Ran'));
//         final removed = await api.portfolios.delete(portfolio.id);

//         expect(removed.name, 'Miles Ran');

//         final portfolios = await api.portfolios.list();
//         expect(portfolios, hasLength(1));
//       });

//       test('update', () async {
//         final portfolio =
//             await api.portfolios.insert(Portfolio('Coffees Drank'));
//         await api.portfolios.update(Portfolio('Bagels Consumed'), portfolio.id);

//         final latest = await api.portfolios.get(portfolio.id);
//         expect(latest.name, equals('Bagels Consumed'));
//       });
//       test('subscribe', () async {
//         final stream = api.portfolios.subscribe();

//         stream.listen(expectAsync1((x) {
//           expect(x, hasLength(1));
//           expect(x.first.name, equals('Coffees Drank'));
//         }, count: 1));
//         await api.portfolios.insert(Portfolio('Coffees Drank'));
//       });
//     });

//     group('entry service', () {
//       Portfolio portfolio;
//       final DateTime dateTime = DateTime(2020, 1, 1, 30, 45);

//       setUp(() async {
//         portfolio =
//             await api.portfolios.insert(Portfolio('Lines of code committed'));
//       });

//       test('insert', () async {
//         final transaction = await api.transactions
//             .insert(portfolio.id, Transaction('BTC', 'USD', 1, 2, dateTime));

//         expect(transaction.amountCredit, 1);
//         expect(transaction.time, dateTime);
//       });

//       test('delete', () async {
//         await api.transactions
//             .insert(portfolio.id, Transaction('BTC', 'USD', 1, 2, dateTime));
//         final transaction2 = await api.transactions
//             .insert(portfolio.id, Transaction('BTC', 'USD', 1, 2, dateTime));

//         await api.transactions.delete(portfolio.id, transaction2.id);

//         final transactions = await api.transactions.list(portfolio.id);
//         expect(transactions, hasLength(1));
//       });

//       test('update', () async {
//         final transaction = await api.transactions
//             .insert(portfolio.id, Transaction('BTC', 'USD', 1, 2, dateTime));
//         final updated = await api.transactions.update(portfolio.id,
//             transaction.id, Transaction('BTC', 'USD', 1, 2, dateTime));
//         expect(updated.amountDebit, 2);
//       });

//       test('subscribe', () async {
//         final stream = api.transactions.subscribe(portfolio.id);

//         stream.listen(expectAsync1((x) {
//           expect(x, hasLength(1));
//           expect(x.first.amountCredit, equals(1));
//         }, count: 1));

//         await api.transactions
//             .insert(portfolio.id, Transaction('BTC', 'USD', 1, 2, dateTime));
//       });
//     });
//   });
// }
