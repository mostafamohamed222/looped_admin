import 'package:flutter_test/flutter_test.dart';

import 'package:looped_admin/main.dart';

void main() {
  testWidgets('App shell shows bottom nav tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Requests'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
