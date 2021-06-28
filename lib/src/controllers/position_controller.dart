import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ZeroPositionController extends GetxController {
  static ZeroPositionController get to => Get.find();
  final showZeroPosition = false.obs;
  final store = GetStorage();

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
