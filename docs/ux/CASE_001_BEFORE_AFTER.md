# Caso 001 — Comparación antes/después de 11R

2026-10-29. Antes: ca0d75f, incluida su corrección UX. Después: implementación local 11R. Se compara con la última versión entregada, no con una versión inicial más difícil.

## Operaciones concretas

Un paso es activar un control con intención: abrir un selector y escoger un elemento son dos pasos. Se excluyen lectura, scroll, ayuda voluntaria, teclado/gestos equivalentes y reanudación. Los siguientes son conteos de procedimientos concretos a partir de controles reales; no son tiempos humanos ni un mínimo universal para cualquier orden de exploración.

| Procedimiento y punto de partida | Antes | 11R | Qué cambia |
| --- | --- | --- | --- |
| Desde N05 hasta mostrar ficha N08 | 3: comprobar, consultar, abrir | 1: Verificar establecimiento | Consultas repetidas agrupadas atómicamente |
| Desde ficha N08 hasta confirmar Q01 y volver al centro de llamada | 8: guardar, abrir expediente, desplegar hipótesis, escogerla, seleccionar dos fichas, comprobar, regresar | 3: Examinar contradicción, elegir conclusión, retomar | Se elimina el formulario de selección exacta en la enseñanza |
| Desde centro con fuentes de Q02 disponibles hasta interpretarlas y regresar | 8: expediente, selector, hipótesis, tres fichas, comprobar, regresar | 3: Interpretar peligro, elegir conclusión, retomar | La decisión es interpretar fuentes mostradas |
| Desde centro tras Q01 hasta examinar G01.S02/Voces y regresar | 6: Audio, grabación, filtro, segmento, leer, regresar | 3: acción de registro de golpes, examinar, retomar | No hay selección técnica sin diferencia perceptible |
| Escoger y confirmar acceso, con consulta ya abierta | 2 | 2 | La corrección anterior ya había simplificado estos pasos; 11R cambia el acceso y hace opcional el plano |
| Desde N22 hasta preparar instrucción N24 | 2 | 1 | La petición de Clara N23 se presenta junto a la preparación |
| Atender la llamada | 1 | 1 | Se conserva la mejora anterior |

La primera deducción no se concede por abrirla. El jugador debe interpretar. Q02 sigue siendo opcional para llegar a un cierre y necesaria para A según las reglas anteriores; el tutorial no la concede. No se cambia la dificultad mediante un final favorable automático.

## Pantallas y navegación

| Aspecto | Antes | 11R |
| --- | --- | --- |
| Estructura oficial | Cuatro secciones con pestañas permanentes | Una superficie de comunicación y consultas contextuales |
| Cambios obligatorios mediante pestañas | Necesarios para herramientas o accesos equivalentes del objetivo | Cero: no existe barra de pestañas en campaña |
| Cambios de actividad | Llamada, expediente, audio y mapa | Conversación, razonamiento, registro y operación siguen siendo actividades distintas dentro de la superficie |
| Archivo | Catálogo y selección de hipótesis/fichas | Fuentes pertinentes primero; expediente completo e historial voluntarios |
| Herramientas iniciales | Pestañas bloqueadas visibles | Herramientas futuras ocultas |
| Ayuda | Objetivo global y avisos | Objetivo breve, instrucciones locales y dos ampliaciones voluntarias |
| Elementos fijos | Cabecera, orientación/avisos, barra de acción y navegación | Cabecera de 88 unidades y dos accesos secundarios de 88; al inicio estos últimos no aparecen |

En una ruta de referencia A por testimonio y patio, sin audio opcional, el modelo anterior requiere seis cambios de sección: Llamadas→Expedientes(Q01)→Llamadas→Mapa→Llamadas(parte)→Expedientes(Q02)→Llamadas. Cinco son accesos/retornos explícitos y uno es el regreso del parte. En 11R esas seis transiciones de actividad siguen teniendo una función, pero se abren desde la llamada con el contenido pertinente; no exigen escoger una aplicación o localizar fichas. No se presenta esto como seis actividades eliminadas. Las consultas administrativas agrupadas sí dejan de requerir pantallas intermedias.

La prueba gráfica registra pasos reales en `docs/validation/prompt_11r/<resolución>/ui_route_metrics.json`. Sus rutas incluyen ayudas, cancelación, error intencional, archivo y restauración de QA; no son recorridos mínimos ni partidas de personas. El diálogo nativo de sustitución se reconoce por señal en la prueba y queda identificado en la matriz.

## Narrativa y resultados

- Ningún ID canónico eliminado o renombrado: 38 diálogos, 57 opciones, diez evidencias y cuatro deducciones permanecen en el motor.
- N06/N07 se agrupan en Verificar; N23 se integra en la presentación de N24. Se conservan en el diario e historial para reconstrucción exacta. Controles N02 y duda de protocolo N09 dejan de competir en el recorrido principal; sus principios se presentan en ayuda/contexto y las rutas antiguas siguen siendo restaurables.
- La acción de N08 ya no pide archivar una fuente que su entrada había registrado; ahora abre la contradicción usando los comandos originales.
- Huéspedes, telefonía, plano, preguntas secundarias y rectificación emocional permanecen en Registros o como acción contextual pertinente.
- A: salida comunicada con las condiciones de interpretación, acceso, instrucción y cooperación originales. B: refugio sin confirmación para el resto de entradas válidas. C: apertura de pasillo con cooperación deteriorada, sin confirmar muerte. Se conservan advertencia y corrección del plan.
- No cambian versión/fingerprint de case_001.json ni formatos narrativos; las diferencias de presentación están en experience.json.

## Enseñanza y límites

Se introducen atención, tono de diálogo, registro, razonamiento, consulta textual, inspección y decisión crítica cuando los hechos los justifican. Registros no es una colección por completar. Las instrucciones se consideran vistas tras una interacción pertinente y se guardan en el mismo checkpoint; se pueden releer en Ayuda.

**Comprobable:** menos operaciones en los procedimientos enumerados, apertura directa, ausencia de pestañas oficiales y conservación de decisiones/guardados. **Esperado:** menor búsqueda administrativa y mejor comprensión. **Pendiente:** diversión, ritmo humano, duración real de 8–15 minutos, satisfacción y uso en Android físico. El [protocolo de playtest](CASE_001_PLAYTEST_PLAN.md) permite contrastarlo sin inventar resultados.
