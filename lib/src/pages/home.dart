import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_dashboard/auth/controller/auth_controller.dart';

import 'dashboard_screen.dart';

class HomeUI extends StatelessWidget {
  const HomeUI({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      init: AuthController(),
      builder: (controller) => Scaffold(
        body: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(
                child: DashboardScreen(),
              ),
            ],
          ),
        ),
      ),
    );

    // return AdaptiveScaffold(
    //   title: const Text('Cryptoken'),
    //   actions: [
    //     Center(
    //       child: CircleAvatar(
    //         radius: 15,
    //         backgroundImage: NetworkImage(widget.user.imageUrl),
    //         child: Container(),
    //       ),
    //     ),
    //     const SizedBox(width: 10),
    //     Center(
    //       child: Text(widget.user.name),
    //     ),
    //     const SizedBox(width: 10),
    //     Padding(
    //       padding: const EdgeInsets.all(12),
    //       child: _isLargeScreen(context)
    //           ? TextButton(
    //               style: TextButton.styleFrom(primary: Colors.white),
    //               onPressed: _handleSignOut,
    //               child: const Text('Sign Out'),
    //             )
    //           : IconButton(
    //               onPressed: _handleSignOut,
    //               icon: const Icon(Icons.logout_rounded),
    //               color: Colors.white,
    //             ),
    //     )
    //   ],
    //   currentIndex: _pageIndex,
    //   destinations: const [
    //     AdaptiveScaffoldDestination(title: 'Home', icon: Icons.home),
    //     AdaptiveScaffoldDestination(title: 'Transactions', icon: Icons.list),
    //     AdaptiveScaffoldDestination(title: 'Settings', icon: Icons.settings),
    //   ],
    //   body: _pageAtIndex(_pageIndex, context),
    //   onNavigationIndexChange: (newIndex) {
    //     setState(() {
    //       _pageIndex = newIndex;
    //     });
    //   },
    //   floatingActionButton:
    //       _hasFloatingActionButton ? _buildFab(context) : null,
    // );
  }

  // bool get _hasFloatingActionButton {
  //   if (_pageIndex == 2) {
  //     return false;
  //   }
  //   return true;
  // }

  // FloatingActionButton _buildFab(BuildContext context) {
  //   return FloatingActionButton(
  //     onPressed: _handleFabPressed,
  //     child: const Icon(Icons.add),
  //   );
  // }

  // void _handleFabPressed() {
  //   if (pageIndex == 0) {
  //     showDialog<NewPortfolioDialog>(
  //       context: context,
  //       builder: (context) => const NewPortfolioDialog(),
  //     );
  //     return;
  //   }

  //   if (pageIndex == 1) {
  //     if (_isLargeScreen(context)) {
  //       showDialog<NewTransactionDialog>(
  //         context: context,
  //         builder: (context) => NewTransactionDialog(),
  //       );
  //     } else {
  //       showGeneralDialog<NewTransactionDialog>(
  //         context: context,
  //         pageBuilder: (context, animation, secondaryAnimation) =>
  //             NewTransactionDialog(),
  //       );
  //     }

  //     return;
  //   }
  // }

  // Future<void> _handleSignOut() async {
  //   final shouldSignOut = await showDialog<bool>(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Are you sure you want to sign out?'),
  //       actions: [
  //         TextButton(
  //           onPressed: () {
  //             Navigator.of(context).pop(false);
  //           },
  //           child: const Text('No'),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             Navigator.of(context).pop(true);
  //           },
  //           child: const Text('Yes'),
  //         ),
  //       ],
  //     ),
  //   );

  //   if (!shouldSignOut!) {
  //     return;
  //   }

  //   widget.onSignOut();
  // }

//   static Widget _pageAtIndex(int index, BuildContext context) {
//     if (index == 0) {
//       return const DashboardPage();
//     }

//     if (index == 1) {
//       return const TransactionsPage();
//     }

//     return const SettingsPage();
//   }
}
