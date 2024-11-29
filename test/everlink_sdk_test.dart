import 'package:flutter_test/flutter_test.dart';
import 'package:everlink_sdk/everlink_sdk.dart';
import 'package:everlink_sdk/everlink_sdk_platform_interface.dart';
import 'package:everlink_sdk/everlink_sdk_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockEverlinkSdkPlatform
    with MockPlatformInterfaceMixin
    implements EverlinkSdkPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final EverlinkSdkPlatform initialPlatform = EverlinkSdkPlatform.instance;

  test('$MethodChannelEverlinkSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelEverlinkSdk>());
  });

  test('getPlatformVersion', () async {
    EverlinkSdk everlinkSdkPlugin = EverlinkSdk();
    MockEverlinkSdkPlatform fakePlatform = MockEverlinkSdkPlatform();
    EverlinkSdkPlatform.instance = fakePlatform;

    expect(await everlinkSdkPlugin.getPlatformVersion(), '42');
  });
}
