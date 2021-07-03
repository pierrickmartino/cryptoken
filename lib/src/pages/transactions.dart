import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intl;
import 'package:web_dashboard/wallet/model/wallet_model.dart';

import '../api/api.dart';
import '../app.dart';
import '../widgets/dialogs.dart';
import '../widgets/portfolios_dropdown.dart';

final _priceFormat =
    intl.NumberFormat.currency(locale: 'de_CH', symbol: '', decimalDigits: 6);

bool _isLargeScreen(BuildContext context) {
  return MediaQuery.of(context).size.width > 960.0;
}

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({Key? key}) : super(key: key);
  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  WalletModel? _selected;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Column(
      children: [
        // PortfolioDropdown(
        //   api: appState.api.portfolios,
        //   onSelected: (portfolio) => setState(() => _selected = portfolio),
        // ),
        Expanded(
          child: _selected == null
              ? const Center(
                  child: CircularProgressIndicator(),
                )
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
  }) : super(
          key: ValueKey(portfolio.id),
        );

  final WalletModel portfolio;
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
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class TransactionTile extends StatelessWidget {
  TransactionTile({
    Key? key,
    required this.portfolio,
    required this.transaction,
  }) : super(key: key);

  final WalletModel portfolio;
  final Transaction transaction;

  Position? positionMain, positionReference;
  Transaction? transactionCache;

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<AppState>(context).api;

    Widget _transactionLabel() {
      switch (transaction.transactionType) {
        case 0:
          return Text(
            'Buy ${transaction.amountMain} ${transaction.tokenMain} at ${_priceFormat.format(transaction.price)} ${transaction.tokenPrice} against ${transaction.amountReference} ${transaction.tokenReference}',
            style: const TextStyle(fontSize: 14),
          );
        case 1:
          return Text(
            'Sell ${transaction.amountMain} ${transaction.tokenMain} at ${_priceFormat.format(transaction.price)} ${transaction.tokenPrice} against ${transaction.amountReference} ${transaction.tokenReference}',
            style: const TextStyle(fontSize: 14),
          );
        default:
          return const Text('N/A');
      }
    }

    return ListTile(
      title: _transactionLabel(),
      subtitle: Text(
        intl.DateFormat('dd/MM/yy HH:mm').format(transaction.time),
        style: const TextStyle(fontSize: 13),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () async {
              positionMain =
                  await api.positions.get(portfolio.id, transaction.tokenMain);
              positionReference = await api.positions
                  .get(portfolio.id, transaction.tokenReference);
              transactionCache = await api.transactions.insert(
                portfolio.id,
                Transaction(
                    transaction.transactionType,
                    transaction.tokenMain,
                    transaction.tokenReference,
                    transaction.tokenFee,
                    transaction.tokenPrice,
                    transaction.amountMain.toDouble(),
                    transaction.amountReference.toDouble(),
                    transaction.amountFee.toDouble(),
                    transaction.price.toDouble(),
                    transaction.time,
                    transaction.withImpactOnSecondPosition),
              );

              if (_isLargeScreen(context)) {
                await showDialog<EditTransactionDialog>(
                  context: context,
                  builder: (context) {
                    return EditTransactionDialog(
                      portfolio: portfolio,
                      transaction: transaction,
                      transactionCache: transactionCache!,
                      positionMain: positionMain!,
                      positionReference: positionReference!,
                    );
                  },
                );
              } else {
                await showGeneralDialog<EditTransactionDialog>(
                  context: context,
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return EditTransactionDialog(
                      portfolio: portfolio,
                      transaction: transaction,
                      transactionCache: transactionCache!,
                      positionMain: positionMain!,
                      positionReference: positionReference!,
                    );
                  },
                );
              }

              await api.transactions.delete(portfolio.id, transactionCache!.id);
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
                    0, //TODO - averagePurchasePrice
                    0, //TODO - purchaseAmount
                    0, //TODO - realizedGain
                    oldPositionMain.time);

                final oldPositionReference =
                    await Provider.of<AppState>(context, listen: false)
                        .api
                        .positions
                        .get(portfolio.id, transaction.tokenReference);

                final newPositionReference = Position(
                    oldPositionReference.token,
                    oldPositionReference.amount + transaction.amountReference,
                    0, //TODO - averagePurchasePrice
                    0, //TODO - purchaseAmount
                    0, //TODO - realizedGain
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
