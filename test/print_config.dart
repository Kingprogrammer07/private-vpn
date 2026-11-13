import 'package:flutter_v2ray/flutter_v2ray.dart';

void main() {
  final url = 'vless://00000000-0000-0000-0000-000000000000@203.0.113.195:8443?type=tcp&security=reality&flow=xtls-rprx-vision&sni=gateway.icloud.com&pbk=1111111111111111111111111111111111111111111&sid=16a8&fp=chrome#Demo';
  final parsed = FlutterV2ray.parseFromURL(url);
  print(parsed.getFullConfiguration());
}
