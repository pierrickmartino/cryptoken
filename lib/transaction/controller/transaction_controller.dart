import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_dashboard/transaction/model/transaction_model.dart';

class TransactionController extends GetxController {
  static TransactionController get to => Get.find();

  //TextEditingController nameController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Rxn<User> firebaseUser = Rxn<User>();

  @override
  Future<void> onReady() async {
    firebaseUser.bindStream(user);
    super.onReady();
  }

  @override
  void onClose() {
    //nameController.dispose();
    super.onClose();
  }

  // Firebase user a realtime stream
  Stream<User?> get user => _auth.authStateChanges();

  Stream<List<TransactionModel>> streamFirestoreTransactionList() {
    debugPrint('streamFirestoreTransactionList');

    final snapshots = _db
        .collection('/users/${firebaseUser.value!.uid}/transactions')
        .snapshots();

    final result = snapshots.map((querySnapshot) {
      return querySnapshot.docs.map((snapshot) {
        return TransactionModel.fromJson(snapshot.data())..id = snapshot.id;
      }).toList();
    });

    return result;
  }

  Future<List<TransactionModel>> futureFirestoreTransactionList() async {
    debugPrint('futureFirestoreTransactionList');

    final querySnapshot = await _db
        .collection('/users/${firebaseUser.value!.uid}/transactions')
        .get();

    final transactions = querySnapshot.docs
        .map((doc) => TransactionModel.fromJson(doc.data())..id = doc.id)
        .toList();

    return transactions;
  }

  Future<void> deleteFirestoreTransaction(String id) async {
    debugPrint('deleteFirestoreTransaction');
    await _db
        .collection('/users/${firebaseUser.value!.uid}/transactions')
        .doc(id)
        .delete();
    update();
  }

  Future insertFirestoreTransaction(TransactionModel transaction) async {
    debugPrint('insertFirestoreTransaction');
    await _db
        .collection('/users/${firebaseUser.value!.uid}/transactions')
        .add(transaction.toJson());
    update();
  }

  Future<void> updateFirestoreTransaction(
      String id, TransactionModel transaction) async {
    debugPrint('updateFirestoreTransaction');
    await _db
        .collection('/users/${firebaseUser.value!.uid}/transactions')
        .doc(id)
        .set(transaction.toJson());
    update();
  }
}
