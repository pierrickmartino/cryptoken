//import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:web_dashboard/position/model/position_model.dart';
import 'package:web_dashboard/token/controller/token_controller.dart';

import '../../constant.dart';

final _numberFormat =
    intl.NumberFormat.currency(locale: 'de_CH', symbol: '', decimalDigits: 0);

class Chart extends StatelessWidget {
  const Chart({
    Key? key,
    required this.positionsList,
  }) : super(key: key);

  final List<PositionModel> positionsList;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TokenController>(
        init: TokenController(),
        builder: (_tokenController) {
          return SizedBox(
            height: 200,
            child: Stack(
              children: [
                // PieChart(
                //   PieChartData(
                //     sectionsSpace: 0,
                //     centerSpaceRadius: 70,
                //     startDegreeOffset: -90,
                //     sections:
                //         _getPieCharSectionData(positionsList, _tokenController),
                //   ),
                // ),
                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: defaultPadding),
                      Text(
                        _getTotalValuation(positionsList, _tokenController),
                        style: Theme.of(context).textTheme.headline4!.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              height: 0.5,
                            ),
                      ),
                      const Text('USD')
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
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

String _getTotalValuation(
    List<PositionModel> positionsList, TokenController _tokenController) {
  double totalValuation = 0;

  for (final element in positionsList) {
    totalValuation = totalValuation +
        (element.amount * _tokenController.tokenPriceGetX(element.token));
  }
  return _numberFormat.format(totalValuation);
}

// List<PieChartSectionData> _getPieCharSectionData(
//     List<PositionModel> positionsList, TokenController _tokenController) {
//   List<PieChartSectionData> pieChartSelectionDatas = [];

//   final double total =
//       _getTotalValuationInDouble(positionsList, _tokenController);

//   for (final element in positionsList) {
//     final PieChartSectionData data = PieChartSectionData(
//       color: Color(element.color),
//       value: (element.amount * _tokenController.tokenPriceGetX(element.token)) /
//           total *
//           100.0,
//       showTitle: false,
//       radius: 25,
//     );
//     pieChartSelectionDatas.add(data);
//   }

//   return pieChartSelectionDatas;
// }



// List<PieChartSectionData> paiChartSelectionDatas = [
//   PieChartSectionData(
//     color: primaryColor,
//     value: 25,
//     showTitle: false,
//     radius: 25,
//   ),
//   PieChartSectionData(
//     color: const Color(0xFF26E5FF),
//     value: 20,
//     showTitle: false,
//     radius: 22,
//   ),
//   PieChartSectionData(
//     color: const Color(0xFFFFCF26),
//     value: 10,
//     showTitle: false,
//     radius: 19,
//   ),
//   PieChartSectionData(
//     color: const Color(0xFFEE2727),
//     value: 15,
//     showTitle: false,
//     radius: 16,
//   ),
//   PieChartSectionData(
//     color: primaryColor.withOpacity(0.1),
//     value: 25,
//     showTitle: false,
//     radius: 13,
//   ),
// ];
