// Copyright 2020, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' hide FirebaseUser;
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth.dart' as auth;

//import 'auth.dart' as auth;

class FirebaseAuthService implements auth.Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  String? uid;
  String? name;
  String? userEmail;
  String? imageUrl;

  @override
  Future<bool> get isSignedIn async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool authSignedIn = prefs.getBool('auth') ?? false;
    return authSignedIn;
  }

// To check if the user is already signed into the
// app using Google Sign In
  @override
  Future<dynamic> getUser() async {
    await Firebase.initializeApp();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool authSignedIn = prefs.getBool('auth') ?? false;

    final User user = _auth.currentUser!;

    if (authSignedIn == true) {
      uid = user.uid;
      name = user.displayName;
      userEmail = user.email;
      imageUrl = user.photoURL;
    }
  }

  @override
  Future<auth.User?> signIn() async {
    await Firebase.initializeApp();

    // Trigger the authentication flow
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;

    // Create a new credential
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    // Once signed in, return the UserCredential
    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);
    final User? user = userCredential.user!;

    if (user != null) {
      // Checking if email and name is null
      assert(user.email != null);
      assert(user.displayName != null);
      assert(user.photoURL != null);

      uid = user.uid;
      name = user.displayName;
      userEmail = user.email;
      imageUrl = user.photoURL;

      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final User? currentUser = _auth.currentUser;
      assert(user.uid == currentUser!.uid);

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('auth', true);

      final _User _user = _User(uid!, name!, userEmail!, imageUrl!);

      return _user;
    }
    return null;
  }

// For authenticating user using Google Sign In
// with Firebase Authentication API.

// Retrieves some general user related information
// from their Google account for ease of the login process

  Future<String?> signInWithGoogle() async {
    await Firebase.initializeApp();

    // Trigger the authentication flow
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;

    // Create a new credential
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    // Once signed in, return the UserCredential
    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);
    final User? user = userCredential.user;

    if (user != null) {
      // Checking if email and name is null
      assert(user.email != null);
      assert(user.displayName != null);
      assert(user.photoURL != null);

      uid = user.uid;
      name = user.displayName;
      userEmail = user.email;
      imageUrl = user.photoURL;

      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final User currentUser = _auth.currentUser!;
      assert(user.uid == currentUser.uid);

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('auth', true);

      return 'Google sign in successful, User UID: ${user.uid}';
    }

    return null;
  }

  Future<String?> registerWithEmailPassword(
      String email, String password) async {
    await Firebase.initializeApp();

    final UserCredential userCredential =
        await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final User? user = userCredential.user;

    if (user != null) {
      // checking if uid or email is null
      assert(user.email != null);

      uid = user.uid;
      userEmail = user.email;

      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      return 'Successfully registered, User UID: ${user.uid}';
    }

    return null;
  }

  Future<String?> signInWithEmailPassword(String email, String password) async {
    await Firebase.initializeApp();

    final UserCredential userCredential =
        await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final User? user = userCredential.user;

    if (user != null) {
      // checking if uid or email is null
      assert(user.email != null);

      uid = user.uid;
      userEmail = user.email;

      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final User? currentUser = _auth.currentUser;
      assert(user.uid == currentUser!.uid);

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('auth', true);

      return 'Successfully logged in, User UID: ${user.uid}';
    }

    return null;
  }

  @override
  Future<String> signOut() async {
    await _auth.signOut();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auth', false);

    uid = null;
    userEmail = null;

    return 'User signed out';
  }

  /// For signing out of their Google account
  Future<void> signOutGoogle() async {
    await googleSignIn.signOut();
    await _auth.signOut();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auth', false);

    uid = null;
    name = null;
    userEmail = null;
    imageUrl = null;

    //print('User signed out of Google account');
  }
}

class _User implements auth.User {
  _User(this.uid, this.name, this.userEmail, this.imageUrl);

  @override
  final String uid, name, userEmail, imageUrl;
}
