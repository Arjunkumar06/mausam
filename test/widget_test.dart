import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mausam/main.dart';

void main() {
  testWidgets('Mausam app smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MausamApp());
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.textContaining('Mausam'), findsWidgets);
  });
}
