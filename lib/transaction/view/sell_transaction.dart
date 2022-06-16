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

bool _isLargeScreen(BuildContext context) {
  return MediaQuery.of(context).size.width > 960.0;
}

var logger = Logger(printer: PrettyPrinter());
var loggerNoStack = Logger(printer: PrettyPrinter(methodCount: 0));

const cryptoListBox = 'cryptoList';

class SellTransactionDialog extends StatelessWidget {
  const SellTransactionDialog({Key? key, required this.selectedTransaction})
      : super(key: key);

  final TransactionModel selectedTransaction;

  @override
  Widget build(BuildContext context) {
    if (_isLargeScreen(context)) {
      return SimpleDialog(
        title: const Text('New Transaction - Sell'),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        children: [
          Container(
            width: 600,
            child: Column(
              children: [
                SellTransactionForm(
                  selectedTransaction: selectedTransaction,
                ),
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
                child: Text('New Transaction - Sell',
                    style: Theme.of(context).textTheme.headline6),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  children: [
                    SellTransactionForm(
                      selectedTransaction: selectedTransaction,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      );
    }
  }
}

class SellTransactionForm extends StatelessWidget {
  SellTransactionForm({Key? key, required this.selectedTransaction})
      : super(key: key);

  //final WalletModel? selectedWallet;
  final TransactionModel selectedTransaction;
  final _formKey = GlobalKey<FormState>();
  final TransactionController transactionController = TransactionController.to;
  final PositionController positionController = PositionController.to;

  // final WalletModel? _selected = WalletModel(name: 'Empty');

  final TransactionModel _transaction = TransactionModel(
    walletId: '',
    transactionType: 1,
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
    withImpactOnSecondPosition: true,
    transactionRefId: '',
  );

  @override
  Widget build(BuildContext context) {
    _transaction
      ..transactionType = 1
      ..walletId = selectedTransaction.walletId
      ..tokenMain = selectedTransaction.tokenMain
      ..tokenMainName = selectedTransaction.tokenMainName
      ..tokenPrice = selectedTransaction.tokenPrice
      ..tokenPriceName = selectedTransaction.tokenPriceName
      ..tokenReference = selectedTransaction.tokenReference
      ..tokenReferenceName = selectedTransaction.tokenReferenceName
      ..tokenFee = selectedTransaction.tokenFee
      ..tokenFeeName = selectedTransaction.tokenFeeName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 14),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                leading: SizedBox(
                  width: 100,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      isDense: true,
                    ),
                    initialValue: 'Amount',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        style: const TextStyle(fontSize: 14),
                        textAlign: TextAlign.end,
                        decoration: InputDecoration(
                          isDense: !_isLargeScreen(context),
                        ),
                        initialValue: _transaction.amountMain.toCurrencyString(
                          mantissaLength: 6,
                          thousandSeparator:
                              ThousandSeparator.SpaceAndPeriodMantissa,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          MoneyInputFormatter(
                            mantissaLength: 6,
                            thousandSeparator:
                                ThousandSeparator.SpaceAndPeriodMantissa,
                          )
                        ],
                        validator: (value) {
                          try {
                            double.parse(
                              value!.toCurrencyString(
                                  mantissaLength: 6,
                                  thousandSeparator: ThousandSeparator.None),
                            );
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
                    const SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      width: 85,
                      child: FutureBuilder<Crypto>(
                        future: _getCryptoBySymbol(_transaction.tokenMain),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            // return DropdownSearch<Crypto>(
                            //   mode: Mode.BOTTOM_SHEET,
                            //   enabled: false,
                            //   showSearchBox: true,
                            //   autoFocusSearchBox: true,
                            //   dropdownSearchDecoration: const InputDecoration(
                            //     border: InputBorder.none,
                            //     focusedBorder: InputBorder.none,
                            //     enabledBorder: InputBorder.none,
                            //     errorBorder: InputBorder.none,
                            //     disabledBorder: InputBorder.none,
                            //     isDense: true,
                            //   ),
                            //   onFind: (String filter) => _getCryptoList(),
                            //   compareFn: (i, s) => i.isEqual(s!),
                            //   dropdownButtonBuilder: (_) => const Padding(
                            //     padding: EdgeInsets.all(6),
                            //     child: Icon(
                            //       Icons.arrow_drop_down,
                            //       size: 18,
                            //       color: Colors.black,
                            //     ),
                            //   ),
                            //   popupItemBuilder: _customPopupItemBuilder,
                            //   dropdownBuilder: _customDropDown,
                            //   selectedItem: snapshot.data,
                            //   onChanged: (newValue) async {
                            //     //setState(() {
                            //     _transaction
                            //       ..tokenMain = newValue!.symbol
                            //       ..tokenMainName = newValue.name;
                            //     //widget.positionMain.token = newValue.symbol;

                            //     //tokenMainCrypto = await _getCryptoBySymbol(
                            //     //    widget.transaction.tokenMain);
                            //     //});
                            //   },
                            // );
                          } else if (snapshot.hasError) {
                            return Text('${snapshot.error}');
                          }

                          return const Text('');
                        },
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                leading: SizedBox(
                  width: 100,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      isDense: true,
                    ),
                    initialValue: 'Price',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        style: const TextStyle(fontSize: 14),
                        textAlign: TextAlign.end,
                        decoration: InputDecoration(
                          isDense: !_isLargeScreen(context),
                        ),
                        initialValue: _transaction.price.toCurrencyString(
                          mantissaLength: 6,
                          thousandSeparator:
                              ThousandSeparator.SpaceAndPeriodMantissa,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          MoneyInputFormatter(
                            mantissaLength: 6,
                            thousandSeparator:
                                ThousandSeparator.SpaceAndPeriodMantissa,
                          )
                        ],
                        validator: (value) {
                          try {
                            double.parse(
                              value!.toCurrencyString(
                                  mantissaLength: 6,
                                  thousandSeparator: ThousandSeparator.None),
                            );
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
                            debugPrint(
                                'Transaction cannot contain "$newValue". Expected a number');
                          }
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      width: 85,
                      child: FutureBuilder<Crypto>(
                        future: _getCryptoBySymbol(_transaction.tokenPrice),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            // return DropdownSearch<Crypto>(
                            //   mode: Mode.BOTTOM_SHEET,
                            //   enabled: false,
                            //   showSearchBox: true,
                            //   autoFocusSearchBox: true,
                            //   dropdownSearchDecoration: const InputDecoration(
                            //     border: InputBorder.none,
                            //     focusedBorder: InputBorder.none,
                            //     enabledBorder: InputBorder.none,
                            //     errorBorder: InputBorder.none,
                            //     disabledBorder: InputBorder.none,
                            //     isDense: true,
                            //   ),
                            //   onFind: (String filter) => _getCryptoList(),
                            //   compareFn: (i, s) => i.isEqual(s!),
                            //   dropdownButtonBuilder: (_) => const Padding(
                            //     padding: EdgeInsets.all(6),
                            //     child: Icon(
                            //       Icons.arrow_drop_down,
                            //       size: 18,
                            //       color: Colors.black,
                            //     ),
                            //   ),
                            //   popupItemBuilder: _customPopupItemBuilder,
                            //   dropdownBuilder: _customDropDown,
                            //   selectedItem: snapshot.data,
                            //   onChanged: (newValue) async {
                            //     _transaction
                            //       ..tokenPrice = newValue!.symbol
                            //       ..tokenPriceName = newValue.name;
                            //   },
                            // );
                          } else if (snapshot.hasError) {
                            return Text('${snapshot.error}');
                          }

                          return const Text('');
                        },
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                leading: SizedBox(
                  width: 100,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      isDense: true,
                    ),
                    initialValue: 'Total',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        style: const TextStyle(fontSize: 14),
                        textAlign: TextAlign.end,
                        initialValue:
                            _transaction.amountReference.toCurrencyString(
                          mantissaLength: 6,
                          thousandSeparator:
                              ThousandSeparator.SpaceAndPeriodMantissa,
                        ),
                        decoration: InputDecoration(
                          isDense: !_isLargeScreen(context),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          MoneyInputFormatter(
                            mantissaLength: 6,
                            thousandSeparator:
                                ThousandSeparator.SpaceAndPeriodMantissa,
                          )
                        ],
                        validator: (value) {
                          try {
                            double.parse(
                              value!.toCurrencyString(
                                  mantissaLength: 6,
                                  thousandSeparator: ThousandSeparator.None),
                            );
                          } catch (e) {
                            return 'Please enter a whole number';
                          }
                          return null;
                        },
                        onChanged: (newValue) {
                          try {
                            _transaction
                              ..price = double.parse(
                                    newValue.toCurrencyString(
                                        mantissaLength: 6,
                                        thousandSeparator:
                                            ThousandSeparator.None),
                                  ) /
                                  _transaction.amountMain
                              ..amountReference = double.parse(
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
                    const SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      width: 85,
                      child: FutureBuilder<Crypto>(
                        future: _getCryptoBySymbol(_transaction.tokenReference),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            // return DropdownSearch<Crypto>(
                            //   mode: Mode.BOTTOM_SHEET,
                            //   enabled: false,
                            //   showSearchBox: true,
                            //   autoFocusSearchBox: true,
                            //   dropdownSearchDecoration: const InputDecoration(
                            //     border: InputBorder.none,
                            //     focusedBorder: InputBorder.none,
                            //     enabledBorder: InputBorder.none,
                            //     errorBorder: InputBorder.none,
                            //     disabledBorder: InputBorder.none,
                            //     isDense: true,
                            //   ),
                            //   onFind: (String filter) => _getCryptoList(),
                            //   compareFn: (i, s) => i.isEqual(s!),
                            //   dropdownButtonBuilder: (_) => const Padding(
                            //     padding: EdgeInsets.all(6),
                            //     child: Icon(
                            //       Icons.arrow_drop_down,
                            //       size: 18,
                            //       color: Colors.black,
                            //     ),
                            //   ),
                            //   popupItemBuilder: _customPopupItemBuilder,
                            //   dropdownBuilder: _customDropDown,
                            //   selectedItem: snapshot.data,
                            //   onChanged: (newValue) async {
                            //     _transaction
                            //       ..tokenReference = newValue!.symbol
                            //       ..tokenReferenceName = newValue.name;
                            //     // widget.positionReference.token =
                            //     //     newValue.symbol;
                            //   },
                            // );
                          } else if (snapshot.hasError) {
                            return Text('${snapshot.error}');
                          }

                          return const Text('');
                        },
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                leading: SizedBox(
                  width: 100,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      isDense: true,
                    ),
                    initialValue: 'Fees (incl.)',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        textAlign: TextAlign.end,
                        initialValue: _transaction.amountFee.toCurrencyString(
                          mantissaLength: 6,
                          thousandSeparator:
                              ThousandSeparator.SpaceAndPeriodMantissa,
                        ),
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          isDense: !_isLargeScreen(context),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          MoneyInputFormatter(
                            mantissaLength: 6,
                            thousandSeparator:
                                ThousandSeparator.SpaceAndPeriodMantissa,
                          )
                        ],
                        validator: (value) {
                          try {
                            double.parse(
                              value!.toCurrencyString(
                                  mantissaLength: 6,
                                  thousandSeparator: ThousandSeparator.None),
                            );
                          } catch (e) {
                            return 'Please enter a whole number';
                          }
                          return null;
                        },
                        onChanged: (newValue) {
                          try {
                            _transaction.amountFee = double.parse(
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
                    const SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      width: 85,
                      child: FutureBuilder<Crypto>(
                        future: _getCryptoBySymbol(_transaction.tokenFee),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            // return DropdownSearch<Crypto>(
                            //   mode: Mode.BOTTOM_SHEET,
                            //   showSearchBox: true,
                            //   autoFocusSearchBox: true,
                            //   dropdownSearchDecoration: const InputDecoration(
                            //     border: InputBorder.none,
                            //     focusedBorder: InputBorder.none,
                            //     enabledBorder: InputBorder.none,
                            //     errorBorder: InputBorder.none,
                            //     disabledBorder: InputBorder.none,
                            //     isDense: true,
                            //   ),
                            //   onFind: (String filter) => _getCryptoList(),
                            //   compareFn: (i, s) => i.isEqual(s!),
                            //   dropdownButtonBuilder: (_) => const Padding(
                            //     padding: EdgeInsets.all(6),
                            //     child: Icon(
                            //       Icons.arrow_drop_down,
                            //       size: 18,
                            //       color: Colors.black,
                            //     ),
                            //   ),
                            //   popupItemBuilder: _customPopupItemBuilder,
                            //   dropdownBuilder: _customDropDown,
                            //   selectedItem: snapshot.data,
                            //   onChanged: (newValue) async {
                            //     _transaction
                            //       ..tokenFee = newValue!.symbol
                            //       ..tokenFeeName = newValue.name;
                            //   },
                            // );
                          } else if (snapshot.hasError) {
                            return Text('${snapshot.error}');
                          }

                          return const Text('');
                        },
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                leading: const SizedBox(
                  width: 50,
                  child: Icon(Icons.info),
                ),
                title: Row(
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
                        //activeBgColor: primaryColor,
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
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                leading: const SizedBox(
                  width: 50,
                  child: Icon(Icons.calendar_today),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                          intl.DateFormat('dd/MM/yyyy HH:mm')
                              .format(_transaction.time),
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.end),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      width: 60,
                      child: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          final result =
                              await DatePicker.showDateTimePicker(context,
                                  //showTitleActions: true,
                                  onChanged: (date) {}, onConfirm: (date) {
                            _transaction.time = date;
                          },
                                  currentTime: _transaction.time,
                                  locale: LocaleType.fr);
                          if (result == null) {
                            return;
                          }
                          // setState(() {
                          //   _transaction.time = result;
                          // });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
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
                            walletId: selectedTransaction.walletId,
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
                            transactionRefId: selectedTransaction.id,
                          );

                          // try {
                          //   // Update the initial transaction to decrease the purchase amount
                          //   await synchronized(() async {
                          //     final TransactionModel _initialTransaction =
                          //         await transactionController
                          //             .getFirestoreTransaction(
                          //                 selectedTransaction.id);

                          //     // Find the new amount Main (token) and amount Ref
                          //     _initialTransaction
                          //       ..amountMain = _initialTransaction.amountMain -
                          //           _transaction.amountMain
                          //       ..amountReference =
                          //           _initialTransaction.amountReference -
                          //               _transaction.amountReference

                          //       // To calculate the new price
                          //       ..price = _initialTransaction.amountReference /
                          //           _initialTransaction.amountMain;

                          //     await transactionController
                          //         .updateFirestoreTransaction(
                          //             selectedTransaction.id,
                          //             _initialTransaction);
                          //   });
                          // } catch (e) {
                          //   debugPrint(e.toString());
                          // }

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
                            debugPrint(e.toString());
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
                            debugPrint(e.toString());
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
                              'Sell transaction - ${_positionMain.token} - ${_positionMain.tokenName} - RealizedPnL calculation');

                          Logger(printer: SimplePrinter()).v(
                              '_positionMain.sellAmount : ${_positionMain.sellAmount}');
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

                          /* = Position courante du token en ajoutant la transaction en cours */
                          Logger(printer: SimplePrinter()).v(
                              'runningPosition : ${_positionMain.amount} - ${_transaction.amountMain}');

                          final double runningPosition =
                              _positionMain.amount - _transaction.amountMain;

                          /* = Somme des quantités totales vendues en ajoutant la transaction en cours */
                          Logger(printer: SimplePrinter()).v(
                              'totalSellQty : ${_positionMain.sellAmount} + ${_transaction.amountMain}');

                          final double totalSellQty = _positionMain.sellAmount +
                              _transaction.amountMain;

                          /* = Gain en capital réalisé sur la position grâce à cette transaction */
                          Logger(printer: SimplePrinter()).v(
                              'realizedPnL : $transactionCost - (${_transaction.amountMain} * ${_positionMain.averageCost})');

                          final double realizedPnL = transactionCost -
                              (_transaction.amountMain *
                                  _positionMain.averageCost);

                          /* = Si la position restante ne représente plus un montant > 0, on repositionne certains champs à 0 */
                          Logger(printer: SimplePrinter()).v(
                              'runningAmount : $runningPosition * ${_transaction.price} ');

                          final double runningAmount =
                              runningPosition * _transaction.price;
                          bool isCloseOrEqualToZero = false;
                          if (runningAmount < 1) {
                            isCloseOrEqualToZero = true;
                          }
                          Logger(printer: SimplePrinter()).v(
                              'isCloseOrEqualToZero : $isCloseOrEqualToZero');

                          newPositionMain = PositionModel(
                              walletId: _positionMain.walletId,
                              token: _positionMain.token,
                              tokenName: _positionMain.tokenName,
                              amount: runningPosition,
                              averageCost: _positionMain.averageCost,
                              purchaseAmount: isCloseOrEqualToZero
                                  ? 0
                                  : _positionMain.purchaseAmount,
                              sellAmount: totalSellQty,
                              realizedPnL: realizedPnL,
                              cost:
                                  isCloseOrEqualToZero ? 0 : _positionMain.cost,
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

                            // Sell
                            newPositionReference = PositionModel(
                                walletId: _positionReference.walletId,
                                token: _positionReference.token,
                                tokenName: _positionReference.tokenName,
                                amount: _positionReference.amount +
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
                            ..snackbar('Successful', 'Transaction inserted !',
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

    return ListTile(
      contentPadding: const EdgeInsets.all(0),
      dense: true,
      title: Text(
        item.symbol,
        style: const TextStyle(fontSize: 14),
      ),
    );
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
