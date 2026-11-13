import 'package:flutter_test/flutter_test.dart';
import 'package:antigravity_vpn/models/server_config.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';

void main() {
  test('Test FlutterV2ray.parseFromURL with VLESS Reality', () {
    final server = ServerConfig.defaultHetzner();
    final vlessUrl = server.toVlessUrl();
    print('VLESS URL: $vlessUrl');

    try {
      final v2rayUrl = FlutterV2ray.parseFromURL(vlessUrl);
      print('Parsed V2RayURL type: ${v2rayUrl.runtimeType}');
      final config = v2rayUrl.getFullConfiguration();
      print('Config JSON:\n$config');
      expect(config, isNotEmpty);
    } catch (e, stack) {
      print('Error parsing: $e');
      print(stack);
      rethrow;
    }
  });
}
