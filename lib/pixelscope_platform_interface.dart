import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'pixelscope_method_channel.dart';

abstract class PixelscopePlatform extends PlatformInterface {
  /// Constructs a PixelscopePlatform.
  PixelscopePlatform() : super(token: _token);

  static final Object _token = Object();

  static PixelscopePlatform _instance = MethodChannelPixelscope();

  /// The default instance of [PixelscopePlatform] to use.
  ///
  /// Defaults to [MethodChannelPixelscope].
  static PixelscopePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PixelscopePlatform] when
  /// they register themselves.
  static set instance(PixelscopePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
