# PULSO MVP - base inicial

Este paquete contiene una primera demo Flutter de PULSO y un esquema SQL inicial para Supabase.

## Qué incluye
- Navegación Inicio / Retos / World / Ranking / Perfil.
- Misiones de ejemplo.
- XP y niveles locales.
- Edición local de apodo y país.
- Ranking y contador WORLD ilustrativos.
- Esquema SQL inicial en `supabase/schema.sql`.

## Qué NO incluye todavía
- Registro real ni inicio de sesión.
- Sincronización entre móviles.
- Rankings reales.
- Validación segura de misiones desde servidor.
- Premios/cupones canjeables.
- Panel administrativo.
- Moderación ni publicación en tiendas.

Los puntos de esta demo se guardan solo en memoria y se reinician al cerrar la app. Los rankings y el contador mundial son datos ficticios de muestra.

## Cómo abrirlo
1. Instalar Flutter SDK y Android Studio (para Android) o Xcode en un Mac (para iOS).
2. Crear el esqueleto de plataforma:
   `flutter create .`
3. Sustituir `pubspec.yaml` y `lib/main.dart` por los de este paquete.
4. Ejecutar:
   `flutter pub get`
   `flutter run`

Para iOS se necesita macOS con Xcode. Para publicar en tiendas hacen falta las cuentas de desarrollador y superar sus revisiones.

## Siguiente paso
Crear un proyecto Supabase, aplicar el esquema SQL después de revisarlo y conectar autenticación, perfiles, misiones y funciones seguras de puntuación. No publicar el esquema en producción sin definir y probar las políticas RLS y permisos.
