// Pantalla principal - Vista semanal del calendario con animaciones de deslizamiento
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../models/event_model.dart';
import '../widgets/event_card.dart';
import '../widgets/event_form_dialog.dart';
import '../widgets/event_detail_dialog.dart';

class WeeklyCalendarScreen extends StatefulWidget {
  const WeeklyCalendarScreen({super.key});

  @override
  State<WeeklyCalendarScreen> createState() => _WeeklyCalendarScreenState();
}

class _WeeklyCalendarScreenState extends State<WeeklyCalendarScreen>
    with SingleTickerProviderStateMixin {
  // Controlador para la animación de deslizamiento entre semanas
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Semana anterior para detectar cambios
  DateTime? _previousWeekStart;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    // Iniciar completamente visible
    _slideController.value = 1.0;
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  // Ejecuta la animación de deslizamiento al cambiar de semana
  void _triggerSlideAnimation(int direction) {
    _slideAnimation = Tween<Offset>(
      begin: Offset(direction.toDouble() * 0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _slideController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, provider, _) {
        final weekDays = provider.getDaysOfCurrentWeek();
        final today = DateTime.now();
        final colorScheme = Theme.of(context).colorScheme;

        // Detectar cambio de semana y disparar animación
        if (_previousWeekStart != null && _previousWeekStart != provider.currentWeekStart) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _triggerSlideAnimation(provider.slideDirection);
          });
        }
        _previousWeekStart = provider.currentWeekStart;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.chevron_left_rounded, size: 28),
              onPressed: provider.goToPreviousWeek,
              tooltip: 'Semana anterior',
            ),
            title: _buildWeekTitle(context, provider),
            actions: [
              IconButton(icon: const Icon(Icons.today_rounded), onPressed: provider.goToCurrentWeek, tooltip: 'Ir a hoy'),
              IconButton(icon: const Icon(Icons.chevron_right_rounded, size: 28), onPressed: provider.goToNextWeek, tooltip: 'Semana siguiente'),
            ],
          ),
          body: Column(
            children: [
              // Cabecera de días con animación
              _buildWeekHeader(context, weekDays, today, colorScheme),
              Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.5)),

              // Columnas de eventos con animación de deslizamiento
              Expanded(
                child: ClipRect(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildDayColumns(context, weekDays, today, provider, colorScheme),
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddEventDialog(context, provider),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Nuevo'),
            tooltip: 'Crear nuevo evento',
          ),
        );
      },
    );
  }

  Widget _buildWeekTitle(BuildContext context, EventProvider provider) {
    const monthAbbr = ['', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    final start = provider.currentWeekStart;
    final end = provider.currentWeekEnd;
    return Text(
      '${start.day} ${monthAbbr[start.month]} - ${end.day} ${monthAbbr[end.month]}, ${end.year}',
      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  Widget _buildWeekHeader(BuildContext context, List<DateTime> weekDays, DateTime today, ColorScheme colorScheme) {
    const dayAbbr = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)),
      child: Row(
        children: List.generate(7, (i) {
          final day = weekDays[i];
          final isToday = day.year == today.year && day.month == today.month && day.day == today.day;
          return Expanded(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(dayAbbr[i], style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isToday ? colorScheme.primary : colorScheme.onSurfaceVariant)),
              const SizedBox(height: 4),
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(shape: BoxShape.circle, color: isToday ? colorScheme.primary : Colors.transparent),
                alignment: Alignment.center,
                child: Text(
                  '${day.day}',
                  style: TextStyle(fontSize: 14, fontWeight: isToday ? FontWeight.bold : FontWeight.w500, color: isToday ? colorScheme.onPrimary : colorScheme.onSurface),
                ),
              ),
            ]),
          );
        }),
      ),
    );
  }

  Widget _buildDayColumns(BuildContext context, List<DateTime> weekDays, DateTime today, EventProvider provider, ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(7, (i) {
        final day = weekDays[i];
        final isToday = day.year == today.year && day.month == today.month && day.day == today.day;
        final dayEvents = provider.getEventsForDate(day);

        return Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: isToday ? colorScheme.primaryContainer.withValues(alpha: 0.15) : null,
              border: Border(
                right: i < 6 ? BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3), width: 0.5) : BorderSide.none,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            child: dayEvents.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Column(children: [
                        Icon(Icons.event_available_rounded, size: 20, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                        const SizedBox(height: 4),
                        Text('Sin\neventos', textAlign: TextAlign.center, style: TextStyle(fontSize: 8, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3))),
                      ]),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: false,
                    itemCount: dayEvents.length,
                    padding: const EdgeInsets.only(bottom: 80),
                    itemBuilder: (context, idx) {
                      return EventCard(
                        event: dayEvents[idx],
                        onTap: () => _showEventDetail(context, dayEvents[idx], provider),
                      );
                    },
                  ),
          ),
        );
      }),
    );
  }

  // CRUD: Mostrar diálogo para crear evento
  void _showAddEventDialog(BuildContext context, EventProvider provider) async {
    final newEvent = await showEventFormDialog(context, initialDate: DateTime.now());
    if (newEvent != null && mounted) {
      provider.addEvent(newEvent);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Evento "${newEvent.title}" creado'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  // CRUD: Mostrar detalle con opciones de editar y eliminar
  void _showEventDetail(BuildContext context, CalendarEvent event, EventProvider provider) {
    showEventDetailDialog(
      context,
      event: event,
      onEdit: () async {
        final updated = await showEventFormDialog(context, existingEvent: event);
        if (updated != null && mounted) {
          provider.updateEvent(updated);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Evento "${updated.title}" actualizado'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        }
      },
      onDelete: () {
        provider.deleteEvent(event.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Evento "${event.title}" eliminado'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      },
    );
  }
}
