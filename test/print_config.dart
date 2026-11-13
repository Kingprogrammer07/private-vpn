import 'package:flutter_v2ray/flutter_v2ray.dart';

void main() {
  final url = 'vless://b831381d-6324-4d53-ad4f-8cda48b30811@178.238.228.77:8443?type=tcp&security=reality&flow=xtls-rprx-vision&sni=www.yahoo.com&pbk=GthdijmSN9UGJpQpr4ofgb6OrZxqWyWPYHINBakbRxo&sid=16a8&fp=chrome#Leda';
  final parsed = FlutterV2ray.parseFromURL(url);
  print(parsed.getFullConfiguration());
}
