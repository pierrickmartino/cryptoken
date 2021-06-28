import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../src/auth/auth.dart';
import '../../src/controllers/menu_controller.dart';

import '../widgets/dialogs.dart';

import 'dashboard_screen.dart';

bool _isLargeScreen(BuildContext context) {
  return MediaQuery.of(context).size.width > 960.0;
}

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
    required this.onSignOut,
    required this.user,
  }) : super(key: key);

  final VoidCallback onSignOut;
  final User user;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MenuController>().scaffoldKey,
      //drawer: const SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            // We want this side menu only for large screen
            // if (Responsive.isDesktop(context))
            //   const Expanded(
            //     // default flex = 1
            //     // and it takes 1/7 part of the screen
            //     child: SideMenu(),
            //   ),
            Expanded(
              // It takes 6/7 part of the screen
              //flex: 6,
              child: DashboardScreen(),
            ),
          ],
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

  void _handleFabPressed() {
    if (_pageIndex == 0) {
      showDialog<NewPortfolioDialog>(
        context: context,
        builder: (context) => const NewPortfolioDialog(),
      );
      return;
    }

    if (_pageIndex == 1) {
      if (_isLargeScreen(context)) {
        showDialog<NewTransactionDialog>(
          context: context,
          builder: (context) => NewTransactionDialog(),
        );
      } else {
        showGeneralDialog<NewTransactionDialog>(
          context: context,
          pageBuilder: (context, animation, secondaryAnimation) =>
              NewTransactionDialog(),
        );
      }

      return;
    }
  }

  Future<void> _handleSignOut() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (!shouldSignOut!) {
      return;
    }

    widget.onSignOut();
  }

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
