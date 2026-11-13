import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/vpn_state.dart';

class PowerButton extends StatefulWidget {
  final VpnConnectionState state;
  final Duration duration;
  final VoidCallback onTap;

  const PowerButton({
    super.key,
    required this.state,
    required this.duration,
    required this.onTap,
  });

  @override
  State<PowerButton> createState() => _PowerButtonState();
}

class _PowerButtonState extends State<PowerButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = widget.state == VpnConnectionState.connected;
    final isConnecting = widget.state == VpnConnectionState.connecting ||
        widget.state == VpnConnectionState.disconnecting;

    Color glowColor;
    Color buttonColor;
    IconData iconData = Icons.power_settings_new_rounded;

    if (isConnected) {
      glowColor = AppColors.connected;
      buttonColor = AppColors.connected;
    } else if (isConnecting) {
      glowColor = AppColors.connecting;
      buttonColor = AppColors.connecting;
    } else {
      glowColor = AppColors.primary;
      buttonColor = AppColors.textSecondary;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            final scale = isConnected ? _pulseAnimation.value : 1.0;
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  if (isConnected)
                    BoxShadow(
                      color: glowColor.withValues(alpha: 0.35),
                      blurRadius: 45,
                      spreadRadius: 8,
                    ),
                  if (isConnecting)
                    BoxShadow(
                      color: glowColor.withValues(alpha: 0.25),
                      blurRadius: 35,
                      spreadRadius: 4,
                    ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Ring
                  Container(
                    width: 190,
                    height: 190,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.surfaceLight,
                          AppColors.surface,
                          AppColors.background,
                        ],
                      ),
                      border: Border.all(
                        color: isConnected
                            ? glowColor.withValues(alpha: 0.8)
                            : isConnecting
                                ? glowColor.withValues(alpha: 0.6)
                                : AppColors.border,
                        width: isConnected ? 3.5 : 2,
                      ),
                    ),
                  ),

                  // Middle Layer
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isConnected
                          ? glowColor.withValues(alpha: 0.12)
                          : AppColors.surface,
                      border: Border.all(
                        color: isConnected
                            ? glowColor.withValues(alpha: 0.4)
                            : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                  ),

                  // Inner Button
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isConnected
                            ? [
                                glowColor.withValues(alpha: 0.9),
                                glowColor.withValues(alpha: 0.6),
                              ]
                            : isConnecting
                                ? [
                                    glowColor.withValues(alpha: 0.7),
                                    glowColor.withValues(alpha: 0.4),
                                  ]
                                : [
                                    AppColors.surfaceLight,
                                    AppColors.surface,
                                  ],
                      ),
                    ),
                    child: Center(
                      child: isConnecting
                          ? const SizedBox(
                              width: 38,
                              height: 38,
                              child: CircularProgressIndicator(
                                strokeWidth: 3.5,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              iconData,
                              color: isConnected ? Colors.black : buttonColor,
                              size: 48,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Duration or Tap Hint
        if (isConnected)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.timer_outlined,
                  size: 16,
                  color: AppColors.connected,
                ),
                const SizedBox(width: 6),
                Text(
                  VpnStatusInfo.formatDuration(widget.duration),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          )
        else
          Text(
            isConnecting ? 'Xavfsiz tunnel o\'rnatilmoqda...' : 'Ulanish uchun bosing',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
}
