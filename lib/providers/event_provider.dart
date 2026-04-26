// Proveedor de estado - Gestión de eventos del calendario
import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../data/sample_events.dart';

class EventProvider extends ChangeNotifier {
  List<CalendarEvent> _events = [];
  late DateTime _currentWeekStart;
  // Dirección de la animación: 1 = adelante, -1 = atrás
  int _slideDirection = 1;

  EventProvider() {
    final now = DateTime.now();
    _currentWeekStart = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    _events = generateSampleEvents();
  }

  // Getters
  List<CalendarEvent> get events => List.unmodifiable(_events);
  DateTime get currentWeekStart => _currentWeekStart;
  DateTime get currentWeekEnd => _currentWeekStart.add(const Duration(days: 6));
  int get slideDirection => _slideDirection;

  // Navegación entre semanas
  void goToPreviousWeek() {
    _slideDirection = -1;
    _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
    notifyListeners();
  }

  void goToNextWeek() {
    _slideDirection = 1;
    _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
    notifyListeners();
  }

  void goToCurrentWeek() {
    final now = DateTime.now();
    final newStart = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    _slideDirection = newStart.isAfter(_currentWeekStart) ? 1 : -1;
    _currentWeekStart = newStart;
    notifyListeners();
  }

  // Obtiene los eventos para una fecha incluyendo repeticiones personalizadas
  List<CalendarEvent> getEventsForDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);

    final filteredEvents = _events.where((event) {
      final eventDate = DateTime(event.date.year, event.date.month, event.date.day);

      // Coincidencia exacta de fecha
      if (eventDate == targetDate) return true;

      // Repetición semanal: mismo día de la semana, en o después de la fecha original
      if (event.repeatType == RepeatType.weekly) {
        if (event.date.weekday == date.weekday) {
          return !targetDate.isBefore(eventDate);
        }
      }

      // Repetición personalizada: coincide si el día de la semana está en repeatDays
      if (event.repeatType == RepeatType.custom && event.repeatDays.contains(date.weekday)) {
        return !targetDate.isBefore(eventDate);
      }

      return false;
    }).toList();

    // Ordenar: todo el día primero, luego por hora de inicio
    filteredEvents.sort((a, b) {
      if (a.isAllDay && b.isAllDay) return 0;
      if (a.isAllDay) return -1;
      if (b.isAllDay) return 1;
      final aMin = (a.startTime?.hour ?? 0) * 60 + (a.startTime?.minute ?? 0);
      final bMin = (b.startTime?.hour ?? 0) * 60 + (b.startTime?.minute ?? 0);
      return aMin.compareTo(bMin);
    });

    return filteredEvents;
  }

  // Lista de 7 fechas (Lun-Dom) de la semana actual mostrada
  List<DateTime> getDaysOfCurrentWeek() {
    return List.generate(7, (i) => _currentWeekStart.add(Duration(days: i)));
  }

  // CRUD - Crear evento
  void addEvent(CalendarEvent event) {
    _events.add(event);
    notifyListeners();
  }

  // CRUD - Actualizar evento
  void updateEvent(CalendarEvent updatedEvent) {
    final index = _events.indexWhere((e) => e.id == updatedEvent.id);
    if (index != -1) {
      _events[index] = updatedEvent;
      notifyListeners();
    }
  }

  // CRUD - Eliminar evento
  void deleteEvent(String eventId) {
    _events.removeWhere((e) => e.id == eventId);
    notifyListeners();
  }
}
