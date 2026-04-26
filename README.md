<div align="center">

# 📅 Calendario Semanal (Flutter Web)

Una aplicación web moderna construida con Flutter para gestionar eventos en una vista semanal, totalmente en español y con un diseño limpio y agradable.

<br/>

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-00B4AB?logo=dart)
![Web](https://img.shields.io/badge/Platform-Web-success)

</div>

---

## ✨ Características principales

- Vista semanal (Lunes a Domingo) con navegación entre semanas.
- Animación de deslizamiento al cambiar de semana (fluida y direccional).
- Múltiples eventos simulados en español distribuidos en 3 semanas.
- CRUD completo de eventos:
  - Crear, ver detalle, editar y eliminar.
- Repetición de eventos:
  - Una sola vez ("Solo ese día").
  - Semanal (mismo día cada semana).
  - Días específicos (custom): selecciona Lunes, Sábado, etc.
- Chip de importancia del evento: Baja, Media, Alta (colores distintivos).
- Categorías con íconos: Exámenes, Trabajo, Tarea, Cumpleaños, Otro.
- Soporte de eventos de todo el día o con hora de inicio/fin.
- Interfaz en español; código en inglés/limpio.
- Theming Material 3, Poppins y diseño moderno.

---

## 🧭 Estructura del proyecto

```
lib/
  main.dart                     # Punto de entrada: tema y Provider
  theme/
    app_theme.dart              # Tema Material 3 (colores, tipografías)
  models/
    event_model.dart            # Modelos: CalendarEvent, enums y extensiones
  data/
    sample_events.dart          # Datos simulados (3 semanas)
  providers/
    event_provider.dart         # Estado global con Provider (CRUD, semanas)
  screens/
    weekly_calendar_screen.dart # Pantalla principal con animaciones
  widgets/
    event_card.dart             # Tarjeta compacta del evento
    event_form_dialog.dart      # Diálogo para crear/editar eventos
    event_detail_dialog.dart    # Diálogo de detalles con acciones
web/
  index.html, favicon, etc.     # Entradas web generadas por Flutter
```

---

## 🚀 Puesta en marcha

1) Requisitos
- Flutter 3.x con soporte para Web activado
- Dart SDK 3.x
- Chrome/Edge u otro navegador moderno

2) Instala dependencias
```
flutter pub get
```

3) Ejecuta en modo desarrollo (servidor web)
```
flutter run -d web-server --web-port=8080
```

4) Compila para producción (build web)
```
flutter build web
```
El resultado quedará en `build/web/` listo para desplegar en cualquier hosting estático.

---

## 🧩 Uso de la app

- Botón "Nuevo": crea un evento con título, descripción, ubicación (opcional), fecha, color, categoría, importancia y repetición.
- Toca cualquier evento para ver sus detalles y acceder a Editar/Eliminar.
- Usa las flechas del AppBar para navegar entre semanas.
- El botón "Hoy" vuelve a la semana actual (con animación direccional correcta).

---

## 🧠 Estado y lógica

- `EventProvider` (Provider + ChangeNotifier):
  - Mantiene la lista maestra de eventos y la semana visible.
  - CRUD de eventos (add/update/delete).
  - Filtra eventos por día considerando repetición semanal y por días específicos.
  - Expone `slideDirection` para animaciones (1 → siguiente, -1 → anterior).

- `CalendarEvent`:
  - Campos: id, title, description, location?, date, start/end time?, color, category, repeatType, repeatDays[], importance.
  - `RepeatType.custom` usa `repeatDays` (1=Lun ... 7=Dom).

---

## 🎨 UI/UX

- Material 3 + Google Fonts (Poppins).
- Tarjetas de evento con color, hora, ubicación, chip de importancia y badge de repetición.
- Diálogos modernos para crear/editar y para ver detalles.
- Animación de deslizamiento y desvanecido al cambiar de semana.

---

## 🧪 Pruebas

- `test/widget_test.dart`: prueba de humo que valida que la app renderiza y muestra el botón "Nuevo".

---

## 📦 Dependencias relevantes

- provider
- google_fonts
- uuid
- intl (si se requiere formateo adicional)

---

## 💡 Notas

- Este proyecto fue configurado para Web; no se incluyen plataformas móviles nativas.
- Todo el contenido de la interfaz está en español; el código mantiene nombres claros y consistentes.