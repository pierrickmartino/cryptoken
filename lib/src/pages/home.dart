import 'package:flutter/material.dart';
import 'package:web_dashboard/src/auth/auth.dart';

import '../auth/mock.dart';
import '../widgets/dialogs.dart';
import '../widgets/third_party/adaptive_scaffold.dart';

import 'dashboard.dart';
import 'settings.dart';
import 'transactions.dart';

bool _isLargeScreen(BuildContext context) {
  return MediaQuery.of(context).size.width > 960.0;
}

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
    required this.onSignOut,
  }) : super(key: key);

  final VoidCallback onSignOut;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _pageIndex = 0;

  final User user = MockUser();

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      title: const Text('Cryptoken'),
      actions: [
        Center(
          child: Text(user.name),
        ),
        const SizedBox(width: 10),
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextButton(
            style: TextButton.styleFrom(primary: Colors.white),
            onPressed: _handleSignOut,
            child: const Text('Sign Out'),
          ),
        )
      ],
      currentIndex: _pageIndex,
      destinations: const [
        AdaptiveScaffoldDestination(title: 'Home', icon: Icons.home),
        AdaptiveScaffoldDestination(title: 'Transactions', icon: Icons.list),
        AdaptiveScaffoldDestination(title: 'Settings', icon: Icons.settings),
      ],
      body: _pageAtIndex(_pageIndex, context),
      onNavigationIndexChange: (newIndex) {
        setState(() {
          _pageIndex = newIndex;
        });
      },
      floatingActionButton:
          _hasFloatingActionButton ? _buildFab(context) : null,
    );
  }

  bool get _hasFloatingActionButton {
    if (_pageIndex == 2) {
      return false;
    }
    return true;
  }

  FloatingActionButton _buildFab(BuildContext context) {
    return FloatingActionButton(
      onPressed: _handleFabPressed,
      child: const Icon(Icons.add),
    );
  }

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

  static Widget _pageAtIndex(int index, BuildContext context) {
    if (index == 0) {
      return const DashboardPage();
    }

    if (index == 1) {
      return const TransactionsPage();
    }

    return const SettingsPage();
  }
}
