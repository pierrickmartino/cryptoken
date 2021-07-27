import 'package:flutter/material.dart';

class LogoGraphicHeader extends StatelessWidget {
  const LogoGraphicHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const String _imageLogo = 'assets/images/default.png';
    return Hero(
      tag: 'App Logo',
      child: CircleAvatar(
          foregroundColor: Colors.blue,
          backgroundColor: Colors.transparent,
          radius: 60,
          child: ClipOval(
            child: Image.asset(
              _imageLogo,
              fit: BoxFit.cover,
              width: 120,
              height: 120,
            ),
          )),
    );
  }
}
