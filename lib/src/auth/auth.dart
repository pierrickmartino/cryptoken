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
