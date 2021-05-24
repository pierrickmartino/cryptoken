// Copyright 2020, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../api/api.dart';
import '../app.dart';
import '../pages/transactions.dart';
import 'dialogs.dart';

final _numberFormat =
    NumberFormat.currency(locale: 'de_CH', symbol: '', decimalDigits: 2);

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
              const IconButton(
                icon: Icon(Icons.refresh),
                onPressed: null,
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

class _ListPositions extends StatelessWidget {
  const _ListPositions({Key? key, this.positions, this.portfolio})
      : super(key: key);

  final List<Position?>? positions;
  final Portfolio? portfolio;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 500,
          childAspectRatio: 2,
          // crossAxisSpacing: 20,
          mainAxisExtent: 300,
          // mainAxisSpacing: 5
        ),
        scrollDirection: Axis.horizontal,
        itemCount: positions!.length,
        itemBuilder: (BuildContext context, int index) {
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          positions![index]!.token,
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
                                              onPressed: () =>
                                                  Navigator.pop(context),
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
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 4),
                    child: Row(
                      children: [
                        Text(
                          _numberFormat.format(positions![index]!.amount),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
