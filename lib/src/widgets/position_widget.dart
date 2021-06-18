import 'dart:async' show Future;

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:web_dashboard/src/class/price.dart';
import 'package:web_dashboard/src/class/variation24.dart';
import 'package:web_dashboard/src/hive/crypto_hive.dart';

import '../api/api.dart';
import '../app.dart';
import '../pages/transactions.dart';

const cryptoListBox = 'cryptoList';
const debitColor = Color(0xffef476f);
const creditColor = Color(0xff06d6a0);

final _numberFormat =
    NumberFormat.currency(locale: 'de_CH', symbol: '', decimalDigits: 2);

bool _isLargeScreen(BuildContext context) {
  return MediaQuery.of(context).size.width > 960.0;
}

class PositionWidget extends StatelessWidget {
  const PositionWidget({
    Key? key,
    required this.position,
    this.portfolio,
    required this.positionPrice,
    this.positionVariation24,
  }) : super(key: key);

  final Position position;
  final Portfolio? portfolio;
  final Price positionPrice;
  final Variation24? positionVariation24;

  Widget _getPositionUnrealizedGain() {
    final _unrealizedGain =
        (positionPrice.price - position.averagePurchasePrice.toDouble()) *
            position.amount.toDouble();
    final _color = _unrealizedGain < 0 ? debitColor : creditColor;

    return Text(
      _numberFormat.format(_unrealizedGain),
      style: TextStyle(
        fontSize: 13,
        color: _color,
      ),
    );
  }

  Widget _getPositionPrice() {
    return Text(
      _numberFormat.format(positionPrice.price),
      style: TextStyle(
        fontSize: 13,
        color: Colors.black.withOpacity(0.6),
      ),
    );
  }

  Widget _getPositionValuation() {
    return Text(
      _numberFormat.format(positionPrice.price * position.amount),
      style: TextStyle(
        color: Colors.black.withOpacity(0.6),
      ),
    );
  }

  Widget _getPositionVariation24() {
    final _color =
        positionVariation24!.priceChangePercent < 0 ? debitColor : creditColor;

    return Text(
      _numberFormat.format(positionVariation24!.priceChangePercent),
      style: TextStyle(
        fontSize: 13,
        color: _color,
      ),
    );
  }

  Future<String> _getIconFromCryptoHive(String symbol) async {
    final boxCrypto = await Hive.openBox<CryptoHive>(cryptoListBox);
    final CryptoHive cryptos = boxCrypto.get(symbol)!;

    return cryptos.logo;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: Card(
        clipBehavior: Clip.antiAlias,
        //color: Colors.white,
        //elevation: 1,
        child: Column(
          children: [
            ListTile(
              leading: FutureBuilder(
                future: _getIconFromCryptoHive(position.token),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Image.network(
                      snapshot.data.toString(),
                      height: 28,
                    );
                  } else {
                    return const Icon(Icons.all_inclusive);
                  }
                },
              ),
              title: Text(position.token),
              trailing: _getPositionValuation(),
            ),
            Padding(
              padding: _isLargeScreen(context)
                  ? const EdgeInsets.fromLTRB(16, 5, 16, 0)
                  : const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    _numberFormat.format(position.amount),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Amount',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: _isLargeScreen(context)
                  ? const EdgeInsets.fromLTRB(16, 5, 16, 0)
                  : const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _getPositionPrice(),
                  const Spacer(),
                  Text(
                    _isLargeScreen(context) ? 'MarketPrice' : 'MarketPr.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: _isLargeScreen(context)
                  ? const EdgeInsets.fromLTRB(16, 5, 16, 0)
                  : const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _getPositionVariation24(),
                  const Spacer(),
                  Text(
                    '24hr Var.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: _isLargeScreen(context)
                  ? const EdgeInsets.fromLTRB(16, 5, 16, 0)
                  : const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    _numberFormat.format(position.averagePurchasePrice),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _isLargeScreen(context)
                        ? 'AvgPurchasePrice'
                        : 'AvgPurchPr.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: _isLargeScreen(context)
                  ? const EdgeInsets.fromLTRB(16, 5, 16, 0)
                  : const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    _numberFormat.format(0),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _isLargeScreen(context) ? 'RealizedGain' : 'Realized',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: _isLargeScreen(context)
                  ? const EdgeInsets.fromLTRB(16, 5, 16, 0)
                  : const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _getPositionUnrealizedGain(),
                  const Spacer(),
                  Text(
                    _isLargeScreen(context) ? 'UnrealizedGain' : 'Unrealized',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            ButtonBar(
              buttonHeight: 10,
              buttonMinWidth: 10,
              buttonPadding: const EdgeInsets.all(0),
              alignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  iconSize: 20,
                  padding: const EdgeInsets.all(6),
                  icon: const Icon(Icons.list),
                  color: Colors.black.withOpacity(0.6),
                  onPressed: () {
                    final appState =
                        Provider.of<AppState>(context, listen: false);

                    showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          height: MediaQuery.of(context).size.height,
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                  children: [
                                    Text(
                                      'Transactions',
                                      style:
                                          Theme.of(context).textTheme.headline6,
                                    ),
                                    const Spacer(),
                                    OutlinedButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Close'),
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                child: TransactionsList(
                                  portfolio: portfolio!,
                                  api: appState.api.transactions,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
