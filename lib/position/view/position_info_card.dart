import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:web_dashboard/src/hive/crypto_hive.dart';
import 'package:web_dashboard/src/responsive.dart';

import '../../constant.dart';

const cryptoListBox = 'cryptoList';

bool _isLargeScreen(BuildContext context) {
  return MediaQuery.of(context).size.width > 960.0;
}

class PositionInfoCard extends StatelessWidget {
  const PositionInfoCard({
    Key? key,
    required this.title,
    required this.positionName,
    required this.svgSrc,
    required this.positionValuation,
    required this.positionAmount,
    required this.positionPrice,
    required this.positionAverageCostTitle,
    required this.positionAverageCost,
    required this.positionUnrealizedTitle,
    required this.positionUnrealized,
    required this.unrealizedColor,
    required this.positionRealizedTitle,
    required this.positionRealized,
    required this.updatedDateTitle,
    required this.updatedDate,
    required this.tokenVariation,
    required this.positionPercentage,
  }) : super(key: key);

  final String title,
      positionName,
      svgSrc,
      positionValuation,
      updatedDateTitle,
      updatedDate,
      positionAmount,
      positionPrice,
      positionAverageCostTitle,
      positionAverageCost,
      positionUnrealizedTitle,
      positionUnrealized,
      positionRealizedTitle,
      positionRealized,
      tokenVariation,
      positionPercentage;

  final Color unrealizedColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
            context: context,
            builder: (context) => SimpleDialog(
                  title: const Text('Position information'),
                  titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  children: [
                    Container(
                      width: _isLargeScreen(context)
                          ? 600
                          : MediaQuery.of(context).size.width - 10,
                      child: Column(
                        children: [
                          displayPosition(context),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 8, right: 8, top: 16),
                            child: ElevatedButton(
                              onPressed: Get.back,
                              child: const Text('Cancel'),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ));
      },
      child: Container(
        margin: const EdgeInsets.only(top: defaultPadding),
        padding: const EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          border: Border.all(width: 2, color: primaryColor.withOpacity(0.15)),
          borderRadius: const BorderRadius.all(
            Radius.circular(defaultPadding),
          ),
        ),
        child: displayPositionLight(context),
      ),
    );
  }

  Widget displayPosition(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return displayPositionForMobileScreen(context);
    } else {
      return displayPositionForLargeScreen(context);
    }
  }

  Widget displayPositionLight(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child:
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              //   child:
              Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 5,
                children: [
                  Text(
                    positionName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              Text(
                positionAmount,
                style: Theme.of(context)
                    .textTheme
                    .caption!
                    .copyWith(color: Colors.white70),
              ),
            ],
          ),
          //),
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
    );
  }

  Widget displayPositionForLargeScreen(BuildContext context) {
    return Row(
      children: [
        // SizedBox(
        //   height: 26,
        //   width: 26,
        //   child: FutureBuilder(
        //     future: _getIconFromCryptoHive(title),
        //     builder: (context, snapshot) {
        //       if (snapshot.hasData) {
        //         return Image.network(snapshot.data.toString());
        //       } else {
        //         return const Icon(Icons.all_inclusive);
        //       }
        //     },
        //   ),
        // ),
        Expanded(
          child:
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              //   child:
              Column(
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
              Row(
                children: [
                  Text(
                    positionAverageCostTitle,
                    style: Theme.of(context)
                        .textTheme
                        .caption!
                        .copyWith(color: Colors.white70),
                  ),
                  Text(
                    positionAverageCost,
                    style: Theme.of(context)
                        .textTheme
                        .caption!
                        .copyWith(color: Colors.white70),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    positionUnrealizedTitle,
                    style: Theme.of(context)
                        .textTheme
                        .caption!
                        .copyWith(color: Colors.white70),
                  ),
                  Text(
                    positionUnrealized,
                    style: Theme.of(context)
                        .textTheme
                        .caption!
                        .copyWith(color: unrealizedColor),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    updatedDateTitle,
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
              )
            ],
          ),
          //),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(positionValuation),
          Text(tokenVariation,
              style: Theme.of(context)
                  .textTheme
                  .caption!
                  .copyWith(color: _isNegativeVariation(tokenVariation))),
          Text(positionPrice,
              style: Theme.of(context)
                  .textTheme
                  .caption!
                  .copyWith(color: Colors.white70)),
          Row(
            children: [
              Text(positionRealizedTitle,
                  style: Theme.of(context)
                      .textTheme
                      .caption!
                      .copyWith(color: Colors.white70)),
              Text(positionRealized,
                  style: Theme.of(context)
                      .textTheme
                      .caption!
                      .copyWith(color: Colors.white70)),
            ],
          ),
          Text(positionPercentage,
              style: Theme.of(context)
                  .textTheme
                  .caption!
                  .copyWith(color: Colors.white70)),
        ])
      ],
    );
  }

  Widget displayPositionForMobileScreen(BuildContext context) {
    return Row(
      children: [
        // SizedBox(
        //   height: 26,
        //   width: 26,
        //   child: FutureBuilder(
        //     future: _getIconFromCryptoHive(title),
        //     builder: (context, snapshot) {
        //       if (snapshot.hasData) {
        //         return Image.network(snapshot.data.toString());
        //       } else {
        //         return const Icon(Icons.all_inclusive);
        //       }
        //     },
        //   ),
        // ),
        Expanded(
          child:
              //Padding(
              // padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              // child:
              Column(
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
              Text(positionPrice,
                  style: Theme.of(context)
                      .textTheme
                      .caption!
                      .copyWith(color: Colors.white70)),
              Text(positionRealizedTitle,
                  style: Theme.of(context)
                      .textTheme
                      .caption!
                      .copyWith(color: Colors.white70)),
              Text(
                positionAverageCostTitle,
                style: Theme.of(context)
                    .textTheme
                    .caption!
                    .copyWith(color: Colors.white70),
              ),
              Text(
                positionUnrealizedTitle,
                style: Theme.of(context)
                    .textTheme
                    .caption!
                    .copyWith(color: Colors.white70),
              ),
              Text(
                updatedDateTitle,
                style: Theme.of(context)
                    .textTheme
                    .caption!
                    .copyWith(color: Colors.white70),
              ),
            ],
            //),
          ),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(positionValuation),
          Text(positionPercentage,
              style: Theme.of(context)
                  .textTheme
                  .caption!
                  .copyWith(color: Colors.white70)),
          Text(tokenVariation,
              style: Theme.of(context)
                  .textTheme
                  .caption!
                  .copyWith(color: _isNegativeVariation(tokenVariation))),
          Text(positionRealized,
              style: Theme.of(context)
                  .textTheme
                  .caption!
                  .copyWith(color: Colors.white70)),
          Text(
            positionAverageCost,
            style: Theme.of(context)
                .textTheme
                .caption!
                .copyWith(color: Colors.white70),
          ),
          Text(
            positionUnrealized,
            style: Theme.of(context)
                .textTheme
                .caption!
                .copyWith(color: unrealizedColor),
          ),
          Text(
            updatedDate,
            style: Theme.of(context)
                .textTheme
                .caption!
                .copyWith(color: Colors.white70),
          ),
        ])
      ],
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
