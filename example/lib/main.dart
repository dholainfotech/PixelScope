// main.dart

import 'package:flutter/material.dart';
import 'package:pixelscope_example/home_screen.dart';
import 'package:pixelscope_example/settings_screen.dart';

import 'device_info_screen.dart';

void main() {
  runApp(PixelscopeApp());
}

class PixelscopeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pixelscope Example App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
      routes: {
        '/settings': (_) => SettingsScreen(),
        '/deviceInfo': (_) => DeviceInfoScreen(),
      },
    );
  }
}
