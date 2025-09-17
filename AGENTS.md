# SistemaTicketsyEDIs – Guía para agentes

## Comandos obligatorios antes de finalizar cambios
1. `dart format .`
2. `flutter test`
3. `flutter build apk`
4. `flutter build ipa`

> Ejecuta todos los comandos en ese orden y documenta los resultados en la sección **Testing** del mensaje final.

## Reglas para Pull Requests
- Incluye un resumen por viñetas y una sección de pruebas ejecutadas.
- Menciona cualquier limitación relevante o seguimiento pendiente.
- Mantén la rama principal limpia; no crees ramas adicionales desde aquí.

## Estilo y convenciones
- Usa `flutter_lints` y respeta `dart format`.
- Prefiere arquitectura *feature-first* y principios Clean cuando apliquen.
- Interfaces de usuario con Material 3, tema claro/oscuro.
- Documenta el código crítico con comentarios breves cuando sea necesario.

## Notas
- Los cambios deben dejar el repositorio en estado limpio (`git status` sin modificaciones pendientes).
- Si algún comando falla por restricciones del entorno, repórtalo de forma explícita.
