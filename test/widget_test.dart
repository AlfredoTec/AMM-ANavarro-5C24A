// Test básico de la aplicación Calendario Semanal
import 'package:flutter_test/flutter_test.dart';
import 'package:calendar_weekly/main.dart';

void main() {
  testWidgets('La app renderiza la pantalla del calendario', (WidgetTester tester) async {
    await tester.pumpWidget(const CalendarWeeklyApp());
    expect(find.text('Nuevo'), findsOneWidget);
  });
}
