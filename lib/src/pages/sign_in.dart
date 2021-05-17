// Copyright 2020, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../auth/auth.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({
    Key? key,
    required this.auth,
    required this.onSuccess,
  }) : super(key: key);

  final Auth auth;
  final ValueChanged<User> onSuccess;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SignInButton(auth: auth, onSuccess: onSuccess),
      ),
    );
  }
}

class SignInButton extends StatefulWidget {
  const SignInButton({
    Key? key,
    required this.auth,
    required this.onSuccess,
  }) : super(key: key);

  final Auth auth;
  final ValueChanged<User> onSuccess;

  @override
  _SignInButtonState createState() => _SignInButtonState();
}

class _SignInButtonState extends State<SignInButton> {
  late Future<bool> _checkSignInFuture;

  @override
  void initState() {
    super.initState();
    _checkSignInFuture = _checkIfSignedIn();
  }

  // Check if the user is signed in. If the user is already signed in (for
  // example, if they signed in and refreshed the page), invoke the `onSuccess`
  // callback right away.
  Future<bool> _checkIfSignedIn() async {
    final alreadySignedIn = await widget.auth.isSignedIn;
    if (alreadySignedIn) {
      final user = await widget.auth.signIn();
      widget.onSuccess(user!);
    }
    return alreadySignedIn;
  }

  Future<void> _signIn() async {
    try {
      final user = await widget.auth.signIn();
      widget.onSuccess(user!);
    } on SignInException {
      _showError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkSignInFuture,
      builder: (context, snapshot) {
        // If signed in, or the future is incomplete, show a circular
        // progress indicator.
        final alreadySignedIn = snapshot.data;
        if (snapshot.connectionState != ConnectionState.done ||
            alreadySignedIn == true) {
          return const CircularProgressIndicator();
        }

        // If sign in failed, show toast and the login button
        if (snapshot.hasError) {
          _showError();
        }

        return ElevatedButton(
          onPressed: _signIn,
          child: const Text('Sign In with Google'),
        );
      },
    );
  }

  void _showError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Unable to sign in.'),
      ),
    );
  }
}
