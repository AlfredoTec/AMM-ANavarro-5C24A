// Diálogo de detalle - Muestra la información completa de un evento
import 'package:flutter/material.dart';
import '../models/event_model.dart';

void showEventDetailDialog(
  BuildContext context, {
  required CalendarEvent event,
  required VoidCallback onEdit,
  required VoidCallback onDelete,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (context) => EventDetailContent(event: event, onEdit: onEdit, onDelete: onDelete),
  );
}

class EventDetailContent extends StatelessWidget {
  final CalendarEvent event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EventDetailContent({
    super.key, required this.event, required this.onEdit, required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    const dayNames = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    const monthNames = ['', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];

    final dateStr = '${dayNames[event.date.weekday - 1]} ${event.date.day} de ${monthNames[event.date.month]}, ${event.date.year}';

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            // Indicador de arrastre
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Encabezado con color del evento
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [event.color.withValues(alpha: 0.15), event.color.withValues(alpha: 0.05)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: event.color.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chips de categoría e importancia
                  Row(
                    children: [
                      // Chip de categoría
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: event.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(event.category.icon, size: 14, color: event.color),
                          const SizedBox(width: 6),
                          Text(event.category.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: event.color)),
                        ]),
                      ),
                      const SizedBox(width: 8),
                      // Chip de importancia
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: event.importance.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(event.importance.icon, size: 14, color: event.importance.color),
                          const SizedBox(width: 6),
                          Text(event.importance.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: event.importance.color)),
                        ]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(event.title, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Descripción
            _buildDetailRow(context, icon: Icons.description_rounded, label: 'Descripción', value: event.description, eventColor: event.color),
            const SizedBox(height: 14),

            // Fecha
            _buildDetailRow(context, icon: Icons.calendar_today_rounded, label: 'Fecha', value: dateStr, eventColor: event.color),
            const SizedBox(height: 14),

            // Horario
            _buildDetailRow(context, icon: Icons.access_time_rounded, label: 'Horario',
              value: event.isAllDay ? 'Todo el día' : _formatTimeRange(event.startTime, event.endTime),
              eventColor: event.color),
            const SizedBox(height: 14),

            // Ubicación
            if (event.location != null && event.location!.isNotEmpty) ...[
              _buildDetailRow(context, icon: Icons.location_on_rounded, label: 'Ubicación', value: event.location!, eventColor: event.color),
              const SizedBox(height: 14),
            ],

            // Repetición
            _buildDetailRow(context,
              icon: event.repeatType != RepeatType.single ? Icons.repeat_rounded : Icons.looks_one_rounded,
              label: 'Repetición',
              value: event.repeatDaysLabel,
              eventColor: event.color),

            const SizedBox(height: 28),

            // Botones de editar y eliminar
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showDeleteConfirmation(context),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Eliminar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    side: BorderSide(color: colorScheme.error.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () { Navigator.pop(context); onEdit(); },
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Editar'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ]),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(BuildContext context, {required IconData icon, required String label, required String value, required Color eventColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: eventColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 20, color: eventColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 14)),
          ]),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar evento'),
        content: Text('¿Estás seguro de que deseas eliminar "${event.title}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          TextButton(
            onPressed: () { Navigator.pop(dialogContext); Navigator.pop(context); onDelete(); },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
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
