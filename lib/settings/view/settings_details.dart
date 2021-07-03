import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_dashboard/position/controller/position_controller.dart';

import '../../constant.dart';

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
}
