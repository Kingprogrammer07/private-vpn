import 'package:flutter_test/flutter_test.dart';
import 'package:antigravity_vpn/models/server_config.dart';
import 'package:antigravity_vpn/models/vpn_state.dart';

void main() {
  group('ServerConfig Tests', () {
    test('Correctly parses standard VLESS Reality URL', () {
      const vlessUrl =
          'vless://a1b2c3d4-e5f6-7890-abcd-ef1234567890@198.51.100.25:443?type=tcp&security=reality&flow=xtls-rprx-vision&sni=www.yahoo.com&pbk=Y7v1zM6nC1wV_m8s2x_P7p0_q5k3L9y8Z1x0A2B3C4D&sid=16a8&fp=chrome#%F0%9F%87%A9%F0%9F%87%AA%20Hetzner%20Frankfurt';

      final config = ServerConfig.fromVlessUrl(vlessUrl);

      expect(config.address, equals('198.51.100.25'));
      expect(config.port, equals(443));
      expect(config.uuid, equals('a1b2c3d4-e5f6-7890-abcd-ef1234567890'));
      expect(config.security, equals('reality'));
      expect(config.network, equals('tcp'));
      expect(config.flow, equals('xtls-rprx-vision'));
      expect(config.sni, equals('www.yahoo.com'));
      expect(config.pbk, equals('Y7v1zM6nC1wV_m8s2x_P7p0_q5k3L9y8Z1x0A2B3C4D'));
      expect(config.sid, equals('16a8'));
      expect(config.countryCode, equals('DE'));
      expect(config.countryFlag, equals('🇩🇪'));
    });

    test('Json serialization and deserialization works seamlessly', () {
      final defaultServer = ServerConfig.defaultHetzner();
      final json = defaultServer.toJson();
      final restored = ServerConfig.fromJson(json);

      expect(restored.address, equals(defaultServer.address));
      expect(restored.port, equals(defaultServer.port));
      expect(restored.uuid, equals(defaultServer.uuid));
      expect(restored.sni, equals(defaultServer.sni));
      expect(restored.security, equals('reality'));
    });
  });

  group('VpnStatusInfo Tests', () {
    test('Format speed correctly', () {
      expect(VpnStatusInfo.formatSpeed(500), equals('500 B/s'));
      expect(VpnStatusInfo.formatSpeed(1024 * 50), equals('50.0 KB/s'));
      expect(VpnStatusInfo.formatSpeed(1024 * 1024 * 3), equals('3.00 MB/s'));
    });

    test('Format total bytes correctly', () {
      expect(VpnStatusInfo.formatBytes(500), equals('500 B'));
      expect(VpnStatusInfo.formatBytes(1024 * 800), equals('800.0 KB'));
      expect(VpnStatusInfo.formatBytes(1024 * 1024 * 150), equals('150.0 MB'));
      expect(VpnStatusInfo.formatBytes(1024 * 1024 * 1024 * 2), equals('2.00 GB'));
    });

    test('Format duration correctly', () {
      expect(
          VpnStatusInfo.formatDuration(const Duration(seconds: 45)), equals('00:45'));
      expect(
          VpnStatusInfo.formatDuration(const Duration(minutes: 5, seconds: 20)),
          equals('05:20'));
      expect(
          VpnStatusInfo.formatDuration(
              const Duration(hours: 1, minutes: 12, seconds: 34)),
          equals('01:12:34'));
    });
  });
}
