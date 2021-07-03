import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:web_dashboard/src/api/api.dart';

import '../../src/app.dart';
import '../../constant.dart';

final _priceFormat =
    intl.NumberFormat.currency(locale: 'de_CH', symbol: '', decimalDigits: 6);

final _dateFormat = intl.DateFormat('dd/MM/yy HH:mm');

class RecentFiles extends StatefulWidget {
  const RecentFiles({
    Key? key,
  }) : super(key: key);

  @override
  _RecentFilesState createState() => _RecentFilesState();
}

class _RecentFilesState extends State<RecentFiles> {
  @override
  Widget build(BuildContext context) {
    //final appState = Provider.of<AppState>(context);

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
            'Recent Files',
            style: Theme.of(context).textTheme.subtitle1,
          ),
          SizedBox(
            width: double.infinity,
            child: Text(''),
            // FutureBuilder<List<Transaction>>(
            //   future: appState.api.transactions.listAll(),
            //   builder: (context, futureSnapshot) {
            //     if (!futureSnapshot.hasData) {
            //       return _buildLoadingIndicator();
            //     }
            //     return StreamBuilder<List<Transaction?>>(
            //       initialData: futureSnapshot.data,
            //       stream: appState.api.transactions.subscribeAll(),
            //       builder: (context, snapshot) {
            //         if (!snapshot.hasData) {
            //           return _buildLoadingIndicator();
            //         }
            //         return DataTable(
            //           horizontalMargin: 0,
            //           columnSpacing: defaultPadding,
            //           columns: const [
            //             DataColumn(
            //               label: Text('Type'),
            //             ),
            //             DataColumn(
            //               label: Text('Date'),
            //             ),
            //             DataColumn(
            //               label: Text('Amount'),
            //             ),
            //             DataColumn(
            //               label: Text('Price'),
            //             ),
            //             DataColumn(
            //               label: Text('Total'),
            //             ),
            //             DataColumn(
            //               label: Text('Fees (incl.)'),
            //             ),
            //           ],
            //           rows: List.generate(
            //             snapshot.data!.length,
            //             (index) => recentFileDataRow(snapshot.data![index]!),
            //           ),
            //         );
            //       },
            //     );
            //   },
            // ),
          ),
        ],
      ),
    );
  }
}

Widget _buildLoadingIndicator() {
  return const Center(
    child: CircularProgressIndicator(),
  );
}

DataRow recentFileDataRow(Transaction transactionInfo) {
  return DataRow(
    cells: [
      DataCell(_getTransactionTypeLabel(transactionInfo.transactionType)),
      DataCell(Text(_dateFormat.format(transactionInfo.time))),
      DataCell(
          Text('${transactionInfo.amountMain} ${transactionInfo.tokenMain}')),
      DataCell(Text(
          '${_priceFormat.format(transactionInfo.price)} ${transactionInfo.tokenPrice}')),
      DataCell(Text(
          '${transactionInfo.amountReference} ${transactionInfo.tokenReference}')),
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
