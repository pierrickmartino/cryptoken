import 'package:fl_chart/fl_chart.dart';
//import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;

import '../../constant.dart';
import '../../position/model/position_model.dart';
import '../../token/controller/token_controller.dart';

final _numberFormat =
    intl.NumberFormat.currency(locale: 'de_CH', symbol: '', decimalDigits: 0);

bool _isLargeScreen(BuildContext context) {
  return MediaQuery.of(context).size.width > 960.0;
}

class Chart extends StatelessWidget {
  const Chart({
    Key? key,
    required this.positionsList,
    required this.totalAmount,
  }) : super(key: key);

  final List<PositionModel> positionsList;
  final double totalAmount;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TokenController>(
        init: TokenController(),
        builder: (_tokenController) {
          return SizedBox(
            height: _isLargeScreen(context)
                ? MediaQuery.of(context).size.height - 850
                : 200,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: double.infinity,
                    startDegreeOffset: -90,
                    sections: _getPieCharSectionData(
                        positionsList, _tokenController, totalAmount),
                  ),
                ),
                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: defaultPadding),
                      Text(
                        _numberFormat.format(totalAmount),
                        style: Theme.of(context).textTheme.headline5!.copyWith(
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

List<PieChartSectionData> _getPieCharSectionData(
    List<PositionModel> positionsList,
    TokenController _tokenController,
    double totalAmount) {
  final List<PieChartSectionData> pieChartSelectionDatas = [];

  for (final element in positionsList) {
    String positionToken = '';
    if (element.token == 'OTHER') {
      positionToken = 'USDT';
    } else {
      positionToken = element.token;
    }

    final PieChartSectionData data = PieChartSectionData(
      title: element.token,
      color: Color(element.color),
      value:
          ((element.amount * _tokenController.tokenPriceGetX(positionToken)) /
                  totalAmount *
                  100.0)
              .roundToDouble(),
      showTitle: true,
      radius: 40,
    );
    pieChartSelectionDatas.add(data);
  }

  return pieChartSelectionDatas;
}
