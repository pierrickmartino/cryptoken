// Copyright 2020, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart' as fire;

import 'api.dart';

class FirebaseDashboardApi implements DashboardApi {
  FirebaseDashboardApi(fire.Firestore firestore, String userId)
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
  final fire.Firestore firestore;
  final String userId;
  final fire.CollectionReference _portfoliosRef;

  FirebasePortfolioApi(this.firestore, this.userId)
      : _portfoliosRef = firestore.collection('users/$userId/portfolios');

  @override
  Stream<List<Portfolio>> subscribe() {
    final snapshots = _portfoliosRef.snapshots();
    final result = snapshots.map((querySnapshot) {
      return querySnapshot.documents.map((snapshot) {
        return Portfolio.fromJson(snapshot.data)..id = snapshot.documentID;
      }).toList();
    });

    return result;
  }

  @override
  Future<Portfolio> delete(String id) async {
    final document = _portfoliosRef.document(id);
    final portfolios = await get(document.documentID);

    await document.delete();

    return portfolios;
  }

  @override
  Future<Portfolio> get(String id) async {
    final document = _portfoliosRef.document(id);
    final snapshot = await document.get();
    return Portfolio.fromJson(snapshot.data)..id = snapshot.documentID;
  }

  @override
  Future<Portfolio> insert(Portfolio portfolio) async {
    final document = await _portfoliosRef.add(portfolio.toJson());
    return await get(document.documentID);
  }

  @override
  Future<List<Portfolio>> list() async {
    final querySnapshot = await _portfoliosRef.getDocuments();
    final portfolios = querySnapshot.documents
        .map((doc) => Portfolio.fromJson(doc.data)..id = doc.documentID)
        .toList();

    return portfolios;
  }

  @override
  Future<Portfolio> update(Portfolio portfolio, String id) async {
    final document = _portfoliosRef.document(id);
    await document.setData(portfolio.toJson());
    final snapshot = await document.get();
    return Portfolio.fromJson(snapshot.data)..id = snapshot.documentID;
  }
}

class FirebaseTransactionApi implements TransactionApi {
  final fire.Firestore firestore;
  final String userId;
  final fire.CollectionReference _positionsRef;

  FirebaseTransactionApi(this.firestore, this.userId)
      : _positionsRef =
            firestore.collection('users/$userId/portfolios/positions');

  @override
  Stream<List<Transaction>> subscribe(String portfolioId) {
    final snapshots = _positionsRef
        .document(portfolioId)
        .collection('transactions')
        .snapshots();
    final result = snapshots.map((querySnapshot) {
      return querySnapshot.documents.map((snapshot) {
        return Transaction.fromJson(snapshot.data)..id = snapshot.documentID;
      }).toList();
    });

    return result;
  }

  @override
  Future<Transaction> delete(String positionId, String id) async {
    final document = _positionsRef.document('$positionId/transactions/$id');
    final transaction = await get(positionId, document.documentID);

    await document.delete();

    return transaction;
  }

  @override
  Future<Transaction> insert(String positionId, Transaction transaction) async {
    final document = await _positionsRef
        .document(positionId)
        .collection('transactions')
        .add(transaction.toJson());
    return await get(positionId, document.documentID);
  }

  @override
  Future<List<Transaction>> list(String positionId) async {
    final transactionsRef =
        _positionsRef.document(positionId).collection('transactions');
    final querySnapshot = await transactionsRef.getDocuments();
    final transactions = querySnapshot.documents
        .map((doc) => Transaction.fromJson(doc.data)..id = doc.documentID)
        .toList();

    return transactions;
  }

  @override
  Future<Transaction> update(
      String positionId, String id, Transaction transaction) async {
    final document = _positionsRef.document('$positionId/transactions/$id');
    await document.setData(transaction.toJson());
    final snapshot = await document.get();
    return Transaction.fromJson(snapshot.data)..id = snapshot.documentID;
  }

  @override
  Future<Transaction> get(String positionId, String id) async {
    final document = _positionsRef.document('$positionId/transactions/$id');
    final snapshot = await document.get();
    return Transaction.fromJson(snapshot.data)..id = snapshot.documentID;
  }
}

class FirebasePositionApi implements PositionApi {
  final fire.Firestore firestore;
  final String userId;
  final fire.CollectionReference _portfoliosRef;

  FirebasePositionApi(this.firestore, this.userId)
      : _portfoliosRef = firestore.collection('users/$userId/portfolios');

  @override
  Stream<List<Position>> subscribe(String positionId) {
    final snapshots =
        _portfoliosRef.document(positionId).collection('positions').snapshots();
    final result = snapshots.map((querySnapshot) {
      return querySnapshot.documents.map((snapshot) {
        return Position.fromJson(snapshot.data)..id = snapshot.documentID;
      }).toList();
    });

    return result;
  }

  @override
  Future<Position> delete(String portfolioId, String id) async {
    final document = _portfoliosRef.document('$portfolioId/positions/$id');
    final position = await get(portfolioId, document.documentID);

    await document.delete();

    return position;
  }

  @override
  Future<Position> insert(String portfolioId, Position position) async {
    final document = await _portfoliosRef
        .document(portfolioId)
        .collection('positions')
        .add(position.toJson());
    return await get(portfolioId, document.documentID);
  }

  @override
  Future<List<Position>> list(String portfolioId) async {
    final positionsRef =
        _portfoliosRef.document(portfolioId).collection('positions');
    final querySnapshot = await positionsRef.getDocuments();
    final positions = querySnapshot.documents
        .map((doc) => Position.fromJson(doc.data)..id = doc.documentID)
        .toList();

    return positions;
  }

  @override
  Future<Position> update(
      String portfolioId, String id, Position position) async {
    final document = _portfoliosRef.document('$portfolioId/positions/$id');
    await document.setData(position.toJson());
    final snapshot = await document.get();
    return Position.fromJson(snapshot.data)..id = snapshot.documentID;
  }

  @override
  Future<Position> get(String portfolioId, String id) async {
    final document = _portfoliosRef.document('$portfolioId/positions/$id');
    final snapshot = await document.get();
    return Position.fromJson(snapshot.data)..id = snapshot.documentID;
  }
}
