import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_dashboard/wallet/controller/wallet_controller.dart';
import 'package:web_dashboard/wallet/model/wallet_model.dart';

bool _isLargeScreen(BuildContext context) {
  return MediaQuery.of(context).size.width > 960.0;
}

class EditWalletDialog extends StatelessWidget {
  const EditWalletDialog({
    Key? key,
    required this.portfolio,
  }) : super(key: key);

  final WalletModel portfolio;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Edit Portfolio'),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      children: [
        Container(
          width: _isLargeScreen(context)
              ? 600
              : MediaQuery.of(context).size.width - 10,
          child: Column(children: [
            EditWalletForm(
              portfolio: portfolio,
            ),
          ]),
        ),
      ],
    );
  }
}

class EditWalletForm extends StatelessWidget {
  EditWalletForm({
    Key? key,
    required this.portfolio,
  }) : super(key: key);

  final WalletModel portfolio;

  final _formKey = GlobalKey<FormState>();
  final WalletController walletController = WalletController.to;

  @override
  Widget build(BuildContext context) {
    String _portfolioName = '';

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TextFormField(
              style: const TextStyle(fontSize: 14),
              initialValue: portfolio.name,
              decoration: const InputDecoration(
                isDense: true,
                hintText: 'Name',
              ),
              onChanged: (value) => _portfolioName = value,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: ElevatedButton(
                  onPressed: Get.back,
                  child: const Text('Cancel'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      debugPrint('portfolio.id : ${portfolio.id}');
                      debugPrint('_portfolioName : ${_portfolioName}');
                      WalletModel _newWallet =
                          WalletModel(name: _portfolioName);
                      walletController.updateFirestoreWallet(
                          _newWallet, portfolio.id);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Portfolio ${portfolio.name} updated'),
                        ),
                      );

                      Get.back();
                    }
                  },
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
