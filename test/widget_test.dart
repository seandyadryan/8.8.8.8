import 'package:flutter_test/flutter_test.dart';

import 'package:warp_proxy_client/src/app.dart';

void main() {
  testWidgets('renders WireGuard dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const NexusWireGuardApp());

    expect(find.text('Nexus WireGuard'), findsOneWidget);
    expect(find.text('WireGuard Profile'), findsOneWidget);
    expect(find.text('VPN mati'), findsOneWidget);
    expect(find.text('Preview .conf'), findsOneWidget);
  });
}
