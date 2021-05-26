// Copyright 2020, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
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
  Portfolio? _selected = Portfolio('');
  final Transaction _transaction = Transaction(
      'BTC', 'USDT', 'USDT', 'USDT', 0, 0, 0, 0, DateTime.now(), true);

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
          onDone: (shouldInsert) async {
            if (shouldInsert) {
              print('Inside shouldInsert');
              // first regarding the Credit part of the transaction
              try {
                // try to find if the position already exists
                final oldPositionCredit = await api.positions
                    .get(_selected!.id, _transaction.tokenCredit);
                final newPositionCredit = Position(
                    oldPositionCredit.token,
                    oldPositionCredit.amount + _transaction.amountCredit,
                    oldPositionCredit.time);
                print('Before update');
                // if we find the position, we need to update it
                await api.positions.update(
                    _selected!.id, _transaction.tokenCredit, newPositionCredit);

                print('After update');
              } catch (e) {
                print('Inside catch');
                // if not, we should get an error then insert the new position
                await api.positions.insert(
                    _selected!.id,
                    Position(
                        _transaction.tokenCredit,
                        _transaction.amountCredit.toDouble(),
                        _transaction.time));
              }

              if (_transaction.withImpactOnSecondPosition)
              // then regarding the Debit part of the transaction
              {
                print('Inside _transaction.withImpactOnSecondPosition');

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
              }
              print('Before insert');
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
                      _transaction.time,
                      _transaction.withImpactOnSecondPosition));

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
    required this.onDone,
  }) : super(key: key);

  final Transaction transaction;
  final Portfolio portfolio;
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
              child: ToggleSwitch(
                //fontSize: 14,
                labels: const ['Buy', 'Sell', 'Deposit', 'Withdrawal'],
                minHeight: 30,
                //minWidth: MediaQuery.of(context).size.width,
                onToggle: (index) {
                  // ignore: avoid_print
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
                    initialValue:
                        widget.transaction.amountCredit.toCurrencyString(
                      mantissaLength: 6,
                      thousandSeparator:
                          ThousandSeparator.SpaceAndPeriodMantissa,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: 'Amount',
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
                        double.parse(value!.toCurrencyString(
                            mantissaLength: 6,
                            thousandSeparator: ThousandSeparator.None));
                      } catch (e) {
                        return 'Please enter a whole number';
                      }
                      return null;
                    },
                    onChanged: (newValue) {
                      try {
                        widget.transaction.amountCredit = double.parse(
                            newValue.toCurrencyString(
                                mantissaLength: 6,
                                thousandSeparator: ThousandSeparator.None));
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
                  width: 60,
                  child: TextFormField(
                    style: const TextStyle(fontSize: 14),
                    initialValue: widget.transaction.tokenCredit,
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: 'Token',
                    ),
                    keyboardType: TextInputType.text,
                    onChanged: (newValue) {
                      widget.transaction.tokenCredit = newValue;
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
                      initialValue: widget.transaction.price.toCurrencyString(
                        mantissaLength: 6,
                        thousandSeparator:
                            ThousandSeparator.SpaceAndPeriodMantissa,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        hintText: 'Price',
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
                          double.parse(value!.toCurrencyString(
                              mantissaLength: 6,
                              thousandSeparator: ThousandSeparator.None));
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
                                  thousandSeparator: ThousandSeparator.None));
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
                    width: 60,
                    child: TextFormField(
                      style: const TextStyle(fontSize: 14),
                      initialValue: widget.transaction.tokenPrice,
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
                    initialValue:
                        widget.transaction.amountDebit.toCurrencyString(
                      mantissaLength: 6,
                      thousandSeparator:
                          ThousandSeparator.SpaceAndPeriodMantissa,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: 'Total Amount',
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
                        double.parse(value!.toCurrencyString(
                            mantissaLength: 6,
                            thousandSeparator: ThousandSeparator.None));
                      } catch (e) {
                        return 'Please enter a whole number';
                      }
                      return null;
                    },
                    onChanged: (newValue) {
                      try {
                        widget.transaction
                            .price = double.parse(newValue.toCurrencyString(
                                mantissaLength: 6,
                                thousandSeparator: ThousandSeparator.None)) /
                            widget.transaction.amountCredit;

                        widget.transaction.amountDebit = double.parse(
                            newValue.toCurrencyString(
                                mantissaLength: 6,
                                thousandSeparator: ThousandSeparator.None));
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
                  width: 60,
                  child: TextFormField(
                    style: const TextStyle(fontSize: 14),
                    initialValue: widget.transaction.tokenDebit,
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
                    initialValue: widget.transaction.amountFee.toCurrencyString(
                      mantissaLength: 6,
                      thousandSeparator:
                          ThousandSeparator.SpaceAndPeriodMantissa,
                    ),
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: 'Fees amount incl.',
                      hintStyle: TextStyle(fontSize: 14),
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
                        double.parse(value!.toCurrencyString(
                            mantissaLength: 6,
                            thousandSeparator: ThousandSeparator.None));
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
                                thousandSeparator: ThousandSeparator.None));
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
                  width: 60,
                  child: TextFormField(
                    style: const TextStyle(fontSize: 14),
                    initialValue: widget.transaction.tokenFee,
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
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 6),
            leading: const SizedBox(
              width: 100,
              child: Icon(Icons.info),
            ),
            title: Row(
              children: [
                const Expanded(
                  child: Text('with impact on the Total token',
                      style: TextStyle(fontSize: 14), textAlign: TextAlign.end),
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
              width: 100,
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
                      try {
                        print('Inside _formKey.currentState!.validate()');

                        // 1. Find the positions (credit and debit) in relation with the transaction
                        final oldPositionCredit =
                            await Provider.of<AppState>(context, listen: false)
                                .api
                                .positions
                                .get(widget.portfolio.id,
                                    widget.transaction.tokenCredit);

                        final newPositionCredit = Position(
                            oldPositionCredit.token,
                            oldPositionCredit.amount -
                                widget.transaction.amountCredit,
                            oldPositionCredit.time);

                        print(
                            'update old Position ${oldPositionCredit.token} - ${oldPositionCredit.amount}');
                        print(
                            'with new Position ${newPositionCredit.token} - ${newPositionCredit.amount}');
                        print(
                            'update position ${widget.transaction.tokenCredit}');

                        // 2. Update the position
                        await Provider.of<AppState>(context, listen: true)
                            .api
                            .positions
                            .update(
                                widget.portfolio.id,
                                widget.transaction.tokenCredit,
                                newPositionCredit);

                        if (widget.transaction.withImpactOnSecondPosition) {
                          print(
                              'Inside widget.transaction.withImpactOnSecondPosition');

                          final oldPositionDebit = await Provider.of<AppState>(
                                  context,
                                  listen: false)
                              .api
                              .positions
                              .get(widget.portfolio.id,
                                  widget.transaction.tokenDebit);

                          final newPositionDebit = Position(
                              oldPositionDebit.token,
                              oldPositionDebit.amount +
                                  widget.transaction.amountDebit,
                              oldPositionDebit.time);

                          await Provider.of<AppState>(context, listen: false)
                              .api
                              .positions
                              .update(
                                  widget.portfolio.id,
                                  widget.transaction.tokenDebit,
                                  newPositionDebit);
                        }

                        // 3. Delete the transaction
                        await Provider.of<AppState>(context, listen: false)
                            .api
                            .transactions
                            .delete(widget.portfolio.id, widget.transaction.id);
                      } catch (e) {
                        print(e);
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
}
