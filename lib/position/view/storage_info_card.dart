import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:web_dashboard/src/hive/crypto_hive.dart';

import '../../constant.dart';

const cryptoListBox = 'cryptoList';

class StorageInfoCard extends StatelessWidget {
  const StorageInfoCard({
    Key? key,
    required this.title,
    required this.svgSrc,
    required this.positionValuation,
    required this.positionAmount,
    required this.updatedDate,
    required this.tokenVariation,
  }) : super(key: key);

  final String title,
      svgSrc,
      positionValuation,
      updatedDate,
      positionAmount,
      tokenVariation;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: defaultPadding),
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        border: Border.all(width: 2, color: primaryColor.withOpacity(0.15)),
        borderRadius: const BorderRadius.all(
          Radius.circular(defaultPadding),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 26,
            width: 26,
            child: FutureBuilder(
              future: _getIconFromCryptoHive(title),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Image.network(snapshot.data.toString());
                } else {
                  return const Icon(Icons.all_inclusive);
                }
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    positionAmount,
                    style: Theme.of(context)
                        .textTheme
                        .caption!
                        .copyWith(color: Colors.white70),
                  ),
                  Text(
                    updatedDate,
                    style: Theme.of(context)
                        .textTheme
                        .caption!
                        .copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(positionValuation),
            Text(tokenVariation,
                style: Theme.of(context)
                    .textTheme
                    .caption!
                    .copyWith(color: _isNegativeVariation(tokenVariation))),
          ])
        ],
      ),
    );
  }

  Color _isNegativeVariation(String variation) {
    if (variation.substring(0, 1) == '-') {
      return Colors.red;
    } else {
      return Colors.green;
    }
  }

  Future<String> _getIconFromCryptoHive(String symbol) async {
    final boxCrypto = await Hive.openBox<CryptoHive>(cryptoListBox);
    final CryptoHive cryptos = boxCrypto.get(symbol)!;

    return cryptos.logo;
  }
}
