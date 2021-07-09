import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_dashboard/wallet/model/wallet_model.dart';

class WalletController extends GetxController {
  static WalletController get to => Get.find();
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

  Stream<List<WalletModel>> streamFirestoreWalletList() {
    debugPrint('streamFirestoreWalletList');

    final snapshots =
        _db.collection('/users/${firebaseUser.value!.uid}/wallets').snapshots();
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
        .doc('/users/${firebaseUser.value!.uid}/wallets')
        .snapshots()
        .map((snapshot) => WalletModel.fromMap(snapshot.data()!));
  }

  Future<void> insertFirestoreWallet(WalletModel wallet) async {
    debugPrint('insertFirestoreWallet');
    await _db
        .collection('/users/${firebaseUser.value!.uid}/wallets')
        .add(wallet.toJson());
    update();
  }

  Future<void> updateFirestoreWallet(WalletModel wallet, String id) async {
    debugPrint('updateFirestoreWallet');
    await _db
        .collection('/users/${firebaseUser.value!.uid}/wallets')
        .doc(id)
        .set(wallet.toJson());
    update();
  }

  Future<void> deleteFirestoreWallet(String id) async {
    debugPrint('deleteFirestoreWallet');
    await _db
        .collection('/users/${firebaseUser.value!.uid}/wallets')
        .doc(id)
        .delete();
    update();
  }
}
