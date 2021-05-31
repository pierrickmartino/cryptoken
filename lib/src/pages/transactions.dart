// Copyright 2020, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intl;

import '../api/api.dart';
import '../app.dart';
import '../widgets/dialogs.dart';
import '../widgets/portfolios_dropdown.dart';

final _priceFormat =
    intl.NumberFormat.currency(locale: 'de_CH', symbol: '', decimalDigits: 6);

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({Key? key}) : super(key: key);
  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  Portfolio? _selected;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Column(
      children: [
        PortfolioDropdown(
            api: appState.api.portfolios,
            onSelected: (portfolio) => setState(() => _selected = portfolio)),
        Expanded(
          child: _selected == null
              ? const Center(child: CircularProgressIndicator())
              : TransactionsList(
                  portfolio: _selected!,
                  api: appState.api.transactions,
                ),
        ),
      ],
    );
  }
}

class TransactionsList extends StatefulWidget {
  TransactionsList({
    required this.portfolio,
    required this.api,
  }) : super(key: ValueKey(portfolio.id));

  final Portfolio portfolio;
  final TransactionApi api;

  @override
  _TransactionsListState createState() => _TransactionsListState();
}

class _TransactionsListState extends State<TransactionsList> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Transaction>>(
      future: widget.api.list(widget.portfolio.id),
      builder: (context, futureSnapshot) {
        if (!futureSnapshot.hasData) {
          return _buildLoadingIndicator();
        }
        return StreamBuilder<List<Transaction?>>(
          initialData: futureSnapshot.data,
          stream: widget.api.subscribe(widget.portfolio.id),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return _buildLoadingIndicator();
            }
            return ListView.builder(
              itemBuilder: (context, index) {
                return TransactionTile(
                  portfolio: widget.portfolio,
                  transaction: snapshot.data![index]!,
                );
              },
              itemCount: snapshot.data!.length,
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }
}

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    Key? key,
    required this.portfolio,
    required this.transaction,
  }) : super(key: key);

  final Portfolio portfolio;
  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
          '${transaction.amountMain} ${transaction.tokenMain} at ${_priceFormat.format(transaction.price)} ${transaction.tokenPrice}'),
      subtitle:
          Text(intl.DateFormat('dd/MM/yy HH:mm').format(transaction.time)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (context) {
                  return EditTransactionDialog(
                    portfolio: portfolio,
                    transaction: transaction,
                  );
                },
              );
            },
            child: const Text('Edit'),
          ),
          TextButton(
            onPressed: () async {
              final shouldDelete = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete transaction?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (shouldDelete!) {
                // To delete an existing transaction we also need to adjust the positions

                // 1. Find the positions (Main and Reference) in relation with the transaction
                final oldPositionMain =
                    await Provider.of<AppState>(context, listen: false)
                        .api
                        .positions
                        .get(portfolio.id, transaction.tokenMain);

                final newPositionMain = Position(
                    oldPositionMain.token,
                    oldPositionMain.amount - transaction.amountMain,
                    oldPositionMain.time);

                final oldPositionReference =
                    await Provider.of<AppState>(context, listen: false)
                        .api
                        .positions
                        .get(portfolio.id, transaction.tokenReference);

                final newPositionReference = Position(
                    oldPositionReference.token,
                    oldPositionReference.amount + transaction.amountReference,
                    oldPositionReference.time);

                // 2. Update the positions
                await Provider.of<AppState>(context, listen: false)
                    .api
                    .positions
                    .update(
                        portfolio.id, transaction.tokenMain, newPositionMain);

                await Provider.of<AppState>(context, listen: false)
                    .api
                    .positions
                    .update(portfolio.id, transaction.tokenReference,
                        newPositionReference);

                // 3. Delete the transaction
                await Provider.of<AppState>(context, listen: false)
                    .api
                    .transactions
                    .delete(portfolio.id, transaction.id);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Transaction deleted'),
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
