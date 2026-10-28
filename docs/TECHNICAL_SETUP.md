# Última Señal — Base técnica del PROMPT 03

Fecha: 2026-10-27. Estado: completado en escritorio Windows. Esta fase crea exclusivamente el punto de entrada técnico; no hay un caso jugable ni navegación de menú.

Este documento conserva el resultado de la fase 03. PROMPT 04 adapta esa misma entrada para mostrar menú y consola; consultar [UI_NAVIGATION.md](UI_NAVIGATION.md) para el estado vigente y las pruebas de navegación. Configuración base y comandos de arranque se conservan; el auxiliar bootstrap ahora comprueba el menú autorizado.

## Entorno real

- Motor encontrado y utilizado: **Godot 4.7.2 estable**, salida exacta `4.7.2.stable.official.ed1daf0bf`.
- Ejecutable gráfico existente: `D:\Descargas\Exe\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe`.
- Ejecutable de consola existente: `D:\Descargas\Exe\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`.
- Ruta de trabajo: `D:\Ultima Señal`. No hay repositorio Git inicializado ni en los directorios ascendentes. No se creó uno.
- Renderizado gráfico observado: Compatibility, OpenGL 3.3.0, Intel UHD Graphics, controlador 27.20.100.8984.
- No se instalaron ni actualizaron herramientas, fuentes o recursos externos.

Las propiedades y sus valores admitidos se consultaron en el propio Godot instalado mediante `ProjectSettings.get_property_list()`. Confirmó `canvas_items`, `expand`, `gl_compatibility` y orientación `Portrait` de valor 1. No fue necesario sustituir la versión preferida.

## Configuración aplicada

| Propiedad | Valor |
| --- | --- |
| Nombre visible | Última Señal |
| Denominación interna | `ultima_senal`, usada para el directorio local del motor |
| Escena de entrada | `res://scenes/core/main.tscn` |
| Tamaño base | 720 × 1280 |
| Ventana de desarrollo inicial | 360 × 640, manteniendo el lienzo lógico base |
| Escalado | `canvas_items` con aspecto `expand` |
| Orientación móvil | Portrait, valor 1 |
| Renderizador de escritorio y móvil | `gl_compatibility` |
| Idioma | Textos en español y locale de respaldo `es` |
| Fuente | Fuente incorporada de Godot, sin descargas |

El directorio local configurado identifica archivos internos del motor y sus registros; no implementa guardado de partidas. No hay empresa, dominio, identificador Android definitivo, presets de exportación ni integración comercial.

## Estructura efectiva

```text
D:\Ultima Señal\
├── .gitignore
├── AGENTS.md
├── project.godot
├── assets/
│   └── ui/base_theme.tres
├── scenes/
│   └── core/main.tscn
├── tests/
│   ├── bootstrap_smoke.gd
│   └── bootstrap_smoke.gd.uid
└── docs/
    ├── .gdignore
    ├── documentación de preproducción y reporte Word conservados
    ├── TECHNICAL_SETUP.md
    ├── cases/ con los tres documentos originales sin cambios
    └── validation/prompt_03/ con tres capturas PNG
```

`.godot/` contiene cachés generadas por el motor y queda fuera del control de versiones mediante `.gitignore`. El UID del script de prueba, generado por Godot, se conserva como archivo de identidad del recurso y no se ignora. `docs/.gdignore` evita importar documentación y capturas como recursos del juego.

Se crearon únicamente directorios con archivos necesarios. Las carpetas `scenes/screens`, `scenes/components`, `scripts/core`, `scripts/systems`, `scripts/ui`, `data/cases`, `data/config`, `assets/fonts`, `assets/images` y `assets/audio` se incorporarán cuando una fase autorizada necesite contenido real. No hay archivos vacíos ni implementaciones anticipadas para reservar esos lugares.

## Escena y estilo compartido

`main.tscn` tiene una raíz Control a pantalla completa, un fondo y un MarginContainer con VBoxContainer. Dos espacios expansibles centran el panel entre cabecera y pie. El panel se ajusta a su contenido; sus etiquetas permiten ajuste de línea. Las posiciones de los textos se resuelven por contenedores, no por coordenadas absolutas.

La pantalla muestra «ÚLTIMA SEÑAL», «CENTRAL DE EMERGENCIAS», «Puerto Umbral, 1998.», «Prototipo técnico» e «Inicialización realizada correctamente.». No tiene botones, casos, llamadas, audio, expedientes ni guardado. La escena no lleva scripts de ejecución; su contenido está declarado en nodos.

El recurso Theme centraliza fondo oscuro, paneles verde petróleo, bordes, ámbar, texto, tamaños y separación de contenedores. Las variaciones se limitan a los elementos que esta pantalla necesita. Los textos son propiedades individuales de Label, sin concatenaciones; podrán incorporarse a localización posteriormente, sin construir aquí un sistema de traducción.

## Comandos reproducibles de verificación

Ejecutar en PowerShell. La ruta del motor corresponde a la instalación encontrada; puede cambiar en otra computadora.

```powershell
$godotExecutable = 'D:\Descargas\Exe\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
```

Versión e importación:

```powershell
& $godotExecutable --version
& $godotExecutable --headless --path 'D:\Ultima Señal' --import
```

Arranque de la aplicación por la escena configurada, sin usar el script de prueba:

```powershell
& $godotExecutable --headless --path 'D:\Ultima Señal' --quit-after 10
& $godotExecutable --path 'D:\Ultima Señal' --quit-after 30
```

Pruebas de configuración y geometría:

```powershell
& $godotExecutable --headless --path 'D:\Ultima Señal' --script res://tests/bootstrap_smoke.gd -- 720x1280
& $godotExecutable --headless --path 'D:\Ultima Señal' --script res://tests/bootstrap_smoke.gd -- 1080x1920
& $godotExecutable --headless --path 'D:\Ultima Señal' --script res://tests/bootstrap_smoke.gd -- 1080x2400
```

Capturas mediante renderizado real, sin `--headless`:

```powershell
& $godotExecutable --path 'D:\Ultima Señal' --script res://tests/bootstrap_smoke.gd -- 720x1280 'D:\Ultima Señal\docs\validation\prompt_03\720x1280.png'
& $godotExecutable --path 'D:\Ultima Señal' --script res://tests/bootstrap_smoke.gd -- 1080x1920 'D:\Ultima Señal\docs\validation\prompt_03\1080x1920.png'
& $godotExecutable --path 'D:\Ultima Señal' --script res://tests/bootstrap_smoke.gd -- 1080x2400 'D:\Ultima Señal\docs\validation\prompt_03\1080x2400.png'
```

El script solo verifica el arranque: configuración, carga de escena/Theme, textos necesarios, límites y altura de etiquetas, ausencia de botones y scripts de juego, tamaño real de ventana y dimensiones del lienzo y captura. No añade comportamiento al juego ni ejecuta sistemas narrativos.

## Resultados observados

| Verificación | Resultado real |
| --- | --- |
| Detección y versión | Coincide con Godot 4.7.2 estable preferido; consola operativa |
| Importación | Salida 0, editor headless carga el proyecto; sin errores de recursos o scripts reportados |
| Inicio directo headless | Salida 0, sin errores críticos reportados |
| Inicio directo gráfico | Salida 0, renderer Compatibility confirmado |
| Pruebas headless | Las tres salidas 0 y `PASS bootstrap_smoke` |
| Pruebas gráficas | Las tres salidas 0 y `PASS bootstrap_smoke`; capturas generadas con sus dimensiones solicitadas |
| Inspección de las capturas | Textos completos, sin superposición ni recortes visibles en las tres resoluciones |

| Ventana y captura | Lienzo lógico observado | Evidencia |
| --- | --- | --- |
| 720 × 1280 | 720 × 1280 | [Captura base](validation/prompt_03/720x1280.png) |
| 1080 × 1920 | 720 × 1280 | [Captura 16 a 9](validation/prompt_03/1080x1920.png) |
| 1080 × 2400 | 720 × 1600 | [Captura 20 a 9](validation/prompt_03/1080x2400.png) |

Se detectó una limitación de la primera comprobación: el display headless arrancaba con una ventana ficticia de 64 × 64 pese a `--resolution`. No se tomó ese resultado como evidencia de la resolución solicitada. Se corrigió el auxiliar para asignar y verificar explícitamente el tamaño de Window y el lienzo expandido. Las tres pruebas headless y gráficas posteriores verificaron los tamaños reales que figuran en la tabla.

No se detectaron errores críticos pendientes de esta etapa. La configuración no se validó en un dispositivo Android ni equivale a una exportación; quedan pendientes SDK, plantillas de exportación, selección de dispositivos, zonas seguras, rendimiento y ejecución real en sus fases. No se creó APK ni se modificó el Caso 001. No hay menú completo, navegación ni mecánicas de la fase 04 o posteriores.
