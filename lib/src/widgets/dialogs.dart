import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_dashboard/src/api/api.dart';
import 'package:web_dashboard/src/widgets/transaction_forms.dart';
import 'package:web_dashboard/wallet/model/wallet_model.dart';

import '../app.dart';

bool _isLargeScreen(BuildContext context) {
  return MediaQuery.of(context).size.width > 960.0;
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
  final WalletModel portfolio;
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

    if (_isLargeScreen(context)) {
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
                _editTransactionForm(api),
              ],
            ),
          ),
        ],
      );
    } else {
      return Card(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Text('Edit Transaction',
                    style: Theme.of(context).textTheme.headline6),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(children: [
                  _editTransactionForm(api),
                ]),
              ),
            ],
          ),
        ),
      );
    }
  }

  EditTransactionForm _editTransactionForm(DashboardApi api) {
    return EditTransactionForm(
      transaction: widget.transaction,
      portfolio: widget.portfolio,
      positionMain: widget.positionMain,
      positionReference: widget.positionReference,
      showToogleSwitch: false,
      onDone: (shouldUpdate) async {
        if (shouldUpdate) {
          // Main axis of the transaction (Buy or Sell Main against Reference)
          try {
            Position newPositionMain;

            // Buy
            if (widget.transaction.transactionType == 0) {
              newPositionMain = Position(
                widget.positionMain.token,
                widget.positionMain.amount -
                    widget.transactionCache.amountMain +
                    widget.transaction.amountMain,

                (((widget.positionMain.purchaseAmount -
                                widget.transactionCache.amountMain) *
                            widget.positionMain.averagePurchasePrice) +
                        (widget.transaction.amountMain +
                            widget.transaction.price)) /
                    ((widget.positionMain.purchaseAmount -
                            widget.transactionCache.amountMain) +
                        widget.transaction
                            .amountMain), //TODO - averagePurchasePrice

                widget.positionMain.purchaseAmount -
                    widget.transactionCache.amountMain +
                    widget.transaction.amountMain,
                widget.positionMain.realizedGain, // Not used for Buy
                widget.positionMain.time,
              );
            }

            // Sell
            else {
              newPositionMain = Position(
                widget.positionMain.token,
                widget.positionMain.amount +
                    widget.transactionCache.amountMain -
                    widget.transaction.amountMain,
                widget.positionMain.averagePurchasePrice, // Not used for Sell
                widget.positionMain.purchaseAmount, // Not used for Sell
                widget.positionMain.realizedGain, //TODO - realizedGain
                widget.positionMain.time,
              );
            }

            // if we are able to find the position, we need to update it
            await api.positions.update(
              widget.portfolio.id,
              widget.transaction.tokenMain,
              newPositionMain,
            );
          } catch (e) {
            // if not, we should catch an error then insert the new position

            //TODO : Is this section really usefull ?
            // It seems that we are already creating the missing
            // position in the validate function of the form

            // Buy
            if (widget.transaction.transactionType == 0) {
              await api.positions.insert(
                widget.portfolio.id,
                Position(
                  widget.transaction.tokenMain,
                  widget.transaction.amountMain.toDouble(),
                  widget.transaction.amountReference.toDouble() /
                      widget.transaction.amountMain
                          .toDouble(), //TODO - averagePurchasePrice
                  0, //TODO - purchaseAmount
                  0, //TODO - realizedGain
                  widget.transaction.time,
                ),
              );
            }
          }

          // Sell
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text('This operation is not authorized'),
            ),
          );

          if (widget.transaction.withImpactOnSecondPosition)
          // Reference axis of the transaction (Buy or Sell Main against Reference)
          {
            try {
              Position newPositionReference;

              // Buy
              if (widget.transaction.transactionType == 0) {
                newPositionReference = Position(
                  widget.positionReference.token,
                  widget.positionReference.amount +
                      widget.transactionCache.amountReference -
                      widget.transaction.amountReference,
                  widget.positionReference
                      .averagePurchasePrice, //TODO - averagePurchasePrice
                  widget
                      .positionReference.purchaseAmount, //TODO - purchaseAmount
                  widget.positionReference.realizedGain, //TODO - realizedGain
                  widget.positionReference.time,
                );
              }

              // Sell
              else {
                newPositionReference = Position(
                  widget.positionReference.token,
                  widget.positionReference.amount -
                      widget.transactionCache.amountReference +
                      widget.transaction.amountReference,
                  widget.positionReference
                      .averagePurchasePrice, //TODO - averagePurchasePrice
                  widget.positionReference.purchaseAmount,
                  widget.positionReference.realizedGain, //TODO - realizedGain
                  widget.positionReference.time,
                );
              }

              // if we are able to find the position, we need to update it
              await api.positions.update(widget.portfolio.id,
                  widget.transaction.tokenReference, newPositionReference);
            } catch (e) {
              // if not, we should catch an error then insert the new position
              await api.positions.insert(
                widget.portfolio.id,
                Position(
                  widget.transaction.tokenReference,
                  -widget.transaction.amountReference.toDouble(),
                  0, //TODO - averagePurchasePrice
                  0, //TODO - purchaseAmount
                  0, //TODO - realizedGain
                  widget.transaction.time,
                ),
              );
            }
          }

          // delete the transaction
          await api.transactions
              .delete(widget.portfolio.id, widget.transaction.id);

          // finally insert the transaction linked to the portfolio
          await api.transactions.insert(
            widget.portfolio.id,
            Transaction(
                widget.transaction.transactionType,
                widget.transaction.tokenMain,
                widget.transaction.tokenReference,
                widget.transaction.tokenFee,
                widget.transaction.tokenPrice,
                widget.transaction.amountMain.toDouble(),
                widget.transaction.amountReference.toDouble(),
                widget.transaction.amountFee.toDouble(),
                widget.transaction.price.toDouble(),
                widget.transaction.time,
                widget.transaction.withImpactOnSecondPosition),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaction updated'),
            ),
          );
        }
        Navigator.of(context).pop();
      },
    );
  }
}
