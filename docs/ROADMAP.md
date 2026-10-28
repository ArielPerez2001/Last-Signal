# ÚLTIMA SEÑAL — Plan de desarrollo

Actualizado: 2026-10-28. Las fases son planificación y no autorizan ejecución. Cada prompt posterior delimita el trabajo; una etapa puede requerir varios prompts.

Estados permitidos: **pendiente**, **en proceso**, **bloqueado**, **completado**. Una dependencia futura no convierte por sí sola una fase en bloqueada. Las etapas 00–08 están completadas. Llamadas y Expedientes comparten una investigación de prueba con motor y guardado aislado; menú/navegación se conservan, Continuar sigue deshabilitado y no hay Caso 001 jugable. PROMPT 09 requiere autorización explícita.

## 00. Contexto maestro

- **Objetivo:** establecer visión, restricciones y metodología.
- **Dependencias:** ninguna.
- **Entregables:** contexto del PROMPT 00 recibido y comprendido.
- **Aceptación:** confirmar objetivos, sistemas y espera del PROMPT 01 sin iniciar desarrollo.
- **Estado:** completado.

## 01. Documentación

- **Objetivo:** conservar una base documental para continuar entre sesiones.
- **Dependencias:** 00 y autorización del PROMPT 01.
- **Entregables:** `AGENTS.md`, `docs/GDD.md`, `docs/STORY_BIBLE.md`, `docs/ROADMAP.md`, `docs/PROGRESS.md` y `docs/DECISIONS.md`.
- **Aceptación:** documentos consistentes, hechos y propuestas diferenciados, inspección y validación registradas, sin código ni instalaciones.
- **Estado:** completado.

## 02. Diseño completo del Caso 001

- **Objetivo:** definir un caso investigable y coherente dentro del MVP.
- **Dependencias:** 01 y autorización explícita de la fase.
- **Entregables:** diseño de conversaciones, pistas, sonidos, registros, deducciones, despacho, eventos críticos y tres resultados con sus condiciones.
- **Aceptación:** recorridos razonados hacia los tres resultados, información suficiente para las decisiones y continuidad revisada con el usuario.
- **Estado:** completado. Diseño y revisión documental realizados en 02; aprobación del usuario expresa al iniciar PROMPT 03, registrada en D-017. Entregables originales conservados: [diseño](cases/CASE_001_DESIGN.md), [especificación](cases/CASE_001_TECHNICAL_SPEC.md) y [pruebas](cases/CASE_001_TEST_PLAN.md).

## 03. Proyecto Godot

- **Objetivo:** establecer la base técnica ejecutable.
- **Dependencias:** 02 y selección explícita de una versión estable de Godot 4.x.
- **Entregables:** proyecto del motor, estructura inicial documentada y configuración base 2D vertical para Android.
- **Aceptación:** apertura y ejecución inicial sin errores en el entorno disponible; versión y procedimiento reproducible registrados.
- **Estado:** completado. Godot 4.7.2 estable; importación, inicio directo, pruebas headless y revisión gráfica en tres resoluciones correctos. Procedimientos y límites de esta base en [TECHNICAL_SETUP.md](TECHNICAL_SETUP.md). Android queda pendiente de sus fases.

## 04. Navegación e interfaz base

- **Objetivo:** disponer del menú y la consola con navegación táctil.
- **Dependencias:** 03.
- **Entregables:** interfaz base, navegación entre secciones y adaptación a resoluciones acordadas.
- **Aceptación:** recorridos de navegación sin bloqueos y lectura e interacción verificadas en las resoluciones seleccionadas.
- **Estado:** completado. Menú, consola, cuatro pestañas y pantallas informativas funcionales; pruebas de configuración/navegación y revisión gráfica en cuatro tamaños. Componentes, comandos, capturas y límites de esta fase en [UI_NAVIGATION.md](UI_NAVIGATION.md).

## 05. Motor narrativo

- **Objetivo:** interpretar datos narrativos separados de la interfaz.
- **Dependencias:** 02, 03 y base de navegación de 04.
- **Entregables:** esquema de contenido, evaluación de condiciones, transiciones y validación de referencias.
- **Aceptación:** recorridos reproducibles y detección de referencias o condiciones inválidas con datos de comprobación.
- **Estado:** completado. Núcleo independiente, esquema JSON 1, transacciones, condiciones/efectos, eventos, finales y reinicio; 485 comprobaciones de núcleo y regresión de interfaz correctas. API, esquema, correspondencia con preproducción y ampliación de restauración en [NARRATIVE_ENGINE.md](technical/NARRATIVE_ENGINE.md). La persistencia se añade en 06; integración jugable del Caso 001 pendiente.

## 06. Estado y guardado

- **Objetivo:** centralizar el estado y conservar progreso local.
- **Dependencias:** 05 y definición de los datos persistentes.
- **Entregables:** estado del juego, guardado versionado y carga local.
- **Aceptación:** guardar, cerrar y recuperar un estado representativo; comportamiento documentado ante ausencia o invalidez del archivo.
- **Estado:** completado. Formato 1 en user://, temporal verificado, respaldo válido anterior, recuperación sin sobrescribir originales, importación transaccional, autoguardado y ciclo de vida opcional. Pruebas de disco, procesos separados y regresión anteriores correctas; API, garantías y límites en [SAVE_SYSTEM.md](technical/SAVE_SYSTEM.md). En 07 se conecta a una demo aislada; sin integración oficial al menú/Caso 001 ni pruebas Android.

## 07. Llamadas

- **Objetivo:** implementar conversaciones con consecuencias.
- **Dependencias:** 04, 05 y 06.
- **Entregables:** interfaz de llamadas y comportamiento de confianza, estrés y cooperación según el diseño aprobado.
- **Aceptación:** opciones, cambios de información y estados coinciden con recorridos esperados y pueden persistirse.
- **Estado:** completado. Controlador de cinco estados, sección Llamadas conectada al motor, opciones por ID/revisión, historial derivado y guardado aislado. Dos rutas de demostración y recuperación correctas; regresión anterior y GUI en cuatro resoluciones, con 40 capturas reales de 07. API, acceso y ampliación de investigación de 08 en [CALL_SYSTEM.md](technical/CALL_SYSTEM.md). Sin campaña/Caso 001.

## 08. Pistas y deducciones

- **Objetivo:** permitir investigar y conectar evidencia.
- **Dependencias:** 02, 04, 05, 06 y 07.
- **Entregables:** expediente, consulta de pistas y evaluación de hipótesis y deducciones.
- **Aceptación:** reproducir deducciones válidas, incompletas y equivocadas según reglas aprobadas y conservar sus estados.
- **Estado:** completado. Catálogo esquema 2, cinco categorías centrales, expediente de fichas descubiertas, detalle/procedencia, selección de dos y reglas de conjunto exacto. Deducciones atómicas con efectos únicos, desbloqueo real de diálogo y formato de guardado 2; lectores originales de esquema/formato 1 conservados. Demo no canónica de cinco pistas/dos conclusiones, 24 grupos de aceptación verificados, regresión previa correcta y 56 capturas reales en cuatro resoluciones. Contratos, procedimientos y límites en [INVESTIGATION_SYSTEM.md](technical/INVESTIGATION_SYSTEM.md). Android y Caso 001 oficial pendientes; fase detenida antes de 09.

## 09. Analizador de audio

- **Objetivo:** descubrir pistas mediante grabaciones y filtros simulados.
- **Dependencias:** 02, 04, 06 y 08.
- **Entregables:** reproducción, selección de fragmentos, filtros simulados y alternativas textuales.
- **Aceptación:** pistas accesibles por los medios aprobados, resultados reproducibles y ausencia de procesamiento avanzado o reconocimiento de voz.
- **Estado:** pendiente.

## 10. Mapa y despacho

- **Objetivo:** asignar recursos limitados y producir consecuencias narrativas.
- **Dependencias:** 02, 04, 05, 06 y 08.
- **Entregables:** mapa básico, ubicaciones, unidades disponibles y reglas de despacho.
- **Aceptación:** disponibilidad y consecuencias coherentes con el diseño, incluidos intentos de asignación no válidos.
- **Estado:** pendiente.

## 11. Integración del Caso 001

- **Objetivo:** conectar los sistemas en un recorrido jugable completo.
- **Dependencias:** 07, 08, 09 y 10, con diseño de 02 aprobado.
- **Entregables:** contenido integrado y recorridos completos hasta los estados de cierre previstos.
- **Aceptación:** llamadas, registros, audio, deducciones, eventos y despacho comparten un estado coherente sin bloqueos de progresión.
- **Estado:** pendiente.

## 12. Resultados y finales

- **Objetivo:** presentar los tres resultados narrativos del Caso 001.
- **Dependencias:** 11 y condiciones aprobadas en 02.
- **Entregables:** resolución, presentación de consecuencias y persistencia del cierre del caso.
- **Aceptación:** cada resultado es alcanzable con un recorrido registrado y responde a sus condiciones aprobadas; no se confunde con el final de campaña.
- **Estado:** pendiente.

## 13. Arte y sonido

- **Objetivo:** consolidar la ambientación visual y sonora del MVP.
- **Dependencias:** 11 y 12.
- **Entregables:** recursos optimizados y presentación coherente con 1998, tonos oscuros, verde petróleo y ámbar.
- **Aceptación:** legibilidad y alternativas textuales conservadas, recursos integrados y procedencia o permisos de uso documentados.
- **Estado:** pendiente.

## 14. Calidad y correcciones

- **Objetivo:** estabilizar el MVP antes de su validación Android.
- **Dependencias:** 12 y 13.
- **Entregables:** registro de incidencias, correcciones y resultados de pruebas funcionales, narrativas y de guardado.
- **Aceptación:** recorridos críticos y tres resultados verificados, sin incidencias críticas abiertas según criterios acordados.
- **Estado:** pendiente.

## 15. Android

- **Objetivo:** preparar y verificar la exportación móvil.
- **Dependencias:** 14; requisitos de Android y herramientas definidos y autorizados.
- **Entregables:** configuración de exportación, paquete Android y procedimiento reproducible.
- **Aceptación:** exportación satisfactoria y comprobaciones disponibles registradas; producir un APK no acredita una prueba en dispositivo real.
- **Estado:** pendiente.

## 16. Pruebas en dispositivo

- **Objetivo:** comprobar el MVP en hardware Android real.
- **Dependencias:** 15 y disponibilidad de dispositivos identificados.
- **Entregables:** evidencia de instalación y ejecución, recorridos, incidencias y datos del dispositivo y versión probados.
- **Aceptación:** interacción, audio, guardado, funcionamiento offline y resultados comprobados en los dispositivos acordados; limitaciones declaradas.
- **Estado:** pendiente.

## 17. Balance y experiencia

- **Objetivo:** ajustar comprensión, dificultad y tensión a partir de pruebas.
- **Dependencias:** 16 y observaciones de juego disponibles.
- **Entregables:** ajustes autorizados, revisión de accesibilidad y evaluación de experiencia.
- **Aceptación:** decisiones comprensibles, pistas suficientes y tensión compatible con la investigación; cambios y nueva verificación registrados.
- **Estado:** pendiente.

## 18. Capítulo I

- **Objetivo:** ampliar el MVP hasta los tres casos del capítulo «El turno nocturno».
- **Dependencias:** 17 y aprobación del diseño de los casos restantes del capítulo.
- **Entregables:** capítulo completo y conexiones de continuidad, reutilizando sistemas existentes.
- **Aceptación:** tres casos completos, progresión y persistencia verificadas, sin contradicciones con la biblia narrativa.
- **Estado:** pendiente.

## 19. Capítulos II–V mediante subfases individuales

- **Objetivo:** completar los otros cuatro capítulos de la campaña.
- **Dependencias:** 18; cada subfase requiere diseño y alcance autorizados.
- **Entregables:** cuatro capítulos adicionales, tres casos principales por capítulo y continuidad de campaña.
- **Aceptación:** quince casos principales totales al terminar, conexiones y desenlaces de campaña verificados.
- **Estado:** pendiente.

### 19.1. Capítulo II — Frecuencias muertas

- **Objetivo:** desarrollar el segundo capítulo según diseño aprobado.
- **Dependencias:** 18 y autorización de 19.1.
- **Entregables:** tres casos y sus conexiones con la progresión existente.
- **Aceptación:** recorridos, resoluciones y guardado comprobados; continuidad revisada.
- **Estado:** pendiente.

### 19.2. Capítulo III — Los desaparecidos

- **Objetivo:** desarrollar el tercer capítulo según diseño aprobado.
- **Dependencias:** 19.1 y autorización de 19.2.
- **Entregables:** tres casos y avance documentado del misterio central.
- **Aceptación:** recorridos, resoluciones y guardado comprobados; continuidad revisada.
- **Estado:** pendiente.

### 19.3. Capítulo IV — Protocolo 07

- **Objetivo:** desarrollar el cuarto capítulo según diseño aprobado.
- **Dependencias:** 19.2 y autorización de 19.3.
- **Entregables:** tres casos y conexiones narrativas aprobadas.
- **Aceptación:** recorridos, resoluciones y guardado comprobados; continuidad revisada.
- **Estado:** pendiente.

### 19.4. Capítulo V — Última señal

- **Objetivo:** desarrollar el quinto capítulo y cerrar la campaña según diseño aprobado.
- **Dependencias:** 19.3 y autorización de 19.4.
- **Entregables:** tres casos y desenlaces de campaña aprobados.
- **Aceptación:** resoluciones y consecuencias acumuladas verificadas; cierre narrativo coherente con los capítulos anteriores.
- **Estado:** pendiente.

## 20. Monetización

- **Objetivo:** decidir un modelo comercial compatible con el producto aprobado.
- **Dependencias:** 19 y decisión explícita del usuario sobre el modelo.
- **Entregables:** decisión documentada y, únicamente si se autoriza, implementación correspondiente.
- **Aceptación:** modelo y alcance aprobados y comprobados según corresponda; no se incorporan publicidad ni compras al MVP por esta planificación.
- **Estado:** pendiente.

## 21. Preparación comercial

- **Objetivo:** preparar materiales y requisitos de distribución.
- **Dependencias:** 20 y definición del canal de distribución.
- **Entregables:** ficha, materiales comerciales y requisitos aplicables revisados para el canal elegido.
- **Aceptación:** materiales y versión candidata revisados por el usuario; sin publicación implícita.
- **Estado:** pendiente.

## 22. Publicación

- **Objetivo:** distribuir la versión aprobada.
- **Dependencias:** 21 y autorización explícita para publicación y operaciones externas necesarias.
- **Entregables:** versión distribuida y registro del proceso en el canal elegido.
- **Aceptación:** disponibilidad verificada y versión publicada identificada, con las autorizaciones correspondientes.
- **Estado:** pendiente.

## 23. Cierre y mantenimiento

- **Objetivo:** conservar continuidad operativa y atender incidencias posteriores.
- **Dependencias:** 22 y alcance de mantenimiento acordado.
- **Entregables:** documentación de cierre, incidencias pendientes y plan de mantenimiento.
- **Aceptación:** entregables y responsabilidades acordados; cada trabajo posterior mantiene su autorización específica.
- **Estado:** pendiente.
