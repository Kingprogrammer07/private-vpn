import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import '../models/server_config.dart';
import '../models/vpn_state.dart';

class VpnService {
  FlutterV2ray? _v2ray;
  final StreamController<VpnStatusInfo> _statusController =
      StreamController<VpnStatusInfo>.broadcast();

  VpnStatusInfo _currentStatus = const VpnStatusInfo();
  Timer? _mockTimer;
  DateTime? _connectedAt;

  Stream<VpnStatusInfo> get statusStream => _statusController.stream;
  VpnStatusInfo get currentStatus => _currentStatus;

  Future<void> initialize() async {
    if (kIsWeb) return;

    if (Platform.isAndroid) {
      try {
        _v2ray = FlutterV2ray(
          onStatusChanged: (status) {
            _handleV2RayStatus(status);
          },
        );
        await _v2ray!.initializeV2Ray();
      } catch (e) {
        debugPrint('V2Ray initialization error: $e');
      }
    }
  }

  void _handleV2RayStatus(V2RayStatus status) {
    VpnConnectionState state;
    switch (status.state.toUpperCase()) {
      case 'CONNECTED':
        state = VpnConnectionState.connected;
        _connectedAt ??= DateTime.now();
        break;
      case 'CONNECTING':
        state = VpnConnectionState.connecting;
        break;
      case 'DISCONNECTING':
        state = VpnConnectionState.disconnecting;
        break;
      case 'DISCONNECTED':
      default:
        state = VpnConnectionState.disconnected;
        _connectedAt = null;
        break;
    }

    Duration duration = Duration.zero;
    if (_connectedAt != null && state == VpnConnectionState.connected) {
      duration = DateTime.now().difference(_connectedAt!);
    }

    _currentStatus = _currentStatus.copyWith(
      state: state,
      uploadSpeedBytes: status.uploadSpeed,
      downloadSpeedBytes: status.downloadSpeed,
      totalUploadBytes: status.upload,
      totalDownloadBytes: status.download,
      connectedDuration: duration,
    );
    _statusController.add(_currentStatus);
  }

  Future<bool> connect(ServerConfig server) async {
    _updateState(VpnConnectionState.connecting);

    if (Platform.isAndroid) {
      if (_v2ray == null) {
        await initialize();
      }
      if (_v2ray != null) {
        try {
          final hasPermission = await _v2ray!.requestPermission();
          debugPrint('VpnService hasPermission: $hasPermission');
          if (!hasPermission) {
            _updateState(VpnConnectionState.disconnected);
            return false;
          }

          final rawUrl = server.toVlessUrl();
          debugPrint('Connecting to VLESS: $rawUrl');
          final v2rayUrl = FlutterV2ray.parseFromURL(rawUrl);
          var fullConfig = v2rayUrl.getFullConfiguration();
          try {
            final Map<String, dynamic> configMap = jsonDecode(fullConfig);
            for (var outbound in configMap['outbounds'] ?? []) {
              if (outbound is Map && outbound['streamSettings'] != null) {
                var reality = outbound['streamSettings']['realitySettings'];
                if (reality != null && reality is Map) {
                  if (reality['password'] != null && reality['publicKey'] == null) {
                    reality['publicKey'] = reality['password'];
                  }
                }
              }
            }
            fullConfig = jsonEncode(configMap);
          } catch (e) {
            debugPrint('Config transform error: $e');
          }

          await _v2ray!.startV2Ray(
            remark: server.name,
            config: fullConfig,
            proxyOnly: false,
          );
          return true;
        } catch (e, stack) {
          debugPrint('Connect error: $e');
          debugPrint('Connect stack: $stack');
          _updateState(VpnConnectionState.error);
          return false;
        }
      }
      return false;
    } else {
      // Simulation / Test mode (for Windows desktop preview and iOS development)
      debugPrint('Running VPN in simulation mode on ${Platform.operatingSystem}');
      await Future.delayed(const Duration(milliseconds: 1200));
      _connectedAt = DateTime.now();
      _updateState(VpnConnectionState.connected);
      _startMockTraffic();
      return true;
    }
  }

  Future<void> disconnect() async {
    _updateState(VpnConnectionState.disconnecting);
    _mockTimer?.cancel();
    _mockTimer = null;

    if (Platform.isAndroid && _v2ray != null) {
      try {
        await _v2ray!.stopV2Ray();
      } catch (e) {
        debugPrint('Disconnect error: $e');
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 500));
    }

    _connectedAt = null;
    _updateState(VpnConnectionState.disconnected);
  }

  Future<int> measurePing(ServerConfig server) async {
    if (Platform.isAndroid && _v2ray != null) {
      try {
        final v2rayUrl = FlutterV2ray.parseFromURL(server.toVlessUrl());
        final fullConfig = v2rayUrl.getFullConfiguration();
        final delay = await _v2ray!.getServerDelay(config: fullConfig);
        return delay;
      } catch (e) {
        return -1;
      }
    } else {
      // Mock ping around 48-62ms for Hetzner Germany
      await Future.delayed(const Duration(milliseconds: 300));
      return 48 + (DateTime.now().millisecond % 15);
    }
  }

  void _updateState(VpnConnectionState state) {
    _currentStatus = _currentStatus.copyWith(
      state: state,
      uploadSpeedBytes: state == VpnConnectionState.connected ? _currentStatus.uploadSpeedBytes : 0,
      downloadSpeedBytes: state == VpnConnectionState.connected ? _currentStatus.downloadSpeedBytes : 0,
      connectedDuration: state == VpnConnectionState.connected ? _currentStatus.connectedDuration : Duration.zero,
    );
    _statusController.add(_currentStatus);
  }

  void _startMockTraffic() {
    _mockTimer?.cancel();
    _mockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentStatus.state != VpnConnectionState.connected) {
        timer.cancel();
        return;
      }

      final duration = _connectedAt != null
          ? DateTime.now().difference(_connectedAt!)
          : Duration.zero;

      // Realistic speed variations: 1.2 MB/s to 4.5 MB/s
      final sec = DateTime.now().second;
      final downSpeed = 1250000 + (sec * 50000) % 2500000;
      final upSpeed = 240000 + (sec * 20000) % 600000;

      _currentStatus = _currentStatus.copyWith(
        connectedDuration: duration,
        downloadSpeedBytes: downSpeed,
        uploadSpeedBytes: upSpeed,
        totalDownloadBytes: _currentStatus.totalDownloadBytes + downSpeed,
        totalUploadBytes: _currentStatus.totalUploadBytes + upSpeed,
        pingMs: 48 + (sec % 12),
      );
      _statusController.add(_currentStatus);
    });
  }

  void dispose() {
    _mockTimer?.cancel();
    _statusController.close();
  }
}
