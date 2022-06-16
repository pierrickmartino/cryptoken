//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:web_dashboard/token/controller/token_controller.dart';
import 'package:web_dashboard/transaction/controller/transaction_controller.dart';
import 'package:web_dashboard/transaction/model/transaction_model.dart';

import '../../constant.dart';
import 'sell_transaction.dart';

final _priceFormat = intl.NumberFormat('#,##0.######', 'de_CH');

final _numberFormat =
    intl.NumberFormat.currency(locale: 'de_CH', symbol: '', decimalDigits: 2);

final _dateFormat = intl.DateFormat('dd/MM/yy HH:mm');

class RecentFiles extends StatelessWidget {
  const RecentFiles({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TransactionController transactionController =
        TransactionController.to;
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: const BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent transactions',
            style: Theme.of(context).textTheme.subtitle1,
          ),
          SizedBox(
            width: double.infinity,
            child:
                //Text(''),
                FutureBuilder<List<TransactionModel>>(
              future: transactionController.getFirestoreTopTransactionList(),
              builder: (context, futureSnapshot) {
                if (!futureSnapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return StreamBuilder<List<TransactionModel>>(
                  initialData: futureSnapshot.data,
                  stream:
                      transactionController.streamFirestoreTopTransactionList(),
                  builder: (context, snapshot) {
                    if (snapshot.data == null) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return DataTable(
                      horizontalMargin: 0,
                      columnSpacing: defaultPadding,
                      columns: const [
                        DataColumn(
                          label: Text('Wallet'),
                        ),
                        DataColumn(
                          label: Text('Type'),
                        ),
                        DataColumn(
                          label: Text('Date'),
                        ),
                        DataColumn(
                          label: Text('Token'),
                        ),
                        DataColumn(
                          label: Text('Amount'),
                        ),
                        DataColumn(
                          label: Text('Price'),
                        ),
                        // DataColumn(
                        //   label: Text('Unrealiz.'),
                        // ),
                        DataColumn(
                          label: Text('Total'),
                        ),
                        DataColumn(
                          label: Text('Fees (incl.)'),
                        ),
                        DataColumn(
                          label: Text(''),
                        ),
                      ],
                      rows: List.generate(
                        snapshot.data!.length,
                        (index) =>
                            recentFileDataRow(snapshot.data![index], context),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

DataRow recentFileDataRow(
    TransactionModel transactionInfo, BuildContext context) {
  final double transactionCost =
      (transactionInfo.amountMain * transactionInfo.price) +
          transactionInfo.amountFee;

  return DataRow(
    cells: [
      // Wallet
      DataCell(Text('${transactionInfo.walletId.substring(0, 5)}...')),
      // Type
      DataCell(_getTransactionTypeLabel(transactionInfo.transactionType)),
      // Date
      DataCell(Text(_dateFormat.format(transactionInfo.time))),
      // Token
      DataCell(Text(transactionInfo.tokenMain)),
      // Amount
      DataCell(Text('${transactionInfo.amountMain}')),
      // Price
      DataCell(Text(
          '${_priceFormat.format(transactionInfo.price)} ${transactionInfo.tokenPrice}')),
      // Unrealized PnL
      //DataCell(_getTransactionPnL(transactionInfo, context)),
      // Total
      DataCell(Text(
          '${_numberFormat.format(transactionCost)} ${transactionInfo.tokenReference}')),
      // Fees (incl.)
      DataCell(Text(
          '${_numberFormat.format(transactionInfo.amountFee)} ${transactionInfo.tokenFee}')),
      // Action
      DataCell(Wrap(
        children: [
          IconButton(
            padding: const EdgeInsets.all(0),
            icon: const Icon(Icons.money_off),
            onPressed: () {
              showGeneralDialog<SellTransactionDialog>(
                context: context,
                pageBuilder: (context, animation, secondaryAnimation) =>
                    SellTransactionDialog(
                  selectedTransaction: transactionInfo,
                ),
              );
            },
          ),
          IconButton(
            padding: const EdgeInsets.all(0),
            icon: const Icon(Icons.edit),
            onPressed: () {
              debugPrint('Button pressed');
            },
          ),
        ],
      )),
    ],
  );
}

Color _getPnLColor(double transactionPnL) {
  if (transactionPnL < 0) {
    return Colors.red;
  } else {
    return Colors.green;
  }
}

Widget _getTransactionPnL(
    TransactionModel transactionInfo, BuildContext context) {
  return GetBuilder<TokenController>(
      init: TokenController(),
      builder: (_) {
        final double transactionPnL =
            (_.tokenPriceGetX(transactionInfo.tokenMain) -
                    transactionInfo.price) *
                transactionInfo.amountMain; // TODO : Intégrer les frais

        final double transactionPnLPercentage =
            (_.tokenPriceGetX(transactionInfo.tokenMain) -
                    transactionInfo.price) /
                transactionInfo.price *
                100;

        final Color color = _getPnLColor(transactionPnL);

        return Text(
            '${_numberFormat.format(transactionPnLPercentage)}%  ${_numberFormat.format(transactionPnL)}',
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ));
      });
}

Widget _getTransactionTypeLabel(int index) {
  switch (index) {
    case 0:
      return const Text('Buy');
    case 1:
      return const Text('Sell');
    default:
      return const Text('');
  }
}
