import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/server_config.dart';

class StorageService {
  static const String _serversKey = 'saved_servers_list';
  static const String _activeServerKey = 'active_server_id';

  /// Resolves the default server configuration.
  /// If `assets/config/default_server.json` is provided (e.g., in private/local builds),
  /// it loads that. Otherwise, falls back to the safe open-source template.
  Future<ServerConfig> getDefaultServer() async {
    try {
      final jsonString = await rootBundle.loadString('assets/config/default_server.json');
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      return ServerConfig.fromJson(decoded);
    } catch (_) {
      return ServerConfig.defaultTemplate();
    }
  }

  Future<List<ServerConfig>> getServers() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_serversKey);
    final defaultServer = await getDefaultServer();
    
    if (rawList == null || rawList.isEmpty) {
      final defaultList = [defaultServer];
      await saveServers(defaultList);
      return defaultList;
    }

    try {
      final list = rawList.map((item) {
        final decoded = jsonDecode(item) as Map<String, dynamic>;
        return ServerConfig.fromJson(decoded);
      }).toList();

      // Synchronize custom embedded default server if it has been updated
      if (defaultServer.address != 'YOUR_SERVER_IP') {
        final defaultIndex = list.indexWhere(
          (s) => s.id == defaultServer.id || s.address == defaultServer.address,
        );
        if (defaultIndex != -1) {
          list[defaultIndex] = defaultServer;
          await saveServers(list);
        }
      }
      return list;
    } catch (e) {
      return [defaultServer];
    }
  }

  Future<void> saveServers(List<ServerConfig> servers) async {
    final prefs = await SharedPreferences.getInstance();
    final stringList = servers.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList(_serversKey, stringList);
  }

  Future<String?> getActiveServerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeServerKey);
  }

  Future<void> setActiveServerId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeServerKey, id);
  }
}
