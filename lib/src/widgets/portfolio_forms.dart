// Copyright 2020, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_dashboard/src/api/api.dart';
import 'package:web_dashboard/src/app.dart';

class NewPortfolioForm extends StatefulWidget {
  const NewPortfolioForm({Key key}) : super(key: key);

  @override
  _NewPortfolioFormState createState() => _NewPortfolioFormState();
}

class _NewPortfolioFormState extends State<NewPortfolioForm> {
  final Portfolio _portfolio = Portfolio('');

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<AppState>(context).api;
    return EditPortfolioForm(
      portfolio: _portfolio,
      onDone: (shouldInsert) {
        if (shouldInsert) {
          api.portfolios.insert(_portfolio);
        }
        Navigator.of(context).pop();
      },
    );
  }
}

class EditPortfolioForm extends StatefulWidget {
  const EditPortfolioForm({
    Key key,
    @required this.portfolio,
    @required this.onDone,
  }) : super(key: key);

  final Portfolio portfolio;
  final ValueChanged<bool> onDone;

  @override
  _EditPortfolioFormState createState() => _EditPortfolioFormState();
}

class _EditPortfolioFormState extends State<EditPortfolioForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              initialValue: widget.portfolio.name,
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
              onChanged: (newValue) {
                widget.portfolio.name = newValue;
              },
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: ElevatedButton(
                  onPressed: () {
                    widget.onDone(false);
                  },
                  child: const Text('Cancel'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      widget.onDone(true);
                    }
                  },
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
