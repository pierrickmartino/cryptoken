// Copyright 2020, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../widgets/dialogs.dart';
import '../widgets/third_party/adaptive_scaffold.dart';
import 'dashboard.dart';
import 'transactions.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key key,
    @required this.onSignOut,
  }) : super(key: key);

  final VoidCallback onSignOut;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      title: const Text('Cryptoken'),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
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
      body: _pageAtIndex(_pageIndex),
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
    if (_pageIndex == 2) return false;
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
      showDialog<NewTransactionDialog>(
        context: context,
        builder: (context) => const NewTransactionDialog(),
      );
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

    if (!shouldSignOut) {
      return;
    }

    widget.onSignOut();
  }

  static Widget _pageAtIndex(int index) {
    if (index == 0) {
      return const DashboardPage();
    }

    if (index == 1) {
      return TransactionsPage();
    }

    return const Center(child: Text('Settings page'));
  }
}
