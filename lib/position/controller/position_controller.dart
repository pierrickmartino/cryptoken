import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:web_dashboard/position/model/position_model.dart';

class PositionController extends GetxController {
  static PositionController get to => Get.find();
  final showZeroPosition = false.obs;
  final store = GetStorage();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Rxn<User> firebaseUser = Rxn<User>();

  @override
  Future<void> onReady() async {
    firebaseUser.bindStream(user);
    super.onReady();
  }

  // Firebase user a realtime stream
  Stream<User?> get user => _auth.authStateChanges();

  Stream<List<PositionModel>> streamFirestorePositionList() {
    final snapshots = _db
        .collection('/users/${firebaseUser.value!.uid}/positions')
        .snapshots();

    final result = snapshots.map((querySnapshot) {
      return querySnapshot.docs.map((snapshot) {
        return PositionModel.fromJson(snapshot.data())..id = snapshot.id;
      }).toList();
    });

    return result;
  }

  Future<void> deleteFirestorePosition(String id) async {
    await _db
        .collection('/users/${firebaseUser.value!.uid}/positions')
        .doc(id)
        .delete();
    update();
  }

  Future<PositionModel> insertFirestorePosition(PositionModel position) async {
    await _db
        .collection('/users/${firebaseUser.value!.uid}/positions')
        .doc(position.token)
        .set(position.toJson());
    update();

    return getFirestorePosition(position.token);
  }

  Future<void> updateFirestorePosition(
      String id, PositionModel position) async {
    await _db
        .collection('/users/${firebaseUser.value!.uid}/positions')
        .doc(id)
        .set(position.toJson());
    update();
  }

  Future<PositionModel> getFirestorePosition(String id) async {
    final snapshot = await _db
        .collection('/users/${firebaseUser.value!.uid}/positions/')
        .doc(id)
        .get();

    return PositionModel.fromJson(snapshot.data()!)..id = snapshot.id;
  }

  Future<List<PositionModel>> getFirestoreTopPositionList() async {
    final snapshot = await _db
        .collection('/users/${firebaseUser.value!.uid}/positions/')
        .orderBy('purchaseAmount', descending: true)
        .limit(5)
        .get();

    final positions = snapshot.docs
        .map((doc) => PositionModel.fromJson(doc.data())..id = doc.id)
        .toList();

    return positions;
  }

  Future<List<PositionModel>> getFirestorePositionList() async {
    final snapshot = await _db
        .collection('/users/${firebaseUser.value!.uid}/positions/')
        .orderBy('purchaseAmount', descending: true)
        .get();

    final positions = snapshot.docs
        .map((doc) => PositionModel.fromJson(doc.data())..id = doc.id)
        .toList();

    return positions;
  }

  Future<List<PositionModel>> getFirestorePositionListByWallet(
      String walletId) async {
    final snapshot = await _db
        .collection('/users/${firebaseUser.value!.uid}/positions/')
        .where('walletId', isEqualTo: walletId)
        .get();

    final positions = snapshot.docs
        .map((doc) => PositionModel.fromJson(doc.data())..id = doc.id)
        .toList();

    return positions;
  }

  bool get currentZeroPosition => showZeroPosition.value;

  Future<void> setZeroPositionDisplay(bool value) async {
    showZeroPosition.value = value;
    await store.write('showZeroPosition', value);
    update();
  }

  Future<void> getZeroPositionDisplayFromStore() async {
    final bool _showZeroPosition = store.read('showZeroPosition') ?? false;
    await setZeroPositionDisplay(_showZeroPosition);
  }
}
