import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:web_dashboard/position/controller/position_controller.dart';
import 'package:web_dashboard/position/model/position_model.dart';
import 'package:web_dashboard/token/controller/token_controller.dart';

import '../../constant.dart';
import 'chart.dart';
import 'position_info_card.dart';

final _numberFormat =
    NumberFormat.currency(locale: 'de_CH', symbol: '', decimalDigits: 2);
final _priceFormat = NumberFormat('#,##0.######', 'de_CH');
final _percentageFormat = NumberFormat('#,##0.##', 'de_CH');

var logger = Logger(printer: PrettyPrinter());
var loggerNoStack = Logger(printer: PrettyPrinter(methodCount: 0));

class PositionDetails extends StatelessWidget {
  const PositionDetails({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PositionController positionController = PositionController.to;

    return GetBuilder<TokenController>(
        init: TokenController(),
        builder: (_tokenController) {
          return FutureBuilder<List<PositionModel>>(
              future: positionController.getFirestorePositionList(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  final double total = _getTotalValuationInDouble(
                      snapshot.data!, _tokenController);
                  final bool existZeroPrice =
                      _existZeroPrice(snapshot.data!, _tokenController);

                  loggerNoStack.i('PositionDetails');
                  Logger(printer: SimplePrinter())
                      .v('Total valuation : ${_numberFormat.format(total)}');
                  Logger(printer: SimplePrinter()).v(
                      'Length of the list of Positions : ${snapshot.data!.length}');
                  Logger(printer: SimplePrinter())
                      .v('Exist a token with zero price : $existZeroPrice');

                  if (!existZeroPrice) {
                    snapshot.data!.sort((b, a) =>
                        (_tokenController.tokenPriceGetX(a.token) * a.amount)
                            .compareTo(
                                _tokenController.tokenPriceGetX(b.token) *
                                    b.amount));

                    /* TODO : Récupérer le paramètre pour savoir si l'on masque les positions à 0 */
                    List<PositionModel> positionsList = snapshot.data!
                      ..removeWhere((element) => element.amount == 0);

                    if (positionsList.length > 4) {
                      positionsList = _aggregatePositions(
                          positionsList, _tokenController, 4);

                      /* Mise à jour de la couleur pour chaque position */
                      positionsList[0].color = primaryColor.value;
                      positionsList[1].color = const Color(0xFF26E5FF).value;
                      positionsList[2].color = const Color(0xFFFFCF26).value;
                      positionsList[3].color = const Color(0xFFEE2727).value;
                      // positionsList[4].color =
                      //     primaryColor.withOpacity(0.1).value;
                    }

                    return Container(
                      padding: const EdgeInsets.all(defaultPadding),
                      decoration: const BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Position Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: defaultPadding),
                          Chart(
                            positionsList: positionsList,
                            totalAmount: total,
                          ),
                          Column(
                            children: List.generate(
                              snapshot.data!.length,
                              (index) => positionInfoCard(
                                  positionsList[index], context, total),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              });
        });
  }

  List<PositionModel> _aggregatePositions(List<PositionModel> positionsList,
      TokenController _tokenController, int groupingCondition) {
    /* On ne garde que les [groupingCondition] premières positions pour regrouper ensuite les autres */
    final List<PositionModel> positionsFirst =
        positionsList.sublist(0, groupingCondition);
    /* Les autres sont donc récupérées dans une liste pour être ensuite agrégés */
    final List<PositionModel> positionsLast =
        positionsList.sublist(groupingCondition);

    double totalOtherValuation = 0;

    for (final element in positionsLast) {
      totalOtherValuation = totalOtherValuation +
          (element.amount * _tokenController.tokenPriceGetX(element.token));
    }

    final PositionModel positionLast = PositionModel(
      walletId: '',
      token: 'OTHER',
      tokenName: 'Other',
      amount: totalOtherValuation,
      averageCost: 0,
      purchaseAmount: 0,
      sellAmount: 0,
      realizedPnL: 0,
      cost: 0,
      time: DateTime.now(),
      color: primaryColor.withOpacity(0.1).value,
    );

    positionsList
      ..clear()
      ..addAll(positionsFirst)
      ..add(positionLast);

    return positionsList;
  }

  bool _existZeroPrice(
      List<PositionModel> positionsList, TokenController _tokenController) {
    bool existZeroPrice = false;

    for (final element in positionsList) {
      if (_tokenController.tokenPriceGetX(element.token) == 0) {
        existZeroPrice = true;
      }
    }
    return existZeroPrice;
  }

  double _getTotalValuationInDouble(
      List<PositionModel> positionsList, TokenController _tokenController) {
    double totalValuation = 0;

    for (final element in positionsList) {
      totalValuation = totalValuation +
          (element.amount * _tokenController.tokenPriceGetX(element.token));
    }
    return totalValuation;
  }
}

Widget positionInfoCard(
    PositionModel positionModel, BuildContext context, double totalValuation) {
  return GetBuilder<TokenController>(
      init: TokenController(),
      builder: (_tokenController) {
        String positionToken = '';
        if (positionModel.token == 'OTHER') {
          positionToken = 'USDT';
        } else {
          positionToken = positionModel.token;
        }
        final double tokenPrice =
            _tokenController.tokenPriceGetX(positionToken);
        final double valuation = tokenPrice * positionModel.amount;
        final String updatedDate =
            _tokenController.tokenUpdatedDateGetX(positionToken);
        final double var24 = _tokenController.tokenVar24GetX(positionToken);
        final double var24Percent =
            _tokenController.tokenVar24PercentGetX(positionToken);

        final double unrealizedPercent =
            (tokenPrice - positionModel.averageCost) /
                positionModel.averageCost *
                100.0;
        final double unrealized =
            (tokenPrice - positionModel.averageCost) * positionModel.amount;
        final double positionPercentage = valuation / totalValuation * 100.0;

        final double realized = positionModel.realizedPnL;

        loggerNoStack.i('PositionInfoCard - ${positionModel.token}');
        Logger(printer: SimplePrinter()).v('Variation sur 24h : $var24');
        Logger(printer: SimplePrinter()).v('Prix : $tokenPrice');

        return PositionInfoCard(
          svgSrc: 'icons/Documents.svg',
          title: positionModel.token,
          positionName: positionModel.tokenName,
          positionValuation: '${_numberFormat.format(valuation)} \$',
          positionAmount:
              'Amount: ${_numberFormat.format(positionModel.amount)}',
          positionPrice: 'Price: ${_priceFormat.format(tokenPrice)} \$',
          positionAverageCostTitle: 'Avg. Cost: ',
          positionAverageCost:
              '${_priceFormat.format(positionModel.averageCost)} \$',
          positionUnrealizedTitle: 'Unrealized: ',
          positionUnrealized:
              '${_numberFormat.format(unrealized)} \$ / ${_percentageFormat.format(unrealizedPercent)}%',
          unrealizedColor: unrealized.isNegative ? Colors.red : Colors.green,
          positionRealizedTitle: 'Realized: ',
          positionRealized: '${_numberFormat.format(realized)} \$',
          updatedDateTitle: 'Last update: ',
          updatedDate: updatedDate,
          tokenVariation:
              '${_numberFormat.format(var24)} \$ / ${_percentageFormat.format(var24Percent)}%',
          positionPercentage:
              '${_percentageFormat.format(positionPercentage)}%',
        );
      });
}
