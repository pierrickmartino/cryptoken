// Copyright 2020, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import 'auth.dart';

class MockAuthService implements Auth {
  @override
  Future<bool> get isSignedIn async {
    return false;
  }

  // To check if the user is already signed into the
// app using Google Sign In
  @override
  Future<dynamic> getUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool authSignedIn = prefs.getBool('auth') ?? false;

    final User user = MockUser();

    if (authSignedIn == true) {
      return user;
    }
  }

  @override
  Future<User> signIn() async {
    // Sign in will randomly fail 25% of the time.
    final random = Random();
    if (random.nextInt(4) == 0) {
      throw SignInException();
    }
    return MockUser();
  }

  @override
  Future<dynamic> signOut() async {
    return null;
  }
}

class MockUser implements User {
  @override
  String get uid => '123';
  @override
  String get name => '-';
  @override
  String get userEmail => '-';
  @override
  String get imageUrl => 'https://picsum.photos/250?image=9';
}
