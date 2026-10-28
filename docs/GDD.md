# ÚLTIMA SEÑAL — Documento de diseño

Fecha de registro: 2026-10-27. Actualización técnica: 2026-10-28, PROMPT 08. Estado: diseño del Caso 001 aprobado; base técnica, navegación, motor/guardado, conversaciones e investigación con demos de desarrollo implementados. Caso 001 sin integrar.

## 1. Identidad y concepto aprobados

**Última Señal** es un thriller narrativo de misterio, investigación y suspenso psicológico. El jugador interpreta a un operador de emergencias durante el turno nocturno de una central de comunicaciones en Puerto Umbral, ciudad costera ficticia, en 1998.

Los primeros acontecimientos deben ser creíbles como investigación criminal: desapariciones, amenazas, accidentes, personas atrapadas y solicitudes de auxilio. Gradualmente aparecen comunicaciones anómalas, contradicciones temporales y grabaciones imposibles. La historia central se relaciona con un incidente de 1981, Estación Nadir y Proyecto ECO. Sus explicaciones permanecen pendientes; consultar [la biblia narrativa](STORY_BIBLE.md).

## 2. Formato y público

| Aspecto | Requisito aprobado |
| --- | --- |
| Plataforma principal | Android |
| Motor | Godot 4.7.2 estable, GDScript y renderizador Compatibility |
| Lenguaje | GDScript |
| Presentación | 2D, principalmente interfaces interactivas |
| Orientación | Vertical |
| Idioma inicial | Español |
| Modalidad | Un jugador, offline |
| Complejidad objetivo | Media, desarrollo modular |

Público objetivo **propuesto, pendiente de aprobación**: personas que disfrutan del misterio narrativo, la observación y la resolución razonada de problemas en móvil. No se ha fijado edad objetivo, clasificación por edades ni duración de las sesiones.

## 3. Experiencia del jugador

Generar misterio, tensión y curiosidad mediante información que el jugador pueda observar, revisar y conectar. Las soluciones deben ser razonables; las decisiones deben poder justificarse con la evidencia disponible. El juego no debe depender únicamente de elegir respuestas.

El ciclo previsto combina atender una comunicación, investigar registros y sonidos, consultar pistas, formular deducciones, decidir el despacho y observar consecuencias. El orden y los requisitos del Caso 001 están detallados en [su diseño](cases/CASE_001_DESIGN.md), elaborado en 02 y aprobado por el usuario al iniciar PROMPT 03; su implementación sigue pendiente.

La investigación no tiene presión de tiempo permanente. En eventos críticos, determinadas acciones avanzan el estado de la emergencia. Se prioriza razonar sobre reaccionar rápidamente, evitando interrupciones innecesarias.

## 4. Sistemas principales

### A. Llamadas y conversaciones

Conversaciones ramificadas y opciones con consecuencias. La confianza, el estrés y la cooperación afectan la interacción. Las decisiones alteran información y resultados. Escalas, condiciones y reglas concretas quedan pendientes del diseño e implementación autorizados.

### B. Analizador de audio

Grabaciones predefinidas, selección de fragmentos y filtros simulados para aislar voces o sonidos ambientales y descubrir pistas auditivas. Debe ofrecer alternativas textuales accesibles. No se requiere procesamiento avanzado de señales ni reconocimiento de voz.

### C. Investigación y deducciones

Expedientes por caso, pistas clasificadas, conexiones entre evidencias, hipótesis y conclusiones. El sistema debe contemplar deducciones válidas, incompletas y equivocadas. La lógica y la presentación deben hacer comprensibles las decisiones sin introducir soluciones arbitrarias.

### D. Mapa y despacho

Ciudad dividida en distritos, ubicaciones ficticias y asignación de unidades de emergencia. Algunos recursos tienen disponibilidad limitada y las decisiones de despacho producen consecuencias narrativas. El mapa, las unidades y sus reglas concretas siguen pendientes.

### E. Tiempo y tensión

La tensión depende de eventos críticos y de acciones significativas. Las reglas sobre qué acciones avanzan una emergencia deberán definirse y verificarse en cada caso. No hay una cuenta regresiva global aprobada.

### F. Progresión narrativa

Los casos tienen una resolución inmediata independiente y conexiones con el misterio central. La visión completa contempla documentos y pistas del misterio, desenlaces alternativos, evaluación del desempeño y expedientes desbloqueables. La selección de elementos presentes en el primer caso se precisará en su diseño.

## 5. Interfaz y accesibilidad

Menú principal y consola de emergencias con acceso a conversaciones, expedientes, audio, mapa y despacho. La composición y navegación detalladas se definirán en la fase correspondiente.

Estética tecnológica de finales de los noventa con interfaz moderna, predominantemente oscura, verde petróleo y ámbar. Priorizar lectura en pantallas pequeñas, interacción táctil y adaptación a diferentes resoluciones.

Requisitos aprobados de accesibilidad y comodidad: alternativas textuales para pistas auditivas, consulta de pistas anteriores, investigación sin presión continua y conservación del progreso local.

Propuestas pendientes de aprobación: tamaño de texto ajustable, información que no dependa solo del color y controles independientes de volumen. Los tamaños mínimos, métricas de contraste y dispositivos de referencia aún no están fijados.

## 6. Arquitectura prevista

Preferir escenas reutilizables, interfaces separadas de la lógica narrativa, casos en datos estructurados preferentemente JSON, estado centralizado y guardado local versionado. Validar referencias y condiciones narrativas y permitir reutilizar los sistemas entre casos.

El código deberá ser legible, mantenible, modular y apropiado para Godot, con tipado de GDScript cuando resulte útil. Evitar sistemas excesivamente complejos y dependencias externas innecesarias. Optimizar recursos para Android y facilitar pruebas reproducibles.

La base de carpetas, la escena de entrada y el Theme se documentan en [TECHNICAL_SETUP.md](TECHNICAL_SETUP.md). El proyecto ofrece menú, consola, motor narrativo y guardado local; Llamadas y Expedientes comparten una investigación técnica aislada con evidencias y deducciones. Audio/Mapa siguen como secciones informativas vacías. El flujo base consta en [UI_NAVIGATION.md](UI_NAVIGATION.md), conversaciones en [CALL_SYSTEM.md](technical/CALL_SYSTEM.md) e investigación en [INVESTIGATION_SYSTEM.md](technical/INVESTIGATION_SYSTEM.md). Los módulos y contenido oficiales se implementarán al autorizar sus fases.

## 7. Alcance del MVP

Únicamente el Caso 001, **La habitación 304**: una mujer solicita ayuda desde una habitación de hotel. Los registros indican que el establecimiento fue clausurado hace diecisiete años. El jugador investiga la llamada, analiza sonidos, comprueba registros y toma decisiones que determinan el desenlace.

El PROMPT 02 precisa la premisa: llamada a las 02:17 desde el Hotel Mirador, golpes en la puerta y registros de clausura tras un incendio de 1981. La propuesta de diseño desarrolla seis etapas, una duración objetivo de primera partida de 8–15 minutos y tres resultados; esa duración no está medida todavía. La explicación global del fenómeno permanece abierta.

Entregables jugables previstos:

- Menú principal y consola de emergencias.
- Conversaciones interactivas.
- Analizador de audio simplificado con alternativas textuales.
- Pistas y deducciones.
- Mapa y despacho básico.
- Tres resultados narrativos diseñados y aprobados: salida comunicada, refugio sin confirmación y contacto perdido en riesgo; sin implementación aún.
- Guardado local.
- Ambientación visual y sonora.
- Ejecución en Android.

Quedan excluidos inicialmente: multijugador, backend o servidores, chatbots o IA generativa en tiempo real, publicidad, compras integradas, doblaje completo, sistemas 3D y campaña completa.

## 8. Visión del juego completo

Cinco capítulos con tres casos principales cada uno: quince casos previstos. Los capítulos son «El turno nocturno», «Frecuencias muertas», «Los desaparecidos», «Protocolo 07» y «Última señal». Sus detalles están en [STORY_BIBLE.md](STORY_BIBLE.md).

La expansión se planifica después del MVP y sus pruebas, según [ROADMAP.md](ROADMAP.md). La monetización y preparación comercial son etapas futuras sujetas a decisiones explícitas; su presencia en el roadmap no incorpora publicidad ni compras al MVP.

## 9. Criterios de calidad

- Coherencia narrativa: preservar los hechos aprobados y registrar cambios autorizados.
- Investigación razonable: relacionar observaciones, deducciones y consecuencias; evitar decisiones arbitrarias.
- Integridad de datos: verificar referencias y condiciones antes de dar por válido el contenido de un caso.
- Usabilidad móvil: lectura clara, controles táctiles y adaptación vertical verificadas en las resoluciones que se acuerden.
- Accesibilidad: las pistas sonoras cuentan con una alternativa textual utilizable.
- Persistencia: el guardado local es versionado y conserva el progreso según las reglas que se definan.
- Reproducibilidad: registrar recorridos y pruebas relevantes, incluidos los tres resultados del primer caso cuando se implementen.
- Funcionamiento offline y rendimiento adecuado a los dispositivos que se seleccionen como referencia.
- Evidencia de plataforma: distinguir validación de escritorio, exportación Android y pruebas en dispositivo real.

No se han aprobado aún presupuestos de memoria, tamaño, tiempo de carga o rendimiento, ni versión mínima de Android. Los criterios técnicos medibles deben fijarse en sus fases antes de declarar su cumplimiento.
