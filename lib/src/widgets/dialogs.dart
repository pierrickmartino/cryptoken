// Copyright 2020, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_dashboard/src/api/api.dart';
import 'package:web_dashboard/src/widgets/transaction_forms.dart';
import 'package:web_dashboard/src/widgets/portfolio_forms.dart';

import '../app.dart';

bool _isLargeScreen(BuildContext context) {
  return MediaQuery.of(context).size.width > 960.0;
}

class NewPortfolioDialog extends StatelessWidget {
  const NewPortfolioDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (_isLargeScreen(context)) {
      return SimpleDialog(
        title: const Text('New Portfolio'),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        children: [
          Container(
            width: 600,
            child: Column(
              children: const [
                NewPortfolioForm(),
              ],
            ),
          ),
        ],
      );
    }

    return SimpleDialog(
      title: const Text('New Portfolio'),
      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      children: [
        Container(
          width: MediaQuery.of(context).size.width - 50,
          child: Column(
            children: const [
              NewPortfolioForm(),
            ],
          ),
        ),
      ],
    );
  }
}

class EditPortfolioDialog extends StatelessWidget {
  const EditPortfolioDialog({
    Key? key,
    required this.portfolio,
  }) : super(key: key);

  final Portfolio portfolio;

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<AppState>(context).api;

    if (_isLargeScreen(context)) {
      return SimpleDialog(
        title: const Text('Edit Portfolio'),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        children: [
          Container(
            width: 600,
            child: Column(children: [
              EditPortfolioForm(
                portfolio: portfolio,
                onDone: (shouldUpdate) {
                  if (shouldUpdate) {
                    api.portfolios.update(portfolio, portfolio.id);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Portfolio updated'),
                      ),
                    );
                  }
                  Navigator.of(context).pop();
                },
              ),
            ]),
          ),
        ],
      );
    }

    return SimpleDialog(
      title: const Text('Edit Portfolio'),
      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      children: [
        Container(
          width: MediaQuery.of(context).size.width - 50,
          child: Column(children: [
            EditPortfolioForm(
              portfolio: portfolio,
              onDone: (shouldUpdate) {
                if (shouldUpdate) {
                  api.portfolios.update(portfolio, portfolio.id);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Portfolio updated'),
                    ),
                  );
                }
                Navigator.of(context).pop();
              },
            ),
          ]),
        ),
      ],
    );
  }
}

class NewTransactionDialog extends StatefulWidget {
  const NewTransactionDialog({Key? key}) : super(key: key);

  @override
  _NewTransactionDialogState createState() => _NewTransactionDialogState();
}

class _NewTransactionDialogState extends State<NewTransactionDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLargeScreen(context)) {
      return SimpleDialog(
        title: const Text('New Transaction'),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        children: [
          Container(
            width: 600,
            child: Column(
              children: const [
                NewTransactionForm(),
              ],
            ),
          ),
        ],
      );
    }

    return SimpleDialog(
      title: const Text('New Transaction'),
      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      children: [
        Container(
          width: MediaQuery.of(context).size.width - 50,
          child: Column(
            children: const [
              NewTransactionForm(),
            ],
          ),
        ),
      ],
    );
  }
}

class EditTransactionDialog extends StatefulWidget {
  const EditTransactionDialog({
    Key? key,
    required this.portfolio,
    required this.transaction,
  }) : super(key: key);

  final Portfolio portfolio;
  final Transaction transaction;

  @override
  _EditTransactionDialogState createState() => _EditTransactionDialogState();
}

class _EditTransactionDialogState extends State<EditTransactionDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<AppState>(context).api;

    if (_isLargeScreen(context)) {
      return SimpleDialog(
        title: const Text('Edit Transaction'),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        children: [
          Container(
            width: 600,
            child: Column(
              children: [
                EditTransactionForm(
                  transaction: widget.transaction,
                  portfolio: widget.portfolio,
                  onDone: (shouldUpdate) async {
                    if (shouldUpdate) {
                      // first regarding the Credit part of the transaction
                      try {
                        // try to find if the position already exists
                        final oldPositionCredit = await api.positions.get(
                            widget.portfolio.id,
                            widget.transaction.tokenCredit);
                        final newPositionCredit = Position(
                            oldPositionCredit.token,
                            oldPositionCredit.amount +
                                widget.transaction.amountCredit,
                            oldPositionCredit.time);

                        // if we find the position, we need to update it
                        await api.positions.update(widget.portfolio.id,
                            widget.transaction.tokenCredit, newPositionCredit);
                      } catch (e) {
                        // if not, we should get an error then insert the new position
                        await api.positions.insert(
                            widget.portfolio.id,
                            Position(
                                widget.transaction.tokenCredit,
                                widget.transaction.amountCredit.toDouble(),
                                widget.transaction.time));
                      }

                      // then regarding the Debit part of the transaction
                      try {
                        // try to find if the position already exists
                        final oldPositionDebit = await api.positions.get(
                            widget.portfolio.id, widget.transaction.tokenDebit);
                        final newPositionDebit = Position(
                            oldPositionDebit.token,
                            oldPositionDebit.amount -
                                widget.transaction.amountDebit,
                            oldPositionDebit.time);

                        // if we find the position, we need to update it
                        await api.positions.update(widget.portfolio.id,
                            widget.transaction.tokenDebit, newPositionDebit);
                      } catch (e) {
                        // if not, we should get an error then insert the new position
                        await api.positions.insert(
                            widget.portfolio.id,
                            Position(
                                widget.transaction.tokenDebit,
                                -widget.transaction.amountDebit.toDouble(),
                                widget.transaction.time));
                      }

                      // finally insert the transaction linked to the portfolio
                      await api.transactions.insert(
                          widget.portfolio.id,
                          Transaction(
                              widget.transaction.tokenCredit,
                              widget.transaction.tokenDebit,
                              widget.transaction.tokenFee,
                              widget.transaction.tokenPrice,
                              widget.transaction.amountCredit.toDouble(),
                              widget.transaction.amountDebit.toDouble(),
                              widget.transaction.amountFee.toDouble(),
                              widget.transaction.price.toDouble(),
                              widget.transaction.time));

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Transaction updated'),
                        ),
                      );
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }

    return SimpleDialog(
      title: const Text('Edit Transaction'),
      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      children: [
        Container(
          width: MediaQuery.of(context).size.width - 50,
          child: Column(
            children: [
              EditTransactionForm(
                transaction: widget.transaction,
                portfolio: widget.portfolio,
                onDone: (shouldUpdate) async {
                  if (shouldUpdate) {
                    // first regarding the Credit part of the transaction
                    try {
                      // try to find if the position already exists
                      final oldPositionCredit = await api.positions.get(
                          widget.portfolio.id, widget.transaction.tokenCredit);
                      final newPositionCredit = Position(
                          oldPositionCredit.token,
                          oldPositionCredit.amount +
                              widget.transaction.amountCredit,
                          oldPositionCredit.time);

                      // if we find the position, we need to update it
                      await api.positions.update(widget.portfolio.id,
                          widget.transaction.tokenCredit, newPositionCredit);
                    } catch (e) {
                      // if not, we should get an error then insert the new position
                      await api.positions.insert(
                          widget.portfolio.id,
                          Position(
                              widget.transaction.tokenCredit,
                              widget.transaction.amountCredit.toDouble(),
                              widget.transaction.time));
                    }

                    // then regarding the Debit part of the transaction
                    try {
                      // try to find if the position already exists
                      final oldPositionDebit = await api.positions.get(
                          widget.portfolio.id, widget.transaction.tokenDebit);
                      final newPositionDebit = Position(
                          oldPositionDebit.token,
                          oldPositionDebit.amount -
                              widget.transaction.amountDebit,
                          oldPositionDebit.time);

                      // if we find the position, we need to update it
                      await api.positions.update(widget.portfolio.id,
                          widget.transaction.tokenDebit, newPositionDebit);
                    } catch (e) {
                      // if not, we should get an error then insert the new position
                      await api.positions.insert(
                          widget.portfolio.id,
                          Position(
                              widget.transaction.tokenDebit,
                              -widget.transaction.amountDebit.toDouble(),
                              widget.transaction.time));
                    }

                    // finally insert the transaction linked to the portfolio
                    await api.transactions.insert(
                        widget.portfolio.id,
                        Transaction(
                            widget.transaction.tokenCredit,
                            widget.transaction.tokenDebit,
                            widget.transaction.tokenFee,
                            widget.transaction.tokenPrice,
                            widget.transaction.amountCredit.toDouble(),
                            widget.transaction.amountDebit.toDouble(),
                            widget.transaction.amountFee.toDouble(),
                            widget.transaction.price.toDouble(),
                            widget.transaction.time));

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Transaction updated'),
                      ),
                    );
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
