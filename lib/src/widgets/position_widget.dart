import 'dart:async' show Future;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:http/http.dart' as http;
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

Future<Price> fetchPrice(String symbol) async {
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

Future<Variation24> fetchVariation24(String symbol) async {
  if (symbol == 'INIT') {
    return Variation24(
      priceChange: 0,
      symbol: '',
      askPrice: 0,
      bidPrice: 0,
      count: 0,
      firstId: 0,
      highPrice: 0,
      lastId: 0,
      lastQty: 0,
      lowPrice: 0,
      lastPrice: 0,
      openPrice: 0,
      prevClosePrice: 0,
      priceChangePercent: 0,
      quoteVolume: 0,
      volume: 0,
      weightedAvgPrice: 0,
      closeTime: 0,
      openTime: 0,
    );
  }
  if (symbol == 'USDT') {
    return Variation24(
      priceChange: 0,
      symbol: 'USDT',
      askPrice: 0,
      bidPrice: 0,
      count: 0,
      firstId: 0,
      highPrice: 0,
      lastId: 0,
      lastQty: 0,
      lowPrice: 0,
      lastPrice: 0,
      openPrice: 0,
      prevClosePrice: 0,
      priceChangePercent: 0,
      quoteVolume: 0,
      volume: 0,
      weightedAvgPrice: 0,
      closeTime: 0,
      openTime: 0,
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

typedef DoubleCallback = void Function(double val);

class PositionWidget extends StatefulWidget {
  const PositionWidget({
    Key? key,
    required this.position,
    required this.onValuationUpdated,
    required this.onUnrealizedGainUpdated,
    this.portfolio,
  }) : super(key: key);

  final Position position;
  final Portfolio? portfolio;
  final DoubleCallback onValuationUpdated, onUnrealizedGainUpdated;

  @override
  _PositionsState createState() => _PositionsState();
}

class _PositionsState extends State<PositionWidget> {
  late Future<Price> futurePrice;
  late Future<Variation24> futureVariation24;

  @override
  void initState() {
    super.initState();

    futurePrice = fetchPrice(widget.position.token)
      ..then((value) =>
          widget.onValuationUpdated(value.price * widget.position.amount))
      ..then((value) => widget.onUnrealizedGainUpdated(
          (value.price - widget.position.averagePurchasePrice.toDouble()) *
              widget.position.amount.toDouble()));
    futureVariation24 = fetchVariation24(widget.position.token);
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
                future: _getIconFromCryptoHive(widget.position.token),
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
              title: Text(widget.position.token),
              trailing: FutureBuilder<Price>(
                future: futurePrice,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      _numberFormat.format(
                          snapshot.data!.price * widget.position.amount),
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.6),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    //print('${snapshot.error}');
                    return Text(
                      'N/A',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black.withOpacity(0.6),
                      ),
                    );
                  }

                  // By default, show a loading spinner.
                  return Text(
                    '-',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.6),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: _isLargeScreen(context)
                  ? const EdgeInsets.fromLTRB(16, 5, 16, 0)
                  : const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    _numberFormat.format(widget.position.amount),
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
                  FutureBuilder<Price>(
                    future: futurePrice,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          _numberFormat.format(snapshot.data!.price),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black.withOpacity(0.6),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        //print('${snapshot.error}');
                        return Text(
                          'N/A',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black.withOpacity(0.6),
                          ),
                        );
                      }

                      // By default, show a loading spinner.
                      return Text(
                        '-',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black.withOpacity(0.6),
                        ),
                      );
                    },
                  ),
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
                  FutureBuilder<Variation24>(
                    future: futureVariation24,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final _color = snapshot.data!.priceChangePercent < 0
                            ? debitColor
                            : creditColor;

                        return Text(
                          _numberFormat
                              .format(snapshot.data!.priceChangePercent),
                          style: TextStyle(
                            fontSize: 13,
                            color: _color,
                          ),
                        );
                      } else if (snapshot.hasError) {
                        //print('${snapshot.error}');
                        return Text(
                          'N/A',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black.withOpacity(0.6),
                          ),
                        );
                      }

                      // By default, show a loading spinner.
                      return Text(
                        '-',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black.withOpacity(0.6),
                        ),
                      );
                    },
                  ),
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
                    _numberFormat.format(widget.position.averagePurchasePrice),
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
                  FutureBuilder<Price>(
                    future: futurePrice,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final _unrealizedGain = (snapshot.data!.price -
                                widget.position.averagePurchasePrice
                                    .toDouble()) *
                            widget.position.amount.toDouble();
                        final _color =
                            _unrealizedGain < 0 ? debitColor : creditColor;

                        return Text(
                          _numberFormat.format(_unrealizedGain),
                          style: TextStyle(
                            fontSize: 13,
                            color: _color,
                          ),
                        );
                      } else if (snapshot.hasError) {
                        //print('${snapshot.error}');
                        return Text(
                          'N/A',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black.withOpacity(0.6),
                          ),
                        );
                      }

                      // By default, show a loading spinner.
                      return Text(
                        '-',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black.withOpacity(0.6),
                        ),
                      );
                    },
                  ),
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
            // const Divider(
            //   height: 14,
            // ),
            const Spacer(),
            ButtonBar(
              buttonHeight: 10,
              buttonMinWidth: 10,
              buttonPadding: const EdgeInsets.all(0),
              alignment: MainAxisAlignment.end,
              children: [
                // IconButton(
                //   iconSize: 20,
                //   padding: const EdgeInsets.all(6),
                //   icon: const Icon(Icons.refresh),
                //   color: Colors.black.withOpacity(0.6),
                //   onPressed: () {
                //     setState(() {
                //       futurePrice = fetchPrice(widget.position.token)
                //         ..then((value) => widget.onValuationUpdated(
                //             value.price * widget.position.amount))
                //         ..then((value) => widget.onUnrealizedGainUpdated(
                //             (value.price -
                //                     widget.position.averagePurchasePrice
                //                         .toDouble()) *
                //                 widget.position.amount.toDouble()));
                //       futureVariation24 =
                //           fetchVariation24(widget.position.token);
                //     });
                //   },
                // ),
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
                                  portfolio: widget.portfolio!,
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

  Future<String> _getIconFromCryptoHive(String symbol) async {
    final boxCrypto = await Hive.openBox<CryptoHive>(cryptoListBox);
    final CryptoHive cryptos = boxCrypto.get(symbol)!;

    return cryptos.logo;
  }
}
