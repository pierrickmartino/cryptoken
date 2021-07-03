import 'package:flutter/material.dart';

class SplashUI extends StatelessWidget {
  const SplashUI({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('Enter SplashUI');

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
