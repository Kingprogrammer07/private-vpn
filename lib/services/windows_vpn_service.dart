import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/server_config.dart';

typedef _InternetSetOptionC = ffi.Int32 Function(
    ffi.IntPtr hInternet, ffi.Uint32 dwOption, ffi.Pointer lpBuffer, ffi.Uint32 dwBufferLength);
typedef _InternetSetOptionDart = int Function(
    int hInternet, int dwOption, ffi.Pointer lpBuffer, int dwBufferLength);

class WindowsVpnService {
  Process? _xrayProcess;
  File? _activeConfigFile;

  /// Find `xray.exe` binary on the Windows machine
  String? findXrayBinary() {
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    final candidates = [
      '$exeDir\\xray\\xray.exe',
      '$exeDir\\xray.exe',
      'windows\\bin\\xray.exe',
      '${Directory.current.path}\\windows\\bin\\xray.exe',
    ];

    for (final candidate in candidates) {
      if (File(candidate).existsSync()) {
        return candidate;
      }
    }
    return null;
  }

  /// Start Xray-core with VLESS Reality configuration and enable Windows System Proxy
  Future<bool> connect(ServerConfig server) async {
    final xrayPath = findXrayBinary();
    if (xrayPath == null) {
      debugPrint('WindowsVpnService: xray.exe not found');
      return false;
    }

    try {
      // 1. Build Xray JSON configuration
      final config = {
        'log': {'loglevel': 'warning'},
        'inbounds': [
          {
            'tag': 'socks-in',
            'port': 10808,
            'listen': '127.0.0.1',
            'protocol': 'socks',
            'settings': {'auth': 'noauth', 'udp': true}
          },
          {
            'tag': 'http-in',
            'port': 10809,
            'listen': '127.0.0.1',
            'protocol': 'http'
          }
        ],
        'outbounds': [
          {
            'tag': 'proxy',
            'protocol': 'vless',
            'settings': {
              'vnext': [
                {
                  'address': server.address,
                  'port': server.port,
                  'users': [
                    {
                      'id': server.uuid,
                      'encryption': 'none',
                      'flow': server.flow.isNotEmpty ? server.flow : 'xtls-rprx-vision'
                    }
                  ]
                }
              ]
            },
            'streamSettings': {
              'network': server.network.isNotEmpty ? server.network : 'tcp',
              'security': server.security.isNotEmpty ? server.security : 'reality',
              'realitySettings': {
                'serverName': server.sni,
                'fingerprint': server.fp.isNotEmpty ? server.fp : 'chrome',
                'publicKey': server.pbk,
                'shortId': server.sid,
                'spiderX': ''
              }
            }
          },
          {
            'tag': 'direct',
            'protocol': 'freedom'
          }
        ]
      };

      // 2. Write configuration to temp directory
      final tempDir = Directory.systemTemp;
      _activeConfigFile = File('${tempDir.path}\\antigravity_vpn_xray.json');
      await _activeConfigFile!.writeAsString(jsonEncode(config));

      // 3. Launch xray.exe process
      _xrayProcess = await Process.start(
        xrayPath,
        ['run', '-c', _activeConfigFile!.path],
        mode: ProcessStartMode.normal,
      );

      _xrayProcess?.exitCode.then((exitCode) {
        debugPrint('Windows Xray exited with code $exitCode');
      });

      // Brief pause to allow socket to bind
      await Future.delayed(const Duration(milliseconds: 500));

      // 4. Enable Windows System Proxy (127.0.0.1:10809)
      await setSystemProxy(enabled: true, proxyAddress: '127.0.0.1:10809');

      debugPrint('Windows VPN successfully connected through VLESS Reality');
      return true;
    } catch (e, stack) {
      debugPrint('Windows VPN connect error: $e\n$stack');
      await disconnect();
      return false;
    }
  }

  /// Disconnect Xray and revert Windows System Proxy
  Future<void> disconnect() async {
    try {
      // 1. Kill Xray process
      if (_xrayProcess != null) {
        _xrayProcess!.kill();
        _xrayProcess = null;
      }

      // 2. Disable Windows System Proxy
      await setSystemProxy(enabled: false);

      // 3. Remove temp config file
      if (_activeConfigFile != null && await _activeConfigFile!.exists()) {
        await _activeConfigFile!.delete();
        _activeConfigFile = null;
      }
      debugPrint('Windows VPN disconnected and system proxy restored.');
    } catch (e) {
      debugPrint('Windows VPN disconnect error: $e');
    }
  }

  /// Measures real TCP handshake latency to server
  Future<int> measurePing(ServerConfig server) async {
    final stopwatch = Stopwatch()..start();
    try {
      final socket = await Socket.connect(
        server.address,
        server.port,
        timeout: const Duration(seconds: 3),
      );
      stopwatch.stop();
      socket.destroy();
      return stopwatch.elapsedMilliseconds;
    } catch (e) {
      return -1;
    }
  }

  /// Toggle Windows System Proxy via Registry and WinINet API
  Future<void> setSystemProxy({required bool enabled, String proxyAddress = '127.0.0.1:10809'}) async {
    try {
      // Set ProxyEnable
      await Process.run('reg', [
        'add',
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings',
        '/v',
        'ProxyEnable',
        '/t',
        'REG_DWORD',
        '/d',
        enabled ? '1' : '0',
        '/f',
      ]);

      if (enabled) {
        // Set ProxyServer
        await Process.run('reg', [
          'add',
          r'HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings',
          '/v',
          'ProxyServer',
          '/t',
          'REG_SZ',
          '/d',
          proxyAddress,
          '/f',
        ]);
      }

      // Refresh Windows Internet Settings so all browsers apply immediately
      _refreshWininetProxy();
    } catch (e) {
      debugPrint('Failed to set Windows proxy: $e');
    }
  }

  void _refreshWininetProxy() {
    try {
      final wininet = ffi.DynamicLibrary.open('wininet.dll');
      final setOption = wininet.lookupFunction<_InternetSetOptionC, _InternetSetOptionDart>(
        'InternetSetOptionW',
      );
      // 39: INTERNET_OPTION_SETTINGS_CHANGED
      setOption(0, 39, ffi.Pointer.fromAddress(0), 0);
      // 37: INTERNET_OPTION_REFRESH
      setOption(0, 37, ffi.Pointer.fromAddress(0), 0);
    } catch (e) {
      debugPrint('Error refreshing WinINet proxy: $e');
    }
  }
}
