// Copyright 2020, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../api/api.dart';
import 'dialogs.dart';

class PortfolioWidget extends StatelessWidget {
  const PortfolioWidget({
    Key? key,
    required this.portfolio,
    required this.api,
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
                  showDialog<EditPortfolioDialog>(
                    context: context,
                    builder: (context) {
                      return EditPortfolioDialog(portfolio: portfolio);
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
              return StreamBuilder<List<Position?>?>(
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
  const _ListPositions({Key? key, this.positions}) : super(key: key);

  final List<Position?>? positions;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          childAspectRatio: 2,
          // crossAxisSpacing: 20,
          // mainAxisSpacing: 5
        ),
        itemCount: positions!.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            height: 20,
            //color: Colors.amber[colorCodes[index]],
            child: Card(
              color: Colors.blue,
              elevation: 2,
              child: Center(
                  child: Text(
                      '${positions![index]!.token} : ${positions![index]!.amount}')),
            ),
          );
        });
  }
}
