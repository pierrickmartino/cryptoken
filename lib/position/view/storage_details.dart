import 'package:flutter/material.dart';

import '../../constant.dart';
import 'chart.dart';
import 'storage_info_card.dart';

class StorageDetails extends StatelessWidget {
  const StorageDetails({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: const BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Storage Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: defaultPadding),
          Chart(),
          StorageInfoCard(
            svgSrc: 'icons/Documents.svg',
            title: 'Documents Files',
            amountOfFiles: '1.3GB',
            numOfFiles: 1328,
          ),
          StorageInfoCard(
            svgSrc: 'icons/media.svg',
            title: 'Media Files',
            amountOfFiles: '15.3GB',
            numOfFiles: 1328,
          ),
          StorageInfoCard(
            svgSrc: 'icons/folder.svg',
            title: 'Other Files',
            amountOfFiles: '1.3GB',
            numOfFiles: 1328,
          ),
          StorageInfoCard(
            svgSrc: 'icons/unknown.svg',
            title: 'Unknown',
            amountOfFiles: '1.3GB',
            numOfFiles: 140,
          ),
        ],
      ),
    );
  }
}
