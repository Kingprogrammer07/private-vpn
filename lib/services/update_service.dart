import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_theme.dart';

class UpdateInfo {
  final String version;
  final int buildNumber;
  final bool forceUpdate;
  final String title;
  final String changelog;
  final String downloadUrlAndroid;
  final String downloadUrlWindows;
  final String githubReleaseUrl;

  const UpdateInfo({
    required this.version,
    required this.buildNumber,
    required this.forceUpdate,
    required this.title,
    required this.changelog,
    required this.downloadUrlAndroid,
    required this.downloadUrlWindows,
    required this.githubReleaseUrl,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      version: json['version'] as String? ?? '1.0.0',
      buildNumber: json['build_number'] as int? ?? 1,
      forceUpdate: json['force_update'] as bool? ?? false,
      title: json['title'] as String? ?? 'Yangi versiya mavjud!',
      changelog: json['changelog'] as String? ?? '',
      downloadUrlAndroid: json['download_url_android'] as String? ?? '',
      downloadUrlWindows: json['download_url_windows'] as String? ?? '',
      githubReleaseUrl: json['github_release_url'] as String? ??
          'https://github.com/Kingprogrammer07/private-vpn/releases/latest',
    );
  }
}

class UpdateService {
  static const String currentVersion = '1.0.0';
  static const int currentBuildNumber = 1;

  static const String updateManifestUrl =
      'https://raw.githubusercontent.com/Kingprogrammer07/private-vpn/main/version.json';

  /// Check if a newer version is published on GitHub
  static Future<UpdateInfo?> checkForUpdate() async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      final request = await client.getUrl(Uri.parse(updateManifestUrl));
      final response = await request.close().timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final Map<String, dynamic> data = jsonDecode(body);
        final updateInfo = UpdateInfo.fromJson(data);

        // Check if remote version is newer than current build
        if (updateInfo.buildNumber > currentBuildNumber ||
            _isVersionGreater(updateInfo.version, currentVersion)) {
          return updateInfo;
        }
      }
    } catch (e) {
      debugPrint('Check for update error: $e');
    }
    return null;
  }

  static bool _isVersionGreater(String remote, String current) {
    final rParts = remote.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final cParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < rParts.length && i < cParts.length; i++) {
      if (rParts[i] > cParts[i]) return true;
      if (rParts[i] < cParts[i]) return false;
    }
    return rParts.length > cParts.length;
  }

  /// Launch download URL based on operating system
  static Future<void> openDownloadLink(UpdateInfo info) async {
    String url = info.githubReleaseUrl;
    if (Platform.isAndroid && info.downloadUrlAndroid.isNotEmpty) {
      url = info.downloadUrlAndroid;
    } else if (Platform.isWindows && info.downloadUrlWindows.isNotEmpty) {
      url = info.downloadUrlWindows;
    }

    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Could not launch update URL: $e');
    }
  }

  /// Show modern cyber-themed in-app update dialog
  static void showUpdateDialog(BuildContext context, UpdateInfo info) {
    showDialog(
      context: context,
      barrierDismissible: !info.forceUpdate,
      builder: (ctx) {
        return Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Icon
                Container(
                  width: 56,
                  height: 56,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.system_update_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  info.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),

                // Version Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    'v${info.version} (Build ${info.buildNumber})',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Changelog
                if (info.changelog.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      info.changelog,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],

                // Action Buttons
                Row(
                  children: [
                    if (!info.forceUpdate) ...[
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text(
                            'Keyinroq',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.background,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          openDownloadLink(info);
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.download_rounded, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Yangilash',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
