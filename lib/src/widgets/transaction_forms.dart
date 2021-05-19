// Copyright 2020, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:web_dashboard/src/api/api.dart';
import 'package:intl/intl.dart' as intl;

import '../app.dart';
import 'portfolios_dropdown.dart';

class NewTransactionForm extends StatefulWidget {
  const NewTransactionForm({Key? key}) : super(key: key);

  @override
  _NewTransactionFormState createState() => _NewTransactionFormState();
}

class _NewTransactionFormState extends State<NewTransactionForm> {
  Portfolio? _selected;
  final Transaction _transaction =
      Transaction('', '', '', '', 0, 0, 0, 0, DateTime.now());

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
          onDone: (shouldInsert) async {
            if (shouldInsert) {
              // first regarding the Credit part of the transaction
              try {
                // try to find if the position already exists
                final oldPositionCredit = await api.positions
                    .get(_selected!.id, _transaction.tokenCredit);
                final newPositionCredit = Position(
                    oldPositionCredit.token,
                    oldPositionCredit.amount + _transaction.amountCredit,
                    oldPositionCredit.time);

                // if we find the position, we need to update it
                await api.positions.update(
                    _selected!.id, _transaction.tokenCredit, newPositionCredit);
              } catch (e) {
                // if not, we should get an error then insert the new position
                await api.positions.insert(
                    _selected!.id,
                    Position(
                        _transaction.tokenCredit,
                        _transaction.amountCredit.toDouble(),
                        _transaction.time));
              }

              // then regarding the Debit part of the transaction
              try {
                // try to find if the position already exists
                final oldPositionDebit = await api.positions
                    .get(_selected!.id, _transaction.tokenDebit);
                final newPositionDebit = Position(
                    oldPositionDebit.token,
                    oldPositionDebit.amount - _transaction.amountDebit,
                    oldPositionDebit.time);

                // if we find the position, we need to update it
                await api.positions.update(
                    _selected!.id, _transaction.tokenDebit, newPositionDebit);
              } catch (e) {
                // if not, we should get an error then insert the new position
                await api.positions.insert(
                    _selected!.id,
                    Position(
                        _transaction.tokenDebit,
                        -_transaction.amountDebit.toDouble(),
                        _transaction.time));
              }

              // finally insert the transaction linked to the portfolio
              await api.transactions.insert(
                  _selected!.id,
                  Transaction(
                      _transaction.tokenCredit,
                      _transaction.tokenDebit,
                      _transaction.tokenFee,
                      _transaction.tokenPrice,
                      _transaction.amountCredit.toDouble(),
                      _transaction.amountDebit.toDouble(),
                      _transaction.amountFee.toDouble(),
                      _transaction.price.toDouble(),
                      _transaction.time));

              //api.transactions.insert(_selected!.id, _transaction);
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
    required this.onDone,
  }) : super(key: key);

  final Transaction transaction;
  final ValueChanged<bool> onDone;

  @override
  _EditTransactionFormState createState() => _EditTransactionFormState();
}

class _EditTransactionFormState extends State<EditTransactionForm> {
  final _formKey = GlobalKey<FormState>();

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
              child: ToggleSwitch(
                //fontSize: 14,
                labels: const ['Buy', 'Sell', 'Deposit', 'Withdrawal'],
                minHeight: 30,
                //minWidth: MediaQuery.of(context).size.width,
                onToggle: (index) {
                  print('switched to: $index');
                },
              ),
            ),
          ),
          const SizedBox(height: 14),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 6),
            //dense: true,
            leading: const SizedBox(
              width: 100,
              child: Text(
                'Amount',
                style: TextStyle(fontSize: 14),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.end,
                    initialValue: widget.transaction.amountCredit.toString(),
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: 'Amount',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      try {
                        double.parse(value!);
                      } catch (e) {
                        return 'Please enter a whole number';
                      }
                      return null;
                    },
                    onChanged: (newValue) {
                      try {
                        widget.transaction.amountCredit =
                            double.parse(newValue);
                      } on FormatException {
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
                  width: 70,
                  child: TextFormField(
                    style: const TextStyle(fontSize: 14),
                    initialValue: widget.transaction.tokenCredit.toString(),
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: 'Token',
                    ),
                    keyboardType: TextInputType.text,
                    onChanged: (newValue) {
                      widget.transaction.tokenDebit = newValue;
                    },
                  ),
                ),
              ],
            ),
          ),
          ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 6),
              leading: const SizedBox(
                width: 100,
                child: Text(
                  'Price',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.end,
                      initialValue: widget.transaction.price.toStringAsFixed(6),
                      decoration: const InputDecoration(
                        isDense: true,
                        hintText: 'Price',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        try {
                          double.parse(value!);
                        } catch (e) {
                          return 'Please enter a whole number';
                        }
                        return null;
                      },
                      onChanged: (newValue) {
                        try {
                          widget.transaction.price = double.parse(newValue);
                        } on FormatException {
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
                    width: 70,
                    child: TextFormField(
                      style: const TextStyle(fontSize: 14),
                      initialValue: widget.transaction.tokenPrice.toString(),
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        isDense: true,
                        hintText: 'Token',
                      ),
                      onChanged: (newValue) {
                        widget.transaction.tokenPrice = newValue;
                      },
                    ),
                  ),
                ],
              )),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 6),
            leading: const SizedBox(
              width: 100,
              child: Text(
                'Total',
                style: TextStyle(fontSize: 14),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.end,
                    initialValue: widget.transaction.amountDebit.toString(),
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: 'Total Amount',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      try {
                        double.parse(value!);
                      } catch (e) {
                        return 'Please enter a whole number';
                      }
                      return null;
                    },
                    onChanged: (newValue) {
                      try {
                        widget.transaction.price = double.parse(newValue) /
                            widget.transaction.amountCredit;
                        widget.transaction.amountDebit = double.parse(newValue);
                      } on FormatException {
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
                  width: 70,
                  child: TextFormField(
                    style: const TextStyle(fontSize: 14),
                    initialValue: widget.transaction.tokenDebit.toString(),
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: 'Token',
                    ),
                    keyboardType: TextInputType.text,
                    onChanged: (newValue) {
                      widget.transaction.tokenDebit = newValue;
                    },
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 6),
            leading: const SizedBox(
              width: 100,
              child: Text(
                'Fees (incl.)',
                style: TextStyle(fontSize: 14),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    textAlign: TextAlign.end,
                    initialValue: widget.transaction.amountFee.toString(),
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: 'Fees amount incl.',
                      hintStyle: TextStyle(fontSize: 14),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      try {
                        double.parse(value!);
                      } catch (e) {
                        return 'Please enter a whole number';
                      }
                      return null;
                    },
                    onChanged: (newValue) {
                      try {
                        widget.transaction.amountFee = double.parse(newValue);
                      } on FormatException {
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
                  width: 70,
                  child: TextFormField(
                    style: const TextStyle(fontSize: 14),
                    initialValue: widget.transaction.tokenFee.toString(),
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: 'Token',
                    ),
                    keyboardType: TextInputType.text,
                    onChanged: (newValue) {
                      widget.transaction.tokenFee = newValue;
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  intl.DateFormat('dd/MM/yyyy HH:mm')
                      .format(widget.transaction.time),
                ),
                OutlinedButton(
                    onPressed: () {
                      DatePicker.showDateTimePicker(context,
                          showTitleActions: true, onChanged: (date) {
                        // print('change $date in time zone ' +
                        //     date.timeZoneOffset.inHours.toString());
                      }, onConfirm: (date) {
                        setState(() {
                          widget.transaction.time = date;
                        });
                        //print('confirm $date');
                      },
                          currentTime: widget.transaction.time,
                          locale: LocaleType.fr);
                    },
                    child: const Text(
                      'Edit',
                      style: TextStyle(color: Colors.blue),
                    )),
              ],
            ),
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
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
}
