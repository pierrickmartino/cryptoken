import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:web_dashboard/position/controller/position_controller.dart';
import 'package:web_dashboard/position/model/position_model.dart';
import 'package:web_dashboard/token/controller/token_controller.dart';

import '../../constant.dart';
import 'chart.dart';
import 'storage_info_card.dart';

final _numberFormat =
    NumberFormat.currency(locale: 'de_CH', symbol: '', decimalDigits: 2);

final _priceFormat = NumberFormat('#,##0.######', 'de_CH');

final _percentageFormat = NumberFormat('#,##0.##', 'de_CH');

class StorageDetails extends StatelessWidget {
  const StorageDetails({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PositionController positionController = PositionController.to;

    return GetBuilder<TokenController>(
        init: TokenController(),
        builder: (_tokenController) {
          return FutureBuilder<List<PositionModel>>(
              future: positionController.getFirestoreTopPosition(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final double total = _getTotalValuationInDouble(
                      snapshot.data!, _tokenController);

                  debugPrint('totalValuation : $total');

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
                          'Storage Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: defaultPadding),
                        Chart(
                          positionsList: snapshot.data!,
                        ),
                        Column(
                          children: List.generate(
                            snapshot.data!.length,
                            (index) => storageInfoCard(
                                snapshot.data![index], context, total),
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
              });
        });
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

Widget storageInfoCard(
    PositionModel positionModel, BuildContext context, double totalValuation) {
  return GetBuilder<TokenController>(
      init: TokenController(),
      builder: (_tokenController) {
        final double tokenPrice =
            _tokenController.tokenPriceGetX(positionModel.token);
        final double valuation = tokenPrice * positionModel.amount;
        final String updatedDate =
            _tokenController.tokenUpdatedDateGetX(positionModel.token);
        final double var24 =
            _tokenController.tokenVar24GetX(positionModel.token);
        final double var24Percent =
            _tokenController.tokenVar24PercentGetX(positionModel.token);

        final double unrealizedPercent =
            (tokenPrice - positionModel.averagePurchasePrice) /
                positionModel.averagePurchasePrice *
                100.0;
        final double unrealized =
            (tokenPrice - positionModel.averagePurchasePrice) *
                positionModel.amount;
        final double positionPercentage = valuation / totalValuation * 100.0;

        debugPrint('Var24Get : ${positionModel.token} -> $var24');
        debugPrint('PriceGetX : ${positionModel.token} -> $tokenPrice');

        return StorageInfoCard(
          svgSrc: 'icons/Documents.svg',
          title: positionModel.token,
          positionValuation: '${_numberFormat.format(valuation)} USD',
          positionAmount:
              'Amount: ${_numberFormat.format(positionModel.amount)}',
          positionPrice: 'Price: ${_priceFormat.format(tokenPrice)} USD',
          positionAveragePurchasePriceTitle: 'Avg. Purchase Price: ',
          positionAveragePurchasePrice:
              '${_priceFormat.format(positionModel.averagePurchasePrice)} USD',
          positionUnrealizedTitle: 'Unrealized: ',
          positionUnrealized:
              '${_numberFormat.format(unrealized)} USD / ${_percentageFormat.format(unrealizedPercent)}%',
          unrealizedColor: unrealized.isNegative ? Colors.red : Colors.green,
          positionRealizedTitle: 'Realized: ',
          positionRealized: '0 USD',
          updatedDateTitle: 'Last update: ',
          updatedDate: updatedDate,
          tokenVariation:
              '${_numberFormat.format(var24)} USD / ${_percentageFormat.format(var24Percent)}%',
          positionPercentage:
              '${_percentageFormat.format(positionPercentage)}%',
        );
      });
}
