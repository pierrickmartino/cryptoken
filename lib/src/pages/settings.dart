import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:flutter/material.dart';

const darkModeBox = 'darkMode';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final box = Hive.box(darkModeBox);

  @override
  Widget build(BuildContext context) {
    var darkMode = box.get('darkMode', defaultValue: false);

    return Column(
      children: [
        Row(
          children: [
            const Text('Theme mode light/dark'),
            const Spacer(),
            Switch(
              value: darkMode,
              onChanged: (val) {
                setState(() {
                  box.put('darkMode', !darkMode);
                });
              },
            ),
          ],
        )
      ],
    );
  }
}
