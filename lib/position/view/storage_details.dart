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
                    (index) => storageInfoCard(snapshot.data![index]),
                  ),
                ),
              ],
            ),
          );
        });
  }
}

StorageInfoCard storageInfoCard(PositionModel positionModel) {
  final tokenController = Get.put(TokenController());

  final double valuation =
      tokenController.tokenPrice(positionModel.token) * positionModel.amount;
  final String updatedDate =
      tokenController.tokenUpdatedDate(positionModel.token);
  final double var24 = tokenController.tokenVar24(positionModel.token);
  final double var24Percent =
      tokenController.tokenVar24Percent(positionModel.token);

  return StorageInfoCard(
    svgSrc: 'icons/Documents.svg',
    title: positionModel.token,
    positionValuation: '${_numberFormat.format(valuation)} USD',
    positionAmount: _numberFormat.format(positionModel.amount),
    updatedDate: updatedDate,
    tokenVariation:
        '${_numberFormat.format(var24)}   ${_numberFormat.format(var24Percent)}%',
  );
}
