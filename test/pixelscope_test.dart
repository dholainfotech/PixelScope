import 'package:flutter_test/flutter_test.dart';
import 'package:pixelscope/pixelscope.dart';
import 'package:pixelscope/pixelscope_platform_interface.dart';
import 'package:pixelscope/pixelscope_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPixelscopePlatform
    with MockPlatformInterfaceMixin
    implements PixelscopePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final PixelscopePlatform initialPlatform = PixelscopePlatform.instance;

  test('$MethodChannelPixelscope is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPixelscope>());
  });

  test('getPlatformVersion', () async {
    Pixelscope pixelscopePlugin = Pixelscope();
    MockPixelscopePlatform fakePlatform = MockPixelscopePlatform();
    PixelscopePlatform.instance = fakePlatform;

    expect(await pixelscopePlugin.getPlatformVersion(), '42');
  });
}
