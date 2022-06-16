import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:web_dashboard/auth/controller/auth_controller.dart';
import 'package:web_dashboard/position/controller/position_controller.dart';
import 'package:web_dashboard/position/model/position_model.dart';
import 'package:web_dashboard/token/controller/token_controller.dart';
import 'package:web_dashboard/transaction/view/new_transaction.dart';
import 'package:web_dashboard/wallet/controller/wallet_controller.dart';
import 'package:web_dashboard/wallet/model/wallet_model.dart';
import 'package:web_dashboard/wallet/view/edit_wallet.dart';

import '../../constant.dart';

final _numberFormat =
    NumberFormat.currency(locale: 'de_CH', symbol: '', decimalDigits: 2);

class FileInfoCard extends StatelessWidget {
  FileInfoCard({
    Key? key,
    required this.wallet,
  }) : super(key: key);

  final WalletModel wallet;
  final Color boxDecorationColor = secondaryColor;

  final AuthController authController = AuthController.to;
  final WalletController walletController = WalletController.to;
  final PositionController positionController = PositionController.to;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PositionModel>>(
        future: positionController.getFirestorePositionListByWallet(wallet.id),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return GetBuilder<TokenController>(
              init: TokenController(),
              builder: (_tokenController) {
                return Container(
                  padding: const EdgeInsets.all(defaultPadding),
                  decoration: BoxDecoration(
                    color: boxDecorationColor,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding:
                                const EdgeInsets.all(defaultPadding * 0.75),
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(
                                  0.1), // wallet.color!.withOpacity(0.1),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                            ),
                            child: SvgPicture.asset(
                              'icons/folder.svg', //wallet.svgSrc!,
                              color: primaryColor, // wallet.color,
                            ),
                          ),
                          PopupMenuButton(
                            iconSize: 18,
                            color: secondaryColor,
                            onSelected: (value) {
                              switch (value) {
                                case 1:
                                  showDialog<EditWalletDialog>(
                                    context: context,
                                    builder: (context) {
                                      return EditWalletDialog(
                                        wallet: wallet,
                                      );
                                    },
                                  );
                                  break;
                                case 2:
                                  walletController
                                      .deleteFirestoreWallet(wallet.id)
                                      .then((value) => Get
                                        ..snackbar('Successful',
                                            'wallet ${wallet.name} deleted !',
                                            snackPosition: SnackPosition.BOTTOM,
                                            duration:
                                                const Duration(seconds: 5),
                                            backgroundColor: Get.theme
                                                .snackBarTheme.backgroundColor,
                                            colorText: Get.theme.snackBarTheme
                                                .actionTextColor));
                                  break;
                                case 3:
                                  showGeneralDialog<NewTransactionDialog>(
                                    context: context,
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        NewTransactionDialog(
                                      selectedWallet: wallet,
                                    ),
                                  );
                                  break;

                                default:
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 1,
                                child: Text(
                                  'Edit',
                                  textScaleFactor: 0.9,
                                ),
                              ),
                              PopupMenuItem(
                                value: 2,
                                enabled: authController.admin.value,
                                child: const Text(
                                  'Delete',
                                  textScaleFactor: 0.9,
                                ),
                              ),
                              const PopupMenuItem(
                                value: 3,
                                child: Text(
                                  'Add transaction',
                                  textScaleFactor: 0.9,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      Text(
                        wallet.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(wallet.id,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .caption!
                              .copyWith(color: Colors.white70)),
                      const ProgressLine(
                        // color: wallet.color,
                        percentage: 100, //wallet.percentage,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _getTotalUnrealized(
                                snapshot.data!, _tokenController),
                            style: Theme.of(context)
                                .textTheme
                                .caption!
                                .copyWith(color: Colors.white70),
                          ),
                          Text(
                            _getTotalValuation(
                                snapshot.data!, _tokenController),
                            style: Theme.of(context)
                                .textTheme
                                .caption!
                                .copyWith(color: Colors.white),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              });
        });
  }
}

String _getTotalUnrealized(
    List<PositionModel> positionList, TokenController _tokenController) {
  double totalUnrealized = 0;

  for (final positionModel in positionList) {
    final double tokenPrice =
        _tokenController.tokenPriceGetX(positionModel.token);
    final double unrealized =
        (tokenPrice - positionModel.averageCost) * positionModel.amount;
    totalUnrealized = totalUnrealized + unrealized;
  }

  return _numberFormat.format(totalUnrealized);
}

String _getTotalValuation(
    List<PositionModel> positionList, TokenController _tokenController) {
  double totalValuation = 0;

  for (final positionModel in positionList) {
    final double tokenPrice =
        _tokenController.tokenPriceGetX(positionModel.token);
    final double valuation = tokenPrice * positionModel.amount;
    totalValuation = totalValuation + valuation;
  }

  return _numberFormat.format(totalValuation);
}

class ProgressLine extends StatelessWidget {
  const ProgressLine({
    Key? key,
    this.color = primaryColor,
    required this.percentage,
  }) : super(key: key);

  final Color? color;
  final int? percentage;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 5,
          decoration: BoxDecoration(
            color: color!.withOpacity(0.1),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) => Container(
            width: constraints.maxWidth * (percentage! / 100),
            height: 5,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
}
