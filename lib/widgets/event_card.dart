// Tarjeta de evento - Representación visual compacta de un evento
import 'package:flutter/material.dart';
import '../models/event_model.dart';

class EventCard extends StatelessWidget {
  final CalendarEvent event;
  final VoidCallback onTap;

  const EventCard({super.key, required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: event.color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border(left: BorderSide(color: event.color, width: 4)),
          boxShadow: [
            BoxShadow(
              color: event.color.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícono de categoría + título
            Row(
              children: [
                Icon(event.category.icon, size: 14, color: event.color),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    event.title,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: event.color.withValues(alpha: 0.9),
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),

            // Hora del evento
            Row(
              children: [
                Icon(Icons.access_time_rounded, size: 10, color: event.color.withValues(alpha: 0.6)),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    event.isAllDay ? 'Todo el día' : _formatTimeRange(event.startTime, event.endTime),
                    style: textTheme.bodySmall?.copyWith(fontSize: 9, color: event.color.withValues(alpha: 0.7)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // Ubicación (solo si existe)
            if (event.location != null && event.location!.isNotEmpty) ...[
              const SizedBox(height: 1),
              Row(
                children: [
                  Icon(Icons.location_on_rounded, size: 10, color: event.color.withValues(alpha: 0.6)),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      event.location!,
                      style: textTheme.bodySmall?.copyWith(fontSize: 9, color: event.color.withValues(alpha: 0.7)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 3),

            // Chip de importancia con color
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: event.importance.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(event.importance.icon, size: 8, color: event.importance.color),
                      const SizedBox(width: 2),
                      Text(
                        event.importance.label,
                        style: TextStyle(fontSize: 7, color: event.importance.color, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),

                // Badge de repetición (si aplica)
                if (event.repeatType != RepeatType.single) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: event.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.repeat_rounded, size: 8, color: event.color),
                        const SizedBox(width: 2),
                        Text(
                          event.repeatType == RepeatType.weekly ? 'Semanal' : 'Custom',
                          style: TextStyle(fontSize: 7, color: event.color, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeRange(TimeOfDay? start, TimeOfDay? end) {
    if (start == null) return 'Todo el día';
    final s = '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    if (end != null) {
      final e = '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
      return '$s - $e';
    }
    return s;
  }
}
