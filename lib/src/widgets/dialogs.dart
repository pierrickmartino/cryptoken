// Copyright 2020, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_dashboard/src/api/api.dart';
import 'package:web_dashboard/src/widgets/transaction_forms.dart';
import 'package:web_dashboard/src/widgets/portfolio_forms.dart';

import '../app.dart';

class NewPortfolioDialog extends StatelessWidget {
  const NewPortfolioDialog({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SimpleDialog(
      title: Text('New Portfolio'),
      children: <Widget>[
        NewPortfolioForm(),
      ],
    );
  }
}

class EditPortfolioDialog extends StatelessWidget {
  const EditPortfolioDialog({
    Key key,
    @required this.portfolio,
  }) : super(key: key);

  final Portfolio portfolio;

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<AppState>(context).api;

    return SimpleDialog(
      title: const Text('Edit Portfolio'),
      children: [
        EditPortfolioForm(
          portfolio: portfolio,
          onDone: (shouldUpdate) {
            if (shouldUpdate) {
              api.portfolios.update(portfolio, portfolio.id);
            }
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class NewTransactionDialog extends StatefulWidget {
  const NewTransactionDialog({Key key}) : super(key: key);

  @override
  _NewTransactionDialogState createState() => _NewTransactionDialogState();
}

class _NewTransactionDialogState extends State<NewTransactionDialog> {
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('New Transaction'),
      children: [
        NewTransactionForm(),
      ],
    );
  }
}

class EditTransactionDialog extends StatelessWidget {
  const EditTransactionDialog({
    Key key,
    this.portfolio,
    this.transaction,
  }) : super(key: key);

  final Portfolio portfolio;
  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<AppState>(context).api;

    return SimpleDialog(
      title: const Text('Edit Transaction'),
      children: [
        EditTransactionForm(
          transaction: transaction,
          onDone: (shouldUpdate) {
            if (shouldUpdate) {
              api.transactions
                  .update(portfolio.id, transaction.id, transaction);
            }
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}
