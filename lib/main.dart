import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:web_dashboard/src/hive/crypto_hive.dart';

import 'src/app.dart';
import 'src/class/cryptos_list.dart';

const settingsBox = 'settings';
const cryptoListBox = 'cryptoList';

Future<void> main() async {
  await Hive.initFlutter();

  await Hive.openBox(settingsBox);

  Hive.registerAdapter(
    CryptoHiveAdapter(),
  );
  final boxCrypto = await Hive.openBox<CryptoHive>(cryptoListBox);

  final cryptoJsonString = await rootBundle.loadString('data/crypto.json');
  final cryptoJsonResponse = json.decode(cryptoJsonString);
  final CryptosList cryptosList = CryptosList.fromJson(cryptoJsonResponse);

  for (final element in cryptosList.cryptos) {
    final crypto = CryptoHive()
      ..symbol = element.symbol
      ..id = element.id
      ..category = element.category
      ..name = element.name
      ..logo = element.logo
      ..slug = element.slug;

    await boxCrypto.put(crypto.symbol, crypto);
  }

  runApp(
    DashboardApp.mock(),
  );
  // runApp(
  //   DashboardApp.firebase(),
  // );
}
