// Punto de entrada - Aplicación Calendario Semanal
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/event_provider.dart';
import 'screens/weekly_calendar_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CalendarWeeklyApp());
}

// Widget raíz con Provider y tema Material 3
class CalendarWeeklyApp extends StatelessWidget {
  const CalendarWeeklyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EventProvider(),
      child: MaterialApp(
        title: 'Calendario Semanal',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const WeeklyCalendarScreen(),
      ),
    );
  }
}
