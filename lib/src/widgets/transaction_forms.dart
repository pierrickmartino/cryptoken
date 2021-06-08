import 'dart:async' show Future;

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../src/api/api.dart';
import '../../src/class/crypto.dart';
import '../../src/hive/crypto_hive.dart';
import '../app.dart';
import 'portfolios_dropdown.dart';

const cryptoListBox = 'cryptoList';

bool _isLargeScreen(BuildContext context) {
  return MediaQuery.of(context).size.width > 960.0;
}

class NewTransactionForm extends StatefulWidget {
  NewTransactionForm({Key? key, this.selectedPortfolio}) : super(key: key);

  Portfolio? selectedPortfolio;

  @override
  _NewTransactionFormState createState() => _NewTransactionFormState();
}

class _NewTransactionFormState extends State<NewTransactionForm> {
  Portfolio? _selected = Portfolio('');

  final Transaction _transaction = Transaction(
    0,
    'BTC',
    'USDT',
    'USDT',
    'USDT',
    0,
    0,
    0,
    0,
    DateTime.now(),
    true,
  );

  final Position _positionMain = Position(
    'BTC',
    0,
    0,
    0,
    0,
    DateTime.now(),
  );

  final Position _positionReference = Position(
    'USDT',
    0,
    0,
    0,
    0,
    DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<AppState>(context).api;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(0),
          child: PortfolioDropdown(
            initPortfolio: widget.selectedPortfolio,
            api: api.portfolios,
            onSelected: (portfolio) {
              setState(() {
                _selected = portfolio;
              });
            },
          ),
        ),
        const SizedBox(height: 14),
        EditTransactionForm(
          transaction: _transaction,
          portfolio: _selected!,
          positionMain: _positionMain,
          positionReference: _positionReference,
          showToogleSwitch: true,
          onDone: (shouldInsert) async {
            if (shouldInsert) {
              // Main axis of the transaction (Buy or Sell Main against Reference)
              try {
                Position newPositionMain;

                // print('Insert Mode');
                // print(
                //     '_positionMain.purchaseAmount : ${_positionMain.purchaseAmount}');
                // print(
                //     '_positionMain.averagePurchasePrice : ${_positionMain.averagePurchasePrice}');
                // print('_transaction.amountMain : ${_transaction.amountMain}');
                // print('_transaction.price : ${_transaction.price}');

                // Buy
                if (_transaction.transactionType == 0) {
                  newPositionMain = Position(
                    _positionMain.token,
                    _positionMain.amount + _transaction.amountMain,
                    ((_positionMain.purchaseAmount *
                                _positionMain.averagePurchasePrice) +
                            (_transaction.amountMain * _transaction.price)) /
                        (_positionMain.purchaseAmount +
                            _transaction.amountMain),
                    _positionMain.purchaseAmount + _transaction.amountMain,
                    _positionMain.realizedGain, // Not used for Buy
                    _positionMain.time,
                  );
                }

                // Sell
                else {
                  newPositionMain = Position(
                    _positionMain.token,
                    _positionMain.amount - _transaction.amountMain,
                    _positionMain.averagePurchasePrice, // Not used for Sell
                    _positionMain.purchaseAmount, // Not used for Sell
                    _positionMain.realizedGain, //TODO - realizedGain
                    _positionMain.time,
                  );
                }

                // if we are able to find the position, we need to update it
                await api.positions.update(
                  _selected!.id,
                  _transaction.tokenMain,
                  newPositionMain,
                );
              } catch (e) {
                // if not, we should catch an error then insert the new position

                //TODO : Is this section really usefull ?
                // It seems that we are already creating the missing
                // position in the validate function of the form

                // Buy
                if (_transaction.transactionType == 0) {
                  await api.positions.insert(
                    _selected!.id,
                    Position(
                      _transaction.tokenMain,
                      _transaction.amountMain.toDouble(),
                      _transaction.amountReference.toDouble() /
                          _transaction.amountMain.toDouble(),
                      _transaction.amountMain.toDouble(),
                      0, //TODO - realizedGain
                      _transaction.time,
                    ),
                  );
                }

                // Sell
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.red,
                    content: Text('This operation is not authorized'),
                  ),
                );
              }

              if (_transaction.withImpactOnSecondPosition)
              // Reference axis of the transaction (Buy or Sell Main against Reference)
              {
                try {
                  Position newPositionReference;

                  // Buy
                  if (_transaction.transactionType == 0) {
                    newPositionReference = Position(
                      _positionReference.token,
                      _positionReference.amount - _transaction.amountReference,
                      _positionReference
                          .averagePurchasePrice, //TODO - averagePurchasePrice
                      _positionReference.purchaseAmount,
                      _positionReference.realizedGain, //TODO - realizedGain
                      _positionReference.time,
                    );
                  }

                  // Sell
                  else {
                    newPositionReference = Position(
                      _positionReference.token,
                      _positionReference.amount + _transaction.amountReference,
                      _positionReference
                          .averagePurchasePrice, //TODO - averagePurchasePrice
                      _positionReference.purchaseAmount,
                      _positionReference.realizedGain, //TODO - realizedGain
                      _positionReference.time,
                    );
                  }

                  // if we are able to find the position, we need to update it
                  await api.positions.update(
                    _selected!.id,
                    _transaction.tokenReference,
                    newPositionReference,
                  );
                } catch (e) {
                  // if not, we should catch an error then insert the new position

                  //TODO : Is this section really usefull ?
                  // It seems that we are already creating the missing
                  // position in the validate function of the form

                  await api.positions.insert(
                    _selected!.id,
                    Position(
                      _transaction.tokenReference,
                      -_transaction.amountReference.toDouble(),
                      0, //TODO - averagePurchasePrice
                      0, //TODO - purchaseAmount
                      0, //TODO - realizedGain
                      _transaction.time,
                    ),
                  );
                }
              }

              // finally insert the transaction linked to the portfolio
              await api.transactions.insert(
                _selected!.id,
                Transaction(
                  _transaction.transactionType,
                  _transaction.tokenMain,
                  _transaction.tokenReference,
                  _transaction.tokenFee,
                  _transaction.tokenPrice,
                  _transaction.amountMain.toDouble(),
                  _transaction.amountReference.toDouble(),
                  _transaction.amountFee.toDouble(),
                  _transaction.price.toDouble(),
                  _transaction.time,
                  _transaction.withImpactOnSecondPosition,
                ),
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transaction inserted'),
                ),
              );
            }
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class EditTransactionForm extends StatefulWidget {
  const EditTransactionForm({
    Key? key,
    required this.transaction,
    required this.portfolio,
    required this.positionMain,
    required this.positionReference,
    required this.showToogleSwitch,
    required this.onDone,
  }) : super(key: key);

  final Transaction transaction;
  final Portfolio portfolio;
  final Position positionMain, positionReference;
  final bool showToogleSwitch;
  final ValueChanged<bool> onDone;

  @override
  _EditTransactionFormState createState() => _EditTransactionFormState();
}

class _EditTransactionFormState extends State<EditTransactionForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(0),
            child: Center(
              child: widget.showToogleSwitch
                  ? ToggleSwitch(
                      // 0 Buy | 1 Sell | 2 Deposit (todo) | 3 Withrawal (todo)
                      labels: const [
                        'Buy',
                        'Sell' /*, 'Deposit', 'Withdrawal'*/
                      ],
                      minHeight: 30,
                      initialLabelIndex: widget.transaction.transactionType,
                      onToggle: (index) {
                        setState(() {
                          widget.transaction.transactionType = index;
                        });
                      },
                    )
                  : _getTransactionTypeLabel(
                      widget.transaction.transactionType),
            ),
          ),
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
                    initialValue:
                        widget.transaction.amountMain.toCurrencyString(
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
                        widget.transaction.amountMain = double.parse(
                          newValue.toCurrencyString(
                              mantissaLength: 6,
                              thousandSeparator: ThousandSeparator.None),
                        );
                      } on FormatException {
                        // ignore: avoid_print
                        print(
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
                    future: _getCryptoBySymbol(widget.transaction.tokenMain),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return DropdownSearch<Crypto>(
                          mode: Mode.BOTTOM_SHEET,
                          showSearchBox: true,
                          autoFocusSearchBox: true,
                          dropdownSearchDecoration: const InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            isDense: true,
                          ),
                          onFind: (String filter) => _getCryptoList(),
                          compareFn: (i, s) => i.isEqual(s!),
                          dropdownButtonBuilder: (_) => const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(
                              Icons.arrow_drop_down,
                              size: 18,
                              color: Colors.black,
                            ),
                          ),
                          popupItemBuilder: _customPopupItemBuilder,
                          dropdownBuilder: _customDropDown,
                          selectedItem: snapshot.data,
                          onChanged: (newValue) async {
                            //setState(() {
                            widget.transaction.tokenMain = newValue!.symbol;
                            widget.positionMain.token = newValue.symbol;
                            //tokenMainCrypto = await _getCryptoBySymbol(
                            //    widget.transaction.tokenMain);
                            //});
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
                    initialValue: widget.transaction.price.toCurrencyString(
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
                        widget.transaction.price = double.parse(
                          newValue.toCurrencyString(
                              mantissaLength: 6,
                              thousandSeparator: ThousandSeparator.None),
                        );
                      } on FormatException {
                        // ignore: avoid_print
                        print(
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
                    future: _getCryptoBySymbol(widget.transaction.tokenPrice),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return DropdownSearch<Crypto>(
                          mode: Mode.BOTTOM_SHEET,
                          showSearchBox: true,
                          autoFocusSearchBox: true,
                          dropdownSearchDecoration: const InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            isDense: true,
                          ),
                          onFind: (String filter) => _getCryptoList(),
                          compareFn: (i, s) => i.isEqual(s!),
                          dropdownButtonBuilder: (_) => const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(
                              Icons.arrow_drop_down,
                              size: 18,
                              color: Colors.black,
                            ),
                          ),
                          popupItemBuilder: _customPopupItemBuilder,
                          dropdownBuilder: _customDropDown,
                          selectedItem: snapshot.data,
                          onChanged: (newValue) async {
                            widget.transaction.tokenPrice = newValue!.symbol;
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
                        widget.transaction.amountReference.toCurrencyString(
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
                        widget.transaction.price = double.parse(
                              newValue.toCurrencyString(
                                  mantissaLength: 6,
                                  thousandSeparator: ThousandSeparator.None),
                            ) /
                            widget.transaction.amountMain;

                        widget.transaction.amountReference = double.parse(
                          newValue.toCurrencyString(
                              mantissaLength: 6,
                              thousandSeparator: ThousandSeparator.None),
                        );
                      } on FormatException {
                        // ignore: avoid_print
                        print(
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
                    future:
                        _getCryptoBySymbol(widget.transaction.tokenReference),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return DropdownSearch<Crypto>(
                          mode: Mode.BOTTOM_SHEET,
                          showSearchBox: true,
                          autoFocusSearchBox: true,
                          dropdownSearchDecoration: const InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            isDense: true,
                          ),
                          onFind: (String filter) => _getCryptoList(),
                          compareFn: (i, s) => i.isEqual(s!),
                          dropdownButtonBuilder: (_) => const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(
                              Icons.arrow_drop_down,
                              size: 18,
                              color: Colors.black,
                            ),
                          ),
                          popupItemBuilder: _customPopupItemBuilder,
                          dropdownBuilder: _customDropDown,
                          selectedItem: snapshot.data,
                          onChanged: (newValue) async {
                            widget.transaction.tokenReference =
                                newValue!.symbol;
                            widget.positionReference.token = newValue.symbol;
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
                    initialValue: widget.transaction.amountFee.toCurrencyString(
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
                        widget.transaction.amountFee = double.parse(
                          newValue.toCurrencyString(
                              mantissaLength: 6,
                              thousandSeparator: ThousandSeparator.None),
                        );
                      } on FormatException {
                        // ignore: avoid_print
                        print(
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
                    future: _getCryptoBySymbol(widget.transaction.tokenFee),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return DropdownSearch<Crypto>(
                          mode: Mode.BOTTOM_SHEET,
                          showSearchBox: true,
                          autoFocusSearchBox: true,
                          dropdownSearchDecoration: const InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            isDense: true,
                          ),
                          onFind: (String filter) => _getCryptoList(),
                          compareFn: (i, s) => i.isEqual(s!),
                          dropdownButtonBuilder: (_) => const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(
                              Icons.arrow_drop_down,
                              size: 18,
                              color: Colors.black,
                            ),
                          ),
                          popupItemBuilder: _customPopupItemBuilder,
                          dropdownBuilder: _customDropDown,
                          selectedItem: snapshot.data,
                          onChanged: (newValue) async {
                            widget.transaction.tokenFee = newValue!.symbol;
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
                  width: 60,
                  child: Checkbox(
                    value: widget.transaction.withImpactOnSecondPosition,
                    onChanged: (newValue) {
                      setState(() {
                        widget.transaction.withImpactOnSecondPosition =
                            newValue!;
                      });
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
                          .format(widget.transaction.time),
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
                        widget.transaction.time = date;
                      },
                              currentTime: widget.transaction.time,
                              locale: LocaleType.fr);
                      if (result == null) {
                        return;
                      }
                      setState(() {
                        widget.transaction.time = result;
                      });
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
                    widget.onDone(false);
                  },
                  child: const Text('Cancel'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Once the user click on validate, we are able to check the positions existence

                      try {
                        // try to find if the position already exists
                        await Provider.of<AppState>(context, listen: false)
                            .api
                            .positions
                            .get(widget.portfolio.id,
                                widget.transaction.tokenMain);
                      } catch (e) {
                        // if not, we should get an error then insert the new position
                        await Provider.of<AppState>(context, listen: false)
                            .api
                            .positions
                            .insert(
                              widget.portfolio.id,
                              Position(
                                widget.transaction.tokenMain,
                                0,
                                0, //TODO - averagePurchasePrice
                                0, //TODO - purchaseAmount
                                0, //TODO - realizedGain
                                DateTime.now(),
                              ),
                            );
                      } finally {
                        final oldPositionMain =
                            await Provider.of<AppState>(context, listen: false)
                                .api
                                .positions
                                .get(widget.portfolio.id,
                                    widget.transaction.tokenMain);
                        widget.positionMain.amount = oldPositionMain.amount;
                        widget.positionMain.averagePurchasePrice =
                            oldPositionMain.averagePurchasePrice;
                        widget.positionMain.purchaseAmount =
                            oldPositionMain.purchaseAmount;
                      }

                      try {
                        // try to find if the position already exists
                        await Provider.of<AppState>(context, listen: false)
                            .api
                            .positions
                            .get(widget.portfolio.id,
                                widget.transaction.tokenReference);
                      } catch (e) {
                        // if not, we should get an error then insert the new position
                        await Provider.of<AppState>(context, listen: false)
                            .api
                            .positions
                            .insert(
                              widget.portfolio.id,
                              Position(
                                widget.transaction.tokenReference,
                                0,
                                0, //TODO - averagePurchasePrice
                                0, //TODO - purchaseAmount
                                0, //TODO - realizedGain
                                DateTime.now(),
                              ),
                            );
                      } finally {
                        final oldPositionReference =
                            await Provider.of<AppState>(context, listen: false)
                                .api
                                .positions
                                .get(widget.portfolio.id,
                                    widget.transaction.tokenReference);
                        widget.positionReference.amount =
                            oldPositionReference.amount;
                        widget.positionReference.averagePurchasePrice =
                            oldPositionReference.averagePurchasePrice;
                        widget.positionReference.purchaseAmount =
                            oldPositionReference.purchaseAmount;
                      }

                      widget.onDone(true);
                    }
                  },
                  child: const Text('OK'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _getTransactionTypeLabel(int index) {
    switch (index) {
      case 0:
        return Text(
          'Buy',
          style: Theme.of(context).textTheme.subtitle1,
        );
      case 1:
        return Text(
          'Sell',
          style: Theme.of(context).textTheme.subtitle1,
        );
      default:
        return const Text('');
    }
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

    //cryptos.sort();

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
