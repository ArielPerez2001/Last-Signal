# Última Señal — Interfaz y navegación del PROMPT 04

Actualización de referencia al cerrar PROMPT 08 (2026-10-28): se conservan menú, consola y sus instancias; Llamadas y Expedientes comparten motor/guardado en una demostración de investigación de desarrollo. Expedientes permite filtros, detalle, selección de dos fichas y conclusiones persistentes. F5 → Ingresar → Llamadas → Prueba de investigación → Responder. Audio/Mapa siguen vacíos y Continuar deshabilitado. Consultar [CALL_SYSTEM.md](technical/CALL_SYSTEM.md) e [INVESTIGATION_SYSTEM.md](technical/INVESTIGATION_SYSTEM.md) para acceso, contratos y capturas actuales; el resto de este documento conserva el registro histórico de 04.

Fecha: 2026-10-27. Estado: completado en escritorio con Godot 4.7.2 estable. El usuario aprobó 00–03 y autorizó únicamente una interfaz navegable. No existe todavía una partida ni un caso ejecutable.

## Integración conservada

Se conserva `scenes/core/main.tscn` como única entrada de `project.godot`, con la misma raíz Control, fondo y Theme compartido de 03. Se sustituye su pantalla estática de inicialización por las vistas del menú, consola e información. No se crea otra aplicación ni una segunda escena de arranque.

La configuración de Godot y `.gitignore` se conservan sin cambios de contenido: base 720 × 1280, Portrait, `canvas_items`/`expand`, ventana de desarrollo 360 × 640, Compatibility en escritorio/móvil y español. El GDD solo actualiza sus dos menciones de estado técnico; no cambia diseño ni historia. STORY_BIBLE, documentos del Caso 001 y reporte Word de 02 permanecen intactos.

## Archivos de interfaz

| Escena | Responsabilidad |
| --- | --- |
| `scenes/core/main.tscn`, modificada | Raíz existente; hospeda las tres vistas y un margen seguro común |
| `scenes/screens/main_menu.tscn` | Identidad, acceso a consola, Continuar deshabilitado, Configuración y Créditos |
| `scenes/screens/dispatch_console.tscn` | Distribuye cabecera fija, contenido desplazable y navegación inferior fija |
| `scenes/screens/sections/calls_panel.tscn` | Estado vacío de comunicaciones; sin llamada ni diálogo |
| `scenes/screens/sections/audio_panel.tscn` | Espacio reservado a audio; sin reproducción ni filtros |
| `scenes/screens/sections/map_panel.tscn` | Espacio reservado a Puerto Umbral; sin localizaciones ni despacho |
| `scenes/screens/sections/evidence_panel.tscn` | Espacio reservado a expedientes; sin pruebas o documentos jugables |
| `scenes/components/console_header.tscn` | Central, ubicación, año, hora estática y regreso al menú |
| `scenes/components/bottom_navigation.tscn` | Cuatro botones con icono, etiqueta y marca textual de sección activa |
| `scenes/components/module_placeholder.tscn` | Composición compartida de los cuatro estados vacíos |
| `scenes/components/information_panel.tscn` | Pantalla reutilizada para Configuración y Créditos |

Los diez archivos de pantalla/componente son nuevos. La raíz y el Theme son adaptaciones de los recursos existentes.

| Script nuevo en `scripts/ui/` | Función limitada a presentación |
| --- | --- |
| `navigation_controller.gd` | Vistas de menú, consola y pantallas informativas; regreso y restauración del foco |
| `main_menu.gd` | Señales de sus tres acciones disponibles y orden de foco; Continuar permanece deshabilitado |
| `dispatch_console.gd` | Selecciona un único panel y restablece Llamadas al ingresar |
| `bottom_navigation.gd` | Selección de botón y marca ACTIVA; emite el ID de sección |
| `information_panel.gd` | Título, texto y regreso de la pantalla informativa |
| `module_placeholder.gd` | Asigna textos e icono de cada estado vacío, sin datos de juego |
| `safe_area.gd` | Márgenes comunes y adaptación al área segura informada por Android |

Se añadió `tests/navigation_smoke.gd` y se adaptó `tests/bootstrap_smoke.gd`. Godot genera sus UID y los de los nuevos scripts; se conservan junto a sus fuentes. Los cuatro SVG en `assets/ui/icons/` son dibujos propios creados para esta interfaz, sin descargas o licencias de terceros. Sus metadatos `.svg.import` se generan mediante Godot; la caché permanece en `.godot/`.

## Flujo implementado

```text
Menú principal
├── Ingresar a la central → Consola → Llamadas
│   ├── Llamadas ↔ Audio ↔ Mapa ↔ Expedientes
│   └── Menú o retroceso → Menú principal
├── Continuar → deshabilitado y sin acción
├── Configuración → pantalla informativa → Volver o retroceso → Menú
└── Créditos → pantalla informativa → Volver o retroceso → Menú
```

Las cuatro secciones se instancian una vez al cargar la consola y se muestran u ocultan; cambiar pestaña no crea más instancias. No hay autoloads, pila global de escenas, datos narrativos o persistencia. Al reingresar a la consola se selecciona Llamadas, independientemente de la pestaña anterior.

La cabecera muestra **02:17 AM** y **1998** como textos fijos. No consulta el reloj real ni inicia una emergencia. Configuración informa que las preferencias no están disponibles y no muestra controles falsamente activos. Créditos solo muestra el título y descripción confirmados, junto a la ausencia de autoría registrada; no atribuye el juego a personas o empresas.

## Interacción y accesibilidad

- Ratón: clic real sobre botones. Las pruebas envían eventos GUI, sin sustituirlos por emisiones directas de señales.
- Táctil: botones nativos de Godot y su conversión de toque a ratón; se comprobó con InputEventScreenTouch simulado en el motor de escritorio, sin atribuirlo a un dispositivo real.
- Teclado: Tab recorre Ingresar, Configuración y Créditos, omitiendo Continuar; flechas recorren la barra; Enter activa; Escape vuelve al nivel anterior.
- Retroceso del sistema: `NOTIFICATION_WM_GO_BACK_REQUEST` vuelve al menú desde consola o información. En el menú no cierra la aplicación. Se desactiva `quit_on_go_back`; cerrar la ventana de escritorio mantiene el comportamiento normal del motor.
- Foco: al cerrar información se restaura su botón de origen; al salir de consola se restaura Ingresar. El borde ámbar muestra el foco.
- Pestaña activa: botón pulsado, borde y texto ACTIVA. No depende solo del color.
- Objetivos táctiles: acciones de 96 unidades lógicas de alto, barra de 112 y botón Menú de al menos 88. Con ventana de escritorio 360 × 640 equivalen respectivamente a 48, 56 y 44 píxeles de alto; no son mediciones de densidad Android.
- Menú, información y contenido de consola permiten scroll vertical cuando hace falta; el scroll horizontal está deshabilitado. Cabecera y barra están fuera del ScrollContainer del contenido y no lo cubren.
- Márgenes: 32 unidades laterales y 24 verticales, más los recortes seguros comunicados por Android, convertidos a coordenadas lógicas. La rama nativa de Android sigue pendiente de verificación en hardware.

Los cambios de vista son inmediatos. Se prioriza respuesta y foco estable; no se añaden efectos o animaciones que retrasen el acceso.

## Decisiones visuales

Se amplía `assets/ui/base_theme.tres`, manteniendo un único Theme. La paleta parte de los valores aprobados en PROMPT 04: fondo #101B1A, superficies #182724/#20342F, verde #72CAA3, ámbar #DDAA63, texto #E7EEE9 y secundario #9AADA4. No se representa un estado crítico falso para utilizar rojo.

Se mantienen fuente incorporada, paneles oscuros, bordes sutiles y jerarquía tipográfica. Los iconos tienen etiqueta visible. La barra inferior queda reservada a navegación; las superficies vacías no aparentan mapas, grabaciones o expedientes cargados. Los SVG se rasterizan desde una fuente de 128 × 128 para mantener nitidez en las resoluciones probadas.

## Pruebas ejecutadas

Motor: `4.7.2.stable.official.ed1daf0bf`. Renderizado real observado: Windows, Compatibility, OpenGL 3.3.0, Intel UHD Graphics. La importación y las pruebas definitivas terminaron sin errores críticos reportados.

| Prueba del PROMPT 04 | Resultado comprobado |
| --- | --- |
| 01 Arranque | La escena de entrada muestra el menú |
| 02 Entrada | Ingresar abre la consola con Llamadas |
| 03 Audio | Cambia a Análisis de señal |
| 04 Mapa | Cambia a Mapa operativo |
| 05 Expedientes | Cambia a Archivo de investigación |
| 06 Repetición | Ocho vueltas completas, 32 cambios adicionales, sin duplicaciones; 106 nodos descendientes del raíz antes y después del flujo |
| 07 Regreso | Botón Menú, Escape y notificación de retroceso vuelven; reingreso abre Llamadas |
| 08 Configuración | Abre, cierra y restaura foco; un texto largo introducido solo por la prueba verifica scroll y acceso al botón de regreso |
| 09 Créditos | Abre/cierra y comunica ausencia de autoría registrada |
| 10 Continuar | Deshabilitado, sin navegación y excluido del ciclo de foco |
| 11 Adaptabilidad | Cuatro resoluciones; barra visible, sin scroll horizontal ni recortes visibles en las capturas |
| 12 Integridad | Importación, arranque, configuración, referencias y auxiliares de prueba correctos |

| Ventana | Lienzo lógico | Arranque headless | Navegación headless | Navegación gráfica |
| --- | --- | --- | --- | --- |
| 720 × 1280 | 720 × 1280 | PASS | PASS | PASS |
| 1080 × 1920 | 720 × 1280 | PASS | PASS | PASS |
| 1080 × 2400 | 720 × 1600 | PASS | PASS | PASS |
| 720 × 1600 | 720 × 1600 | PASS | PASS | PASS |

Se conservaron **28 capturas**, siete vistas por resolución, en `docs/validation/prompt_04/`. Se inspeccionaron menú, configuración, créditos y los cuatro módulos en cada tamaño. No se declara revisión visual a partir de headless.

Evidencias base: [Menú](validation/prompt_04/720x1280/menu.png), [Llamadas](validation/prompt_04/720x1280/calls.png), [Audio](validation/prompt_04/720x1280/audio.png), [Mapa](validation/prompt_04/720x1280/map.png), [Expedientes](validation/prompt_04/720x1280/evidence.png), [Configuración](validation/prompt_04/720x1280/settings.png), [Créditos](validation/prompt_04/720x1280/credits.png).

### Comandos reproducibles

En PowerShell, con el ejecutable existente:

```powershell
$godotExecutable = 'D:\Descargas\Exe\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
& $godotExecutable --headless --path 'D:\Ultima Señal' --import
& $godotExecutable --headless --path 'D:\Ultima Señal' --quit-after 10
& $godotExecutable --path 'D:\Ultima Señal' --quit-after 30
```

Ejecutar estas pruebas para cada tamaño de la tabla, sustituyendo `720x1280`:

```powershell
& $godotExecutable --headless --path 'D:\Ultima Señal' --script res://tests/bootstrap_smoke.gd -- 720x1280
& $godotExecutable --headless --path 'D:\Ultima Señal' --script res://tests/navigation_smoke.gd -- 720x1280
& $godotExecutable --path 'D:\Ultima Señal' --script res://tests/navigation_smoke.gd -- 720x1280 'D:\Ultima Señal\docs\validation\prompt_04\720x1280'
```

Sin segundo argumento de usuario, navegación no toma capturas. Con directorio de destino, requiere renderizador gráfico y guarda los siete PNG con sus dimensiones físicas verificadas.

### Incidencias corregidas

1. El auxiliar SceneTree necesitó referirse a la notificación de retroceso como constante de Node; se corrigió el error de análisis antes de aceptar la prueba.
2. El recorrido Tab inicial no omitía correctamente el botón deshabilitado. Se excluyó Continuar del foco y se fijó un ciclo explícito entre las tres acciones disponibles; Tab, flechas y Enter pasaron después.
3. Una prueba gráfica de 720 × 1600 mostró selecciones no aplicadas. Se ajustó la inyección del auxiliar para actualizar la posición del puntero y enviar pulsación/liberación sin ceder un frame entre ambas. Se repitió esa resolución y después el recorrido gráfico completo en las cuatro; todas las ejecuciones definitivas pasaron. No se eliminó ninguna aserción de selección.
4. Se ajustaron los colores de foco/hover de la acción principal para conservar texto oscuro sobre verde y se aumentó la resolución de importación de los iconos propios.

Las aserciones de configuración de 03 se conservan en bootstrap. Solo se sustituyen sus expectativas de pantalla estática y ausencia de botones/scripts por las del menú autorizado; las pruebas nuevas cubren el comportamiento añadido.

## Límites y preparación de PROMPT 05

No se implementaron motor narrativo, casos, diálogos, evidencias, deducciones, audio, mapa operativo, despacho, guardado, publicidad, compras o servicios en línea. Ingresar abre una interfaz vacía; no inicia el Caso 001. No hay APK ni pruebas en teléfono.

Quedan pendientes Android real, recortes seguros del fabricante, retroceso físico/gestual, densidad táctil, lector de pantalla y rendimiento móvil. El texto de créditos necesita autoría confirmada para poder ampliarse. Las preferencias continúan no disponibles.

Para PROMPT 05, las vistas ya están separadas del controlador de navegación. El futuro motor podrá entregar contenido al panel correspondiente sin reemplazar la raíz o la barra; sus datos, condiciones y efectos deberán respetar la especificación aprobada del caso. No se crea aquí ese motor ni un contrato de eventos adicional. **PROMPT 05 requiere autorización nueva.**
