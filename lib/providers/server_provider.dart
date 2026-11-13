import 'package:flutter/foundation.dart';
import '../models/server_config.dart';
import '../services/storage_service.dart';

class ServerProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<ServerConfig> _servers = [];
  ServerConfig? _activeServer;
  bool _isLoading = true;

  List<ServerConfig> get servers => _servers;
  ServerConfig? get activeServer => _activeServer;
  bool get isLoading => _isLoading;

  ServerProvider() {
    loadServers();
  }

  Future<void> loadServers() async {
    _isLoading = true;
    notifyListeners();

    _servers = await _storageService.getServers();
    final activeId = await _storageService.getActiveServerId();

    if (_servers.isNotEmpty) {
      if (activeId != null) {
        _activeServer = _servers.firstWhere(
          (s) => s.id == activeId,
          orElse: () => _servers.first,
        );
      } else {
        _activeServer = _servers.first;
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> selectServer(ServerConfig server) async {
    _activeServer = server;
    await _storageService.setActiveServerId(server.id);
    notifyListeners();
  }

  Future<bool> addServerFromUrl(String vlessUrl) async {
    try {
      final newServer = ServerConfig.fromVlessUrl(vlessUrl);
      // Remove existing with same id if any
      _servers.removeWhere((s) => s.id == newServer.id);
      _servers.add(newServer);
      _activeServer = newServer;

      await _storageService.saveServers(_servers);
      await _storageService.setActiveServerId(newServer.id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Failed to add server: $e');
      return false;
    }
  }

  Future<void> deleteServer(String id) async {
    _servers.removeWhere((s) => s.id == id);
    if (_activeServer?.id == id) {
      _activeServer = _servers.isNotEmpty ? _servers.first : null;
      if (_activeServer != null) {
        await _storageService.setActiveServerId(_activeServer!.id);
      }
    }
    await _storageService.saveServers(_servers);
    notifyListeners();
  }

  void updateServerPing(String id, int ping) {
    final idx = _servers.indexWhere((s) => s.id == id);
    if (idx != -1) {
      _servers[idx].pingMs = ping;
      if (_activeServer?.id == id) {
        _activeServer?.pingMs = ping;
      }
      notifyListeners();
    }
  }
}
