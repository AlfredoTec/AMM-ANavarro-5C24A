// Modelo de datos - Estructura de eventos del calendario
import 'package:flutter/material.dart';

// Categorías disponibles para cada evento
enum EventCategory { exams, work, task, birthday, other }

extension EventCategoryExtension on EventCategory {
  // Etiqueta en español para la interfaz
  String get label {
    switch (this) {
      case EventCategory.exams: return 'Exámenes';
      case EventCategory.work: return 'Trabajo';
      case EventCategory.task: return 'Tarea';
      case EventCategory.birthday: return 'Cumpleaños';
      case EventCategory.other: return 'Otro';
    }
  }

  // Ícono representativo de cada categoría
  IconData get icon {
    switch (this) {
      case EventCategory.exams: return Icons.school_rounded;
      case EventCategory.work: return Icons.work_rounded;
      case EventCategory.task: return Icons.task_alt_rounded;
      case EventCategory.birthday: return Icons.cake_rounded;
      case EventCategory.other: return Icons.event_rounded;
    }
  }
}

// Tipo de repetición del evento
enum RepeatType { single, weekly, custom }

extension RepeatTypeExtension on RepeatType {
  String get label {
    switch (this) {
      case RepeatType.single: return 'Solo ese día';
      case RepeatType.weekly: return 'Semanal';
      case RepeatType.custom: return 'Días específicos';
    }
  }
}

// Nivel de importancia del evento
enum EventImportance { low, medium, high }

extension EventImportanceExtension on EventImportance {
  // Etiqueta en español
  String get label {
    switch (this) {
      case EventImportance.low: return 'Baja';
      case EventImportance.medium: return 'Media';
      case EventImportance.high: return 'Alta';
    }
  }

  // Color asociado a cada nivel de importancia
  Color get color {
    switch (this) {
      case EventImportance.low: return const Color(0xFF4CAF50);
      case EventImportance.medium: return const Color(0xFFFF9800);
      case EventImportance.high: return const Color(0xFFF44336);
    }
  }

  // Ícono asociado a cada nivel
  IconData get icon {
    switch (this) {
      case EventImportance.low: return Icons.arrow_downward_rounded;
      case EventImportance.medium: return Icons.remove_rounded;
      case EventImportance.high: return Icons.arrow_upward_rounded;
    }
  }
}

// Nombres abreviados de los días en español (1=Lun, 7=Dom)
const Map<int, String> weekdayLabels = {
  1: 'Lun', 2: 'Mar', 3: 'Mié', 4: 'Jue', 5: 'Vie', 6: 'Sáb', 7: 'Dom',
};

// Modelo principal del evento del calendario
class CalendarEvent {
  final String id;
  final String title;
  final String description;
  final String? location;
  final DateTime date;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final Color color;
  final EventCategory category;
  final RepeatType repeatType;
  // Días de la semana en que se repite (1=Lun..7=Dom), usado cuando repeatType == custom
  final List<int> repeatDays;
  final EventImportance importance;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    this.location,
    required this.date,
    this.startTime,
    this.endTime,
    required this.color,
    this.category = EventCategory.task,
    this.repeatType = RepeatType.single,
    this.repeatDays = const [],
    this.importance = EventImportance.medium,
  });

  // Evento de todo el día si no tiene hora de inicio ni fin
  bool get isAllDay => startTime == null && endTime == null;

  // Copia inmutable con campos opcionales sobreescritos
  CalendarEvent copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    Color? color,
    EventCategory? category,
    RepeatType? repeatType,
    List<int>? repeatDays,
    EventImportance? importance,
    bool clearLocation = false,
    bool clearStartTime = false,
    bool clearEndTime = false,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: clearLocation ? null : (location ?? this.location),
      date: date ?? this.date,
      startTime: clearStartTime ? null : (startTime ?? this.startTime),
      endTime: clearEndTime ? null : (endTime ?? this.endTime),
      color: color ?? this.color,
      category: category ?? this.category,
      repeatType: repeatType ?? this.repeatType,
      repeatDays: repeatDays ?? this.repeatDays,
      importance: importance ?? this.importance,
    );
  }

  // Texto legible de los días de repetición
  String get repeatDaysLabel {
    if (repeatType == RepeatType.single) return 'Solo ese día';
    if (repeatType == RepeatType.weekly) return 'Cada semana';
    if (repeatDays.isEmpty) return 'Sin días';
    final sorted = List<int>.from(repeatDays)..sort();
    return sorted.map((d) => weekdayLabels[d] ?? '?').join(', ');
  }
}
