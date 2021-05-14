// Copyright 2020, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

// import 'package:charts_flutter/flutter.dart' as charts;
// import 'package:intl/intl.dart' as intl;

import '../api/api.dart';
//import '../utils/chart_utils.dart' as utils;
import 'dialogs.dart';

// The number of days to show in the chart
//const _daysBefore = 10;

class PortfolioWidget extends StatelessWidget {
  const PortfolioWidget({
    Key key,
    @required this.portfolio,
    @required this.api,
  }) : super(key: key);

  final Portfolio portfolio;
  final DashboardApi api;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(portfolio.name),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  showDialog<EditCategoryDialog>(
                    context: context,
                    builder: (context) {
                      return null;
                      //EditCategoryDialog(category: portfolio);
                    },
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          // Load the initial snapshot using a FutureBuilder, and subscribe to
          // additional updates with a StreamBuilder.
          child: FutureBuilder<List<Position>>(
            future: api.positions.list(portfolio.id),
            builder: (context, futureSnapshot) {
              if (!futureSnapshot.hasData) {
                return _buildLoadingIndicator();
              }
              return StreamBuilder<List<Position>>(
                initialData: futureSnapshot.data,
                stream: api.positions.subscribe(portfolio.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return _buildLoadingIndicator();
                  }
                  return _ListPositions(
                    positions: snapshot.data,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ListPositions extends StatelessWidget {
  const _ListPositions({Key key, this.positions}) : super(key: key);

  final List<Position> positions;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          childAspectRatio: 2,
          // crossAxisSpacing: 20,
          // mainAxisSpacing: 5
        ),
        itemCount: positions.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            height: 20,
            //color: Colors.amber[colorCodes[index]],
            child: Card(
              color: Colors.blue,
              elevation: 2,
              child:
                  Center(child: Text('Positions : ${positions[index].value}')),
            ),
          );
        });
  }
}

// class _BarChart extends StatelessWidget {
//   final List<ap.Position> entries;

//   _BarChart({this.entries});

//   @override
//   Widget build(BuildContext context) {
//     return charts.BarChart(
//       [_seriesData()],
//       animate: false,
//     );
//   }

//   charts.Series<utils.EntryTotal, String> _seriesData() {
//     return charts.Series<utils.EntryTotal, String>(
//       id: 'Entries',
//       colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
//       domainFn: (entryTotal, _) {
//         if (entryTotal == null) return null;

//         var format = intl.DateFormat.Md();
//         return format.format(entryTotal.day);
//       },
//       measureFn: (total, _) {
//         if (total == null) return null;

//         return total.value;
//       },
//       data: utils.entryTotalsByDay(entries, _daysBefore),
//     );
//   }
// }
