import 'package:cloud_firestore/cloud_firestore.dart' as fire;

import 'api.dart';

class FirebaseDashboardApi implements DashboardApi {
  FirebaseDashboardApi(dynamic firestore, String userId)
      : portfolios = FirebasePortfolioApi(firestore, userId),
        transactions = FirebaseTransactionApi(firestore, userId),
        positions = FirebasePositionApi(firestore, userId);

  @override
  final PortfolioApi portfolios;

  @override
  final PositionApi positions;

  @override
  final TransactionApi transactions;
}

class FirebasePortfolioApi implements PortfolioApi {
  FirebasePortfolioApi(this.firestore, this.userId)
      : _portfoliosRef = firestore.collection('users/$userId/portfolios');

  final dynamic firestore;
  final String userId;
  final fire.CollectionReference<Map<String, dynamic>> _portfoliosRef;

  @override
  Stream<List<Portfolio>> subscribe() {
    final snapshots = _portfoliosRef.snapshots();

    final result = snapshots.map((querySnapshot) {
      return querySnapshot.docs.map((snapshot) {
        return Portfolio.fromJson(snapshot.data())..id = snapshot.id;
      }).toList();
    });

    return result;
  }

  @override
  Future<Portfolio> delete(String id) async {
    final document = _portfoliosRef.doc(id);
    final portfolios = await get(document.id);

    await document.delete();

    return portfolios;
  }

  @override
  Future<Portfolio> get(String id) async {
    final document = _portfoliosRef.doc(id);
    final snapshot = await document.get();
    return Portfolio.fromJson(snapshot.data()!)..id = snapshot.id;
  }

  @override
  Future<Portfolio> insert(Portfolio portfolio) async {
    final document = await _portfoliosRef.add(portfolio.toJson());
    return await get(document.id);
  }

  @override
  Future<List<Portfolio>> list() async {
    final querySnapshot = await _portfoliosRef.get();
    final portfolios = querySnapshot.docs
        .map((doc) => Portfolio.fromJson(doc.data())..id = doc.id)
        .toList();

    return portfolios;
  }

  @override
  Future<Portfolio> update(Portfolio portfolio, String id) async {
    final document = _portfoliosRef.doc(id);
    await document.set(portfolio.toJson());
    final snapshot = await document.get();
    return Portfolio.fromJson(snapshot.data()!)..id = snapshot.id;
  }
}

class FirebaseTransactionApi implements TransactionApi {
  FirebaseTransactionApi(this.firestore, this.userId)
      : _positionsRef = firestore.collection('users/$userId/portfolios');

  final dynamic firestore;
  final String userId;
  final fire.CollectionReference<Map<String, dynamic>> _positionsRef;

  @override
  Stream<List<Transaction>> subscribe(String portfolioId) {
    final snapshots =
        _positionsRef.doc(portfolioId).collection('transactions').snapshots();
    final result = snapshots.map((querySnapshot) {
      return querySnapshot.docs.map((snapshot) {
        return Transaction.fromJson(snapshot.data())..id = snapshot.id;
      }).toList();
    });

    return result;
  }

  @override
  Future<Transaction> delete(String positionId, String id) async {
    final document = _positionsRef.doc('$positionId/transactions/$id');
    final transaction = await get(positionId, document.id);

    await document.delete();

    return transaction;
  }

  @override
  Future<Transaction> insert(String positionId, Transaction transaction) async {
    final document = await _positionsRef
        .doc(positionId)
        .collection('transactions')
        .add(transaction.toJson());
    return await get(positionId, document.id);
  }

  // TODO
  @override
  Future<Transaction> insertFromPortfolio(
      String portfolioId, Transaction transaction) async {
    final document = await _positionsRef
        .doc(portfolioId)
        .collection('transactions')
        .add(transaction.toJson());
    return await get(portfolioId, document.id);
  }

  @override
  Future<List<Transaction>> list(String positionId) async {
    final transactionsRef =
        _positionsRef.doc(positionId).collection('transactions');
    final querySnapshot = await transactionsRef.get();
    final transactions = querySnapshot.docs
        .map((doc) => Transaction.fromJson(doc.data())..id = doc.id)
        .toList();

    return transactions;
  }

  @override
  Future<Transaction> update(
      String positionId, String id, Transaction transaction) async {
    final document = _positionsRef.doc('$positionId/transactions/$id');
    await document.set(transaction.toJson());
    final snapshot = await document.get();
    return Transaction.fromJson(snapshot.data()!)..id = snapshot.id;
  }

  @override
  Future<Transaction> get(String positionId, String id) async {
    final document = _positionsRef.doc('$positionId/transactions/$id');
    final snapshot = await document.get();
    return Transaction.fromJson(snapshot.data()!)..id = snapshot.id;
  }
}

class FirebasePositionApi implements PositionApi {
  FirebasePositionApi(this.firestore, this.userId)
      : _portfoliosRef = firestore.collection('users/$userId/portfolios');

  final dynamic firestore;
  final String userId;
  final fire.CollectionReference<Map<String, dynamic>> _portfoliosRef;

  @override
  Stream<List<Position>> subscribe(String positionId) {
    final snapshots =
        _portfoliosRef.doc(positionId).collection('positions').snapshots();
    final result = snapshots.map((querySnapshot) {
      return querySnapshot.docs.map((snapshot) {
        return Position.fromJson(snapshot.data())..id = snapshot.id;
      }).toList();
    });

    return result;
  }

  @override
  Future<Position> delete(String portfolioId, String id) async {
    final document = _portfoliosRef.doc('$portfolioId/positions/$id');
    final position = await get(portfolioId, document.id);

    await document.delete();

    return position;
  }

  @override
  Future<Position> insert(String portfolioId, Position position) async {
    final document = await _portfoliosRef
        .doc(portfolioId)
        .collection('positions')
        .doc(position.token)
        .set(position.toJson());

    return await get(portfolioId, position.token);
  }

  @override
  Future<List<Position>> list(String portfolioId) async {
    final positionsRef =
        _portfoliosRef.doc(portfolioId).collection('positions');
    final querySnapshot = await positionsRef.get();
    final positions = querySnapshot.docs
        .map((doc) => Position.fromJson(doc.data())..id = doc.id)
        .toList();

    return positions;
  }

  @override
  Future<Position> update(
      String portfolioId, String id, Position position) async {
    final document = _portfoliosRef.doc('$portfolioId/positions/$id');
    await document.set(position.toJson());
    final snapshot = await document.get();
    return Position.fromJson(snapshot.data()!)..id = snapshot.id;
  }

  @override
  Future<Position> get(String portfolioId, String id) async {
    final document = _portfoliosRef.doc('$portfolioId/positions/$id');
    final snapshot = await document.get();
    return Position.fromJson(snapshot.data()!)..id = snapshot.id;
  }
}
