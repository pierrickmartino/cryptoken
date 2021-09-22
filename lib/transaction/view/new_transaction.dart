import 'dart:math';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart' as intl;
import 'package:logger/logger.dart';
import 'package:synchronized/extension.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:web_dashboard/constant.dart';
import 'package:web_dashboard/position/controller/position_controller.dart';
import 'package:web_dashboard/position/model/position_model.dart';
import 'package:web_dashboard/src/class/crypto.dart';
import 'package:web_dashboard/src/hive/crypto_hive.dart';
import 'package:web_dashboard/transaction/controller/transaction_controller.dart';
import 'package:web_dashboard/transaction/model/transaction_model.dart';
import 'package:web_dashboard/wallet/model/wallet_model.dart';

bool _isLargeScreen(BuildContext context) {
  return MediaQuery.of(context).size.width > 960.0;
}

var logger = Logger(printer: PrettyPrinter());
var loggerNoStack = Logger(printer: PrettyPrinter(methodCount: 0));

const cryptoListBox = 'cryptoList';

class NewTransactionDialog extends StatelessWidget {
  const NewTransactionDialog({Key? key, this.selectedWallet}) : super(key: key);

  final WalletModel? selectedWallet;

  @override
  Widget build(BuildContext context) {
    /**
   * Dans le cas d'un écran mobile, on favorisera le fullscreen pour la saisie.
   * En revanche, si l'on est sur LargeScreen, on essaiera de trouver un 
   * ratio adequat.
   * 
   * https://medium.com/flutter-community/a-visual-guide-to-input-decorations-for-flutter-textfield-706cf1877e25
   */

    if (_isLargeScreen(context)) {
      return SimpleDialog(
        title: const Text('New Transaction'),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 1 / 4,
            child: Column(
              children: [
                NewTransactionForm(
                  selectedWallet: selectedWallet,
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return SimpleDialog(
        title: const Text('New Transaction'),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 9 / 10,
            child: Column(
              children: [
                NewTransactionForm(
                  selectedWallet: selectedWallet,
                ),
              ],
            ),
          ),
        ],
      );
    }
  }
}

class NewTransactionForm extends StatelessWidget {
  NewTransactionForm({Key? key, this.selectedWallet}) : super(key: key);

  final WalletModel? selectedWallet;
  final _formKey = GlobalKey<FormState>();
  final TransactionController transactionController = TransactionController.to;
  final PositionController positionController = PositionController.to;

  // final WalletModel? _selected = WalletModel(name: 'Empty');

  final TransactionModel _transaction = TransactionModel(
    walletId: '',
    transactionType: 0,
    tokenMain: 'BTC',
    tokenMainName: 'Bitcoin',
    tokenReference: 'USDT',
    tokenReferenceName: 'Tether',
    tokenFee: 'USDT',
    tokenFeeName: 'Tether',
    tokenPrice: 'USDT',
    tokenPriceName: 'Tether',
    amountMain: 0,
    amountReference: 0,
    amountFee: 0,
    price: 0,
    time: DateTime.now(),
    withImpactOnSecondPosition: false,
    transactionRefId: '',
  );

  @override
  Widget build(BuildContext context) {
    _transaction.transactionType = 0;

    loggerNoStack.i('Buy transaction - New');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Padding(
              //   padding: const EdgeInsets.all(0),
              //   child: Center(
              //     child: ToggleSwitch(
              //       // 0 Buy | 1 Sell | 2 Deposit (todo) | 3 Withrawal (todo)
              //       labels: const [
              //         'Buy',
              //         'Sell' /*, 'Deposit', 'Withdrawal'*/
              //       ],
              //       minHeight: 30,
              //       activeBgColor: primaryColor,
              //       activeFgColor: Colors.white,
              //       initialLabelIndex: _transaction.transactionType,
              //       onToggle: (index) {
              //         _transaction.transactionType = index;
              //       },
              //     ),
              //   ),
              // ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _transaction.amountMain.toCurrencyString(
                        mantissaLength: 6,
                        thousandSeparator:
                            ThousandSeparator.SpaceAndPeriodMantissa,
                      ),
                      inputFormatters: [
                        MoneyInputFormatter(
                          mantissaLength: 6,
                          thousandSeparator:
                              ThousandSeparator.SpaceAndPeriodMantissa,
                        ),
                      ],
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.checklist),
                        //prefixText: 'USD ',
                        labelText: 'Amount',
                        isDense: !_isLargeScreen(context),
                        border: const OutlineInputBorder(),
                      ),
                      textAlign: TextAlign.end,
                      validator: (value) {
                        if (value!.substring(0, 1) == '-') {
                          return 'Amount must be greather than 0';
                        }

                        try {
                          final double amount = double.parse(
                            value.toCurrencyString(
                                mantissaLength: 6,
                                thousandSeparator: ThousandSeparator.None),
                          );
                          Logger(printer: SimplePrinter())
                              .i('Amount : $amount');
                        } catch (e) {
                          return 'Please enter a whole number';
                        }
                        return null;
                      },
                      onChanged: (newValue) {
                        try {
                          _transaction.amountMain = double.parse(
                            newValue.toCurrencyString(
                                mantissaLength: 6,
                                thousandSeparator: ThousandSeparator.None),
                          );
                        } on FormatException {
                          debugPrint(
                              'Transaction cannot contain "$newValue". Expected a number');
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 120,
                    child: FutureBuilder<Crypto>(
                      future: _getCryptoBySymbol(_transaction.tokenMain),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return DropdownSearch<Crypto>(
                            showSearchBox: true,
                            autoFocusSearchBox: true,
                            dropdownSearchDecoration: InputDecoration(
                              labelText: '',
                              border: InputBorder.none,
                              isDense: !_isLargeScreen(context),
                            ),
                            onFind: (String filter) => _getCryptoList(),
                            compareFn: (i, s) => i.isEqual(s!),
                            popupItemBuilder: _customPopupItemBuilder,
                            dropdownBuilder: _customDropDown,
                            dropdownButtonBuilder: (_) => const Padding(
                              padding: EdgeInsets.only(bottom: 16),
                              child: Icon(
                                Icons.arrow_drop_down,
                                size: 18,
                              ),
                            ),
                            selectedItem: snapshot.data,
                            onChanged: (newValue) async {
                              _transaction
                                ..tokenMain = newValue!.symbol
                                ..tokenMainName = newValue.name;
                            },
                          );
                        } else if (snapshot.hasError) {
                          return Text('${snapshot.error}');
                        }

                        return const Text('');
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _transaction.price.toCurrencyString(
                        mantissaLength: 6,
                        thousandSeparator:
                            ThousandSeparator.SpaceAndPeriodMantissa,
                      ),
                      inputFormatters: [
                        MoneyInputFormatter(
                          mantissaLength: 6,
                        ),
                      ],
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.checklist),
                        //prefixText: 'USD ',
                        labelText: 'Price',
                        isDense: !_isLargeScreen(context),
                        border: const OutlineInputBorder(),
                      ),
                      textAlign: TextAlign.end,
                      validator: (value) {
                        if (value!.substring(0, 1) == '-') {
                          return 'Amount must be greather than 0';
                        }
                        try {
                          final double price = double.parse(
                            value.toCurrencyString(
                                mantissaLength: 6,
                                thousandSeparator: ThousandSeparator.None),
                          );
                          Logger(printer: SimplePrinter()).i('Price : $price');
                        } catch (e) {
                          return 'Please enter a whole number';
                        }
                        return null;
                      },
                      onChanged: (newValue) {
                        try {
                          _transaction.price = double.parse(
                            newValue.toCurrencyString(
                                mantissaLength: 6,
                                thousandSeparator: ThousandSeparator.None),
                          );
                        } on FormatException {
                          Logger(printer: SimplePrinter()).e(
                              'Transaction cannot contain "$newValue". Expected a number');
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 120,
                    child: FutureBuilder<Crypto>(
                      future: _getCryptoBySymbol(_transaction.tokenPrice),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return DropdownSearch<Crypto>(
                            showSearchBox: true,
                            autoFocusSearchBox: true,
                            dropdownSearchDecoration: InputDecoration(
                              labelText: '',
                              isDense: !_isLargeScreen(context),
                              border: InputBorder.none,
                            ),
                            onFind: (String filter) => _getCryptoList(),
                            compareFn: (i, s) => i.isEqual(s!),
                            popupItemBuilder: _customPopupItemBuilder,
                            dropdownBuilder: _customDropDown,
                            dropdownButtonBuilder: (_) => const Padding(
                              padding: EdgeInsets.only(bottom: 16),
                              child: Icon(
                                Icons.arrow_drop_down,
                                size: 18,
                              ),
                            ),
                            selectedItem: snapshot.data,
                            onChanged: (newValue) async {
                              _transaction
                                ..tokenPrice = newValue!.symbol
                                ..tokenPriceName = newValue.name;
                            },
                          );
                        } else if (snapshot.hasError) {
                          return Text('${snapshot.error}');
                        }

                        return const Text('');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      initialValue: intl.DateFormat('dd-MM-yyyy')
                          .format(_transaction.time),
                      inputFormatters: [MaskedInputFormatter('00-00-0000')],
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.calendar_today),
                        //prefixText: 'USD ',
                        labelText: 'Date',
                        isDense: !_isLargeScreen(context),
                        border: const OutlineInputBorder(),
                      ),
                      textAlign: TextAlign.end,
                      validator: (value) {
                        if (!RegExp(
                                r'^([0][1-9]|[12][0-9]|3[01])[\/\-]([0][1-9]|1[012])[\/\-]\d{4}?$')
                            .hasMatch(value!)) {
                          return 'Enter a correct date format';
                        } else {
                          return null;
                        }
                      },
                      onChanged: (value) {
                        if (value.length == 10) {
                          value = value.substring(6, 10) +
                              value.substring(3, 5) +
                              value.substring(0, 2);
                          value =
                              '$value ${intl.DateFormat('HH:mm').format(_transaction.time)}:00';
                          try {
                            _transaction.time =
                                DateTime.parse(value); // "20120227 13:27:00"
                            Logger(printer: SimplePrinter()).i('Date : $value');
                          } on FormatException {
                            Logger(printer: SimplePrinter()).e('Date : $value');
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 120,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      initialValue:
                          intl.DateFormat('HH:mm').format(_transaction.time),
                      inputFormatters: [MaskedInputFormatter('00:00')],
                      decoration: InputDecoration(
                        //prefixText: 'USD ',
                        prefixIcon: const Icon(Icons.timer),
                        labelText: 'Time',
                        isDense: !_isLargeScreen(context),
                        border: const OutlineInputBorder(),
                      ),
                      textAlign: TextAlign.end,
                      validator: (value) {
                        if (!RegExp(
                                r'^((0?[1-9]|[1][0-9]|[2][0-3])[:]([0-5][0-9])?)?$')
                            .hasMatch(value!)) {
                          return 'Enter a correct time format';
                        } else {
                          return null;
                        }
                      },
                      onChanged: (value) {
                        if (value.length == 5) {
                          value =
                              '${intl.DateFormat('yyyyMMdd').format(_transaction.time)} $value:00';
                          try {
                            _transaction.time =
                                DateTime.parse(value); // "20120227 13:27:00"
                            Logger(printer: SimplePrinter()).i('date : $value');
                          } on FormatException {
                            Logger(printer: SimplePrinter()).e('date : $value');
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),

              // ListTile(
              //   contentPadding: const EdgeInsets.symmetric(horizontal: 6),
              //   leading: SizedBox(
              //     width: 100,
              //     child: TextFormField(
              //       decoration: const InputDecoration(
              //         border: InputBorder.none,
              //         focusedBorder: InputBorder.none,
              //         enabledBorder: InputBorder.none,
              //         errorBorder: InputBorder.none,
              //         disabledBorder: InputBorder.none,
              //         isDense: true,
              //       ),
              //       initialValue: 'Total',
              //       style: const TextStyle(fontSize: 14),
              //     ),
              //   ),
              //   title: Row(
              //     children: [
              //       Expanded(
              //         child: TextFormField(
              //           style: const TextStyle(fontSize: 14),
              //           textAlign: TextAlign.end,
              //           initialValue:
              //               _transaction.amountReference.toCurrencyString(
              //             mantissaLength: 6,
              //             thousandSeparator:
              //                 ThousandSeparator.SpaceAndPeriodMantissa,
              //           ),
              //           decoration: InputDecoration(
              //             isDense: !_isLargeScreen(context),
              //           ),
              //           keyboardType: TextInputType.number,
              //           inputFormatters: [
              //             MoneyInputFormatter(
              //               mantissaLength: 6,
              //               thousandSeparator:
              //                   ThousandSeparator.SpaceAndPeriodMantissa,
              //             )
              //           ],
              //           validator: (value) {
              //             try {
              //               double.parse(
              //                 value!.toCurrencyString(
              //                     mantissaLength: 6,
              //                     thousandSeparator: ThousandSeparator.None),
              //               );
              //             } catch (e) {
              //               return 'Please enter a whole number';
              //             }
              //             return null;
              //           },
              //           onChanged: (newValue) {
              //             try {
              //               _transaction
              //                 ..price = double.parse(
              //                       newValue.toCurrencyString(
              //                           mantissaLength: 6,
              //                           thousandSeparator:
              //                               ThousandSeparator.None),
              //                     ) /
              //                     _transaction.amountMain
              //                 ..amountReference = double.parse(
              //                   newValue.toCurrencyString(
              //                       mantissaLength: 6,
              //                       thousandSeparator: ThousandSeparator.None),
              //                 );
              //             } on FormatException {
              //               debugPrint(
              //                   'Transaction cannot contain "$newValue". Expected a number');
              //             }
              //           },
              //         ),
              //       ),
              //       const SizedBox(
              //         width: 10,
              //       ),
              //       SizedBox(
              //         width: 85,
              //         child: FutureBuilder<Crypto>(
              //           future: _getCryptoBySymbol(_transaction.tokenReference),
              //           builder: (context, snapshot) {
              //             if (snapshot.hasData) {
              //               return DropdownSearch<Crypto>(
              //                 mode: Mode.BOTTOM_SHEET,
              //                 showSearchBox: true,
              //                 autoFocusSearchBox: true,
              //                 dropdownSearchDecoration: const InputDecoration(
              //                   border: InputBorder.none,
              //                   focusedBorder: InputBorder.none,
              //                   enabledBorder: InputBorder.none,
              //                   errorBorder: InputBorder.none,
              //                   disabledBorder: InputBorder.none,
              //                   isDense: true,
              //                 ),
              //                 onFind: (String filter) => _getCryptoList(),
              //                 compareFn: (i, s) => i.isEqual(s!),
              //                 dropdownButtonBuilder: (_) => const Padding(
              //                   padding: EdgeInsets.all(6),
              //                   child: Icon(
              //                     Icons.arrow_drop_down,
              //                     size: 18,
              //                     color: Colors.black,
              //                   ),
              //                 ),
              //                 popupItemBuilder: _customPopupItemBuilder,
              //                 dropdownBuilder: _customDropDown,
              //                 selectedItem: snapshot.data,
              //                 onChanged: (newValue) async {
              //                   _transaction
              //                     ..tokenReference = newValue!.symbol
              //                     ..tokenReferenceName = newValue.name;
              //                   // widget.positionReference.token =
              //                   //     newValue.symbol;
              //                 },
              //               );
              //             } else if (snapshot.hasError) {
              //               return Text('${snapshot.error}');
              //             }

              //             return const Text('');
              //           },
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              // ListTile(
              //   contentPadding: const EdgeInsets.symmetric(horizontal: 6),
              //   leading: SizedBox(
              //     width: 100,
              //     child: TextFormField(
              //       decoration: const InputDecoration(
              //         border: InputBorder.none,
              //         focusedBorder: InputBorder.none,
              //         enabledBorder: InputBorder.none,
              //         errorBorder: InputBorder.none,
              //         disabledBorder: InputBorder.none,
              //         isDense: true,
              //       ),
              //       initialValue: 'Fees (incl.)',
              //       style: const TextStyle(fontSize: 14),
              //     ),
              //   ),
              //   title: Row(
              //     children: [
              //       Expanded(
              //         child: TextFormField(
              //           textAlign: TextAlign.end,
              //           initialValue: _transaction.amountFee.toCurrencyString(
              //             mantissaLength: 6,
              //             thousandSeparator:
              //                 ThousandSeparator.SpaceAndPeriodMantissa,
              //           ),
              //           style: const TextStyle(fontSize: 14),
              //           decoration: InputDecoration(
              //             isDense: !_isLargeScreen(context),
              //           ),
              //           keyboardType: TextInputType.number,
              //           inputFormatters: [
              //             MoneyInputFormatter(
              //               mantissaLength: 6,
              //               thousandSeparator:
              //                   ThousandSeparator.SpaceAndPeriodMantissa,
              //             )
              //           ],
              //           validator: (value) {
              //             try {
              //               double.parse(
              //                 value!.toCurrencyString(
              //                     mantissaLength: 6,
              //                     thousandSeparator: ThousandSeparator.None),
              //               );
              //             } catch (e) {
              //               return 'Please enter a whole number';
              //             }
              //             return null;
              //           },
              //           onChanged: (newValue) {
              //             try {
              //               _transaction.amountFee = double.parse(
              //                 newValue.toCurrencyString(
              //                     mantissaLength: 6,
              //                     thousandSeparator: ThousandSeparator.None),
              //               );
              //             } on FormatException {
              //               debugPrint(
              //                   'Transaction cannot contain "$newValue". Expected a number');
              //             }
              //           },
              //         ),
              //       ),
              //       const SizedBox(
              //         width: 10,
              //       ),
              //       SizedBox(
              //         width: 85,
              //         child: FutureBuilder<Crypto>(
              //           future: _getCryptoBySymbol(_transaction.tokenFee),
              //           builder: (context, snapshot) {
              //             if (snapshot.hasData) {
              //               return DropdownSearch<Crypto>(
              //                 mode: Mode.BOTTOM_SHEET,
              //                 showSearchBox: true,
              //                 autoFocusSearchBox: true,
              //                 dropdownSearchDecoration: const InputDecoration(
              //                   border: InputBorder.none,
              //                   focusedBorder: InputBorder.none,
              //                   enabledBorder: InputBorder.none,
              //                   errorBorder: InputBorder.none,
              //                   disabledBorder: InputBorder.none,
              //                   isDense: true,
              //                 ),
              //                 onFind: (String filter) => _getCryptoList(),
              //                 compareFn: (i, s) => i.isEqual(s!),
              //                 dropdownButtonBuilder: (_) => const Padding(
              //                   padding: EdgeInsets.all(6),
              //                   child: Icon(
              //                     Icons.arrow_drop_down,
              //                     size: 18,
              //                     color: Colors.black,
              //                   ),
              //                 ),
              //                 popupItemBuilder: _customPopupItemBuilder,
              //                 dropdownBuilder: _customDropDown,
              //                 selectedItem: snapshot.data,
              //                 onChanged: (newValue) async {
              //                   _transaction
              //                     ..tokenFee = newValue!.symbol
              //                     ..tokenFeeName = newValue.name;
              //                 },
              //               );
              //             } else if (snapshot.hasError) {
              //               return Text('${snapshot.error}');
              //             }

              //             return const Text('');
              //           },
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'with impact on the Total token',
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.end,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    width: 90,
                    child: ToggleSwitch(
                      // 0 Yes | 1 No
                      labels: const ['Y', 'N'],
                      minHeight: 30,
                      minWidth: 44,
                      fontSize: 12,
                      activeBgColor: primaryColor,
                      activeFgColor: Colors.white,
                      initialLabelIndex:
                          _transaction.withImpactOnSecondPosition ? 0 : 1,
                      onToggle: (index) {
                        if (index == 0) {
                          _transaction.withImpactOnSecondPosition = true;
                        } else {
                          _transaction.withImpactOnSecondPosition = false;
                        }
                      },
                    ),
                  ),
                ],
              ),
              // ListTile(
              //   contentPadding: const EdgeInsets.symmetric(horizontal: 6),
              //   leading: const SizedBox(
              //     width: 50,
              //     child: Icon(Icons.info),
              //   ),
              //   title: Row(
              //     children: [
              //       const Expanded(
              //         child: Text(
              //           'with impact on the Total token',
              //           style: TextStyle(fontSize: 14),
              //           textAlign: TextAlign.end,
              //         ),
              //       ),
              //       const SizedBox(
              //         width: 10,
              //       ),
              //       SizedBox(
              //         width: 90,
              //         child: ToggleSwitch(
              //           // 0 Yes | 1 No
              //           labels: const ['Y', 'N'],
              //           minHeight: 30,
              //           minWidth: 44,
              //           fontSize: 12,
              //           activeBgColor: primaryColor,
              //           activeFgColor: Colors.white,
              //           initialLabelIndex:
              //               _transaction.withImpactOnSecondPosition ? 0 : 1,
              //           onToggle: (index) {
              //             if (index == 0) {
              //               _transaction.withImpactOnSecondPosition = true;
              //             } else {
              //               _transaction.withImpactOnSecondPosition = false;
              //             }
              //           },
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              const Divider(
                height: 40,
                thickness: 1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back<void>();
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // New transaction creation

                          final PositionModel _positionMain = PositionModel(
                            walletId: '',
                            token: 'BTC',
                            tokenName: 'Bitcoin',
                            amount: 0,
                            averageCost: 0,
                            purchaseAmount: 0,
                            sellAmount: 0,
                            realizedPnL: 0,
                            cost: 0,
                            time: DateTime.now(),
                            color: Color.fromARGB(
                                    Random().nextInt(256),
                                    Random().nextInt(256),
                                    Random().nextInt(256),
                                    Random().nextInt(256))
                                .value,
                          );

                          final PositionModel _positionReference =
                              PositionModel(
                                  walletId: '',
                                  token: 'USDT',
                                  tokenName: 'Tether',
                                  amount: 0,
                                  averageCost: 0,
                                  purchaseAmount: 0,
                                  sellAmount: 0,
                                  realizedPnL: 0,
                                  cost: 0,
                                  time: DateTime.now(),
                                  color: Color.fromARGB(
                                          Random().nextInt(256),
                                          Random().nextInt(256),
                                          Random().nextInt(256),
                                          Random().nextInt(256))
                                      .value);

                          final TransactionModel _newTransaction =
                              TransactionModel(
                            walletId: selectedWallet!.id,
                            tokenMain: _transaction.tokenMain,
                            tokenMainName: _transaction.tokenMainName,
                            tokenReference: _transaction.tokenReference,
                            tokenReferenceName: _transaction.tokenReferenceName,
                            tokenFee: _transaction.tokenFee,
                            tokenFeeName: _transaction.tokenFeeName,
                            tokenPrice: _transaction.tokenPrice,
                            tokenPriceName: _transaction.tokenPriceName,
                            amountMain: _transaction.amountMain,
                            amountReference: _transaction.amountReference,
                            amountFee: _transaction.amountFee,
                            price: _transaction.price,
                            transactionType: _transaction.transactionType,
                            withImpactOnSecondPosition:
                                _transaction.withImpactOnSecondPosition,
                            time: _transaction.time,
                            transactionRefId: '',
                          );

                          try {
                            // Control if the position MAIN already exists

                            await synchronized(() async {
                              final PositionModel _position =
                                  await positionController.getFirestorePosition(
                                      _newTransaction.tokenMain);
                              _positionMain
                                ..walletId = _position.walletId
                                ..token = _position.token
                                ..tokenName = _position.tokenName
                                ..amount = _position.amount
                                ..averageCost = _position.averageCost
                                ..purchaseAmount = _position.purchaseAmount
                                ..sellAmount = _position.sellAmount
                                ..realizedPnL = _position.realizedPnL
                                ..cost = _position.cost
                                ..time = _position.time;
                            });
                          } catch (e) {
                            // If not, we should get an error then insert the new position MAIN

                            await synchronized(() async {
                              final PositionModel _position =
                                  await positionController
                                      .insertFirestorePosition(PositionModel(
                                          walletId: selectedWallet!.id,
                                          token: _newTransaction.tokenMain,
                                          tokenName:
                                              _newTransaction.tokenMainName,
                                          amount: 0,
                                          averageCost: 0,
                                          purchaseAmount: 0,
                                          sellAmount: 0,
                                          realizedPnL: 0,
                                          cost: 0,
                                          time: DateTime.now(),
                                          color: Color.fromARGB(
                                                  Random().nextInt(256),
                                                  Random().nextInt(256),
                                                  Random().nextInt(256),
                                                  Random().nextInt(256))
                                              .value));

                              _positionMain
                                ..walletId = _position.walletId
                                ..token = _position.token
                                ..tokenName = _position.tokenName
                                ..amount = _position.amount
                                ..averageCost = _position.averageCost
                                ..purchaseAmount = _position.purchaseAmount
                                ..sellAmount = _position.sellAmount
                                ..realizedPnL = _position.realizedPnL
                                ..cost = _position.cost
                                ..time = _position.time;
                            });
                          }

                          try {
                            // Control if the position REF already exists

                            await synchronized(() async {
                              final PositionModel _position =
                                  await positionController.getFirestorePosition(
                                      _newTransaction.tokenReference);

                              _positionReference
                                ..walletId = _position.walletId
                                ..token = _position.token
                                ..tokenName = _position.tokenName
                                ..amount = _position.amount
                                ..averageCost = _position.averageCost
                                ..purchaseAmount = _position.purchaseAmount
                                ..sellAmount = _position.sellAmount
                                ..realizedPnL = _position.realizedPnL
                                ..cost = _position.cost
                                ..time = _position.time;
                            });
                          } catch (e) {
                            // If not, we should get an error then insert the new position REF

                            await synchronized(() async {
                              final PositionModel _position =
                                  await positionController
                                      .insertFirestorePosition(PositionModel(
                                          walletId: selectedWallet!.id,
                                          token: _newTransaction.tokenReference,
                                          tokenName: _newTransaction
                                              .tokenReferenceName,
                                          amount: 0,
                                          averageCost: 0,
                                          purchaseAmount: 0,
                                          sellAmount: 0,
                                          realizedPnL: 0,
                                          cost: 0,
                                          time: DateTime.now(),
                                          color: Color.fromARGB(
                                                  Random().nextInt(256),
                                                  Random().nextInt(256),
                                                  Random().nextInt(256),
                                                  Random().nextInt(256))
                                              .value));

                              _positionReference
                                ..walletId = _position.walletId
                                ..token = _position.token
                                ..tokenName = _position.tokenName
                                ..amount = _position.amount
                                ..averageCost = _position.averageCost
                                ..purchaseAmount = _position.purchaseAmount
                                ..sellAmount = _position.sellAmount
                                ..realizedPnL = _position.realizedPnL
                                ..cost = _position.cost
                                ..time = _position.time;
                            });
                          }

                          // Main axis of the transaction (Buy or Sell Main against Reference)
                          PositionModel newPositionMain;

                          /**
                           * ------------------------------------------------------------------------
                           * WARNING
                           * ------------------------------------------------------------------------
                           * Pour l'instant les Fees peuvent être modifié au niveau de leur devise
                           * mais dans l'idéal on devrait toujours être en devise de référence (USD)
                           */

                          loggerNoStack.i(
                              'Buy transaction - ${_positionMain.token} - ${_positionMain.tokenName}- averageCost calculation');

                          Logger(printer: SimplePrinter()).v(
                              '_positionMain.purchaseAmount : ${_positionMain.purchaseAmount}');
                          Logger(printer: SimplePrinter()).v(
                              '_positionMain.averageCost : ${_positionMain.averageCost}');
                          Logger(printer: SimplePrinter())
                              .v('_positionMain.cost : ${_positionMain.cost}');

                          Logger(printer: SimplePrinter())
                              .v('_transaction.price : ${_transaction.price}');
                          Logger(printer: SimplePrinter()).v(
                              '_transaction.amountMain : ${_transaction.amountMain}');
                          Logger(printer: SimplePrinter()).v(
                              '_transaction.amountFee : ${_transaction.amountFee}');

                          /* = Coût réel de la transaction en incluant les frais */
                          Logger(printer: SimplePrinter()).v(
                              'transactionCost : ${_transaction.amountMain} * ${_transaction.price} + ${_transaction.amountFee}');

                          final double transactionCost =
                              _transaction.amountMain * _transaction.price +
                                  _transaction.amountFee;

                          /* = Coùt courant de la position en y ajoutant la transaction en cours */
                          Logger(printer: SimplePrinter()).v(
                              'runningCost : ${_positionMain.cost} + $transactionCost');

                          final double runningCost =
                              _positionMain.cost + transactionCost;

                          /* = Position courante du token en ajoutant la transaction en cours */
                          Logger(printer: SimplePrinter()).v(
                              'runningPosition : ${_positionMain.amount} + ${_transaction.amountMain}');

                          final double runningPosition =
                              _positionMain.amount + _transaction.amountMain;

                          /* = Somme des quantités totales achetées en ajoutant la transaction en cours */
                          Logger(printer: SimplePrinter()).v(
                              'totalPurchaseQty : ${_positionMain.purchaseAmount} + ${_transaction.amountMain}');

                          final double totalPurchaseQty =
                              _positionMain.purchaseAmount +
                                  _transaction.amountMain;

                          /* = Coùt moyen de la position */
                          Logger(printer: SimplePrinter()).v(
                              'averageCost : $runningCost / $totalPurchaseQty');

                          final double averageCost =
                              runningCost / totalPurchaseQty;

                          newPositionMain = PositionModel(
                              walletId: _positionMain.walletId,
                              token: _positionMain.token,
                              tokenName: _positionMain.tokenName,
                              amount: runningPosition,
                              averageCost: averageCost,
                              purchaseAmount: totalPurchaseQty,
                              sellAmount: _positionMain.sellAmount,
                              realizedPnL:
                                  _positionMain.realizedPnL, // Not used for Buy
                              cost: runningCost,
                              time: _positionMain.time,
                              color: Color.fromARGB(
                                      Random().nextInt(256),
                                      Random().nextInt(256),
                                      Random().nextInt(256),
                                      Random().nextInt(256))
                                  .value);

                          // If we are able to find the position, we need to update it
                          await synchronized(() async {
                            await positionController.updateFirestorePosition(
                                _transaction.tokenMain, newPositionMain);
                          });

                          if (_transaction.withImpactOnSecondPosition)
                          // Reference axis of the transaction (Buy or Sell Main against Reference)
                          {
                            PositionModel newPositionReference;

                            newPositionReference = PositionModel(
                                walletId: _positionReference.walletId,
                                token: _positionReference.token,
                                tokenName: _positionReference.tokenName,
                                amount: _positionReference.amount -
                                    _transaction.amountReference,
                                averageCost: _positionReference
                                    .averageCost, //TODO - averageCost
                                purchaseAmount:
                                    _positionReference.purchaseAmount,
                                sellAmount: _positionReference.sellAmount,
                                realizedPnL: _positionReference
                                    .realizedPnL, //TODO - realizedGain
                                cost: _positionReference.cost,
                                time: _positionReference.time,
                                color: Color.fromARGB(
                                        Random().nextInt(256),
                                        Random().nextInt(256),
                                        Random().nextInt(256),
                                        Random().nextInt(256))
                                    .value);

                            // if we are able to find the position, we need to update it
                            await synchronized(() async {
                              await positionController.updateFirestorePosition(
                                  _transaction.tokenReference,
                                  newPositionReference);
                            });
                          }

                          // finally we need to insert the transaction
                          await synchronized(() async {
                            await transactionController
                                .insertFirestoreTransaction(_newTransaction);
                          }).then((value) => Get
                            ..back<void>()
                            ..snackbar<void>(
                                'Successful', 'Transaction inserted !',
                                snackPosition: SnackPosition.BOTTOM,
                                duration: const Duration(seconds: 5),
                                backgroundColor:
                                    Get.theme.snackBarTheme.backgroundColor,
                                colorText:
                                    Get.theme.snackBarTheme.actionTextColor));
                        }
                      },
                      child: const Text('OK'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _customDropDown(
      BuildContext context, Crypto? item, String itemDesignation) {
    if (item == null) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(item.symbol),
    );

    // return ListTile(
    //   contentPadding: const EdgeInsets.all(0),
    //   dense: !_isLargeScreen(context),
    //   title: Text(
    //     item.symbol,
    //     //style: const TextStyle(fontSize: 14),
    //   ),
    // );
  }

  Widget _customPopupItemBuilder(
      BuildContext context, Crypto item, bool isSelected) {
    return ListTile(
      selected: isSelected,
      title: Text(
        item.symbol,
        style: const TextStyle(fontSize: 14),
      ),
      subtitle: Text(
        item.name.toString(),
        style: const TextStyle(fontSize: 13),
      ),
      leading: Image.network(
        item.logo,
        height: 28,
      ),
    );
  }

  Future<List<Crypto>> _getCryptoList() async {
    final boxCrypto = await Hive.openBox<CryptoHive>(cryptoListBox);

    final cryptos = <Crypto>[];
    boxCrypto.toMap().entries.forEach(
          (e) => cryptos.add(
            Crypto(
                category: e.value.category,
                id: e.value.id,
                logo: e.value.logo,
                name: e.value.name,
                slug: e.value.slug,
                symbol: e.value.symbol),
          ),
        );

    return cryptos;
  }

  Future<Crypto> _getCryptoBySymbol(String symbol) async {
    final boxCrypto = await Hive.openBox<CryptoHive>(cryptoListBox);
    final CryptoHive cryptos = boxCrypto.get(symbol)!;

    return Crypto(
        category: cryptos.category,
        logo: cryptos.logo,
        id: cryptos.id,
        name: cryptos.name,
        slug: cryptos.slug,
        symbol: cryptos.symbol);
  }
}
