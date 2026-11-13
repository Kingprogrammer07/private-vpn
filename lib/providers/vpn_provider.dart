import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/server_config.dart';
import '../models/vpn_state.dart';
import '../services/vpn_service.dart';

class VpnProvider extends ChangeNotifier {
  final VpnService _vpnService = VpnService();
  VpnStatusInfo _status = const VpnStatusInfo();
  StreamSubscription<VpnStatusInfo>? _subscription;

  VpnStatusInfo get status => _status;
  VpnConnectionState get connectionState => _status.state;
  bool get isConnected => _status.state == VpnConnectionState.connected;
  bool get isConnecting => _status.state == VpnConnectionState.connecting;

  VpnProvider() {
    _init();
  }

  Future<void> _init() async {
    await _vpnService.initialize();
    _subscription = _vpnService.statusStream.listen((newStatus) {
      _status = newStatus;
      notifyListeners();
    });
  }

  Future<void> toggleConnection(ServerConfig? activeServer) async {
    if (activeServer == null) return;

    if (isConnected) {
      await _vpnService.disconnect();
    } else if (_status.state == VpnConnectionState.disconnected ||
        _status.state == VpnConnectionState.error) {
      await _vpnService.connect(activeServer);
    }
  }

  Future<int> checkPing(ServerConfig server) async {
    final ping = await _vpnService.measurePing(server);
    return ping;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _vpnService.dispose();
    super.dispose();
  }
}
