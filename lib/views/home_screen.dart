import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/server_provider.dart';
import '../providers/vpn_provider.dart';
import '../services/update_service.dart';
import 'widgets/power_button.dart';
import 'widgets/server_selector_card.dart';
import 'widgets/speed_gauge_card.dart';
import 'widgets/status_badge.dart';
import 'server_list_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkAppUpdateSilently();
  }

  void _checkAppUpdateSilently() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final update = await UpdateService.checkForUpdate();
      if (update != null && mounted) {
        UpdateService.showUpdateDialog(context, update);
      }
    });
  }

  void _showServerList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ServerListBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer2<VpnProvider, ServerProvider>(
          builder: (context, vpnProvider, serverProvider, child) {
            final activeServer = serverProvider.activeServer;
            final vpnStatus = vpnProvider.status;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  // App Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 40,
                                height: 40,
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.primary.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Image.asset(
                                  'assets/images/app_logo.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.shield_rounded,
                                    color: AppColors.primary,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "PRIVATE VPN",
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  Text(
                                    'Ultra-Fast VLESS VPN',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Status Badge
                      StatusBadge(state: vpnStatus.state),
                    ],
                  ),

                  const Spacer(flex: 1),

                  // Power Button Centerpiece
                  PowerButton(
                    state: vpnStatus.state,
                    duration: vpnStatus.connectedDuration,
                    onTap: () {
                      vpnProvider.toggleConnection(activeServer);
                    },
                  ),

                  const Spacer(flex: 2),

                  // Real-time Traffic Gauges
                  SpeedGaugeCard(status: vpnStatus),

                  const SizedBox(height: 14),

                  // Active Server Selector Card
                  ServerSelectorCard(
                    activeServer: activeServer,
                    onTap: () => _showServerList(context),
                  ),

                  const SizedBox(height: 14),

                  // Security and Features Info Row
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.lock_outline_rounded,
                            size: 13, color: AppColors.connected),
                        SizedBox(width: 6),
                        Text(
                          'TLS 1.3 Reality Niqoblash • 0-Log Maxfiylik',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
