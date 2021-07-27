import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:settings_ui/settings_ui.dart';
import 'package:synchronized/extension.dart';
import 'package:web_dashboard/position/controller/position_controller.dart';
import 'package:web_dashboard/position/model/position_model.dart';
import 'package:web_dashboard/token/controller/token_controller.dart';
import 'package:web_dashboard/token/model/price.dart';
import 'package:web_dashboard/token/model/variation24.dart';

class SettingsUI extends StatefulWidget {
  const SettingsUI({
    Key? key,
  }) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsUI> {
  bool lockInBackground = true;
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings UI')),
      body: buildSettingsList(),
    );
  }

  Widget buildSettingsList() {
    return GetBuilder<PositionController>(
      builder: (controller) => SettingsList(
        sections: [
          SettingsSection(
            title: 'Common',
            tiles: [
              SettingsTile.switchTile(
                title: 'Show position with zero amount',
                leading: const Icon(Icons.visibility),
                switchValue: controller.currentZeroPosition,
                onToggle: (bool value) {
                  //setState(() {
                  controller.setZeroPositionDisplay(value);
                  //});
                },
              ),
              SettingsTile(
                title: 'Refresh token data',
                leading: const Icon(Icons.refresh),
                onPressed: _processRefreshData,
              ),
              const SettingsTile(
                title: 'Environment',
                subtitle: 'Production',
                leading: Icon(Icons.cloud_queue),
              ),
            ],
          ),
          SettingsSection(
            title: 'Account',
            tiles: const [
              SettingsTile(title: 'Phone number', leading: Icon(Icons.phone)),
              SettingsTile(title: 'Email', leading: Icon(Icons.email)),
              SettingsTile(title: 'Sign out', leading: Icon(Icons.exit_to_app)),
            ],
          ),
          SettingsSection(
            title: 'Security',
            tiles: [
              SettingsTile.switchTile(
                title: 'Lock app in background',
                leading: const Icon(Icons.phonelink_lock),
                switchValue: lockInBackground,
                onToggle: (bool value) {
                  setState(() {
                    lockInBackground = value;
                    notificationsEnabled = value;
                  });
                },
              ),
              SettingsTile.switchTile(
                  title: 'Use fingerprint',
                  subtitle:
                      'Allow application to access stored fingerprint IDs.',
                  leading: const Icon(Icons.fingerprint),
                  onToggle: (bool value) {},
                  switchValue: false),
              SettingsTile.switchTile(
                title: 'Change password',
                leading: const Icon(Icons.lock),
                switchValue: true,
                onToggle: (bool value) {},
              ),
              SettingsTile.switchTile(
                title: 'Enable Notifications',
                enabled: notificationsEnabled,
                leading: const Icon(Icons.notifications_active),
                switchValue: true,
                onToggle: (value) {},
              ),
            ],
          ),
          // SettingsSection(
          //   title: 'Misc',
          //   tiles: [
          //     SettingsTile(
          //         title: 'Terms of Service', leading: Icon(Icons.description)),
          //     SettingsTile(
          //         title: 'Open source licenses',
          //         leading: Icon(Icons.collections_bookmark)),
          //   ],
          // ),
          CustomSection(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 22, bottom: 8),
                  child: Image.asset(
                    'images/settings.png',
                    height: 50,
                    width: 50,
                    color: const Color(0xFF777777),
                  ),
                ),
                const Text(
                  'Version: 1.0.5',
                  style: TextStyle(color: Color(0xFF777777)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Retrieve all the available positions for the user.
  /// Then for each of them, use of the Binance API to get price
  /// and variation 24h.
  /// Storage of the position/price and position/var
  Future<void> _processRefreshData(BuildContext context) async {
    late List<PositionModel> _positionList;
    final PositionController positionController = PositionController.to;
    final TokenController tokenController = TokenController.to;

    await synchronized(() async {
      await positionController.getFirestorePositionList().then((value) {
        _positionList = value;
        int _positionPriceCounter = _positionList.length;
        int _positionVar24Counter = _positionList.length;

        // for each position we need to fetch the last market price
        for (var i = 0; i < _positionList.length; i++) {
          final futurePrice = _fetchPrice(_positionList[i].token).then((value) {
            tokenController
              ..setTokenPriceGetX(
                  value.symbol.replaceFirst('USDT', ''), value.price)
              ..setTokenUpdatedDateGetX(value.symbol.replaceFirst('USDT', ''));
          }).whenComplete(() {
            _positionPriceCounter = _positionPriceCounter - 1;
          });

          final futureVariation24 = _fetchVariation24(_positionList[i].token)
              .then((value) {
            tokenController
              ..setTokenVar24GetX(
                  value.symbol.replaceFirst('USDT', ''), value.priceChange)
              ..setTokenVar24PercentGetX(value.symbol.replaceFirst('USDT', ''),
                  value.priceChangePercent);
          }).whenComplete(
                  () => _positionVar24Counter = _positionVar24Counter - 1);

          Future.wait([
            futurePrice,
            futureVariation24,
          ]).whenComplete(() {
            if (_positionPriceCounter == 0 && _positionVar24Counter == 0) {
              Get.snackbar<void>(
                  'Refresh', 'Token market data successfully udpdated !',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 5),
                  backgroundColor: Get.theme.snackBarTheme.backgroundColor,
                  colorText: Get.theme.snackBarTheme.actionTextColor);
            }
          });

          Get.back(result: 'success');
        }
      });
    });

    return;
  }

  Future<Price> _fetchPrice(String symbol) async {
    if (symbol == 'INIT') {
      return Price(price: 0, symbol: '');
    }
    if (symbol == 'USDT') {
      return Price(price: 1, symbol: 'USDT');
    }

    symbol = '${symbol}USDT';

    final response = await http.get(
      Uri.parse('https://api3.binance.com/api/v3/ticker/price?symbol=$symbol'),
    );

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return Price.fromJson(
        jsonDecode(response.body),
      );
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load price');
    }
  }

  Future<Variation24> _fetchVariation24(String symbol) async {
    if (symbol == 'INIT') {
      return Variation24(
        priceChange: 0,
        symbol: '',
        priceChangePercent: 0,
      );
    }
    if (symbol == 'USDT') {
      return Variation24(
        priceChange: 0,
        symbol: 'USDT',
        priceChangePercent: 0,
      );
    }

    symbol = '${symbol}USDT';

    final response = await http.get(
      Uri.parse('https://api3.binance.com/api/v3/ticker/24hr?symbol=$symbol'),
    );

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.

      return Variation24.fromJson(
        jsonDecode(response.body),
      );
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load price');
    }
  }
}
