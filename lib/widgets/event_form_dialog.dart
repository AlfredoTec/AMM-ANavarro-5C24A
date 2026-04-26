// Formulario de evento - Crear y editar eventos del calendario
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/event_model.dart';
import '../theme/app_theme.dart';

// Muestra el formulario como bottom sheet modal
Future<CalendarEvent?> showEventFormDialog(
  BuildContext context, {
  CalendarEvent? existingEvent,
  DateTime? initialDate,
}) {
  return showModalBottomSheet<CalendarEvent>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (context) => EventFormContent(
      existingEvent: existingEvent,
      initialDate: initialDate,
    ),
  );
}

class EventFormContent extends StatefulWidget {
  final CalendarEvent? existingEvent;
  final DateTime? initialDate;

  const EventFormContent({super.key, this.existingEvent, this.initialDate});

  @override
  State<EventFormContent> createState() => _EventFormContentState();
}

class _EventFormContentState extends State<EventFormContent> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late DateTime _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  late bool _isAllDay;
  late Color _selectedColor;
  late EventCategory _selectedCategory;
  late RepeatType _selectedRepeatType;
  late List<int> _selectedRepeatDays;
  late EventImportance _selectedImportance;

  @override
  void initState() {
    super.initState();
    final event = widget.existingEvent;
    if (event != null) {
      _titleController = TextEditingController(text: event.title);
      _descriptionController = TextEditingController(text: event.description);
      _locationController = TextEditingController(text: event.location ?? '');
      _selectedDate = event.date;
      _startTime = event.startTime;
      _endTime = event.endTime;
      _isAllDay = event.isAllDay;
      _selectedColor = event.color;
      _selectedCategory = event.category;
      _selectedRepeatType = event.repeatType;
      _selectedRepeatDays = List<int>.from(event.repeatDays);
      _selectedImportance = event.importance;
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _locationController = TextEditingController();
      _selectedDate = widget.initialDate ?? DateTime.now();
      _startTime = null;
      _endTime = null;
      _isAllDay = true;
      _selectedColor = AppTheme.eventColors[0];
      _selectedCategory = EventCategory.task;
      _selectedRepeatType = RepeatType.single;
      _selectedRepeatDays = [];
      _selectedImportance = EventImportance.medium;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              controller: scrollController,
              children: [
                // Indicador de arrastre
                Center(
                  child: Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Título del diálogo
                Text(
                  widget.existingEvent != null ? 'Editar Evento' : 'Nuevo Evento',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold, color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Campo: Título
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título', hintText: 'Nombre del evento',
                    prefixIcon: Icon(Icons.title_rounded),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'El título es obligatorio' : null,
                ),
                const SizedBox(height: 14),

                // Campo: Descripción
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción', hintText: 'Detalles del evento',
                    prefixIcon: Icon(Icons.description_rounded),
                  ),
                  maxLines: 3,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'La descripción es obligatoria' : null,
                ),
                const SizedBox(height: 14),

                // Campo: Ubicación (opcional)
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Ubicación (opcional)', hintText: '¿Dónde es el evento?',
                    prefixIcon: Icon(Icons.location_on_rounded),
                  ),
                ),
                const SizedBox(height: 20),

                // Selector de fecha
                _buildSectionTitle('Fecha'),
                const SizedBox(height: 8),
                _buildDatePicker(context, colorScheme),
                const SizedBox(height: 20),

                // Toggle todo el día + selectores de hora
                _buildSectionTitle('Horario'),
                const SizedBox(height: 8),
                _buildAllDayToggle(colorScheme),
                if (!_isAllDay) ...[
                  const SizedBox(height: 10),
                  _buildTimePickers(context, colorScheme),
                ],
                const SizedBox(height: 20),

                // Selector de color
                _buildSectionTitle('Color del evento'),
                const SizedBox(height: 8),
                _buildColorPicker(),
                const SizedBox(height: 20),

                // Selector de categoría
                _buildSectionTitle('Categoría'),
                const SizedBox(height: 8),
                _buildCategorySelector(colorScheme),
                const SizedBox(height: 20),

                // Selector de importancia
                _buildSectionTitle('Importancia'),
                const SizedBox(height: 8),
                _buildImportanceSelector(colorScheme),
                const SizedBox(height: 20),

                // Selector de repetición
                _buildSectionTitle('Repetición'),
                const SizedBox(height: 8),
                _buildRepeatSelector(colorScheme),
                // Selector de días específicos (solo si es custom)
                if (_selectedRepeatType == RepeatType.custom) ...[
                  const SizedBox(height: 10),
                  _buildDaySelector(colorScheme),
                ],
                const SizedBox(height: 28),

                // Botones de acción
                _buildActionButtons(context, colorScheme),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, ColorScheme colorScheme) {
    const dayNames = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    const monthNames = ['', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];

    final dayName = dayNames[_selectedDate.weekday - 1];
    final monthName = monthNames[_selectedDate.month];
    final formatted = '$dayName ${_selectedDate.day} de $monthName, ${_selectedDate.year}';

    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) setState(() => _selectedDate = picked);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(formatted, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500))),
            Icon(Icons.arrow_drop_down, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildAllDayToggle(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: SwitchListTile(
        title: const Text('Todo el día', style: TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
          _isAllDay ? 'El evento dura todo el día' : 'Definir hora de inicio y fin',
          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
        ),
        value: _isAllDay,
        onChanged: (value) {
          setState(() {
            _isAllDay = value;
            if (_isAllDay) { _startTime = null; _endTime = null; }
            else { _startTime = const TimeOfDay(hour: 9, minute: 0); _endTime = const TimeOfDay(hour: 10, minute: 0); }
          });
        },
        activeThumbColor: colorScheme.primary,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildTimePickers(BuildContext context, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(child: _buildTimePickerButton(context, label: 'Inicio', time: _startTime, icon: Icons.play_arrow_rounded, colorScheme: colorScheme, onTimePicked: (t) => setState(() => _startTime = t))),
        const SizedBox(width: 12),
        Expanded(child: _buildTimePickerButton(context, label: 'Fin', time: _endTime, icon: Icons.stop_rounded, colorScheme: colorScheme, onTimePicked: (t) => setState(() => _endTime = t))),
      ],
    );
  }

  Widget _buildTimePickerButton(BuildContext context, {required String label, required TimeOfDay? time, required IconData icon, required ColorScheme colorScheme, required ValueChanged<TimeOfDay> onTimePicked}) {
    final timeStr = time != null ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}' : '--:--';
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(context: context, initialTime: time ?? const TimeOfDay(hour: 9, minute: 0));
        if (picked != null) onTimePicked(picked);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
        child: Row(children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
            Text(timeStr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ]),
        ]),
      ),
    );
  }

  Widget _buildColorPicker() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: AppTheme.eventColors.length,
        itemBuilder: (context, index) {
          final color = AppTheme.eventColors[index];
          final isSelected = _selectedColor.toARGB32() == color.toARGB32();
          return GestureDetector(
            onTap: () => setState(() => _selectedColor = color),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: color, shape: BoxShape.circle,
                border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                boxShadow: isSelected ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 2)] : null,
              ),
              child: isSelected ? const Icon(Icons.check_rounded, color: Colors.white, size: 22) : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategorySelector(ColorScheme colorScheme) {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: EventCategory.values.map((cat) {
          final sel = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              avatar: Icon(cat.icon, size: 16, color: sel ? colorScheme.onPrimary : colorScheme.primary),
              label: Text(cat.label, style: TextStyle(fontSize: 12, color: sel ? colorScheme.onPrimary : colorScheme.onSurfaceVariant)),
              selected: sel,
              onSelected: (_) => setState(() => _selectedCategory = cat),
              selectedColor: colorScheme.primary,
              checkmarkColor: colorScheme.onPrimary,
              backgroundColor: colorScheme.surfaceContainerHighest,
            ),
          );
        }).toList(),
      ),
    );
  }

  // Selector de importancia con colores
  Widget _buildImportanceSelector(ColorScheme colorScheme) {
    return Row(
      children: EventImportance.values.map((imp) {
        final sel = _selectedImportance == imp;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => setState(() => _selectedImportance = imp),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? imp.color.withValues(alpha: 0.2) : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: sel ? imp.color : colorScheme.outline.withValues(alpha: 0.3),
                    width: sel ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(imp.icon, size: 20, color: sel ? imp.color : colorScheme.onSurfaceVariant),
                    const SizedBox(height: 4),
                    Text(
                      imp.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                        color: sel ? imp.color : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Selector de tipo de repetición (solo ese día / semanal / días específicos)
  Widget _buildRepeatSelector(ColorScheme colorScheme) {
    return SegmentedButton<RepeatType>(
      segments: RepeatType.values.map((type) {
        return ButtonSegment<RepeatType>(
          value: type,
          label: Text(type.label, style: const TextStyle(fontSize: 11)),
          icon: Icon(
            type == RepeatType.single ? Icons.looks_one_rounded
                : type == RepeatType.weekly ? Icons.repeat_rounded
                : Icons.date_range_rounded,
            size: 18,
          ),
        );
      }).toList(),
      selected: {_selectedRepeatType},
      onSelectionChanged: (sel) {
        setState(() {
          _selectedRepeatType = sel.first;
          if (_selectedRepeatType != RepeatType.custom) _selectedRepeatDays = [];
        });
      },
    );
  }

  // Selector de días específicos de la semana
  Widget _buildDaySelector(ColorScheme colorScheme) {
    return Wrap(
      spacing: 6,
      children: weekdayLabels.entries.map((entry) {
        final selected = _selectedRepeatDays.contains(entry.key);
        return FilterChip(
          label: Text(entry.value, style: TextStyle(
            fontSize: 12,
            color: selected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
          )),
          selected: selected,
          onSelected: (val) {
            setState(() {
              if (val) { _selectedRepeatDays.add(entry.key); }
              else { _selectedRepeatDays.remove(entry.key); }
            });
          },
          selectedColor: colorScheme.primary,
          checkmarkColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.surfaceContainerHighest,
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons(BuildContext context, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
            label: const Text('Cancelar'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: _saveEvent,
            icon: const Icon(Icons.check_rounded),
            label: const Text('Guardar'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  void _saveEvent() {
    if (_formKey.currentState?.validate() ?? false) {
      final event = CalendarEvent(
        id: widget.existingEvent?.id ?? const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        date: _selectedDate,
        startTime: _isAllDay ? null : _startTime,
        endTime: _isAllDay ? null : _endTime,
        color: _selectedColor,
        category: _selectedCategory,
        repeatType: _selectedRepeatType,
        repeatDays: _selectedRepeatType == RepeatType.custom ? _selectedRepeatDays : [],
        importance: _selectedImportance,
      );
      Navigator.pop(context, event);
    }
  }
}
