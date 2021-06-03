import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../api/api.dart';
import 'dialogs.dart';
import 'position_widget.dart';

const settingsBox = 'settings';

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
    return ValueListenableBuilder(
        valueListenable: Hive.box(settingsBox).listenable(),
        builder: (listenerContext, Box<dynamic> box, listenerWidget) {
          final showZeroPosition =
              box.get('showZeroPosition', defaultValue: false);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Row(
                  children: [
                    Text(
                      portfolio.name,
                      style: const TextStyle(color: Color(0xff3A6EA5)),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add),
                      color: const Color(0xff3A6EA5),
                      onPressed: () {
                        showDialog<NewTransactionDialog>(
                          context: context,
                          builder: (context) => NewTransactionDialog(
                            selectedPortfolio: portfolio,
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      color: const Color(0xff3A6EA5),
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
                    const Text('Valuation'),
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
                                portfolio, //TODO : Temporary as we need to find transactions based on positions
                            positions: showZeroPosition
                                ? snapshot.data!
                                : snapshot.data!
                                    .where((Position? element) =>
                                        element!.amount > 0 ||
                                        element.amount < 0)
                                    .toList(),
                            //)
                            // snapshot.data!
                            //     .where((Position? element) =>
                            //         element!.amount > 0 || element.amount < 0)
                            //     .toList(),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        });
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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 900,
          //childAspectRatio: 1,
          // crossAxisSpacing: 20,
          mainAxisExtent: 270,
          mainAxisSpacing: 5,
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
