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
    required this.wallet,
  }) : super(key: key);

  final WalletModel wallet;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Edit wallet'),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      children: [
        Container(
          width: _isLargeScreen(context)
              ? 600
              : MediaQuery.of(context).size.width - 10,
          child: Column(children: [
            EditWalletForm(
              wallet: wallet,
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
    required this.wallet,
  }) : super(key: key);

  final WalletModel wallet;

  final _formKey = GlobalKey<FormState>();
  final WalletController walletController = WalletController.to;

  @override
  Widget build(BuildContext context) {
    String _walletName = '';

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TextFormField(
              style: const TextStyle(fontSize: 14),
              initialValue: wallet.name,
              decoration: const InputDecoration(
                isDense: true,
                hintText: 'Name',
              ),
              onChanged: (value) => _walletName = value,
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
                      final WalletModel _newWallet =
                          WalletModel(name: _walletName);
                      walletController
                          .updateFirestoreWallet(_newWallet, wallet.id)
                          .then((value) => Get
                            ..back<void>()
                            ..snackbar<void>(
                                'Successful', 'wallet ${wallet.name} updated !',
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
          ),
        ],
      ),
    );
  }
}
