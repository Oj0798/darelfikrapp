import 'package:flutter_test/flutter_test.dart';
import 'package:darelfikrapp/app/app.dart';


void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const DarElFikrApp());
    expect(find.text('Dar El Fikr'), findsOneWidget);
  });
}
