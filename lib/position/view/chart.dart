//import 'package:fl_chart/fl_chart.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;

import '../../constant.dart';
import '../../position/model/position_model.dart';
import '../../token/controller/token_controller.dart';

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
            height: 100, // initial value : 200
            child: Stack(
              children: [
                // DonutPieChart(
                //   _createSampleData(),
                //   // Disable animations for image tests.
                //   animate: false,
                // ),
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

  /// Create one series with sample hard coded data.
  static List<charts.Series<LinearSales, int>> _createSampleData() {
    final data = [
      LinearSales(0, 100),
      LinearSales(1, 75),
      LinearSales(2, 25),
      LinearSales(3, 5),
    ];

    return [
      charts.Series<LinearSales, int>(
        id: 'Sales',
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        data: data,
      )
    ];
  }
}

class DonutPieChart extends StatelessWidget {
  const DonutPieChart(this.seriesList, {this.animate, Key? key})
      : super(key: key);

  final List<charts.Series> seriesList;
  final bool? animate;

  @override
  Widget build(BuildContext context) {
    return charts.PieChart(
      seriesList, animate: animate,
      // Configure the width of the pie slices to 60px. The remaining space in
      // the chart will be left as a hole in the center.
      //defaultRenderer: charts.ArcRendererConfig(arcWidth: 60)
    );
  }
}

/// Sample linear data type.
class LinearSales {
  LinearSales(this.year, this.sales);
  final int year;
  final int sales;
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
