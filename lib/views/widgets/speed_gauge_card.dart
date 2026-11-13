import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/vpn_state.dart';

class SpeedGaugeCard extends StatelessWidget {
  final VpnStatusInfo status;

  const SpeedGaugeCard({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isConnected = status.state == VpnConnectionState.connected;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Download
          _buildMetric(
            icon: Icons.arrow_downward_rounded,
            iconColor: AppColors.primary,
            label: 'YUKLASH (DOWN)',
            speedText: isConnected
                ? VpnStatusInfo.formatSpeed(status.downloadSpeedBytes)
                : '0.0 KB/s',
            totalText: isConnected
                ? VpnStatusInfo.formatBytes(status.totalDownloadBytes)
                : '0 B',
          ),

          // Divider
          Container(
            width: 1,
            height: 48,
            color: AppColors.border,
          ),

          // Upload
          _buildMetric(
            icon: Icons.arrow_upward_rounded,
            iconColor: AppColors.connected,
            label: "JO'NATISH (UP)",
            speedText: isConnected
                ? VpnStatusInfo.formatSpeed(status.uploadSpeedBytes)
                : '0.0 KB/s',
            totalText: isConnected
                ? VpnStatusInfo.formatBytes(status.totalUploadBytes)
                : '0 B',
          ),

          // Divider
          Container(
            width: 1,
            height: 48,
            color: AppColors.border,
          ),

          // Ping
          _buildPingMetric(isConnected ? status.pingMs : -1),
        ],
      ),
    );
  }

  Widget _buildMetric({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String speedText,
    required String totalText,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          speedText,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          totalText,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildPingMetric(int ping) {
    Color pingColor = AppColors.textMuted;
    String pingStatus = '--';
    String pingVal = '--';

    if (ping > 0) {
      pingVal = '$ping ms';
      if (ping < 70) {
        pingColor = AppColors.connected;
        pingStatus = 'Ultra Tez';
      } else if (ping < 120) {
        pingColor = AppColors.connecting;
        pingStatus = 'Yaxshi';
      } else {
        pingColor = AppColors.error;
        pingStatus = 'Sekin';
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bolt_rounded, size: 14, color: pingColor),
            const SizedBox(width: 2),
            const Text(
              'PING',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          pingVal,
          style: TextStyle(
            color: pingColor,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          pingStatus,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
