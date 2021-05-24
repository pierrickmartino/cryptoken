// Copyright 2020, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:http/http.dart' as http;

import '../api/api.dart';
import '../app.dart';
import '../pages/transactions.dart';

final _numberFormat =
    NumberFormat.currency(locale: 'de_CH', symbol: '', decimalDigits: 2);

Future<Price> fetchPrice(String symbol) async {
  if (symbol == 'INIT') {
    return Price(price: 0, symbol: '');
  }
  if (symbol == 'USDT') {
    return Price(price: 1, symbol: 'USDT');
  }

  symbol = '${symbol}USDT';

  final response = await http.get(
      Uri.parse('https://api3.binance.com/api/v3/ticker/price?symbol=$symbol'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Price.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load price');
  }
}

class Price {
  Price({
    required this.symbol,
    required this.price,
  });

  factory Price.fromJson(Map<String, dynamic> json) {
    return Price(
      symbol: json['symbol'],
      price: double.parse(json['price']),
    );
  }

  final String symbol;
  final double price;
}

class PositionWidget extends StatefulWidget {
  const PositionWidget({
    Key? key,
    required this.position,
    this.portfolio,
  }) : super(key: key);

  final Position position;
  final Portfolio? portfolio;

  @override
  _PositionsState createState() => _PositionsState();
}

class _PositionsState extends State<PositionWidget> {
  late Future<Price> futurePrice;

  @override
  void initState() {
    super.initState();
    futurePrice = fetchPrice('INIT');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      child: Card(
        color: Colors.cyan,
        elevation: 2,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 4),
              child: Row(
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.position.token,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      setState(() {
                        futurePrice = fetchPrice(widget.position.token);
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.list),
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
                                      const Text('Transactions'),
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
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 10),
              child: Row(
                children: [
                  Text(
                    _numberFormat.format(widget.position.amount),
                  ),
                  const Spacer(),
                  const Text('Amount'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 10, right: 10),
              child: Row(
                children: [
                  FutureBuilder<Price>(
                    future: futurePrice,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(_numberFormat.format(snapshot.data!.price));
                      } else if (snapshot.hasError) {
                        print('${snapshot.error}');
                        return Text('${snapshot.error}');
                      }

                      // By default, show a loading spinner.
                      return const Text('-');
                    },
                  ),
                  const Spacer(),
                  const Text('MarketPrice'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
