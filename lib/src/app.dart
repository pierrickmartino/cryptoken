import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constant.dart';
import '../route.dart';
import 'api/api.dart';
import 'api/firebase.dart';
import 'api/mock.dart';
import 'auth/auth.dart';
import 'auth/firebase.dart';

const settingsBox = 'settings';

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
  const DashboardApp({Key? key, required this.auth, required this.apiBuilder})
      : super(key: key);

  /// Runs the app using Firebase
  DashboardApp.firebase()
      : auth = FirebaseAuthService(),
        apiBuilder = _apiBuilder;

  /// Runs the app using mock data
  // DashboardApp.mock()
  //     : auth = MockAuthService(),
  //       apiBuilder = _mockApiBuilder;

  // static final ApiBuilder _mockApiBuilder =
  //     (user) => MockDashboardApi()..fillWithMockData();
  static final ApiBuilder _apiBuilder =
      (user) => FirebaseDashboardApi(FirebaseFirestore.instance, user.uid);

  final Auth auth;
  final ApiBuilder apiBuilder;

  @override
  _DashboardAppState createState() => _DashboardAppState();
}

class _DashboardAppState extends State<DashboardApp> {
  //late AppState appState;

  @override
  void initState() {
    //appState = AppState(widget.auth);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return
        // ValueListenableBuilder(
        //     valueListenable: Hive.box(settingsBox).listenable(),
        //     builder: (listenerContext, Box<dynamic> box, listenerWidget) {
        //       final darkMode = box.get('darkMode', defaultValue: false);
        // return
        //Provider.value(
        // value: _appState,
        // child:
        GetMaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),

      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bgColor,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
            .apply(bodyColor: Colors.white),
        canvasColor: secondaryColor,
      ),
      // ThemeData(
      //   primaryColor: const Color(0xff004e98),
      //   accentColor: const Color(0xffff6700),
      //   dividerColor: const Color(0xffc0c0c0),
      //   canvasColor: const Color(0xffEBEBEB),
      // ),
      initialRoute: '/',
      getPages: AppRoutes.routes,
      // home: SignInSwitcher(
      //   appState: _appState,
      //   apiBuilder: widget.apiBuilder,
      // ),
      //),
      //);
      //}
    );
  }
}

/// Switches between showing the [SignInPage] or [HomePage], depending on
/// whether or not the user is signed in.
// class SignInSwitcher extends StatefulWidget {
//   const SignInSwitcher({
//     Key? key,
//     this.appState,
//     this.apiBuilder,
//   }) : super(key: key);

//   final AppState? appState;
//   final ApiBuilder? apiBuilder;

//   @override
//   _SignInSwitcherState createState() => _SignInSwitcherState();
// }

// class _SignInSwitcherState extends State<SignInSwitcher> {
//   bool _isSignedIn = false;

//   @override
//   Widget build(BuildContext context) {
//     //final FirebaseAuth _auth = FirebaseAuth.instance;

//     return AnimatedSwitcher(
//       switchInCurve: Curves.easeOut,
//       switchOutCurve: Curves.easeOut,
//       duration: const Duration(milliseconds: 600),
//       child: _isSignedIn
//           ? FutureBuilder<User>(
//               builder: (context, futureSnapshot) {
//                 if (!futureSnapshot.hasData) {
//                   return const Center(
//                     child: CircularProgressIndicator(),
//                   );
//                 }

//                 if (futureSnapshot.hasError) {
//                   return const Center(
//                     child: CircularProgressIndicator(),
//                   );
//                 }

//                 return MultiProvider(
//                   providers: [
//                     ChangeNotifierProvider(
//                       create: (context) => MenuController(),
//                     ),
//                   ],
//                   child: HomePage(
//                     onSignOut: _handleSignOut,
//                     user: futureSnapshot.data!,
//                   ),
//                 );
//               },
//               future: _getUser(),
//               initialData: MockUser())
//           : SignInPage(
//               auth: widget.appState!.auth!,
//               onSuccess: _handleSignIn,
//             ),
//     );
//   }

//   void _handleSignIn(User user) {
//     widget.appState!.api = widget.apiBuilder!(user);

//     setState(() {
//       _isSignedIn = true;
//     });
//   }

//   Future<User> _getUser() async {
//     final _user = await widget.appState!.auth!.signIn();
//     if (_user == null) {
//       return MockUser();
//     } else {
//       return _user;
//     }
//   }

//   Future<void> _handleSignOut() async {
//     await widget.appState!.auth!.signOut();
//     setState(() {
//       _isSignedIn = false;
//     });
//   }
// }
