import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:web_dashboard/transaction/controller/transaction_controller.dart';
import 'package:web_dashboard/transaction/model/transaction_model.dart';

import '../../constant.dart';

final _priceFormat =
    intl.NumberFormat.currency(locale: 'de_CH', symbol: '', decimalDigits: 6);

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
                //   FutureBuilder<List<TransactionModel>>(
                // future: transactionController.futureFirestoreTransactionList(),
                // builder: (context, futureSnapshot) {
                //   if (!futureSnapshot.hasData) {
                //     return const Center(
                //       child: CircularProgressIndicator(),
                //     );
                //   }
                //   return
                StreamBuilder<List<TransactionModel>>(
              //initialData: futureSnapshot.data,
              stream: transactionController.streamFirestoreTransactionList(),
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
                      label: Text('Amount'),
                    ),
                    DataColumn(
                      label: Text('Price'),
                    ),
                    DataColumn(
                      label: Text('Unrealiz.'),
                    ),
                    DataColumn(
                      label: Text('Total'),
                    ),
                    DataColumn(
                      label: Text('Fees (incl.)'),
                    ),
                  ],
                  rows: List.generate(
                    snapshot.data!.length,
                    (index) => recentFileDataRow(snapshot.data![index]),
                  ),
                );
              },
              //);
              //},
            ),
          ),
        ],
      ),
    );
  }
}

DataRow recentFileDataRow(TransactionModel transactionInfo) {
  return DataRow(
    cells: [
      // Wallet
      DataCell(Text('${transactionInfo.walletId.substring(0, 5)}...')),
      // Type
      DataCell(_getTransactionTypeLabel(transactionInfo.transactionType)),
      // Date
      DataCell(Text(_dateFormat.format(transactionInfo.time))),
      // Amount
      DataCell(
          Text('${transactionInfo.amountMain} ${transactionInfo.tokenMain}')),
      // Price
      DataCell(Text(
          '${_priceFormat.format(transactionInfo.price)} ${transactionInfo.tokenPrice}')),
      // Unrealized PnL
      DataCell(Text('0')),
      // Total
      DataCell(Text(
          '${transactionInfo.amountReference} ${transactionInfo.tokenReference}')),
      // Fees (incl.)
      DataCell(
          Text('${transactionInfo.amountFee} ${transactionInfo.tokenFee}')),
    ],
  );
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
