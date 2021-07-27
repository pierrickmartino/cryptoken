import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;
import 'package:synchronized/extension.dart';
import 'package:web_dashboard/position/controller/position_controller.dart';
import 'package:web_dashboard/position/model/position_model.dart';
import 'package:web_dashboard/token/model/price.dart';
import 'package:web_dashboard/token/model/variation24.dart';

class TokenController extends GetxController {
  static TokenController get to => Get.find();

  @override
  Future<void> onInit() async {
    // the delay allow the application to load positions before tokens
    await Future<dynamic>.delayed(const Duration(seconds: 3));
    // then we can refresh token price and variation
    await _processRefreshData();
    super.onInit();
  }

  // Key,Value Map to store token prices
  Map<String, double> tokenPriceMap = <String, double>{};

  // Get the token price with GetX Map
  double tokenPriceGetX(String token) {
    return tokenPriceMap['price_$token'] ?? 0;
  }

  // Update token price in the map using GetX method
  // Important to use update() at the end to notify the update
  void setTokenPriceGetX(String token, double price) {
    tokenPriceMap
      ..putIfAbsent('price_$token', () {
        debugPrint('insert : price_$token');
        return price;
      })
      ..update('price_$token', (value) {
        debugPrint('update : price_$token -> $value');
        return price;
      });

    update();
  }

  Map<String, String> tokenUpdatedDateMap = <String, String>{};
  String tokenUpdatedDateGetX(String token) {
    return tokenUpdatedDateMap['date_$token'] ?? '';
  }

  void setTokenUpdatedDateGetX(String token) {
    tokenUpdatedDateMap
      ..putIfAbsent('date_$token', () {
        debugPrint('insert : date_$token');
        return intl.DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now());
      })
      ..update('date_$token', (value) {
        debugPrint(
            'update : date_$token -> ${intl.DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}');
        return intl.DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now());
      });

    update();
  }

  Map<String, double> tokenVar24Map = <String, double>{};
  double tokenVar24GetX(String token) {
    return tokenVar24Map['var24_$token'] ?? 0;
  }

  void setTokenVar24GetX(String token, double priceChange) {
    tokenVar24Map
      ..putIfAbsent('var24_$token', () {
        debugPrint('insert : var24_$token');
        return priceChange;
      })
      ..update('var24_$token', (value) {
        debugPrint('update : var24_$token -> $value');
        return priceChange;
      });

    update();
  }

  Map<String, double> tokenVar24PercentMap = <String, double>{};
  double tokenVar24PercentGetX(String token) {
    return tokenVar24PercentMap['var24%_$token'] ?? 0;
  }

  void setTokenVar24PercentGetX(String token, double priceChangePercent) {
    tokenVar24PercentMap
      ..putIfAbsent('var24%_$token', () {
        debugPrint('insert : var24%_$token');
        return priceChangePercent;
      })
      ..update('var24%_$token', (value) {
        debugPrint('update : var24%_$token -> $value');
        return priceChangePercent;
      });

    update();
  }

  /// Retrieve all the available positions for the user.
  /// Then for each of them, use of the Binance API to get price
  /// and variation 24h.
  /// Storage of the position/price and position/var
  Future<void> _processRefreshData() async {
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
        }
      });
    });
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
