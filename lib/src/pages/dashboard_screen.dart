import 'package:flutter/material.dart';
import 'package:web_dashboard/settings/view/settings_details.dart';
import 'package:web_dashboard/wallet/view/my_files.dart';

import '../../constant.dart';
import '../../position/view/storage_details.dart';
import '../../transaction/view/recent_files.dart';
import '../responsive.dart';
import '../widgets/dashboard/header.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            const Header(),
            const SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      const MyFiles(),
                      const SizedBox(height: defaultPadding),
                      const RecentFiles(),
                      if (Responsive.isMobile(context))
                        const SizedBox(height: defaultPadding),
                      if (Responsive.isMobile(context)) const StorageDetails(),
                      const SizedBox(height: defaultPadding),
                      if (Responsive.isMobile(context)) const SettingsDetails(),
                    ],
                  ),
                ),
                if (!Responsive.isMobile(context))
                  const SizedBox(width: defaultPadding),
                // On Mobile means if the screen is less than 850 we dont want to show it
                if (!Responsive.isMobile(context))
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: const [
                        StorageDetails(),
                        SizedBox(height: defaultPadding),
                        SettingsDetails(),
                      ],
                    ),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
