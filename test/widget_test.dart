import 'package:flutter_test/flutter_test.dart';

import 'package:PantryPal/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(initialRoute: '/welcome'));
    await tester.pumpAndSettle();

    // 验证欢迎页面渲染
    expect(find.text('PantryPal'), findsOneWidget);
  });
}
