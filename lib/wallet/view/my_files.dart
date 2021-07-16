import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:synchronized/extension.dart';
import 'package:web_dashboard/position/controller/position_controller.dart';
import 'package:web_dashboard/position/model/position_model.dart';
import 'package:web_dashboard/token/controller/token_controller.dart';
import 'package:web_dashboard/token/model/price.dart';
import 'package:web_dashboard/token/model/variation24.dart';
import 'package:web_dashboard/wallet/controller/wallet_controller.dart';
import 'package:web_dashboard/wallet/model/wallet_model.dart';

import '../../constant.dart';

import '../../src/responsive.dart';
import 'file_info_card.dart';
import 'new_wallet.dart';

class MyFiles extends StatelessWidget {
  const MyFiles({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Files',
              style: Theme.of(context).textTheme.subtitle1,
            ),
            Wrap(
              spacing: 5,
              children: [
                ElevatedButton.icon(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: defaultPadding * 1.5,
                      vertical: defaultPadding /
                          (Responsive.isMobile(context) ? 2 : 1),
                    ),
                  ),
                  onPressed: () {
                    showDialog<NewWalletDialog>(
                      context: context,
                      builder: (context) => const NewWalletDialog(),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add New'),
                ),
                IconButton(
                  onPressed: _processRefreshData,
                  icon: const Icon(Icons.refresh),
                ),
                const IconButton(
                  onPressed: null,
                  icon: Icon(Icons.settings),
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: defaultPadding),
        Responsive(
          mobile: FileInfoCardGridView(
            crossAxisCount: _size.width < 650 ? 2 : 4,
            childAspectRatio: _size.width < 650 ? 1.3 : 1,
          ),
          tablet: const FileInfoCardGridView(),
          desktop: FileInfoCardGridView(
            childAspectRatio: _size.width < 1400 ? 1.1 : 1.4,
          ),
        ),
      ],
    );
  }

  /// Retrieve all the available positions for the user.
  /// Then for each of them, use of the Binance API to get price
  /// and variation 24h.
  /// Storage of the position/price and position/var
  Future<void> _processRefreshData() async {
    late List<PositionModel> _positionList;
    // List<Price> priceList = <Price>[];
    // List<Variation24> variation24List = <Variation24>[];
    // double valuation = 0;
    // double unrealizedGain = 0;
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
              ..setTokenPrice(
                  value.symbol.replaceFirst('USDT', ''), value.price)
              ..setTokenUpdatedDate(value.symbol.replaceFirst('USDT', ''));
          }).whenComplete(() {
            _positionPriceCounter = _positionPriceCounter - 1;
          });

          final futureVariation24 = _fetchVariation24(_positionList[i].token)
              .then((value) {
            tokenController
              ..setTokenVar24(
                  value.symbol.replaceFirst('USDT', ''), value.priceChange)
              ..setTokenVar24Percent(value.symbol.replaceFirst('USDT', ''),
                  value.priceChangePercent);
          }).whenComplete(
                  () => _positionVar24Counter = _positionVar24Counter - 1);

          Future.wait([
            futurePrice,
            futureVariation24,
          ]).whenComplete(() {
            if (_positionPriceCounter == 0 && _positionVar24Counter == 0) {
              Get.snackbar<void>(
                  'Refresh', 'Token market date successfully udpdated !',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 5),
                  backgroundColor: Get.theme.snackBarTheme.backgroundColor,
                  colorText: Get.theme.snackBarTheme.actionTextColor);
            }
          });
        }
      });
    });

    return;
  }
}

class FileInfoCardGridView extends StatelessWidget {
  const FileInfoCardGridView({
    Key? key,
    this.crossAxisCount = 4,
    this.childAspectRatio = 1,
  }) : super(key: key);

  final int crossAxisCount;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    final WalletController walletController = WalletController.to;

    return StreamBuilder<List<WalletModel>>(
      stream: walletController.streamFirestoreWalletList(),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: snapshot.data!.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: defaultPadding,
            mainAxisSpacing: defaultPadding,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, index) =>
              FileInfoCard(wallet: snapshot.data![index]),
        );
      },
    );
  }
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
