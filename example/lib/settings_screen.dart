// settings_screen.dart

import 'package:flutter/material.dart';
import 'package:pixelscope/pixelscope.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _wifiSSID = '';
  String _wifiPassword = '';
  String _deviceInfo = '';
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _listenToWifiSSID();
    _fetchWifiSSID();
  }

  void _listenToWifiSSID() {
    Pixelscope.wifiSSIDStream.listen((ssid) {
      setState(() {
        _wifiSSID = ssid;
      });
    });
  }

  Future<void> _fetchWifiSSID() async {
    await Pixelscope.getWifiSSID();
  }

  Future<void> _setWifiSSID() async {
    String? result = await Pixelscope.setWifiSSID(ssid: _wifiSSID);
    setState(() {
      _statusMessage = result ?? 'Failed to set Wi-Fi SSID';
    });
  }

  Future<void> _setWifiPassword() async {
    String? result = await Pixelscope.setWifiPassword(password: _wifiPassword);
    setState(() {
      _statusMessage = result ?? 'Failed to set Wi-Fi password';
    });
  }

  Future<void> _getBatteryLevel() async {
    Pixelscope.batteryLevelStream.listen((level) {
      setState(() {
        _statusMessage = 'Battery Level: $level%';
      });
    });
    await Pixelscope.getBatteryLevel();
  }

  Future<void> _getFirmwareVersion() async {
    Pixelscope.firmwareVersionStream.listen((version) {
      setState(() {
        _statusMessage = 'Firmware Version: $version';
      });
    });
    await Pixelscope.getFirmwareVersion();
  }

  Future<void> _getDeviceCategory() async {
    String? result = await Pixelscope.getDeviceCategory();
    setState(() {
      _statusMessage = 'Device Category: ${result ?? 'Unknown'}';
    });
  }

  Future<void> _checkDevice() async {
    bool? isVerified = await Pixelscope.checkDevice();
    setState(() {
      _statusMessage = isVerified == true ? 'Device is verified' : 'Device check failed';
    });
  }

  Future<void> _isJoyCamera() async {
    bool? isJoyCam = await Pixelscope.isJoyCamera();
    setState(() {
      _statusMessage = isJoyCam == true ? 'Device is JoyCamera' : 'Device is not JoyCamera';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings and Device Info'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Wi-Fi Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              decoration: InputDecoration(labelText: 'Wi-Fi SSID'),
              controller: TextEditingController(text: _wifiSSID),
              onChanged: (value) {
                _wifiSSID = value;
              },
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Wi-Fi Password'),
              obscureText: true,
              onChanged: (value) {
                _wifiPassword = value;
              },
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _setWifiSSID,
                  child: Text('Set Wi-Fi SSID'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _setWifiPassword,
                  child: Text('Set Wi-Fi Password'),
                ),
              ],
            ),
            Divider(),
            Text('Device Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ElevatedButton(
              onPressed: _getBatteryLevel,
              child: Text('Get Battery Level'),
            ),
            ElevatedButton(
              onPressed: _getFirmwareVersion,
              child: Text('Get Firmware Version'),
            ),
            ElevatedButton(
              onPressed: _getDeviceCategory,
              child: Text('Get Device Category'),
            ),
            ElevatedButton(
              onPressed: _checkDevice,
              child: Text('Check Device'),
            ),
            ElevatedButton(
              onPressed: _isJoyCamera,
              child: Text('Is JoyCamera'),
            ),
            SizedBox(height: 20),
            Text(
              _statusMessage,
              style: TextStyle(fontSize: 16, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
