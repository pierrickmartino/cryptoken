import 'package:hive/hive.dart';

import 'package:flutter/material.dart';

import '../../constants.dart';

const settingsBox = 'settings';

class SettingsDetails extends StatefulWidget {
  const SettingsDetails({
    Key? key,
  }) : super(key: key);
  @override
  _SettingsDetailsState createState() => _SettingsDetailsState();
}

class _SettingsDetailsState extends State<SettingsDetails> {
  final box = Hive.box(settingsBox);

  @override
  Widget build(BuildContext context) {
    final darkMode = box.get('darkMode', defaultValue: false);
    final showZeroPosition = box.get('showZeroPosition', defaultValue: false);

    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: const BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: defaultPadding),
          ListTile(
            title: const Text(
              'Theme mode light/dark',
              style: TextStyle(fontSize: 14),
            ),
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
            title: const Text(
              'Show position with zero amount',
              style: TextStyle(fontSize: 14),
            ),
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
      ),
    );
  }
}
