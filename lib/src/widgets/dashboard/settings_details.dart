import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants.dart';
import '../../controllers/controllers.dart';

class SettingsDetails extends StatelessWidget {
  const SettingsDetails({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            trailing: GetBuilder<ThemeController>(
              builder: (controller) => Switch(
                value: getThemeModeFromString(controller.currentTheme),
                onChanged: (val) {
                  controller.setThemeMode(val ? 'dark' : 'light');
                },
              ),
            ),
          ),
          ListTile(
            title: const Text(
              'Show position with zero amount',
              style: TextStyle(fontSize: 14),
            ),
            trailing: GetBuilder<ZeroPositionController>(
              builder: (controller) => Switch(
                value: controller.currentZeroPosition,
                onChanged: (val) {
                  controller.setZeroPositionDisplay(val);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool getThemeModeFromString(String themeString) {
    bool _setThemeMode = false;
    if (themeString == 'light') {
      _setThemeMode = false;
    }
    if (themeString == 'dark') {
      _setThemeMode = true;
    }
    return _setThemeMode;
  }
}
