import 'package:flutter_test/flutter_test.dart';
import 'package:movi/main.dart';

void main() {
  testWidgets('App load test', (WidgetTester tester) async {
    await tester.pumpWidget(const MoviApp());
    expect(find.byType(MoviApp), findsOneWidget);
  });
}
