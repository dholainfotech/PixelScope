// home_screen.dart

import 'package:flutter/material.dart';
import 'package:pixelscope/pixelscope.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSDKInitialized = false;
  bool _isVideoFeedStarted = false;
  bool _isRecording = false;
  Stream<Uint8List>? _frameStream;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeSDK();
  }

  Future<void> _initializeSDK() async {
    String? result = await Pixelscope.initSDK();
    setState(() {
      _isSDKInitialized = result != null && result.contains('SDK Initialized');
      _statusMessage = result ?? 'Failed to initialize SDK';
    });
  }

  Future<void> _startVideoFeed() async {
    if (!_isSDKInitialized) {
      await _initializeSDK();
    }
    String? result = await Pixelscope.startVideoFeed();
    if (result != null && result.contains('Video Feed Started')) {
      setState(() {
        _isVideoFeedStarted = true;
        _frameStream = Pixelscope.frameStream;
        _statusMessage = 'Video Feed Started';
      });
    } else {
      setState(() {
        _statusMessage = result ?? 'Failed to start video feed';
      });
    }
  }

// ...existing code...

  Future<void> _stopVideoFeed() async {
    if (!_isVideoFeedStarted) {
      setState(() {
        _statusMessage = 'Video feed is not started';
      });
      return;
    }
    String? result = await Pixelscope.stopVideoFeed();
    if (result != null && result.contains('Video Feed Stopped')) {
      setState(() {
        _isVideoFeedStarted = false;
        _frameStream = null;
        _statusMessage = 'Video Feed Stopped';
      });
      // Re-initialize SDK to ensure a fresh state
      await _initializeSDK();
    } else {
      setState(() {
        _statusMessage = result ?? 'Failed to stop video feed';
      });
    }
  }

// ...existing code...

  Future<void> _capturePhoto() async {
    if (!_isVideoFeedStarted) {
      setState(() {
        _statusMessage = 'Video feed is not started';
      });
      return;
    }

    // Get the external storage directory
    Directory? directory = await getExternalStorageDirectory();
    if (directory == null) {
      setState(() {
        _statusMessage = 'Unable to access storage';
      });
      return;
    }

    String dirPath = '${directory.path}/Pixelscope';
    await Directory(dirPath).create(recursive: true);
    String fileName = 'IMG_${DateTime.now().millisecondsSinceEpoch}.jpg';
    int saveLocation = 0; // 0 for Phone

    String? result = await Pixelscope.snapPhoto(
      fileName: '$dirPath/$fileName',
      phoneOrSD: saveLocation,
    );
    setState(() {
      _statusMessage = result ?? 'Photo capture failed';
    });
  }

  Future<void> _startRecording() async {
    if (!_isVideoFeedStarted) {
      setState(() {
        _statusMessage = 'Video feed is not started';
      });
      return;
    }

    // Get the external storage directory
    Directory? directory = await getExternalStorageDirectory();
    if (directory == null) {
      setState(() {
        _statusMessage = 'Unable to access storage';
      });
      return;
    }

    String dirPath = '${directory.path}/Pixelscope';
    await Directory(dirPath).create(recursive: true);
    String fileName = 'VID_${DateTime.now().millisecondsSinceEpoch}.mp4';
    int saveLocation = 0; // 0 for Phone

    String? result = await Pixelscope.startRecord(
      fileName: '$dirPath/$fileName',
      phoneOrSD: saveLocation,
    );

    if (result != null && result.contains('Recording started')) {
      setState(() {
        _isRecording = true;
        _statusMessage = 'Recording started';
      });
    } else {
      setState(() {
        _statusMessage = result ?? 'Failed to start recording';
      });
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) {
      setState(() {
        _statusMessage = 'Recording is not in progress';
      });
      return;
    }

    int saveLocation = 0; // Should match the location used to start recording

    String? result = await Pixelscope.stopRecord(phoneOrSD: saveLocation);

    if (result != null && result.contains('Recording stopped')) {
      setState(() {
        _isRecording = false;
        _statusMessage = 'Recording stopped';
      });
    } else {
      setState(() {
        _statusMessage = result ?? 'Failed to stop recording';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final videoFeed = _isVideoFeedStarted && _frameStream != null
        ? StreamBuilder<Uint8List>(
      stream: _frameStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            gaplessPlayback: true,
            fit: BoxFit.contain,
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error receiving frames'));
        } else {
          return Center(child: Text('Waiting for frames...'));
        }
      },
    )
        : Container(
      color: Colors.black,
      child: Center(
        child: Text(
          'Video feed not started',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Pixelscope'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: videoFeed,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _statusMessage,
              style: TextStyle(fontSize: 16, color: Colors.blue),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8.0,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isVideoFeedStarted ? _stopVideoFeed : _startVideoFeed,
                  child: Text(_isVideoFeedStarted ? 'Stop Video Feed' : 'Start Video Feed'),
                ),
                ElevatedButton(
                  onPressed: _isVideoFeedStarted ? _capturePhoto : null,
                  child: Text('Capture Photo'),
                ),
                ElevatedButton(
                  onPressed: _isVideoFeedStarted
                      ? (_isRecording ? _stopRecording : _startRecording)
                      : null,
                  child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/deviceInfo');
                  },
                  child: Text('Device Info'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
