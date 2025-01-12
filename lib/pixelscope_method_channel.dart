import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'pixelscope_platform_interface.dart';

/// An implementation of [PixelscopePlatform] that uses method channels.
class MethodChannelPixelscope extends PixelscopePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('pixelscope');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
