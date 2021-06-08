import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../api/api.dart';
import 'dialogs.dart';
import 'position_widget.dart';

const settingsBox = 'settings';
const portfolioListBox = 'portfolioList';
const debitColor = Color(0xffef476f);
const creditColor = Color(0xff06d6a0);

final _numberFormat =
    NumberFormat.currency(locale: 'de_CH', symbol: '', decimalDigits: 2);

bool _isLargeScreen(BuildContext context) {
  return MediaQuery.of(context).size.width > 960.0;
}

class PortfolioWidget extends StatefulWidget {
  const PortfolioWidget({
    Key? key,
    required this.portfolio,
    required this.api,
  }) : super(key: key);

  final Portfolio portfolio;
  final DashboardApi api;

  @override
  _PortfolioWidgetState createState() => _PortfolioWidgetState();
}

class _PortfolioWidgetState extends State<PortfolioWidget> {
  double _valuation = 0, _unrealizedGain = 0;
  set valuation(double value) => setState(() => _valuation = value);
  set unrealizedGain(double value) => setState(() => _unrealizedGain = value);

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
                      widget.portfolio.name,
                      style: const TextStyle(color: Color(0xff3A6EA5)),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add),
                      color: const Color(0xff3A6EA5),
                      onPressed: () {
                        if (_isLargeScreen(context)) {
                          showDialog<NewTransactionDialog>(
                            context: context,
                            builder: (context) => NewTransactionDialog(
                              selectedPortfolio: widget.portfolio,
                            ),
                          );
                        } else {
                          showGeneralDialog<NewTransactionDialog>(
                            context: context,
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    NewTransactionDialog(
                              selectedPortfolio: widget.portfolio,
                            ),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      color: const Color(0xff3A6EA5),
                      onPressed: () {
                        showDialog<EditPortfolioDialog>(
                          context: context,
                          builder: (context) {
                            return EditPortfolioDialog(
                              portfolio: widget.portfolio,
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4, right: 4),
                child: Container(
                  height: 50,
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _numberFormat.format(_valuation),
                              ),
                              Text(
                                'Valuation',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black.withOpacity(0.6),
                                ),
                              ),
                              SizedBox(
                                width: _isLargeScreen(context) ? 50 : 20,
                              ),
                              Text(
                                _numberFormat.format(_unrealizedGain),
                                style: TextStyle(
                                  color: _unrealizedGain < 0
                                      ? debitColor
                                      : creditColor,
                                ),
                              ),
                              Text(
                                _isLargeScreen(context)
                                    ? 'UnrealizedGain'
                                    : 'Unrealized',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Padding(
              //   padding: const EdgeInsets.only(top: 4, left: 10, right: 10),
              //   child: Row(
              //     children: [
              //       Text(
              //         _numberFormat.format(0),
              //       ),
              //       const Spacer(),
              //       const Text('24h Var.'),
              //     ],
              //   ),
              // ),
              // Padding(
              //   padding: const EdgeInsets.only(top: 4, left: 10, right: 10),
              //   child: Row(
              //     children: [
              //       Text(
              //         _numberFormat.format(0),
              //       ),
              //       const Spacer(),
              //       const Text('RealizedGain'),
              //     ],
              //   ),
              // ),

              // const SizedBox(
              //   height: 10,
              // ),
              Expanded(
                // Load the initial snapshot using a FutureBuilder, and subscribe to
                // additional updates with a StreamBuilder.
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: FutureBuilder<List<Position>>(
                    future: widget.api.positions.list(widget.portfolio.id),
                    builder: (context, futureSnapshot) {
                      if (!futureSnapshot.hasData) {
                        return _buildLoadingIndicator();
                      }
                      return StreamBuilder<List<Position?>?>(
                        initialData: futureSnapshot.data,
                        stream:
                            widget.api.positions.subscribe(widget.portfolio.id),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return _buildLoadingIndicator();
                          }

                          return _ListPositions(
                            portfolio: widget
                                .portfolio, //TODO : Temporary as we need to find transactions based on positions
                            positions: showZeroPosition
                                ? snapshot.data!
                                : snapshot.data!
                                    .where((Position? element) =>
                                        element!.amount > 0 ||
                                        element.amount < 0)
                                    .toList(),
                            onValuationUpdated: (val) {
                              setState(() {
                                _valuation = _valuation + val;
                              });
                            },
                            onUnrealizedGainUpdated: (val) {
                              setState(() {
                                _unrealizedGain = _unrealizedGain + val;
                              });
                            },
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
  const _ListPositions({
    Key? key,
    this.positions,
    this.portfolio,
    required this.onValuationUpdated,
    required this.onUnrealizedGainUpdated,
  }) : super(key: key);

  final List<Position?>? positions;
  final Portfolio? portfolio;
  final DoubleCallback onValuationUpdated, onUnrealizedGainUpdated;

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
          maxCrossAxisExtent: 500,
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
            onValuationUpdated: (val) {
              setState(() {
                widget.onValuationUpdated(val);
              });
            },
            onUnrealizedGainUpdated: (val) {
              setState(() {
                widget.onUnrealizedGainUpdated(val);
              });
            },
          );
        });
  }
}
