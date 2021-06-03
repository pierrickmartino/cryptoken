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
    return SimpleDialog(
      title: const Text('New Portfolio'),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      children: [
        Container(
          width: _isLargeScreen(context)
              ? 600
              : MediaQuery.of(context).size.width - 10,
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

    return SimpleDialog(
      title: const Text('Edit Portfolio'),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      children: [
        Container(
          width: _isLargeScreen(context)
              ? 600
              : MediaQuery.of(context).size.width - 10,
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
    return SimpleDialog(
      title: const Text('New Transaction'),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      children: [
        Container(
          width: _isLargeScreen(context)
              ? 600
              : MediaQuery.of(context).size.width - 10,
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
    required this.transaction,
    required this.transactionCache,
    required this.portfolio,
    required this.positionMain,
    required this.positionReference,
  }) : super(key: key);

  final Transaction transaction, transactionCache;
  final Portfolio portfolio;
  final Position positionMain, positionReference;

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

    return SimpleDialog(
      title: const Text('Edit Transaction'),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      children: [
        Container(
          width: _isLargeScreen(context)
              ? 600
              : MediaQuery.of(context).size.width - 10,
          child: Column(
            children: [
              EditTransactionForm(
                transaction: widget.transaction,
                portfolio: widget.portfolio,
                positionMain: widget.positionMain,
                positionReference: widget.positionReference,
                onDone: (shouldUpdate) async {
                  if (shouldUpdate) {
                    // print('Update Mode');

                    // print(
                    //     'transactionCache Main : ${widget.transactionCache.tokenMain} : ${widget.transactionCache.amountMain.toString()}');

                    // first regarding the Main part of the transaction
                    try {
                      // print(
                      //     'widget.positionMain : ${widget.positionMain.token} : ${widget.positionMain.amount}');
                      // print(
                      //     'newPositionMain calculation : ${widget.positionMain.amount} - ${widget.transactionCache.amountMain} + ${widget.transaction.amountMain}');

                      final newPositionMain = Position(
                          widget.positionMain.token,
                          widget.positionMain.amount -
                              widget.transactionCache.amountMain +
                              widget.transaction.amountMain,
                          widget.positionMain.time);

                      // if we find the position, we need to update it
                      await api.positions.update(widget.portfolio.id,
                          widget.transaction.tokenMain, newPositionMain);
                    } catch (e) {
                      // print(
                      //     'widget.positionMain : ${widget.positionMain.token} : ${widget.positionMain.amount}');
                      // if not, we should get an error then insert the new position
                      await api.positions.insert(
                          widget.portfolio.id,
                          Position(
                              widget.transaction.tokenMain,
                              widget.transaction.amountMain.toDouble(),
                              widget.transaction.time));
                    }

                    if (widget.transaction.withImpactOnSecondPosition)
                    // then regarding the Reference part of the transaction
                    {
                      try {
                        // print(
                        //     'widget.positionReference : ${widget.positionReference.token} : ${widget.positionReference.amount}');

                        final newPositionReference = Position(
                            widget.positionReference.token,
                            widget.positionReference.amount +
                                widget.transactionCache.amountReference -
                                widget.transaction.amountReference,
                            widget.positionReference.time);

                        // if we find the position, we need to update it
                        await api.positions.update(
                            widget.portfolio.id,
                            widget.transaction.tokenReference,
                            newPositionReference);
                      } catch (e) {
                        // print(
                        //     'widget.positionReference : ${widget.positionReference.token} : ${widget.positionReference.amount}');
                        // if not, we should get an error then insert the new position
                        await api.positions.insert(
                            widget.portfolio.id,
                            Position(
                                widget.transaction.tokenReference,
                                -widget.transaction.amountReference.toDouble(),
                                widget.transaction.time));
                      }
                    }

                    // delete the transaction
                    await api.transactions
                        .delete(widget.portfolio.id, widget.transaction.id);

                    // finally insert the transaction linked to the portfolio
                    await api.transactions.insert(
                        widget.portfolio.id,
                        Transaction(
                            widget.transaction.tokenMain,
                            widget.transaction.tokenReference,
                            widget.transaction.tokenFee,
                            widget.transaction.tokenPrice,
                            widget.transaction.amountMain.toDouble(),
                            widget.transaction.amountReference.toDouble(),
                            widget.transaction.amountFee.toDouble(),
                            widget.transaction.price.toDouble(),
                            widget.transaction.time,
                            widget.transaction.withImpactOnSecondPosition));

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
