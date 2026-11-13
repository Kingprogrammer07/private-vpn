import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/server_config.dart';

class StorageService {
  static const String _serversKey = 'saved_servers_list';
  static const String _activeServerKey = 'active_server_id';

  Future<List<ServerConfig>> getServers() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_serversKey);
    
    if (rawList == null || rawList.isEmpty) {
      // Default to Hetzner Germany
      final defaultList = [ServerConfig.defaultHetzner()];
      await saveServers(defaultList);
      return defaultList;
    }

    try {
      final list = rawList.map((item) {
        final decoded = jsonDecode(item) as Map<String, dynamic>;
        return ServerConfig.fromJson(decoded);
      }).toList();

      // Ensure default server has the latest real keys
      final defaultServer = ServerConfig.defaultHetzner();
      final defaultIndex = list.indexWhere((s) => s.id == defaultServer.id || s.id == 'hetzner_de_1' || s.address == '178.238.228.77');
      if (defaultIndex != -1) {
        list[defaultIndex] = defaultServer;
        await saveServers(list);
      }
      return list;
    } catch (e) {
      return [ServerConfig.defaultHetzner()];
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
