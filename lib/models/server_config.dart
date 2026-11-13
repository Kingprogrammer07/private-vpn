class ServerConfig {
  final String id;
  final String name;
  final String address;
  final int port;
  final String uuid;
  final String flow;
  final String security; // reality, tls, none
  final String network;  // tcp, ws, grpc
  final String sni;
  final String pbk;      // public key for reality
  final String sid;      // short id
  final String fp;       // fingerprint (chrome, firefox, etc.)
  final String countryCode;
  final String rawUrl;
  int pingMs;

  ServerConfig({
    required this.id,
    required this.name,
    required this.address,
    required this.port,
    required this.uuid,
    this.flow = 'xtls-rprx-vision',
    this.security = 'reality',
    this.network = 'tcp',
    required this.sni,
    required this.pbk,
    this.sid = '',
    this.fp = 'chrome',
    this.countryCode = 'DE',
    this.rawUrl = '',
    this.pingMs = -1,
  });

  /// Parse from standard vless:// URI
  factory ServerConfig.fromVlessUrl(String url) {
    final cleanUrl = url.trim();
    if (!cleanUrl.startsWith('vless://')) {
      throw FormatException('Faqat vless:// protokoli qo\'llab-quvvatlanadi');
    }

    // Split remark (after #)
    final hashIndex = cleanUrl.indexOf('#');
    String remark = 'Hetzner Server';
    String mainPart = cleanUrl;
    if (hashIndex != -1) {
      remark = Uri.decodeComponent(cleanUrl.substring(hashIndex + 1));
      mainPart = cleanUrl.substring(0, hashIndex);
    }

    final withoutScheme = mainPart.replaceFirst('vless://', '');
    final atIndex = withoutScheme.indexOf('@');
    if (atIndex == -1) {
      throw const FormatException('Noto\'g\'ri VLESS formati: UUID topilmadi');
    }

    final uuid = withoutScheme.substring(0, atIndex);
    final rest = withoutScheme.substring(atIndex + 1);

    final questionIndex = rest.indexOf('?');
    String hostPort = rest;
    Map<String, String> queryParams = {};

    if (questionIndex != -1) {
      hostPort = rest.substring(0, questionIndex);
      final queryString = rest.substring(questionIndex + 1);
      final uri = Uri.parse('http://dummy/?$queryString');
      queryParams = uri.queryParameters;
    }

    final hostParts = hostPort.split(':');
    final host = hostParts[0];
    final port = hostParts.length > 1 ? int.tryParse(hostParts[1]) ?? 443 : 443;

    // Detect country by remark or address
    String country = 'DE';
    final lowerRemark = remark.toLowerCase();
    if (lowerRemark.contains('us') || lowerRemark.contains('usa') || lowerRemark.contains('america')) {
      country = 'US';
    } else if (lowerRemark.contains('nl') || lowerRemark.contains('netherlands')) {
      country = 'NL';
    } else if (lowerRemark.contains('fi') || lowerRemark.contains('finland')) {
      country = 'FI';
    } else if (lowerRemark.contains('uz') || lowerRemark.contains('uzb')) {
      country = 'UZ';
    }

    return ServerConfig(
      id: '${host}_$port',
      name: remark.isNotEmpty ? remark : 'Hetzner VLESS Reality',
      address: host,
      port: port,
      uuid: uuid,
      flow: queryParams['flow'] ?? 'xtls-rprx-vision',
      security: queryParams['security'] ?? 'reality',
      network: queryParams['type'] ?? 'tcp',
      sni: queryParams['sni'] ?? '',
      pbk: queryParams['pbk'] ?? '',
      sid: queryParams['sid'] ?? '',
      fp: queryParams['fp'] ?? 'chrome',
      countryCode: country,
      rawUrl: cleanUrl,
    );
  }

  /// Convert to vless:// URI
  String toVlessUrl() {
    if (rawUrl.isNotEmpty) return rawUrl;
    final params = <String, String>{
      'type': network,
      'security': security,
      if (flow.isNotEmpty) 'flow': flow,
      if (sni.isNotEmpty) 'sni': sni,
      if (pbk.isNotEmpty) 'pbk': pbk,
      if (sid.isNotEmpty) 'sid': sid,
      if (fp.isNotEmpty) 'fp': fp,
    };

    final query = params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
    final remarkEncoded = Uri.encodeComponent(name);
    return 'vless://$uuid@$address:$port?$query#$remarkEncoded';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'port': port,
      'uuid': uuid,
      'flow': flow,
      'security': security,
      'network': network,
      'sni': sni,
      'pbk': pbk,
      'sid': sid,
      'fp': fp,
      'countryCode': countryCode,
      'rawUrl': rawUrl,
      'pingMs': pingMs,
    };
  }

  factory ServerConfig.fromJson(Map<String, dynamic> json) {
    return ServerConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      port: json['port'] as int,
      uuid: json['uuid'] as String,
      flow: json['flow'] as String? ?? 'xtls-rprx-vision',
      security: json['security'] as String? ?? 'reality',
      network: json['network'] as String? ?? 'tcp',
      sni: json['sni'] as String? ?? '',
      pbk: json['pbk'] as String? ?? '',
      sid: json['sid'] as String? ?? '',
      fp: json['fp'] as String? ?? 'chrome',
      countryCode: json['countryCode'] as String? ?? 'DE',
      rawUrl: json['rawUrl'] as String? ?? '',
      pingMs: json['pingMs'] as int? ?? -1,
    );
  }

  String get countryFlag {
    switch (countryCode.toUpperCase()) {
      case 'DE':
        return '🇩🇪';
      case 'NL':
        return '🇳🇱';
      case 'FI':
        return '🇫🇮';
      case 'US':
        return '🇺🇸';
      case 'GB':
      case 'UK':
        return '🇬🇧';
      case 'UZ':
        return '🇺🇿';
      default:
        return '🌐';
    }
  }

  /// Default Leda Private Server template with actual server keys
  static ServerConfig defaultHetzner() {
    return ServerConfig(
      id: 'leda_private_1',
      name: '🇩🇪 Leda Private Server',
      address: '178.238.228.77',
      port: 8443,
      uuid: 'b831381d-6324-4d53-ad4f-8cda48b30811',
      flow: 'xtls-rprx-vision',
      security: 'reality',
      network: 'tcp',
      sni: 'gateway.icloud.com',
      pbk: 'GthdijmSN9UGJpQpr4ofgb6OrZxqWyWPYHINBakbRxo',
      sid: '16a8',
      fp: 'chrome',
      countryCode: 'DE',
      pingMs: 48,
    );
  }
}
