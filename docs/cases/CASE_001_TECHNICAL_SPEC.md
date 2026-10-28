# Caso 001 — Especificación técnica documental

Versión 1.0 · 2026-10-27 · PROMPT 02. Propuesta transformable a JSON; **no constituye código, motor ni archivos funcionales**. Fuente de textos y reglas: [diseño completo](CASE_001_DESIGN.md). Verificación: [plan de pruebas](CASE_001_TEST_PLAN.md).

## 1. Límites y dependencias

Contenido fijo, elecciones deterministas y escenas 2D futuras. Sin IA, reconocimiento de voz, síntesis de conversaciones ni procesamiento real de audio. Solo un caso, cuatro personajes humanos, diez evidencias, cuatro deducciones, dos grabaciones y una unidad con dos destinos. No se especifica una arquitectura universal de campañas ni un editor de contenido.

| Sistema previsto | Consume | Emite / contrato de integración |
| --- | --- | --- |
| Interfaz y navegación | Nodo actual, opciones y estados derivados | Peticiones por ID; no modifica variables directamente |
| Contenido del caso | Tablas del diseño y catálogos | Textos exactos, condiciones, efectos y referencias validadas |
| Lógica narrativa | Estado y petición permitida | Una transacción con efectos, siguiente nodo y eventos aplicables |
| Expediente y deducciones | Conjuntos de evidencia y reglas Q01–Q04 | Adquisición/confirmación por ID, idempotente |
| Audio simulado | Segmentos, variantes y transcripciones | Recurso predefinido o texto; E03 con la misma condición de selección |
| Mapa y despacho | Una R1 y estados documentados | U01/U02 al recibir parte; nunca llegadas por reloj real |
| Estado y guardado | Transacción completa y cursor | Instantánea local versionada recuperable, sin efectos duplicados |
| Evaluación | Instantánea de K02, deducciones y evidencias | Resultado ya fijado y explicaciones; no vuelve a calcular un desenlace diferente |

La fase 03 solo preparará el proyecto si el usuario la autoriza. El motor narrativo y los demás sistemas se implementarán en sus fases. Esta especificación no autoriza instalarlos o construirlos.

## 2. Identificadores y referencias

Prefijo único `c001_`, minúsculas ASCII, números con dos dígitos. El nombre visible mantiene tildes y español; los ID no cambian por editar un texto.

| Entidad | Patrón y rango de esta versión |
| --- | --- |
| Caso | `c001` |
| Personaje | `c001_p00`…`c001_p04` |
| Nodo y opción | `c001_n01`…`c001_n38`; `c001_n03_o01`, por ejemplo |
| Evidencia / deducción | `c001_e01`…`c001_e10`; `c001_q01`…`c001_q04` |
| Grabación / segmento | `c001_g01`, `c001_g02`; `c001_g01_s02` |
| Variante | `c001_g01_s02_original`, `c001_g01_s02_voz_fondo` |
| Lugar / recurso | `c001_l01`, `c001_l02`; `c001_r1` |
| Evento crítico / unidad | `c001_k01`, `c001_k02`; `c001_u01`, `c001_u02` |
| Resultado | `c001_final_a`, `c001_final_b`, `c001_final_c` |
| Acción de audio / mapa | `c001_t01`…`c001_t07`; `c001_m01`…`c001_m05` |

END es un destino terminal reservado. Las letras A–F de etapa no son identificadores de final. P00 es Sistema. Las abreviaturas N/E/Q/G/K/U/M/T de la documentación siempre se expanden con el prefijo; no se mezclan ID abreviados con completos en los datos futuros.

Rechazar ID duplicados, destinos inexistentes, referencias a evidencia ajena al catálogo, personajes no registrados, variantes fuera de segmento y condiciones con variables no declaradas. Ninguna opción se construye a partir de una cadena ejecutable.

## 3. Modelo de datos propuesto

Cada estructura es un contrato documental. Todos los campos de lógica son datos declarativos, nunca expresiones de código que se evalúen dinámicamente.

| Estructura | Campos requeridos y significado |
| --- | --- |
| Caso | `id`, `content_version`, `title`, `diegetic_date`, `incoming_time`, `entry_node`, `characters`, `variables`, `nodes`, `evidence`, `deductions`, `recordings`, `locations`, `resources`, `events`, `endings`, `terminal_target` |
| Personaje | `id`, `display_name`, `role`; rasgos y límites de conocimiento permanecen en el diseño |
| Variable | `name`, `type`, `initial`, `allowed_values` o límites, `persistence`, referencias a modificadores y consumidores |
| Nodo | `id`, `speaker_id`, `stage_scope`, `text` o `text_variants`, `entry_effects`, `options`, `panel_id` opcional |
| Variante de texto | `condition`, `text`, `priority`; una variante de respaldo explícita si no hay coincidencia |
| Opción | `id`, `text`, `visible_when`, `enabled_when`, `disabled_reason`, `effects`, `next` o `resolution_event` |
| Condición | Operador permitido, variable o colección, valor/ID y subcondiciones cuando corresponda |
| Efecto | Operador permitido, destino, valor/ID, `once_key` cuando no baste la unicidad natural del conjunto |
| Evidencia | `id`, `title`, `description`, `category`, `source_labels`, `acquisition_rules`, `unlock_when`, `deduction_ids`, `essential_for`, `recovery_routes` |
| Deducción | `id`, `question`, `required_evidence_ids`, `confirmation_text`, `effects`, `unlocks`; el conjunto requerido es exacto |
| Grabación | `id`, `unlock_when`, `duration_seconds`, `segments`, `capture_metadata`; no almacena una conversación generada |
| Segmento | `id`, `start_seconds`, `end_seconds`, `variants` |
| Variante de audio | `id`, `label`, futuro `asset_ref`, `transcript`, `effects_on_consult`; texto disponible sin archivo sonoro |
| Lugar | `id`, `label`, `initial_text`, `revealed_text`, `unlock_when` |
| Recurso | `id`, `label`, `state_values`, `initial_state`, `assignment_actions` |
| Despacho | `id`, `resource_id`, `target_id`, `preconditions`, `effects`, `report_event_id` |
| Evento crítico | `id`, `trigger`, `preconditions`, `once_key`, `effects`, `target` o `outcome_rules`, `fallback_on_invalid` |
| Desenlace | `id`, `predicate`, `entry_node`, `communication_state`, `evaluation_rows`; persistencia de las evidencias ya descubiertas |
| Instantánea de guardado | Versiones, caso, estado persistente, cursor, registros e instantánea de resolución descritos en sección 8 |

No hay un nodo especial para cada pulsación de una herramienta: el nodo de panel sigue activo hasta Volver o hasta un parte. Un contenido visto no cambia el diálogo salvo que lo diga su regla de adquisición.

### Ejemplo ilustrativo de datos, exclusivamente en Markdown

Este fragmento describe N03.O01 y su nodo. El nodo real deberá incluir también O02 según el guion; el ejemplo no es una exportación completa ni se guarda como JSON funcional.

```json
{
  "id": "c001_n03",
  "speaker_id": "c001_p02",
  "stage_scope": ["A"],
  "text": "¿Emergencias? Por favor… alguien está golpeando. Estoy encerrada en una habitación.",
  "entry_effects": [],
  "options": [
    {
      "id": "c001_n03_o01",
      "text": "Estoy aquí. Dígame su nombre y dónde está.",
      "visible_when": {"op": "always"},
      "enabled_when": {"op": "always"},
      "disabled_reason": "",
      "effects": [
        {"op": "add_clamped", "target": "confianza", "value": 1},
        {"op": "add_clamped", "target": "estres", "value": -1}
      ],
      "next": "c001_n04"
    }
  ]
}
```

Ejemplo de condición compuesta: la habilitación de N10.O09 exige simultáneamente etapa C, pertenencia de Q01 a deducciones y de E06 a evidencias. Su texto de bloqueo no muestra información de 1981 adicional a la ficha ya descubierta. Ejemplo de efecto único: confirmar Q01 inserta su ID en el conjunto, sin volver a otorgar nada al abrir su tarjeta.

## 4. Estado, inicialización e invariantes

### Variables persistentes del caso

| Nombre | Tipo | Inicial | Valores permitidos | Escrituras autorizadas | Lecturas narrativas |
| --- | --- | --- | --- | --- | --- |
| confianza | Entero | 1 | 0, 1, 2 | N03.O01 +1; N03.O02 −1; N21.O01 +1; N21.O02 −1; N18.O01 =1 | Cooperación, C, evaluación |
| estres | Entero | 1 | 0, 1, 2 | N03.O01 −1; N03.O02 +1; N21.O01 −1; N21.O02 +1; N18.O01 =0 | Cooperación, C, evaluación |
| evidencias | Conjunto de ID | Vacío | Catálogo E01–E10 | Nodos y audio indicados abajo | Deducciones, desbloqueos, evaluación |
| deducciones | Conjunto de ID | Vacío | Catálogo Q01–Q04 | Solo confirmación con conjunto correcto | Progreso a D, A, continuidad, consulta N38 |
| unidad | Enum | disponible | disponible, rumbo_frente, frente_lista, rumbo_patio, patio_lista, cerrada | M01–M05, entradas N19/N20, K02 | Despacho, servicio y A |
| plan | Enum | ninguno | ninguno, refugio, servicio, pasillo | N24.O02/O03, N26.O02, N25.O02 y N26.O01 | Confirmación, K02 |
| comunicacion | Enum | entrante | entrante, activa, cerrada, interrumpida | Atender en N01/N02; K02 | Permisos de acción y cierre |
| resultado | Enum | pendiente | pendiente, A, B, C | Solo K02 | Rama final y lectura posterior |
| etapa | Enum | A | A, B, C, D, E, F | N06.O01 B; N08.O01 C; K01 D; N22.O01 E; K02 F | Permisos y variantes de texto |

Las sumas emocionales saturan entre 0 y 2; una asignación se aplica antes de cualquier evaluación de destino. La cooperación se deriva: suficiente con confianza al menos 1 y estrés como máximo 1; insuficiente en los demás casos. No se guarda como otra variable susceptible de desacuerdo.

### Registro de escrituras de evidencia

| Fuente | Efecto |
| --- | --- |
| Entrada N04 | Insertar E01 |
| Entrada N08 | Insertar E02 |
| Entrada N11 | Insertar E04 |
| Entrada N12 | Insertar E03 |
| Entrada N14 | Insertar E05 |
| Entrada N15 | Insertar E09 |
| Entrada N19 | Insertar E06, fijar unidad frente_lista; solo dentro de la transacción U01 validada como no ejecutada previamente |
| Entrada N20 | Insertar E06/E07/E04, fijar unidad patio_lista; solo dentro de la transacción U02 validada como no ejecutada previamente |
| Entrada N21 | Insertar E08 |
| Entrada N22 | Insertar E10 |
| T04 o T05 sobre G01.S02, variante voz de fondo | Insertar E03 |
| T06 sobre G02, después de N22 | Insertar E10, normalmente ya existente |

Consultar transcripción de G02 muestra E08 ya recibida. Los textos G01.S01 tampoco crean otra identidad. El expediente conserva la primera fuente y permite anexar una segunda fuente al recuperar E03/E04; esa procedencia es metadato, sin efectos narrativos adicionales.

### Estado de infraestructura persistente

`current_node` y `terminal_view` ubican la presentación. `transaction_log` identifica opciones y acciones ya comprometidas; `applied_once_keys` identifica K01/K02/U01/U02 y la opción de calma N18.O01. `resolution_snapshot` permanece vacío hasta K02 y después almacena confianza, estrés, cooperación derivada, unidad, plan y Q02 al transmitir, además del resultado. El historial de texto se puede reconstruir por los ID visitados y variantes resueltas, sin registrar audio real.

### Invariantes obligatorias

1. Q confirmada implica todas sus evidencias; todo ID pertenece al catálogo.
2. D o E implica E01/E02/E06 y Q01. F añade E08/E10 y resultado no pendiente.
3. E07 implica E04 y E06; unidad patio_lista implica E07, E04 y E06. Una vez en F, unidad cerrada conserva esas evidencias y la posición de resolución en la instantánea.
4. El cursor N25 exige plan distinto de ninguno. Fuera de N25 puede conservarse ninguno; en F el plan final no cambia.
5. Servicio no puede prepararse ni transmitirse sin patio_lista; antes de K02 la unidad no cambia fuera de las cinco acciones de mapa y los dos partes.
6. Resultado pendiente implica etapa distinta de F y comunicación entrante/activa; A implica F/cerrada; B o C implican F/interrumpida.
7. No hay nuevas pruebas o deducciones tras K02. El expediente final solo muestra lo ya obtenido.
8. N18.O01 se compromete una sola vez; sus modificaciones no se repiten por cargar o releer.
9. No hay regreso de F a C/E, ni de E a D. Reabrir N10 mantiene E; N38 solo está disponible con Q04 y antes de K02.
10. Una acción de consulta no avanza urgencia ni altera magnitudes emocionales. Un doble toque no ejecuta dos transacciones de la misma visita.

Un guardado que viola invariantes se rechaza o se recupera desde una copia válida anterior. No se inventa una evidencia para reparar silenciosamente un estado contradictorio.

## 5. Condiciones, opciones y efectos

Vocabulario mínimo de condiciones declarativas: `always`, `all`, `any`, `not`, `equals`, `at_least`, `at_most`, `contains` y `once_not_applied`. `all`/`any` contienen subcondiciones; no contienen texto de programa. Comparar solo tipos compatibles y rechazar referencias desconocidas.

Vocabulario mínimo de efectos: `set`, `add_clamped`, `add_to_set`, `mark_once`, `enter_node` y `resolve_case`. Los ID de recursos y destinos se validan antes de comprometer. `enter_node` incluye sus efectos de entrada en la misma operación; no inicia una cadena automática de nodos con elección.

Reglas de evaluación:

- Mostrar la opción si cumple `visible_when`. Habilitarla solo si también cumple `enabled_when`.
- Antes de confirmar, reevaluar requisitos contra el estado vigente, incluso si estaba habilitada al dibujarla.
- Elegir siempre la variante textual más específica; N10 usa etapa, N16 estado de unidad, N25 plan y Q02, N30 plan y Q02, y N36 Q03. En N30, servicio con Q02 solo ocurre en B por cooperación insuficiente, pues patio_lista ya se exige para transmitir ese plan. N37 genera filas con las reglas exhaustivas del diseño. Ninguna variante depende de azar.
- Toda opción común del guion tiene condición `always` respecto de su nodo. Las excepciones son N10.O08/O09/O10/O11 y N24.O03, exactamente como indican sus tablas.
- N10.O09 permanece visible en C aunque falten requisitos; N10.O10 solo existe en E. No se puede lanzar de nuevo K01 desde E.
- N24.O03 es invisible sin E04 y deshabilitada sin patio_lista. El resto de planes permite concluir con B/C según las reglas; no hay cierre por un botón sin investigación mínima.
- Rutas de texto y efectos no descritos en el guion no se improvisan durante la implementación.

Una opción no debe mantener efectos en `on_hover`, selección preliminar ni reproducción visual. Las evidencias del nodo se otorgan al entrar y guardan antes de permitir otro botón. Las confirmaciones de deducción no consumen unidad ni cooperación.

## 6. Eventos y transiciones de sistemas

| ID | Disparador y requisitos | Efectos únicos, destino y control de repetición |
| --- | --- | --- |
| K01 — Contrastar fechas | N10.O09 en C, Q01 y E06, resultado pendiente | Marcar K01, etapa D, entrar N21 con E08. La salida N22.O01 lleva a E. No se agenda ningún temporizador |
| U01 — Parte del frente | M03 en N16, unidad rumbo_frente | Marcar U01, entrar N19, unidad frente_lista y E06 en una operación |
| U02 — Parte del patio | M04 en N16, unidad rumbo_patio | Marcar U02, entrar N20, unidad patio_lista y E04/E06/E07. Se puede llegar tras M02 directo o M05 desde frente |
| K02 — Transmitir instrucción | N25.O01 en E, comunicación activa, resultado pendiente, plan válido, E06; servicio exige patio_lista | Tomar instantánea; resolver A/C/B en ese orden; marcar K02; unidad cerrada; etapa F; comunicación cerrada para A o interrumpida para B/C; entrar N27/N33/N30 respectivamente |

Los eventos de unidad son acciones directas de recepción de parte, no mensajes que se disparen en segundo plano mientras se lee. Para esta única unidad U01 y U02 suceden como máximo una vez cada uno. M05 no puede ejecutarse si ya se llegó al patio. No existe una cola de eventos genérica necesaria para este caso.

K02 aplica las tres reglas de sección 10 del diseño, exhaustivas y mutuamente excluyentes: A requiere servicio, Q02, patio_lista y cooperación; C requiere pasillo con confianza 0/estrés 2; resto válido B. Confirmar una deducción después de preparar un plan exige volver a las herramientas; al regresar se puede volver a elegir plan, sin transmitirlo automáticamente.

Entrar en N25 no consume K02. Cancelar N26 o corregir N25 no tiene penalización. Si un requisito cambió o el estado es inválido, mostrar «La instrucción no se puede transmitir con este estado. Revise el expediente y el despacho», volver a N24 con plan ninguno y conservar estado previo sin K02. Una petición después de F solo informa «Atención cerrada» y no mueve el cursor final.

## 7. Acciones de herramientas e integración táctil

El diseño contiene el contrato exhaustivo de T01–T07 y M01–M05. Las acciones adicionales de interfaz son seleccionar tarjeta de hipótesis, seleccionar/quitar evidencia y comprobar relación. Solo comprobar con el conjunto exacto inserta Q; el resto son selecciones temporales.

El panel no deja arrastrar evidencias inexistentes a una hipótesis. Selecciones parciales o excesivas no alteran estado. Q04 requiere tres pruebas; el resto dos o tres según catálogo. El orden de selección no importa. La tarjeta no muestra el nombre de las pruebas faltantes como solución automática.

Para audio, T04/T05 comparten `effects_on_consult`; adquirir E03 no depende del volumen, del archivo sonoro o de esperar al segundo exacto. El segmento se selecciona con botones, sin detección de frecuencia ni precisión motora. Las transcripciones de las variantes se mantienen sincronizadas con su contenido futuro. T06 no desbloquea E10 antes de N22.

Mapa: dos botones de ubicación y una tarjeta R1. Los botones de despacho usan requisitos tanto al mostrar como al confirmar. Recibir parte es una transición explícita a un nodo de la unidad. Volver de ese nodo lleva a N10; para reubicar se abre de nuevo N16. Las fuentes siempre se pueden consultar en el expediente sin volver a ejecutar sus efectos de adquisición.

## 8. Persistencia y reanudación propuestas

Guardado local versionado, sin servicio externo. Propuesta inicial de contrato: `save_version = 1`, `content_version = "c001-1.0"`, `case_id = "c001"`. Los nombres de archivo y el método específico de reemplazo se elegirán al implementar la fase 06, sin cambiar estos compromisos de comportamiento.

Cada instantánea incluye:

- Los nueve campos persistentes del caso de la sección 4 y un cursor a un nodo o END.
- Registro ordenado de visitas, ID de opción/acción y variante de texto mostrada para reconstruir historial.
- ID de transacción y claves de efectos únicos ya comprometidos.
- Instantánea de resolución, si K02 se ejecutó, y metadatos de procedencia de evidencia.
- Estado de lectura de cierre; volver al menú no borra el expediente.

Temporales no persistentes: audio reproduciéndose, posición de reproducción, selección provisional de pruebas, tarjeta o segmento seleccionado, desplazamiento y animaciones. Al cargar un panel se restablece su selección vacía y el audio detenido; la evidencia ya registrada persiste. El tiempo real transcurrido con la app cerrada no avanza nada.

### Unidad transaccional

Una petición se identifica por caso, visita y acción. Se comprueban requisitos; se calculan efectos, destino y efectos de entrada; se construye una instantánea coherente; se intenta guardar; después se habilita el siguiente conjunto de botones. No existe un checkpoint con unidad rumbo_patio y E07 ya otorgada por un parte aún no recibido.

La aplicación futura debe usar reemplazo de archivo seguro y conservar una copia válida anterior. Si falla la escritura, la transacción permanece comprometida en la sesión y en su registro en memoria; se muestra el error. «Reintentar» vuelve a escribir la instantánea actual, sin ejecutar los efectos otra vez. Si se cierra antes de guardar, al cargar se vuelve al último checkpoint durable y se advierte de esa limitación; no se promete conservar cambios que no llegaron a disco.

### Ejemplos de reanudación

| Punto de cierre | Reanudación requerida |
| --- | --- |
| Antes de confirmar N03 | Mismo texto y mismas magnitudes iniciales; sin efecto de una opción aún no elegida |
| Después de elegir N03 | N04 y E01 presentes; no repetir ±1 por recrear pantalla |
| En N16 con rumbo_patio | Misma asignación; puede recibir parte; no despachar otra R1 |
| Después de recibir U02 | N20 con E04/E06/E07 y patio_lista; recibir parte otra vez no altera nada |
| En N21 | E08 y D guardados; se muestra la revelación y aún puede elegir su respuesta |
| Después de N18.O01 | Calma aplicada una vez; la opción no vuelve a ofrecerse |
| En N25 antes de transmitir | Mismo plan pendiente; se pueden corregir o transmitir; sin final fijado |
| Después de K02, incluso antes de leer la primera frase | Resultado, instantánea y rama final ya fijados; no recalcular con unidad cerrada |
| Después de N37 / END | Menú y expediente final de solo lectura; ninguna nueva adquisición |

Carga valida formato, versiones, ID y todas las invariantes antes de reemplazar la sesión activa. Un archivo desconocido se conserva y se informa; no se migra silenciosamente ni se comienza una nueva partida encima. «Nueva partida» desde un progreso existente requiere confirmación de reemplazo de esa partida, una decisión de navegación sin efecto sobre el misterio. No se añade un sistema de múltiples ranuras ni una galería de campañas.

## 9. Requisitos de validación futura y aceptación documental

Validación estructural futura: todas las referencias existen; todo nodo tiene salida o destino terminal; cada variante posee cobertura; cada efecto usa un tipo permitido; cada evidencia esencial tiene una obtención obligatoria recuperable o una fuente alternativa; no hay despachos duplicables; todo final es alcanzable con fuentes previas.

Las comprobaciones de esta fase se limitan a integridad del Markdown, revisión del grafo y evaluación de reglas documentadas. No equivalen a ejecutar un motor o verificar JSON funcional. [El plan de pruebas](CASE_001_TEST_PLAN.md) separa esas revisiones de las pruebas que solo se podrán ejecutar al implementar.
