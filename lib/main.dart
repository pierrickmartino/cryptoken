import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:web_dashboard/src/hive/crypto_hive.dart';
import 'package:web_dashboard/src/hive/portfolio_hive.dart';
import 'package:web_dashboard/wallet/controller/wallet_controller.dart';

import 'auth/controller/auth_controller.dart';
import 'constant.dart';
import 'position/controller/position_controller.dart';
import 'route.dart';
import 'src/class/cryptos_list.dart';

const cryptoListBox = 'cryptoList';
const portfolioListBox = 'portfolioList';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  Get
    ..put<AuthController>(AuthController())
    ..put<ZeroPositionController>(ZeroPositionController())
    ..put<WalletController>(WalletController());

  // initialization
  await Hive.initFlutter();

  // register the adapter to insert Portfolio in box
  Hive.registerAdapter(
    PortfolioHiveAdapter(),
  );
  // open the box dedicated to Portfolios
  await Hive.openBox<PortfolioHive>(portfolioListBox);

  // register the adapter to insert Crypto in box
  Hive.registerAdapter(
    CryptoHiveAdapter(),
  );
  // open the box dedicated to Cryptos
  final boxCrypto = await Hive.openBox<CryptoHive>(cryptoListBox);

  // retrieve the crypto list from the Json crypto.json (from coinmarketcap)
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

  // to debug : flutter run -d chrome --web-port=5000
  runApp(const CryptokenApp());
}

class CryptokenApp extends StatelessWidget {
  const CryptokenApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bgColor,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
            .apply(bodyColor: Colors.white),
        canvasColor: secondaryColor,
      ),
      initialRoute: '/',
      getPages: AppRoutes.routes,
    );
  }
}
