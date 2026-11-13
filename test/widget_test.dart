import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:antigravity_vpn/core/theme/app_theme.dart';
import 'package:antigravity_vpn/models/vpn_state.dart';
import 'package:antigravity_vpn/views/widgets/status_badge.dart';

void main() {
  testWidgets('StatusBadge renders correctly in disconnected state',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const AppWrapper(
        child: StatusBadge(state: VpnConnectionState.disconnected),
      ),
    );

    expect(find.text("O'CHIRILGAN"), findsOneWidget);
  });

  testWidgets('StatusBadge renders correctly in connected state',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const AppWrapper(
        child: StatusBadge(state: VpnConnectionState.connected),
      ),
    );

    expect(find.text('HIMOYALANGAN'), findsOneWidget);
  });
}

class AppWrapper extends StatelessWidget {
  final Widget child;
  const AppWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: Center(child: child),
      ),
    );
  }
}
