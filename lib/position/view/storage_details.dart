import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:web_dashboard/position/controller/position_controller.dart';
import 'package:web_dashboard/position/model/position_model.dart';
import 'package:web_dashboard/src/responsive.dart';
import 'package:web_dashboard/token/controller/token_controller.dart';

import '../../constant.dart';
import 'chart.dart';
import 'storage_info_card.dart';

final _numberFormat =
    NumberFormat.currency(locale: 'de_CH', symbol: '', decimalDigits: 2);

final _priceFormat =
    NumberFormat.currency(locale: 'de_CH', symbol: '', decimalDigits: 5);

class StorageDetails extends StatelessWidget {
  const StorageDetails({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PositionController positionController = PositionController.to;

    return FutureBuilder<List<PositionModel>>(
        future: positionController.getFirestoreTopPosition(),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
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
                    (index) => storageInfoCard(snapshot.data![index], context),
                  ),
                ),
              ],
            ),
          );
        });
  }
}

StorageInfoCard storageInfoCard(
    PositionModel positionModel, BuildContext context) {
  final tokenController = Get.put(TokenController());

  final double tokenPrice = tokenController.tokenPrice(positionModel.token);
  final double valuation = tokenPrice * positionModel.amount;
  final String updatedDate =
      tokenController.tokenUpdatedDate(positionModel.token);
  final double var24 = tokenController.tokenVar24(positionModel.token);
  final double var24Percent =
      tokenController.tokenVar24Percent(positionModel.token);

  final double unrealizedPercent =
      (tokenPrice - positionModel.averagePurchasePrice) /
          positionModel.averagePurchasePrice *
          100.0;
  final double unrealized =
      (tokenPrice - positionModel.averagePurchasePrice) * positionModel.amount;

  return StorageInfoCard(
    svgSrc: 'icons/Documents.svg',
    title: positionModel.token,
    positionValuation: '${_numberFormat.format(valuation)} USD',
    positionAmount: 'Amount: ${_numberFormat.format(positionModel.amount)}',
    positionPrice: 'Price: ${_priceFormat.format(tokenPrice)} USD',
    positionAveragePurchasePriceTitle: 'Avg. Purchase Price: ',
    positionAveragePurchasePrice:
        '${_priceFormat.format(positionModel.averagePurchasePrice)} USD',
    positionUnrealizedTitle: 'Unrealized: ',
    positionUnrealized:
        '${_numberFormat.format(unrealized)} USD / ${_numberFormat.format(unrealizedPercent)}%',
    unrealizedColor: unrealized.isNegative ? Colors.green : Colors.red,
    positionRealizedTitle: 'Realized: ',
    positionRealized: '0 USD',
    updatedDateTitle: 'Last update: ',
    updatedDate: updatedDate,
    tokenVariation:
        '${_numberFormat.format(var24)} USD / ${_numberFormat.format(var24Percent)}%',
  );
}
