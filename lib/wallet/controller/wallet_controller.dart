import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_dashboard/wallet/model/wallet_model.dart';

class WalletController extends GetxController {
  static WalletController get to => Get.find();
  TextEditingController nameController = TextEditingController();
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
    nameController.dispose();
    super.onClose();
  }

  // Firebase user a realtime stream
  Stream<User?> get user => _auth.authStateChanges();

  Stream<List<WalletModel>> streamFirestoreWalletList() {
    final snapshots = _db
        .collection('/users/${firebaseUser.value!.uid}/portfolios')
        .snapshots();
    final result = snapshots.map((querySnapshot) {
      return querySnapshot.docs.map((snapshot) {
        return WalletModel.fromJson(snapshot.data())..id = snapshot.id;
      }).toList();
    });

    return result;
  }

  Stream<WalletModel> streamFirestoreWallet() {
    debugPrint('streamFirestoreWallet()');

    return _db
        .doc('/users/${firebaseUser.value!.uid}/portfolios')
        .snapshots()
        .map((snapshot) => WalletModel.fromMap(snapshot.data()!));
  }

  Future<void> insertFirestoreWallet(WalletModel portfolio) async {
    await _db
        .collection('/users/${firebaseUser.value!.uid}/portfolios')
        .add(portfolio.toJson());
    update();
  }

  Future<void> updateFirestoreWallet(WalletModel portfolio, String id) async {
    debugPrint('updateFirestoreWallet');
    await _db
        .collection('/users/${firebaseUser.value!.uid}/portfolios')
        .doc(id)
        .set(portfolio.toJson());
  }

  Future<WalletModel> getFirestoreUser() {
    return _db.doc('/users/${firebaseUser.value!.uid}/portfolios').get().then(
        (documentSnapshot) => WalletModel.fromMap(documentSnapshot.data()!));
  }
}
