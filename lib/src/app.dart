// Copyright 2020, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'api/api.dart';
import 'api/firebase.dart';
import 'api/mock.dart';
import 'auth/auth.dart';
import 'auth/firebase.dart';
import 'auth/mock.dart';
import 'pages/home.dart';
import 'pages/sign_in.dart';

/// The global state the app.
class AppState {
  AppState(this.auth);

  final Auth? auth;
  late DashboardApi api;
}

/// Creates a [DashboardApi] for the given user. This allows users of this
/// widget to specify whether [MockDashboardApi] or [ApiBuilder] should be
/// created when the user logs in.
typedef ApiBuilder = DashboardApi Function(User user);

/// An app that displays a personalized dashboard.
class DashboardApp extends StatefulWidget {
  static final ApiBuilder _mockApiBuilder =
      (user) => MockDashboardApi()..fillWithMockData();
  static final ApiBuilder _apiBuilder =
      (user) => FirebaseDashboardApi(FirebaseFirestore.instance, user.uid);

  final Auth auth;
  final ApiBuilder apiBuilder;

  /// Runs the app using Firebase
  DashboardApp.firebase()
      : auth = FirebaseAuthService(),
        apiBuilder = _apiBuilder;

  /// Runs the app using mock data
  DashboardApp.mock()
      : auth = MockAuthService(),
        apiBuilder = _mockApiBuilder;

  @override
  _DashboardAppState createState() => _DashboardAppState();
}

class _DashboardAppState extends State<DashboardApp> {
  late AppState _appState;

  @override
  void initState() {
    super.initState();
    _appState = AppState(widget.auth);
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: _appState,
      child: MaterialApp(
        theme: ThemeData(
          primaryColor: const Color(0xff004e98),
          accentColor: const Color(0xffff6700),
          dividerColor: const Color(0xffc0c0c0),
          canvasColor: const Color(0xffEBEBEB),
        ),
        debugShowCheckedModeBanner: false,
        home: SignInSwitcher(
          appState: _appState,
          apiBuilder: widget.apiBuilder,
        ),
      ),
    );
  }
}

/// Switches between showing the [SignInPage] or [HomePage], depending on
/// whether or not the user is signed in.
class SignInSwitcher extends StatefulWidget {
  const SignInSwitcher({
    Key? key,
    this.appState,
    this.apiBuilder,
  }) : super(key: key);

  final AppState? appState;
  final ApiBuilder? apiBuilder;

  @override
  _SignInSwitcherState createState() => _SignInSwitcherState();
}

class _SignInSwitcherState extends State<SignInSwitcher> {
  bool _isSignedIn = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeOut,
      duration: const Duration(milliseconds: 200),
      child: _isSignedIn
          ? HomePage(
              onSignOut: _handleSignOut,
            )
          : SignInPage(
              auth: widget.appState!.auth!,
              onSuccess: _handleSignIn,
            ),
    );
  }

  void _handleSignIn(User user) {
    widget.appState!.api = widget.apiBuilder!(user);

    setState(() {
      _isSignedIn = true;
    });
  }

  Future<void> _handleSignOut() async {
    await widget.appState!.auth!.signOut();
    setState(() {
      _isSignedIn = false;
    });
  }
}
