import 'package:flutter_test/flutter_test.dart';

import 'package:warp_proxy_client/src/app.dart';

void main() {
  testWidgets('renders proxy dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const WarpProxyApp());

    expect(find.text('Nexus Proxy'), findsOneWidget);
    expect(find.text('Server'), findsOneWidget);
    expect(find.text('Proxy mati'), findsOneWidget);
    expect(find.text('SOCKS5 proxy: 127.0.0.1:1080'), findsOneWidget);
  });
}
