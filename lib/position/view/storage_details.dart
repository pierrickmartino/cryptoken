import 'package:flutter/material.dart';
import 'package:web_dashboard/position/controller/position_controller.dart';
import 'package:web_dashboard/position/model/position_model.dart';

import '../../constant.dart';
import 'chart.dart';
import 'storage_info_card.dart';

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
                const Chart(),
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
  return StorageInfoCard(
    svgSrc: 'icons/Documents.svg',
    title: positionModel.token,
    amountOfFiles: '0 USD',
    numOfFiles: positionModel.amount,
  );
}
