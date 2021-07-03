// import 'package:flutter/material.dart';
// import 'package:web_dashboard/wallet/controller/wallet_controller.dart';
// import 'package:web_dashboard/wallet/model/wallet_model.dart';

// class NewPortfolioForm extends StatelessWidget {
//   NewPortfolioForm({Key? key}) : super(key: key);

//   final WalletModel _portfolio = WalletModel(name: 'Empty');

//   @override
//   Widget build(BuildContext context) {
//     //final api = Provider.of<AppState>(context).api;
//     return EditPortfolioForm(
//       portfolio: _portfolio,
//       // onDone: (shouldInsert) {
//       //   if (shouldInsert) {
//       //     debugPrint('shouldInsert');
//       //   }
//       //   Navigator.of(context).pop();
//       // },
//     );
//   }
// }

// class EditPortfolioForm extends StatelessWidget {
//   EditPortfolioForm({
//     Key? key,
//     required this.portfolio,
//   }) : super(key: key);

//   final WalletModel portfolio;

//   final _formKey = GlobalKey<FormState>();
//   final WalletController walletController = WalletController.to;

//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: _formKey,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(bottom: 16),
//             child: TextFormField(
//               style: const TextStyle(fontSize: 14),
//               initialValue: portfolio.name,
//               decoration: const InputDecoration(
//                 isDense: true,
//                 hintText: 'Name',
//               ),
//               onChanged: (value) => null,
//               validator: (value) {
//                 if (value!.isEmpty) {
//                   return 'Please enter a name';
//                 }
//                 return null;
//               },
//             ),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(left: 8, right: 8),
//                 child: ElevatedButton(
//                   onPressed: () {
//                     debugPrint('CancelInsert');
//                     //onDone(false);
//                   },
//                   child: const Text('Cancel'),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(left: 8, right: 8),
//                 child: ElevatedButton(
//                   onPressed: () {
//                     if (_formKey.currentState!.validate()) {
//                       WalletModel _newWallet =
//                           WalletModel(name: portfolio.name);
//                       walletController.insertFirestoreWallet(_newWallet);
//                       //api.portfolios.insert(_portfolio);

//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('Portfolio inserted'),
//                         ),
//                       );
//                     }
//                   },
//                   child: const Text('OK'),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
