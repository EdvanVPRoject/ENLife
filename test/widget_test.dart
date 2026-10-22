import 'package:flutter_test/flutter_test.dart';
import 'package:enlife/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ENLifeApp());
    expect(find.byType(ENLifeApp), findsOneWidget);
  });
}
