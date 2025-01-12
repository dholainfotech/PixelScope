import 'package:flutter/material.dart';
import 'package:pixelscope/pixelscope.dart';

class DeviceInfoScreen extends StatefulWidget {
  @override
  _DeviceInfoScreenState createState() => _DeviceInfoScreenState();
}

class _DeviceInfoScreenState extends State<DeviceInfoScreen> {
  String _deviceStatus = '';
  bool _isLoading = true;

  Future<void> _getDeviceStatus() async {
    String? result = await Pixelscope.getStatus();
    setState(() {
      _deviceStatus = result ?? 'Unable to get device status';
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _getDeviceStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Device Information'),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Device Status:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    _deviceStatus,
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }
}