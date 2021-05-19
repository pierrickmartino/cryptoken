// Copyright 2020, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

abstract class Auth {
  Future<bool> get isSignedIn;
  Future<User?> signIn();
  Future<dynamic> signOut();
  Future<dynamic> getUser();
}

// todo : improve to match the google User
abstract class User {
  String get uid;
  String get name;
  String get userEmail;
  String get imageUrl;
}

class SignInException implements Exception {}
