// Copyright 2020, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;

import '../api/api.dart';
import 'dialogs.dart';
import 'position_widget.dart';

final _numberFormat =
    NumberFormat.currency(locale: 'de_CH', symbol: '', decimalDigits: 2);

Future<Price> fetchPrice(String symbol) async {
  if (symbol == 'INIT') {
    symbol = 'BTCUSDT';
  } else {
    symbol = '${symbol}USDT';
  }

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

class PortfolioWidget extends StatelessWidget {
  const PortfolioWidget({
    Key? key,
    required this.portfolio,
    required this.api,
  }) : super(key: key);

  final Portfolio portfolio;
  final DashboardApi api;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: Row(
            children: [
              Text(portfolio.name),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  showDialog<NewTransactionDialog>(
                    context: context,
                    builder: (context) => const NewTransactionDialog(),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  showDialog<EditPortfolioDialog>(
                    context: context,
                    builder: (context) {
                      return EditPortfolioDialog(portfolio: portfolio);
                    },
                  );
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4, left: 10, right: 10),
          child: Row(
            children: [
              Text(
                _numberFormat.format(0),
              ),
              const Spacer(),
              const Text('24h Var.'),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4, left: 10, right: 10),
          child: Row(
            children: [
              Text(
                _numberFormat.format(0),
              ),
              const Spacer(),
              const Text('RealizedGain'),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4, left: 10, right: 10),
          child: Row(
            children: [
              Text(
                _numberFormat.format(0),
              ),
              const Spacer(),
              const Text('UnrealizedGain'),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Expanded(
          // Load the initial snapshot using a FutureBuilder, and subscribe to
          // additional updates with a StreamBuilder.
          child: Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: FutureBuilder<List<Position>>(
              future: api.positions.list(portfolio.id),
              builder: (context, futureSnapshot) {
                if (!futureSnapshot.hasData) {
                  return _buildLoadingIndicator();
                }
                return StreamBuilder<List<Position?>?>(
                  initialData: futureSnapshot.data,
                  stream: api.positions.subscribe(portfolio.id),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return _buildLoadingIndicator();
                    }
                    return _ListPositions(
                      portfolio:
                          portfolio, // TODO : Temporary as we need to find transactions based on positions
                      positions: snapshot.data,
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ListPositions extends StatefulWidget {
  const _ListPositions({Key? key, this.positions, this.portfolio})
      : super(key: key);

  final List<Position?>? positions;
  final Portfolio? portfolio;

  @override
  _ListPositionsState createState() => _ListPositionsState();
}

class _ListPositionsState extends State<_ListPositions> {
  late Future<Price> futurePrice;

  @override
  void initState() {
    super.initState();
    futurePrice = fetchPrice('INIT');
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 500,
          childAspectRatio: 2,
          // crossAxisSpacing: 20,
          mainAxisExtent: 250,
          // mainAxisSpacing: 5
        ),
        scrollDirection: Axis.horizontal,
        itemCount: widget.positions!.length,
        itemBuilder: (BuildContext context, int index) {
          return PositionWidget(
            position: widget.positions![index]!,
            portfolio: widget.portfolio,
          );
        });
  }
}
