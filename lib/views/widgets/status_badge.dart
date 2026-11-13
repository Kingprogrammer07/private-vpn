import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/vpn_state.dart';

class StatusBadge extends StatelessWidget {
  final VpnConnectionState state;

  const StatusBadge({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    IconData icon;

    switch (state) {
      case VpnConnectionState.connected:
        color = AppColors.connected;
        text = 'HIMOYALANGAN';
        icon = Icons.shield_rounded;
        break;
      case VpnConnectionState.connecting:
        color = AppColors.connecting;
        text = 'ULANMOQDA';
        icon = Icons.sync_rounded;
        break;
      case VpnConnectionState.disconnecting:
        color = AppColors.connecting;
        text = 'UZILMOQDA';
        icon = Icons.sync_rounded;
        break;
      case VpnConnectionState.error:
        color = AppColors.error;
        text = 'XATOLIK';
        icon = Icons.error_outline_rounded;
        break;
      case VpnConnectionState.disconnected:
        color = AppColors.textMuted;
        text = 'O\'CHIRILGAN';
        icon = Icons.shield_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
