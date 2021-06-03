import 'package:hive/hive.dart';

import 'package:flutter/material.dart';

const settingsBox = 'settings';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final box = Hive.box(settingsBox);

  @override
  Widget build(BuildContext context) {
    final darkMode = box.get('darkMode', defaultValue: false);
    final showZeroPosition = box.get('showZeroPosition', defaultValue: false);

    return Column(
      children: [
        ListTile(
          title: const Text('Theme mode light/dark'),
          trailing: Switch(
            value: darkMode,
            onChanged: (val) {
              setState(() {
                box.put('darkMode', !darkMode);
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Show position with zero amount'),
          trailing: Switch(
            value: showZeroPosition,
            onChanged: (val) {
              setState(() {
                box.put('showZeroPosition', !showZeroPosition);
              });
            },
          ),
        )
      ],
    );
  }
}
