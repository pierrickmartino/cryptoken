import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_dashboard/utils/validator.dart';

import '../controller/auth_controller.dart';

import 'form_input_field_with_icon.dart';
import 'form_vertical_spacing.dart';
import 'label_button.dart';
import 'logo_graphic_header.dart';
import 'primary_button.dart';
import 'reset_password_ui.dart';
import 'sign_up_ui.dart';

class SignInUI extends StatelessWidget {
  SignInUI({Key? key}) : super(key: key);

  final AuthController authController = AuthController.to;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    debugPrint('Enter SignInUI');

    return Scaffold(
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // LogoGraphicHeader(),
                  // const SizedBox(height: 48),
                  FormInputFieldWithIcon(
                    controller: authController.emailController,
                    iconPrefix: Icons.email,
                    labelText: 'Email',
                    validator: Validator().email,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) => null,
                    onSaved: (value) =>
                        authController.emailController.text = value!,
                  ),
                  FormVerticalSpace(),
                  FormInputFieldWithIcon(
                    controller: authController.passwordController,
                    iconPrefix: Icons.lock,
                    labelText: 'Password',
                    validator: Validator().password,
                    obscureText: true,
                    onChanged: (value) => null,
                    onSaved: (value) =>
                        authController.passwordController.text = value!,
                    maxLines: 1,
                  ),
                  FormVerticalSpace(),
                  PrimaryButton(
                      labelText: 'Sign in',
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await authController
                              .signInWithEmailAndPassword(context);
                        }
                      }),
                  FormVerticalSpace(),
                  LabelButton(
                    labelText: 'Reset password ?',
                    onPressed: () => Get.to<ResetPasswordUI>(ResetPasswordUI()),
                  ),
                  LabelButton(
                    labelText: 'Sign up',
                    onPressed: () => Get.to<SignUpUI>(SignUpUI()),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';

// import '../auth/auth.dart';

// class SignInPage extends StatelessWidget {
//   const SignInPage({
//     Key? key,
//     required this.auth,
//     required this.onSuccess,
//   }) : super(key: key);

//   final Auth auth;
//   final ValueChanged<User> onSuccess;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: SignInButton(auth: auth, onSuccess: onSuccess),
//       ),
//     );
//   }
// }

// class SignInButton extends StatefulWidget {
//   const SignInButton({
//     Key? key,
//     required this.auth,
//     required this.onSuccess,
//   }) : super(key: key);

//   final Auth auth;
//   final ValueChanged<User> onSuccess;

//   @override
//   _SignInButtonState createState() => _SignInButtonState();
// }

// class _SignInButtonState extends State<SignInButton> {
//   late Future<bool> _checkSignInFuture;

//   @override
//   void initState() {
//     super.initState();
//     _checkSignInFuture = _checkIfSignedIn();
//   }

//   // Check if the user is signed in. If the user is already signed in (for
//   // example, if they signed in and refreshed the page), invoke the `onSuccess`
//   // callback right away.
//   Future<bool> _checkIfSignedIn() async {
//     final alreadySignedIn = await widget.auth.isSignedIn;
//     if (alreadySignedIn) {
//       final user = await widget.auth.signIn();
//       widget.onSuccess(user!);
//     }
//     return alreadySignedIn;
//   }

//   Future<void> _signIn() async {
//     try {
//       final user = await widget.auth.signIn();
//       widget.onSuccess(user!);
//     } on SignInException {
//       _showError();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<bool>(
//       future: _checkSignInFuture,
//       builder: (context, snapshot) {
//         // If signed in, or the future is incomplete, show a circular
//         // progress indicator.
//         final alreadySignedIn = snapshot.data;
//         if (snapshot.connectionState != ConnectionState.done ||
//             alreadySignedIn == true) {
//           return const CircularProgressIndicator();
//         }

//         // If sign in failed, show toast and the login button
//         // if (snapshot.hasError) {
//         //   _showError();
//         // }

//         return ElevatedButton(
//           onPressed: _signIn,
//           child: const Text('Sign In with Google'),
//         );
//       },
//     );
//   }

//   void _showError() {
//     debugPrint('Unable to sign in.');

//     // ScaffoldMessenger.of(context).showSnackBar(
//     //   const SnackBar(
//     //     content: Text('Unable to sign in.'),
//     //   ),
//     // );
//   }
// }
