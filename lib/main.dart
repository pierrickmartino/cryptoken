import 'package:flutter/material.dart';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'src/app.dart';

const darkModeBox = 'darkMode';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox(darkModeBox);
  runApp(DashboardApp.mock());
  //runApp(DashboardApp.firebase());
}
