import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wallop/main.dart';

void main() {
//  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWallop();
}

void testWallop() {
  testWidgets('App name smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WallopApp());

    // Verify that our app is called what we expect
//    expect(find.byTooltip('Show Preferences'), findsOneWidget);
  });
}
