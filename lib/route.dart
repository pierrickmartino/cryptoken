import 'package:get/get.dart';

import 'package:web_dashboard/src/pages/home.dart';
import 'package:web_dashboard/src/pages/splash.dart';

import 'auth/view/reset_password_ui.dart';
import 'auth/view/sign_in.dart';
import 'auth/view/sign_up_ui.dart';
import 'settings/view/settings.dart';

class AppRoutes {
  AppRoutes._(); //this is to prevent anyone from instantiating this object
  static final routes = [
    GetPage(name: '/', page: () => const SplashUI()),
    GetPage(name: '/signin', page: () => SignInUI()),
    GetPage(name: '/signup', page: () => SignUpUI()),
    GetPage(name: '/home', page: () => const HomeUI()),
    GetPage(name: '/settings', page: () => SettingsUI()),
    GetPage(name: '/reset-password', page: () => ResetPasswordUI()),
    //GetPage(name: '/update-profile', page: () => UpdateProfileUI()),
  ];
}
