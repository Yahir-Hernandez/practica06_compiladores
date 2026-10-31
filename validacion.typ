#set text(font: "New Computer Modern", size: 12pt)
#set page(paper: "us-letter")
#set par(justify: true)
= Ejercicios de Validación (Práctica 6)
#outline()
_Alumno: Hernandez Garcia Oscar Yahir_

== 1. Introducción y Marco de Trabajo

La presente actividad evalúa el dominio conceptual en la construcción de autómatas canónicos
LR(1) y su compactación a LALR(1). El ejercicio se centra en la capacidad de auditoría analítica:
detectar propagaciones erróneas de lookaheads, fusiones inválidas de núcleos (kernels) y transiciones defectuosas, evaluándolas mediante un análisis crítico y el uso de herramientas LLM.

== 2. Gramática Parametrizada

$
  (1) & S' --> S \
  (2) & S --> L = R \
  (3) & S --> R \
  (4) & L --> \& R thin thin ("D = Impar") \
  (5) & L --> id \
  (6) & R --> L \
$

== 3. Caso Base con Errores Inducidos

A continuación, se presenta un extracto de la colección canónica de ítems LR(1) y su compacta-
ción, el cual contiene tres *inconsistencias conceptuales intencionadas*:

*Estado $I_0$ (LR(1))*:
$
  "Cerradura"([S' → dot S, \$]) = { & \
                                    & [S' → dot S, \$],
                                      [S → dot L = R, \$],
                                      [S → dot R, \$], \
                                    & [L → dot \* R, =\/\$],
                                      [L → dot id, =\/\$],
                                      [R → dot L, \$] \
                                    & }
$

*Estado $I_2$ (Obtenido de Goto($I_0, L$)):*
$
  { [S → L dot = R, \$], [R → L dot , \$] }
$
*Fusión de Kernels para LALR(1):*
Se asume erróneamente que $I_4 = {[L → \* dot R, = \$]}$ e $I_9 = {[L → \* dot R, \$]}$ tienen núcleos
distintos por la diferencia de un símbolo y no se fusionan. Además, en el Estado I2, en la celda
de acción bajo el terminal ’=’ se inserta forzosamente un Reduce 6.

= 4. Instrucciones de la Actividad

== 4.1 Fase 1: Auditoría Manual del Caso Base
+ Sustituye la producción (4) según tu dígito D. Desarrolla matemáticamente el Estado $I_0, I_2$ y la transición completa para el operador unario (\* o &).
$
  I_0 = "Cerradura"([S' -> dot S, \$]) & = { \
                                       & [S' -> dot S, \$], \
                                       & [S -> dot L = R, \$], \
                                       & [S -> dot R, \$], \
                                       & [L -> dot \& R, = \/ \$], \
                                       & [L -> dot "id", = \/ \$], \
                                       & [R -> dot L, \$] \
                                       & }
$
$
  I_2 = "Goto"(I_0, L) & = { \
                       & [S -> L dot = R, \$], \
                       & [R -> L dot , \$] \
                       & }
$
$
  I_4 = "Goto"(I_0, \&) & = { [L -> \& dot R,=\/\$] \
                        & [R -> dot L, =\/\$] \
                        & [L -> dot \& R, =\/\$] \
                        & [L -> dot id, =\/\$] \
                        & }
$

Transiciones que salen de I4:
$
  "Goto"(I_4, \&) = I_4 \
  "Goto"(I_4, id) = { [L → id dot , =\/\$] }\
  "Goto"(I_4, L) = { [R → L dot, =\/\$] } \
  "Goto"(I_4, R) = { [L → \&R dot, =\/\$] }\
$

=== Tres errores y por qué violan las definiciones

- Error 1: Se omite la regla de fusión de LALR(1).

  El error de tomar a $I_4 = {[L → \* dot R, = \$]}$ e $I_9 = {[L → \* dot R, \$]}$ como núcleos distintos por el hecho de $I_9$ no tenga el lookahead =, es un error conceptual. La definición de fusión de núcleo (kernel) establece que si dos estados tienen nucleos de la forma $[A -> alpha dot B beta, a ]$ y $[A -> alpha dot B beta, b ]$, respectivamente, entonces ambos estados deben fusionarse en un único estado $I = {[A -> alpha dot B beta, a], [A -> alpha dot B beta, b]} = {[A -> alpha dot B beta, a\/b]}$. Por lo tanto, $I_4$ e $I_9$ deberían fusionarse en un único estado.
- Error 2: Se define el nucleo de estado mirando su lookahead y no su producción.

  La definición de núcleo dice:

  El núcleo o kernel de un ítem $L R(1)$ de la forma $[X → alpha dot beta, a]$ es el componente:
  $
    X -> alpha dot beta
  $
  que corresponde a los ítems $L R(0)$.
  Entonces, los lookaheads deben de ignorarse al momento de determinar si dos ítems son iguales o no. Por lo tanto, $I_4$ e $I_9$ deberían fusionarse en un único estado.
- Error 3: Se inserta un Reduce 6 en la celda de acción bajo el terminal ’=’ del Estado $I_2$.

  En la tabla $L R(1), thin thin "acción"[I, a] = "reduce" A → alpha$ si y solo si $[A → alpha dot, a] ∈ I$, pero podemos ver que  en $I_2 = { [S -> L dot = R, \$],[R -> L dot , \$] }$, el simbolo terminal ’=’ no es un lookahead de ningún ítem, por lo que no se puede insertar un Reduce 6 en la celda de acción bajo el terminal ’=’ del Estado $I_2$. Para el simbolo "=", la con el item $[S -> L dot = R, \$]$ podemos generar una acción de Shift, pero no un Reduce 6. Por lo tanto, la inserción de un Reduce 6 en la celda de acción bajo el terminal ’=’ del Estado $I_2$ es incorrecta.

== 4.2 Fase 2: Inyección de Nuevos Errores

#let items(..xs) = xs.pos().join(linebreak())

#let cell-style = (
  inset: 7pt,
  stroke: 0.5pt + luma(150),
)

=== Desarrollo completo de la tabla de ánalisis LALR(1)

*Conjunto Fist:*
$
  "FIRST"(S') = "FIRST"(S) = "FIRST"(L) = "FIRST"(R) = { \&, "id" }
$
*Colección canónica LR(1): *

#table(
  columns: (auto, auto, 1fr),
  align: (center + horizon, left + horizon, left + horizon),
  ..cell-style,
  stroke: (x, y) => (
    left: if x == 0 or y > 0 { 1pt } else { 0pt },
    right: 1pt,
    top: if y <= 1 { 1pt } else { 0pt },
    bottom: 1pt,
  ),
  table.header[*Estado*][*Origen*][*Ítems*],

  [$I_0$], [$"Cerradura"([S' -> dot S, \$])$],
  items(
    $[S' -> dot S, \$]$,
    $[S -> dot L = R, \$]$,
    $[S -> dot R, \$]$,
    $[L -> dot \& R, = \/ \$]$,
    $[L -> dot "id", = \/ \$]$,
    $[R -> dot L, \$]$,
  ),

  [$I_1$], [$"Goto"(I_0, S)$],
  items($[S' -> S dot, \$]$),

  [$I_2$], [$"Goto"(I_0, L)$],
  items($[S -> L dot = R, \$]$, $[R -> L dot, \$]$),

  [$I_3$], [$"Goto"(I_0, R)$],
  items($[S -> R dot, \$]$),

  [$I_4$], [$"Goto"(I_0, \&)$],
  items(
    $[L -> \& dot R, = \/ \$]$,
    $[R -> dot L, = \/ \$]$,
    $[L -> dot \& R, = \/ \$]$,
    $[L -> dot "id", = \/ \$]$,
  ),

  [$I_5$], [$"Goto"(I_0, "id")$],
  items($[L -> "id" dot, = \/ \$]$),

  [$I_6$], [$"Goto"(I_2, =)$],
  items(
    $[S -> L = dot R, \$]$,
    $[R -> dot L, \$]$,
    $[L -> dot \& R, \$]$,
    $[L -> dot "id", \$]$,
  ),

  [$I_7$], [$"Goto"(I_4, R)$],
  items($[L -> \& R dot, = \/ \$]$),

  [$I_8$], [$"Goto"(I_4, L)$],
  items($[R -> L dot, = \/ \$]$),

  [$I_9$], [$"Goto"(I_6, R)$],
  items($[S -> L = R dot, \$]$),

  [$I_10$], [$"Goto"(I_6, L)$],
  items($[R -> L dot, \$]$),

  [$I_11$], [$"Goto"(I_6, \&)$],
  items(
    $[L -> \& dot R, \$]$,
    $[R -> dot L, \$]$,
    $[L -> dot \& R, \$]$,
    $[L -> dot "id", \$]$,
  ),

  [$I_12$], [$"Goto"(I_6, "id")$],
  items($[L -> "id" dot, \$]$),

  [$I_13$], [$"Goto"(I_11, R)$],
  items($[L -> \& R dot, \$]$),
)
*Fusión de kernels (LALR(1))*

#table(
  columns: (auto, auto, auto, auto),
  align: center + horizon,
  ..cell-style,
  stroke: (x, y) => (
    left: if x == 0 or y > 0 { 1pt } else { 0pt },
    right: 1pt,
    top: if y <= 1 { 1pt } else { 0pt },
    bottom: 1pt,
  ),
  table.header[*Núcleo común*][*Estados LR(1)*][*Lookaheads unidos*][*Estado LALR*],

  [$L -> \& dot R$],
  [$I_4,I_11$],
  [${=, \$}$], [$I_(4,11)$],

  [$L -> "id" dot$],
  [$I_5,I_12$],
  [${=, \$}$], [$I_(5,12)$],

  [$L -> \& R dot$],
  [$I_7,I_13$],
  [${=, \$}$], [$I_(7,13)$],

  [$R -> L dot$],
  [$I_8,I_10$],
  [${=, \$}$], [$I_(8,10)$],
)

*Estados del autómata LALR(1):*
#table(
  columns: (auto, 1fr),
  align: (center + horizon, left + horizon),
  ..cell-style,
  stroke: (x, y) => (
    left: if x == 0 or y > 0 { 1pt } else { 0pt },
    right: 1pt,
    top: if y <= 1 { 1pt } else { 0pt },
    bottom: 1pt,
  ),
  table.header[*Estado*][*Ítems*],

  [$I_0$],
  items(
    $[S' -> dot S, \$]$,
    $[S -> dot L = R, \$]$,
    $[S -> dot R, \$]$,
    $[L -> dot \& R, = \/ \$]$,
    $[L -> dot "id", = \/ \$]$,
    $[R -> dot L, \$]$,
  ),
  [$I_1$], items($[S' -> S dot, \$]$),
  [$I_2$], items($[S -> L dot = R, \$]$, $[R -> L dot, \$]$),
  [$I_3$], items($[S -> R dot, \$]$),
  [$I_(4,11)$],
  items(
    $[L -> \& dot R, = \/ \$]$,
    $[R -> dot L, = \/ \$]$,
    $[L -> dot \& R, = \/ \$]$,
    $[L -> dot "id", = \/ \$]$,
  ),
  [$I_(5,12)$], items($[L -> "id" dot, = \/ \$]$),
  [$I_6$],
  items(
    $[S -> L = dot R, \$]$,
    $[R -> dot L, \$]$,
    $[L -> dot \& R, \$]$,
    $[L -> dot "id", \$]$,
  ),
  [$I_(7,13)$], items($[L -> \& R dot, = \/ \$]$),
  [$I_(8,10)$], items($[R -> L dot, = \/ \$]$),
  [$I_9$], items($[S -> L = R dot, \$]$),
)

*Tabla de análisis LALR(1):*

#align(center)[
  #table(
    columns: 8,
    align: center + horizon,
    inset: 7pt,
    stroke: 0.5pt + luma(150),
    table.header(
      table.cell(rowspan: 2)[*Estado*],
      table.cell(colspan: 4)[*ACTION*],
      table.cell(colspan: 3)[*GOTO*],
      [$=$], [$\&$], [id], [$\$$], [$S$], [$L$], [$R$],
    ),

    [$I_0$], [], [$s_(4,11)$], [$s_(5,12)$], [], [$1$], [$2$], [$3$],
    [$I_1$], [], [], [], [acc], [], [], [],
    [$I_2$], [$s_6$], [], [], [$r_6$], [], [], [],
    [$I_3$], [], [], [], [$r_3$], [], [], [],
    [$I_(4,11)$], [], [$s_(4,11)$], [$s_(5,12)$], [], [], [$(8,10)$], [$(7,13)$],
    [$I_(5,12)$], [$r_5$], [], [], [$r_5$], [], [], [],
    [$I_6$], [], [$s_(4,11)$], [$s_(5,12)$], [], [], [$(8,10)$], [$9$],
    [$I_(7,13)$], [$r_4$], [], [], [$r_4$], [], [], [],
    [$I_(8,10)$], [$r_6$], [], [], [$r_6$], [], [], [],
    [$I_9$], [], [], [], [$r_2$], [], [], [],
  )
]
=== Introducción de errores adicionales
- *Fallo tipo A (Propagación LR(1))*: Asigna un lookahead incorrecto durante una operación de cerradura profunda.
  $
    I_6 = "Goto"(I_2, =) & = { \
                         & [S -> L = dot R, \$], \
                         & [R -> dot L, = \/ \$], \
                         & [L -> dot \& R, = \/ \$], \
                         & [L -> dot "id", = \/ \$] \
                         & }
  $

  *Estado correcto (solución):*

  $
    I_6 = "Goto"(I_2, =) & = { \
                         & [S -> L = dot R, \$], \
                         & [R -> dot L, \$], \
                         & [L -> dot \& R, \$], \
                         & [L -> dot "id", \$] \
                         & }
  $

  Error en $[S -> L = dot R, \$]$ el punto está antes de $R$ con
  $beta = epsilon$, así que $"FIRST"(beta a) = "FIRST"(epsilon \$) = {\$}$.
  El `=` ya fue consumido en la transición $"Goto"(I_2, =)$ y no puede volver a
  aparecer como lookahead. Ese lookahead incorrecto se heredó a $[R -> dot L]$ y,
  por propagación, a $[L -> dot \& R]$ y $[L -> dot "id"]$.

  Viola $L R (1)$ porque el lookahead de un ítem de cerradura debe ser
  $"FIRST"(beta a)$ para cada $a$ del ítem que la genera. Aquí se tomó $=$, que no
  pertenece a $"FIRST"(epsilon \$)$.

  Como consecuencia, $I_10$ e $I_12$ heredarían $=$ y tendrían $r_6$ y $r_5$ en la
  columna $=$. La tabla aceptaría reducir en contextos donde el análisis debería
  dar error (por ejemplo, tras $L = L$ con $=$ como siguiente símbolo).

- *Fallo tipo B (Fusión Inválida LALR(1)):* Agrupa dos estados cuyos kernels parecen similares pero difieren en la posición   del punto o en un símbolo, generando un falso conflicto Reduce/Reduce.

  Estados que se fusionan por error:

  $
    I_3 = "Goto"(I_0, R) & = { [S -> R dot, \$] } \
    I_9 = "Goto"(I_6, R) & = { [S -> L = R dot, \$] }
  $

  Fusión inválida:

  $
    I_(3,9) & = { \
            & [S -> R dot, \$], \
            & [S -> L = R dot, \$] \
            & }
  $

  El error está en la fusión de los estados $I_3$ y $I_9$. Los núcleos son
  $"ker"(I_5) = {L -> "id" dot}$ y $"ker"(I_8) = {R -> L dot}$.
  Aunque los dos tienen el punto al final y los mismos lookaheads $= \/ \$$,
  son ítems LR(0) distintos (otra producción y otro lado izquierdo), así que
  no se pueden fusionar.

  Falso conflicto en la tabla ACTION:

  #align(center)[
    #table(
      columns: 4,
      align: center + horizon,
      inset: 6pt,
      stroke: 0.5pt,
      [*Estado*], [$=$], [$\&$ / id], [$\$$],
      [$I_(3,9)$], [], [], [$r_2 \/ r_3$],
    )
  ]

  Viola $L R (1)$ porque el estado fusionado contiene dos ítems de reducción con el mismo lookahead $\$$, lo que es un conflicto Reduce/Reduce.

== 4.3 Fase 3: Contraste Crítico y Experimentación con Prompts

Somete tus estados corruptos a un modelo de lenguaje (LLM) o evalúalo formalmente:
- *P1 (Prompt Directo)*: ”Encuentra los errores en estos estados LALR(1) para la gramática
dada...”
- *P2 (Prompt Estructurado)*: ”Actúa como un analizador sintáctico. Revisa si la fusión de

núcleos y la propagación de lookaheads en estos estados cumple el algoritmo de com-
compactación...”

- *P3 (Prompt Socrático)*: ”Hazme preguntas para descubrir por qué la fusión que hice del
estado I4 genera un conflicto en el parser...”

=== Tabla comparativa de resultados de los prompts con Deepseek como LLM:

#[  #set text(size: 8.5pt)
  #table(
    columns: (auto, 1fr, 1fr, 1fr),
    align: left + top,
    ..cell-style,
    stroke: (x: none),
    table.header[*Criterio*][*P1: Directo*][*P2: Estructurado*][*P3: Socrático*],

    [*Errores raíz detectados*],
    [2 de 2: fusión $I_3$/$I_9$ y lookaheads de $I_6$.],
    [2 de 2: los mismos.],
    [2 de 2, Despues de responder las preguntas.],

    [*Verificación de lo correcto*],
    [Comentario breve sobre $I_(4,11)$ e $I_(5,12)$, con una justificación poco rigurosa ("reciben ítems desde $I_4$").],
    [Revisa una por una las cuatro fusiones válidas ($I_(4,11)$, $I_(5,12)$, $I_(7,13)$, $I_(8,10)$) y las confirma con su núcleo.],
    [Confirma $I_(4,11)$, pero da como "núcleo" los cuatro ítems (kernel y clausura).],

    [*Omisiones*],
    [No deriva $"FIRST"(beta a)$ para $I_6$. No prueba que, tras corregir, no queden conflictos. Tabla corregida solo parcial.],
    [No deriva $"FIRST"(beta a)$ para $I_6$. Afirma que la gramática es LALR(1) sin verificar todas las celdas. Tabla corregida solo parcial.],
    [No presenta la tabla corregida ni la derivación de $I_6$.],

    [*Alucinaciones e imprecisiones*],
    [Ninguna alucinación grave. Imprecisión: la razón por la que $I_(4,11)$ conserva $= \/ \$$.],
    [Ninguna alucinación grave. Imprecisión: typo en la notación de lookahead ("`=/`" sin `$`).],
    [Ninguna alucinación grave. Imprecisión: confunde kernel con clausura. Filtra la pista ("el conflicto está en $I_(3,9)$") en la primera respuesta.],
  )]
=== Reflexión

/*Los tres prompts localizaron los dos errores sembrados, lo que sugiere que el modelo
maneja bien la definición formal de LALR(1) cuando la violación se puede comprobar con
una regla local. El caso más claro es la fusión de $I_3$ con $I_9$: basta comparar los
núcleos LR(0) para ver que no coinciden, y los tres lo señalaron sin dudar. El error de
lookaheads en $I_6$ es más sutil, porque exige recalcular $"FIRST"(beta a)$ y además queda
enmascarado tras la fusión: $I_10$ e $I_12$ se unen con $I_8$ e $I_5$, que ya traen
$= \/ \$$, de modo que la tabla LALR final no cambia. Solo P2 hizo explícita esta
observación, y ninguno mostró la derivación paso a paso, por lo que esa corrección tuvo
que verificarse a mano.

Las diferencias entre prompts estuvieron más en la calidad del análisis que en los
hallazgos. P1 fue rápido, pero infló el conteo al presentar como errores independientes
las consecuencias de la fusión inválida. P2 separó causas de consecuencias y verificó las
fusiones válidas, lo que lo hace el más auditable. P3 fue el único que detectó que la
premisa del prompt era falsa (el conflicto no nace de $I_4$), pero reveló la pista desde
su primera respuesta y emitió el diagnóstico con una respuesta incompleta del estudiante
("no sé" en la pregunta 4), así que su valor didáctico depende de que quien responde
participe de verdad.

No se encontraron alucinaciones graves, pero sí imprecisiones: confundir kernel con
clausura, justificar sin rigor por qué $I_(4,11)$ conserva sus lookaheads y un error de
notación. Estas imprecisiones se leen con la misma fluidez que las respuestas correctas,
por lo que son difíciles de detectar sin dominar el tema. La conclusión es que un LLM
sirve como segundo revisor, pero no sustituye la verificación formal. Cabe aclarar que se
trató de una sola ejecución con un solo modelo, así que los resultados no son
estadísticamente concluyentes.*/

Las auditorías con los tres prompts arrojaron resultados consistentes, pero no completos. El LLM detectó los errores que inyecté a propósito, pero ninguno de los prompts logró que hiciera un análisis completo: no derivó paso a paso el cálculo de los lookaheads de $I_6$ ni comprobó que, tras la corrección, no quedaran conflictos en la tabla.

La redacción del prompt influyó en la calidad de la respuesta, pero no en la detección de los errores. P1 fue rápido, pero infló el conteo al presentar como errores independientes lo que eran consecuencias de la fusión inválida. P2 separó las causas de las consecuencias y verificó las fusiones válidas, lo que lo hace el más fácil de auditar. En P3, la respuesta del modelo no se basó en lo que yo contesté a sus preguntas, sino en información que ya tenía del documento, por lo que el enfoque socrático no funcionó como guía real.

Respecto a las alucinaciones, no encontré ninguna grave, pero sí imprecisiones: confundir kernel con clausura, justificar sin rigor por qué $I_(4,11)$ conserva sus lookaheads y un error de notación. Estas imprecisiones se leen con la misma fluidez que las respuestas correctas, por lo que son difíciles de detectar sin dominar el tema.

En conclusión, el LLM es útil si cuenta con la información suficiente para analizar, pero no sustituye la verificación formal. Cabe aclarar que se trató de una sola ejecución con un solo modelo, así que los resultados no son estadísticamente concluyentes. Aun así, al menos en este ejercicio de LALR(1), la IA puede detectar errores que los humanos pasamos por alto, y nuestro conocimiento del tema nos permite verificar si su respuesta es correcta.
