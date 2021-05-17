// Copyright 2020, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import '../api/api.dart';

/// Subscribes to the latest list of categories and allows the user to select
/// one.
class PortfolioDropdown extends StatefulWidget {
  const PortfolioDropdown({
    Key? key,
    required this.api,
    required this.onSelected,
  }) : super(key: key);

  final PortfolioApi api;
  final ValueChanged<Portfolio> onSelected;

  @override
  _PortfolioDropdownState createState() => _PortfolioDropdownState();
}

class _PortfolioDropdownState extends State<PortfolioDropdown> {
  Portfolio? _selected;
  Future<List<Portfolio>>? _future;
  Stream<List<Portfolio>>? _stream;

  @override
  void initState() {
    super.initState();

    // This widget needs to wait for the list of Categories, select the first
    // Portfolio, and emit an `onSelected` event.
    //
    // This could be done inside the FutureBuilder's `builder` callback,
    // but calling setState() during the build is an error. (Calling the
    // onSelected callback will also cause the parent widget to call
    // setState()).
    //
    // Instead, we'll create a new Future that sets the selected Portfolio and
    // calls `onSelected` if necessary. Then, we'll pass *that* future to
    // FutureBuilder. Now the selected portfolio is set and events are emitted
    // *before* the build is triggered by the FutureBuilder.
    _future = widget.api.list().then((portfolios) {
      if (portfolios.isEmpty) {
        return portfolios;
      }

      _setSelected(portfolios.first);
      return portfolios;
    });

    // Same here, we'll create a new stream that handles any potential
    // setState() operations before we trigger our StreamBuilder.
    _stream = widget.api.subscribe().map((portfolios) {
      if (!portfolios.contains(_selected) && portfolios.isNotEmpty) {
        _setSelected(portfolios.first);
      }

      return portfolios;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Portfolio>>(
      future: _future,
      builder: (context, futureSnapshot) {
        // Show an empty dropdown while the data is loading.
        if (!futureSnapshot.hasData) {
          return DropdownButton<Portfolio>(items: []);
        }

        return StreamBuilder<List<Portfolio>>(
          initialData: futureSnapshot.hasData ? futureSnapshot.data : [],
          stream: _stream,
          builder: (context, snapshot) {
            final data = snapshot.hasData ? snapshot.data : <Portfolio>[];
            return DropdownButton<Portfolio>(
              value: _selected,
              items: data!.map(_buildDropdownItem).toList(),
              onChanged: (portfolio) {
                _setSelected(portfolio!);
              },
            );
          },
        );
      },
    );
  }

  void _setSelected(Portfolio portfolio) {
    if (_selected == portfolio) {
      return;
    }
    setState(() {
      _selected = portfolio;
    });

    widget.onSelected(_selected!);
  }

  DropdownMenuItem<Portfolio> _buildDropdownItem(Portfolio portfolio) {
    return DropdownMenuItem<Portfolio>(
      value: portfolio,
      child: Text(portfolio.name),
    );
  }
}
