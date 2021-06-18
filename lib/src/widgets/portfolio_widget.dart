import 'dart:async' show Future;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:web_dashboard/src/class/price.dart';
import 'package:web_dashboard/src/class/variation24.dart';
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
  late List<Position> _positionList;
  List<Price> priceList = <Price>[];
  List<Variation24> variation24List = <Variation24>[];
  double valuation = 0;
  double unrealizedGain = 0;
  bool _loading = true;

  //GlobalKey<PositionWidgetState> _keyChild1 = GlobalKey();

  @override
  void initState() {
    _initList();
    _getTaskAsync();
    super.initState();
  }

  void _initList() {
    priceList.add(Price(symbol: 'BTCUSDT', price: 0));
    variation24List.add(
        Variation24(symbol: 'BTCUSDT', priceChange: 0, priceChangePercent: 0));
  }

  void _getTaskAsync() {
    widget.api.positions.list(widget.portfolio.id).then((value) {
      _positionList = value;
      int _positionPriceCounter = _positionList.length;
      int _positionVar24Counter = _positionList.length;

      // for each position we need to fetch the last market price
      for (var i = 0; i < _positionList.length; i++) {
        final futurePrice = _fetchPrice(_positionList[i].token).then((value) {
          priceList.add(value);
          valuation = valuation + (value.price * _positionList[i].amount);
          unrealizedGain = unrealizedGain +
              ((value.price - _positionList[i].averagePurchasePrice) *
                  _positionList[i].amount);
        }).whenComplete(() {
          _positionPriceCounter = _positionPriceCounter - 1;
        });

        final futureVariation24 = _fetchVariation24(_positionList[i].token)
            .then((value) {
          variation24List.add(value);
        }).whenComplete(
                () => _positionVar24Counter = _positionVar24Counter - 1);

        Future.wait([
          futurePrice,
          futureVariation24,
        ]).whenComplete(() {
          if (_positionPriceCounter == 0 && _positionVar24Counter == 0) {
            setState(() {
              _loading = false;
            });
          }
        });
      }
    });
  }

  Widget _getPositions(bool loading, bool showZeroPosition,
      List<Price> priceList, List<Variation24> variation24List) {
    if (loading) {
      return _buildLoadingIndicator();
    } else {
      return _ListPositions(
          portfolio: widget
              .portfolio, //TODO : Temporary as we need to find transactions based on positions
          positions: showZeroPosition
              ? _positionList
              : _positionList
                  .where((Position? element) =>
                      element!.amount > 0 || element.amount < 0)
                  .toList(),
          priceList: priceList,
          variation24List: variation24List);
    }
  }

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
                    // IconButton(
                    //   icon: const Icon(Icons.refresh_rounded),
                    //   color: const Color(0xff3A6EA5),
                    //   onPressed: () {
                    //     setState(() {});
                    //   },
                    // ),
                    IconButton(
                      icon: const Icon(Icons.add_rounded),
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
                      icon: const Icon(Icons.settings_rounded),
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
                                _numberFormat.format(valuation),
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
                                _numberFormat.format(unrealizedGain),
                                style: TextStyle(
                                  color: unrealizedGain < 0
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

              Expanded(
                // Load the initial snapshot using a FutureBuilder, and subscribe to
                // additional updates with a StreamBuilder.
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: _getPositions(
                    _loading,
                    showZeroPosition,
                    priceList,
                    variation24List,
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

class _ListPositions extends StatelessWidget {
  const _ListPositions({
    Key? key,
    this.positions,
    this.portfolio,
    required this.priceList,
    required this.variation24List,
  }) : super(key: key);

  final List<Position?>? positions;
  final Portfolio? portfolio;
  final List<Price> priceList;
  final List<Variation24> variation24List;

  @override
  Widget build(BuildContext context) {
    return GridView.extent(
      scrollDirection: Axis.horizontal,
      primary: false,
      mainAxisSpacing: 5,
      maxCrossAxisExtent: 500,
      children: getPositionsList(priceList, variation24List),
    );
  }

  List<Widget> getPositionsList(
      List<Price> priceList, List<Variation24> variation24List) {
    final List<Widget> positionsList = [];
    for (var index = 0; index < positions!.length; index++) {
      // priceList.forEach((element) {
      //   print('${element.symbol} -> ${element.price.toString()}');
      // });
      // priceList
      //     .lastWhere(
      //         (element) => element.symbol == '${positions![index]!.token}USDT')
      //     .forEach((element) {
      //   print('${element.symbol} -> ${element.price.toString()}');
      // });

      // print(priceList
      //     .where((element) => element.symbol == positions![index]!.token));

      positionsList.add(PositionWidget(
          position: positions![index]!,
          portfolio: portfolio,
          positionPrice: priceList.lastWhere(
            (Price element) =>
                element.symbol == '${positions![index]!.token}USDT',
            orElse: () => Price(symbol: 'BTCUSD', price: 1),
          ),
          positionVariation24: variation24List.lastWhere(
            (Variation24 element) =>
                element.symbol == '${positions![index]!.token}USDT',
            orElse: () => Variation24(
                symbol: 'BTCUSD', priceChange: 1, priceChangePercent: 1),
          )));
    }

    return positionsList;
  }
}
