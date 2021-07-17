import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:web_dashboard/position/controller/position_controller.dart';

class SettingsUI extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsUI> {
  bool lockInBackground = true;
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings UI')),
      body: buildSettingsList(),
    );
  }

  Widget buildSettingsList() {
    return GetBuilder<PositionController>(
      builder: (controller) => SettingsList(
        sections: [
          SettingsSection(
            title: 'Common',
            tiles: [
              SettingsTile.switchTile(
                title: 'Show position with zero amount',
                leading: const Icon(Icons.details),
                switchValue: controller.currentZeroPosition,
                onToggle: (bool value) {
                  //setState(() {
                  controller.setZeroPositionDisplay(value);
                  //});
                },
              ),
              const SettingsTile(
                title: 'Environment',
                subtitle: 'Production',
                leading: Icon(Icons.cloud_queue),
              ),
            ],
          ),
          SettingsSection(
            title: 'Account',
            tiles: const [
              SettingsTile(title: 'Phone number', leading: Icon(Icons.phone)),
              SettingsTile(title: 'Email', leading: Icon(Icons.email)),
              SettingsTile(title: 'Sign out', leading: Icon(Icons.exit_to_app)),
            ],
          ),
          SettingsSection(
            title: 'Security',
            tiles: [
              SettingsTile.switchTile(
                title: 'Lock app in background',
                leading: const Icon(Icons.phonelink_lock),
                switchValue: lockInBackground,
                onToggle: (bool value) {
                  setState(() {
                    lockInBackground = value;
                    notificationsEnabled = value;
                  });
                },
              ),
              SettingsTile.switchTile(
                  title: 'Use fingerprint',
                  subtitle:
                      'Allow application to access stored fingerprint IDs.',
                  leading: const Icon(Icons.fingerprint),
                  onToggle: (bool value) {},
                  switchValue: false),
              SettingsTile.switchTile(
                title: 'Change password',
                leading: const Icon(Icons.lock),
                switchValue: true,
                onToggle: (bool value) {},
              ),
              SettingsTile.switchTile(
                title: 'Enable Notifications',
                enabled: notificationsEnabled,
                leading: const Icon(Icons.notifications_active),
                switchValue: true,
                onToggle: (value) {},
              ),
            ],
          ),
          // SettingsSection(
          //   title: 'Misc',
          //   tiles: [
          //     SettingsTile(
          //         title: 'Terms of Service', leading: Icon(Icons.description)),
          //     SettingsTile(
          //         title: 'Open source licenses',
          //         leading: Icon(Icons.collections_bookmark)),
          //   ],
          // ),
          CustomSection(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 22, bottom: 8),
                  child: Image.asset(
                    '/images/settings.png',
                    height: 50,
                    width: 50,
                    color: const Color(0xFF777777),
                  ),
                ),
                const Text(
                  'Version: 1.0.5',
                  style: TextStyle(color: Color(0xFF777777)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
