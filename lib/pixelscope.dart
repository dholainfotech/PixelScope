// pixelscope.dart

import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:typed_data';

class Pixelscope {
  static const MethodChannel _channel = MethodChannel('pixelscope');
  static const EventChannel _frameChannel = EventChannel('pixelscope/frames');

  // Additional EventChannels
  static const EventChannel _batteryLevelChannel = EventChannel(
      'pixelscope/battery_level');
  static const EventChannel _firmwareVersionChannel = EventChannel(
      'pixelscope/firmware_version');

  // Existing methods...

  /// Initializes the SDK.
  static Future<String?> initSDK() async {
    try {
      final String? result = await _channel.invokeMethod('initSDK');
      return result;
    } catch (e) {
      return 'Failed to initialize SDK: $e';
    }
  }

  /// Starts the video feed.
  static Future<String?> startVideoFeed() async {
    try {
      final String? result = await _channel.invokeMethod('startVideoFeed');
      return result;
    } catch (e) {
      return 'Failed to start video feed: $e';
    }
  }

  /// Stops the video feed.
  static Future<String?> stopVideoFeed() async {
    try {
      final String? result = await _channel.invokeMethod('stopVideoFeed');
      return result;
    } catch (e) {
      return 'Failed to stop video feed: $e';
    }
  }

  /// Stream of video frames as byte arrays.
  static Stream<Uint8List> get frameStream =>
      _frameChannel.receiveBroadcastStream().map((event) => event as Uint8List);

  /// Initiates battery level retrieval.
  static Future<void> getBatteryLevel() async {
    try {
      await _channel.invokeMethod('getBatteryLevel');
    } catch (e) {
      print('Failed to get battery level: $e');
    }
  }

  /// Stream of battery levels.
  static Stream<int> get batteryLevelStream =>
      _batteryLevelChannel.receiveBroadcastStream().map((event) => event as int);

  /// Initiates firmware version retrieval.
  static Future<void> getFirmwareVersion() async {
    try {
      await _channel.invokeMethod('getFirmwareVersion');
    } catch (e) {
      print('Failed to get firmware version: $e');
    }
  }

  /// Stream of firmware versions.
  static Stream<String> get firmwareVersionStream =>
      _firmwareVersionChannel.receiveBroadcastStream().map((event) => event as String);


  /// Sets the brightness level.
  /// [brightness]: Brightness value (e.g., between 0.0 and 1.0).
  static Future<String?> setBrightness(double brightness) async {
    try {
      final String? result = await _channel.invokeMethod('setBrightness', {'brightness': brightness});
      return result;
    } catch (e) {
      return 'Failed to set brightness: $e';
    }
  }

  /// Captures a photo.
  /// [fileName]: Desired name for the snapshot file.
  /// [phoneOrSD]: Location to save (0 for Phone, 1 for SD Card).
  static Future<String?> snapPhoto({required String fileName, required int phoneOrSD}) async {
    try {
      final String? result = await _channel.invokeMethod('snapPhoto', {
        'fileName': fileName,
        'phoneOrSD': phoneOrSD,
      });
      return result;
    } on PlatformException catch (e) {
      return 'Failed to capture photo: ${e.message}';
    }
  }

  /// Starts video recording.
  /// [fileName]: Desired name for the video file.
  /// [phoneOrSD]: Location to save (0 for Phone, 1 for SD Card).
  static Future<String?> startRecord({required String fileName, required int phoneOrSD}) async {
    try {
      final String? result = await _channel.invokeMethod('startRecord', {
        'fileName': fileName,
        'phoneOrSD': phoneOrSD,
      });
      return result;
    } on PlatformException catch (e) {
      return 'Failed to start recording: ${e.message}';
    }
  }

  /// Stops video recording.
  /// [phoneOrSD]: Location where the recording was saved (0 for Phone, 1 for SD Card).
  static Future<String?> stopRecord({required int phoneOrSD}) async {
    try {
      final String? result = await _channel.invokeMethod('stopRecord', {
        'phoneOrSD': phoneOrSD,
      });
      return result;
    } on PlatformException catch (e) {
      return 'Failed to stop recording: ${e.message}';
    }
  }

  
  /// Sets the video resolution.
  /// [width]: Desired video width in pixels.
  /// [height]: Desired video height in pixels.
  static Future<String?> setResolution({required int width, required int height}) async {
    try {
      final String? result = await _channel.invokeMethod('setResolution', {
        'width': width,
        'height': height,
      });
      return result;
    } catch (e) {
      return 'Failed to set resolution: $e';
    }
  }

  /// Sets the contrast level.
  /// [contrast]: Contrast value between 0.0 and 1.0.
  static Future<String?> setContrast(double contrast) async {
    try {
      final String? result = await _channel.invokeMethod('setContrast', {'contrast': contrast});
      return result;
    } on PlatformException catch (e) {
      return 'Failed to set contrast: ${e.message}';
    }
  }

  /// Sets the saturation level.
  /// [saturation]: Saturation value between 0.0 and 1.0.
  static Future<String?> setSaturation(double saturation) async {
    try {
      final String? result = await _channel.invokeMethod('setSaturation', {'saturation': saturation});
      return result;
    } on PlatformException catch (e) {
      return 'Failed to set saturation: ${e.message}';
    }
  }

  /// Sets the zoom level.
  /// [zoom]: Zoom level as an integer value.
  static Future<String?> setZoom(int zoom) async {
    try {
      final String? result = await _channel.invokeMethod('setZoom', {'zoom': zoom});
      return result;
    } on PlatformException catch (e) {
      return 'Failed to set zoom: ${e.message}';
    }
  }

  /// Sets whether the video feed is mirrored.
  /// [mirror]: `true` to mirror the video feed, `false` to display normally.
  static Future<String?> setMirror(bool mirror) async {
    try {
      final String? result = await _channel.invokeMethod('setMirror', {'mirror': mirror});
      return result;
    } on PlatformException catch (e) {
      return 'Failed to set mirror: ${e.message}';
    }
  }

  /// Rotates the video feed.
  /// [rotation]: Rotation angle in degrees (0, 90, 180, 270).
  static Future<String?> setRotation(int rotation) async {
    try {
      final String? result = await _channel.invokeMethod('setRotation', {'rotation': rotation});
      return result;
    } on PlatformException catch (e) {
      return 'Failed to set rotation: ${e.message}';
    }
  }

  /// Initiates the retrieval of the current Wi-Fi SSID.
  /// Listen to [wifiSSIDStream] to receive the SSID.
  static Future<void> getWifiSSID() async {
    try {
      await _channel.invokeMethod('getWifiSSID');
    } on PlatformException catch (e) {
      print('Failed to get Wi-Fi SSID: ${e.message}');
    }
  }

  /// Stream of Wi-Fi SSID strings received from the device.
  static const EventChannel _wifiSSIDChannel = EventChannel('pixelscope/wifi_ssid');

  static Stream<String> get wifiSSIDStream =>
      _wifiSSIDChannel.receiveBroadcastStream().map((event) => event as String);


  /// Sets the Wi-Fi SSID.
  /// [ssid]: The new SSID to set.
  static Future<String?> setWifiSSID({required String ssid}) async {
    try {
      final String? result = await _channel.invokeMethod('setWifiSSID', {'ssid': ssid});
      return result;
    } on PlatformException catch (e) {
      return 'Failed to set Wi-Fi SSID: ${e.message}';
    }
  }

  /// Sets the Wi-Fi password.
  /// [password]: The new Wi-Fi password to set.
  static Future<String?> setWifiPassword({required String password}) async {
    try {
      final String? result = await _channel.invokeMethod('setWifiPassword', {'password': password});
      return result;
    } on PlatformException catch (e) {
      return 'Failed to set Wi-Fi password: ${e.message}';
    }
  }

  /// Checks if the connected device is a JoyCamera.
  /// Returns `true` if it is, `false` otherwise.
  static Future<bool?> isJoyCamera() async {
    try {
      final bool? isJoyCam = await _channel.invokeMethod('isJoyCamera');
      return isJoyCam;
    } on PlatformException catch (e) {
      print('Failed to check if device is JoyCamera: ${e.message}');
      return null;
    }
  }

  /// Checks if the connected device is the intended microscope device.
  /// Returns `true` if it is, `false` otherwise.
  static Future<bool?> checkDevice() async {
    try {
      final bool? isDeviceVerified = await _channel.invokeMethod('checkDevice');
      return isDeviceVerified;
    } on PlatformException catch (e) {
      print('Failed to verify device: ${e.message}');
      return null;
    }
  }

  /// Retrieves the device category.
  ///
  /// Returns a String description of the device category.
  static Future<String?> getDeviceCategory() async {
    try {
      final String? result = await _channel.invokeMethod('getDeviceCategory');
      return result;
    } on PlatformException catch (e) {
      return 'Failed to get device category: ${e.message}';
    }
  }

  /// Retrieves the current device status.
  ///
  /// Returns a String description of the device status.
  static Future<String?> getStatus() async {
    try {
      final String? result = await _channel.invokeMethod('getStatus');
      return result;
    } on PlatformException catch (e) {
      return 'Failed to get device status: ${e.message}';
    }
  }




}
