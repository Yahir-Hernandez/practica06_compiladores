#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#set text(lang: "es")
#show figure.where(kind: table): set block(breakable: true)

#block(
  width: 100%,
  inset: 15pt,
  radius: 5pt,
  grid(
    columns: (1fr, 3fr, 1fr),
    align: horizon + center,
    image("imgs/UNAM.png", width: 2.5cm),
    align(center)[
      #text(size: 11pt, weight: "black")[
        Universidad Nacional Autónoma de México \
        Facultad de Ciencias · Laboratorio de Compiladores
      ]
      #v(0.4em)
      #text(size: 17pt, weight: "bold")[Práctica 6: Parser Canónico LR(1) y Compactación]
      #v(0.2em)
      #text(size: 13pt, weight: "semibold")[LALR(1)]
      #v(0.2em)
      #text(size: 10.5pt)[Construcción de Tablas, Fusión de Kernels y Motor de Ejecución]
      #v(0.5em)
      #text(size: 10pt, style: "italic")[
        Apis Lorenzana Said \
        Hernández Garcia Oscar Yahir \
        Sandoval Sandoval Gerardo Gael
      ]
    ],
    image("/imgs/ciencias.png", width: 2.5cm),
  ),
)

= Proceso Analítico LALR(1)
#align(center, image("imgs/a1p6.png", width: 80%))
== Resumen de estados y transiciones
#let items(..xs) = xs.pos().join(linebreak())

#grid(
  columns: (auto, auto),
  table(
    columns: (auto, auto, auto),
    align: (center + horizon, center + horizon, left + horizon),
    inset: 7pt,
    //stroke: 0.5pt + luma(150),
    stroke: (x, y) => (
      left: if x == 0 or y > 0 { 1pt } else { 0pt },
      right: 1pt,
      top: if y <= 1 { 1pt } else { 0pt },
      bottom: 1pt,
    ),
    fill: (_, y) => if y == 0 { luma(220) } else if calc.even(y) { luma(245) },

    table.header[*Estado*][*Origen*][*Ítems*],

    [$I_0$],
    [$"Cerradura"([S' -> .S, \$])$],
    items(
      $[S' -> .S, \$]$,
      $[S -> .L=R, \$]$,
      $[S -> .R, \$]$,
      $[L -> .*R, =\/\$]$,
      $[L -> ."id", =\/\$]$,
      $[R -> .L, \$]$,
    ),

    [$I_1$], [$"Goto"(I_0, S)$], items($[S' -> S., \$]$),

    [$I_2$], [$"Goto"(I_0, L)$], items($[S -> L.=R, \$]$, $[R -> L., \$]$),
    [$I_3$], [$"Goto"(I_0, R)$], items($[S -> R., \$]$),

    [$I_4$],
    [$"Goto"(I_0, *)$],
    items(
      $[L -> *.R, =\/\$]$,
      $[R -> .L, =\/\$]$,
      $[L -> .*R, =\/\$]$,
      $[L -> ."id", =\/\$]$,
    ),

    [$I_5$], [$"Goto"(I_0, "id")$], items($[L -> "id"., =\/\$]$),
  ),
  table(
    columns: (auto, auto, auto),
    align: (center + horizon, center + horizon, left + horizon),
    inset: 7pt,
    //stroke: 0.5pt + luma(150),
    stroke: (x, y) => (
      left: if x == 0 or y > 0 { 1pt } else { 0pt },
      right: 1pt,
      top: if y <= 1 { 1pt } else { 0pt },
      bottom: 1pt,
    ),
    fill: (_, y) => if y == 0 { luma(220) } else if calc.even(y) { luma(245) },

    table.header[*Estado*][*Origen*][*Ítems*],
    [$I_6$],
    [$"Goto"(I_2, =)$],
    items(
      $[S -> L=.R, \$]$,
      $[R -> .L, \$]$,
      $[L -> .*R, \$]$,
      $[L -> ."id", \$]$,
    ),

    [$I_7$], [$"Goto"(I_4, R)$], items($[L -> *R., =\/\$]$),

    [$I_8$], [$"Goto"(I_4, L)$], items($[R -> L., =\/\$]$),

    [$I_9$], [$"Goto"(I_6, R)$], items($[S -> L=R., \$]$),

    [$I_10$], [$"Goto"(I_6, L)$], items($[R -> L., \$]$),

    [$I_11$],
    [$"Goto"(I_6, *)$],
    items(
      $[L -> *.R, \$]$,
      $[R -> .L, \$]$,
      $[L -> .*R, \$]$,
      $[L -> ."id", \$]$,
    ),

    [$I_12$], [$"Goto"(I_6, "id")$], items($[L -> "id"., \$]$),

    [$I_13$], [$"Goto"(I_11, R)$], items($[L -> *R., \$]$),
  ),
)
== Listado de fusiones de kernels
#align(center, image("imgs/a2p6.png", width: 100%))
=== Autómata LALR(1)
#figure(
  diagram(
    node-stroke: 0.8pt + black,
    node-fill: white,
    edge-stroke: 0.8pt + black,
    spacing: (22mm, 20mm),

    // Estados
    node((2, 0), $I_0$, name: <i0>, shape: circle),

    node((0, 1), $I_1$, name: <i1>, shape: circle), // acepta
    node((1, 1), $I_3$, name: <i3>, shape: circle),
    node((2, 1), $I_2$, name: <i2>, shape: circle),
    node((3.5, 1), $I_("4,11")$, name: <i4_11>, shape: circle),
    node((5, 1), $I_("7,13")$, name: <i7_13>, shape: circle),

    node((3.5, 2.5), $I_("8,10")$, name: <i8_10>, shape: circle),

    node((0, 3.5), $I_9$, name: <i9>, shape: circle),
    node((2, 3.5), $I_6$, name: <i6>, shape: circle),
    node((5, 3.5), $I_("5,12")$, name: <i5_12>, shape: circle),

    // Transiciones desde I0
    edge(<i0>, <i1>, "->", $S$),
    edge(<i0>, <i3>, "->", $R$),
    edge(<i0>, <i2>, "->", $L$),
    edge(<i0>, <i4_11>, "->", $*$),
    edge(<i0>, <i5_12>, "->", $"id"$, bend: 80deg),

    // Transiciones desde I2
    edge(<i2>, <i6>, "->", $=$),

    // Transiciones desde I4,11
    edge(<i4_11>, <i4_11>, "->", $*$, bend: 130deg),
    edge(<i4_11>, <i7_13>, "->", $R$),
    edge(<i4_11>, <i8_10>, "->", $L$),
    edge(<i4_11>, <i5_12>, "->", $"id"$),

    // Transiciones desde I6
    edge(<i6>, <i9>, "->", $R$),
    edge(<i6>, <i8_10>, "->", $L$),
    edge(<i6>, <i4_11>, "->", $*$),
    edge(<i6>, <i5_12>, "->", $"id"$),
  ),
)
== Tabla de análisis LALR(1)
Nota: para el código los estados se
renumeraron conservando el número menor de cada fusión: $4 = I_("4,11")$, $5 = I_("5,12")$,
$7 = I_("7,13")$ y $8 = I_("8,10")$.

#let tabla-estilo = (
  inset: 6pt,
  align: center + horizon,
  stroke: 0.6pt + luma(120),
)

#figure(
  table(
    columns: (auto, auto, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    ..tabla-estilo,
    fill: (_, y) => if y <= 1 { luma(220) } else if calc.even(y) { luma(245) },
    table.header(
      table.cell(rowspan: 2)[*Estado*],
      table.cell(rowspan: 2)[*Estados LR(1)*],
      table.cell(colspan: 4)[*ACCION*],
      table.cell(colspan: 3)[*IR_A*],
      [$=$], [$*$], [$"id"$], [$\$$], [$S$], [$L$], [$R$],
    ),
    [0], [$I_0$], [], [s4], [s5], [], [1], [2], [3],
    [1], [$I_1$], [], [], [], [*acc*], [], [], [],
    [2], [$I_2$], [*s6*], [], [], [r6], [], [], [],
    [3], [$I_3$], [], [], [], [r3], [], [], [],
    [4], [$I_4, I_11$], [], [s4], [s5], [], [], [8], [7],
    [5], [$I_5, I_12$], [r5], [], [], [r5], [], [], [],
    [6], [$I_6$], [], [s4], [s5], [], [], [8], [9],
    [7], [$I_7, I_13$], [r4], [], [], [r4], [], [], [],
    [8], [$I_8, I_10$], [r6], [], [], [r6], [], [], [],
    [9], [$I_9$], [], [], [], [r2], [], [], [],
  ),
  caption: [Tabla LALR(1).],
)


== Demostración del conflicto SLR(1) en '$=$'

En esta gramática $"Follow"(S) = {\$}$ y $"Follow"(L) = "Follow"(R) = {=, \$}$. El '$=$' entra a
$"Follow"(L)$ por $S -> L = R$, y como $R -> L$ y $L -> *R$, los Follow de $L$ y $R$ se contienen
mutuamente.

En el autómata LR(0), $"Goto"(I_0, L)$ lleva al estado $I_2 = {S -> L. = R, R -> L.}$. El primer ítem
pide desplazar con '$=$' (s6) y el segundo está completo, así que SLR(1) reduce $R -> L$ con todo
$"Follow"(R)$, que incluye '$=$'. La celda $"ACCION"[2, =]$ queda con ${s 6, r 6}$ y la gramática no es
SLR(1). El problema es que $"Follow"(R)$ junta contextos distintos: una $R$ va seguida de '$=$' sólo
cuando está debajo de un $*$ ($S => L = R => *R = R$), nunca cuando sale de reducir la $L$ con la que
empieza la sentencia.

LR(1) sí conserva ese contexto. En $I_0$ el ítem $R -> .L$ se agrega por cerradura desde
$[S -> .R, \$]$, y como $"First"(epsilon \$) = {\$}$, su lookahead es únicamente $\$$. Al avanzar sobre
$L$ queda $I_2 = {[S -> L. = R, \$], [R -> L., \$]}$, de modo que r6 va sólo en la columna $\$$ y s6 en
la columna '$=$'. El conflicto desaparece.

La fusión LALR(1) no lo vuelve a meter, porque el kernel de $I_2$, ${S -> L. = R, R -> L.}$, no lo
comparte ningún otro estado y por eso $I_2$ conserva su lookahead exacto. Los estados que sí se fusionan
($I_("4,11")$, $I_("5,12")$, $I_("7,13")$ e $I_("8,10")$) tienen un solo ítem de reducción cada uno, así
que unir sus lookaheads tampoco provoca conflictos reducción/reducción. La tabla LALR(1) queda sin
conflictos. $qed$

= Diseño de solución

El driver es el mismo de la práctica 5; sólo cambian la gramática, las tablas y las acciones semánticas.

#figure(
  diagram(
    node-stroke: 0.8pt + black,
    node-fill: white,
    edge-stroke: 0.8pt + black,
    node-corner-radius: 3pt,
    spacing: (10mm, 11mm),

    node((0, 0), align(center)[Entrada \ `* id = id`], name: <entrada>, shape: rect),
    node((1, 0), align(center)[*Lexer* \ `tokenizar()`], name: <lexer>, shape: rect),
    node((2, 0), align(center)[Tokens \ `* id = id $`], name: <tokens>, shape: rect),
    node((1, 1), align(center)[*Driver* \ `analizar()` \ ciclo shift / reduce], name: <driver>, shape: rect, fill: luma(235)),
    node((0, 1), align(center)[*Pila* \ (estado, símbolo, nodo)], name: <pila>, shape: rect),
    node((2, 1), align(center)[*Tablas LALR(1)* \ `ACCION[10][4]` \ `IR_A[10][3]`], name: <tablas>, shape: rect),
    node((2, 2), align(center)[*Gramática* \ `PRODUCCIONES` \ ($A$, $|beta|$)], name: <gram>, shape: rect),
    node((1, 2), align(center)[*Acciones semánticas* \ `accionSemantica()`], name: <sem>, shape: rect),
    node((1, 3), align(center)[*Aceptar* \ AST + árbol de reducciones], name: <ok>, shape: rect),
    node((0, 2), align(center)[*Error* \ estado, celda vacía, \ terminales esperados], name: <err>, shape: rect),

    edge(<entrada>, <lexer>, "->"),
    edge(<lexer>, <tokens>, "->"),
    edge(<tokens>, <driver>, "->", [token actual], label-side: left),
    edge(<driver>, <pila>, "<->", [push / pop]),
    edge(<driver>, <tablas>, "<->", [consulta]),
    edge(<driver>, <gram>, "->", [regla k], label-side: left),
    edge(<driver>, <sem>, "->", [reducir]),
    edge(<sem>, <ok>, "->", [acc]),
    edge(<driver>, <err>, "->", [celda vacía], label-side: right),
  ),
  caption: [Arquitectura del driver de pila.],
)

La pila guarda pares (estado, símbolo) junto con el subárbol de cada símbolo y empieza en el estado 0.
En cada paso, con $s$ en el tope y $a$ como token actual:

+ $"ACCION"[s, a] = s j$: se apila $(j, a)$ y se avanza al siguiente token.
+ $"ACCION"[s, a] = r k$ con $A -> beta$: se sacan $|beta|$ entradas, se arma el subárbol de $A$ y se
  apila $"IR_A"[s', A]$, donde $s'$ es el nuevo tope.
+ $"ACCION"[s, a] = "acc"$: la cadena es válida y se imprime el AST.
+ Celda vacía: la cadena se rechaza.

= Tabla de vectores de prueba

El estado final es el que queda en el tope de la pila al aceptar o al encontrar la celda vacía.

#figure(
  table(
    columns: (auto, auto, auto, auto, 1fr),
    ..tabla-estilo,
    align: (center + horizon, left + horizon, center + horizon, center + horizon, left + horizon),
    fill: (_, y) => if y == 0 { luma(220) } else if calc.even(y) { luma(245) },
    table.header[*\#*][*Tokens de entrada*][*Estado final*][*Resultado*][*Motivo*],
    [1], [`id $`], [1], [Aceptada], [$S => R => L => "id"$.],
    [2], [`* id $`], [1], [Aceptada], [$S => R => L => *R => *"id"$.],
    [3], [`id = id $`], [1], [Aceptada], [En el estado 2 con '$=$' se desplaza y luego se reduce $S -> L = R$.],
    [4], [`* id = id $`], [1], [Aceptada], [$*"id"$ se reduce a $L$ y sigue igual que el caso 3.],
    [5], [`* * id = * id $`], [1], [Aceptada], [El estado 4 se desplaza a sí mismo con cada $*$.],
    [6], [`$`], [0], [Rechazada], [$"ACCION"[0, \$]$ vacía: la cadena vacía no se genera.],
    [7], [`id = $`], [6], [Rechazada], [$"ACCION"[6, \$]$ vacía: falta el lado derecho.],
    [8], [`= id $`], [0], [Rechazada], [$"ACCION"[0, =]$ vacía: falta el lado izquierdo.],
    [9], [`id = id = id $`], [9], [Rechazada], [$"ACCION"[9, =]$ vacía: no hay asignaciones encadenadas.],
    [10], [`id id $`], [5], [Rechazada], [$"ACCION"[5, "id"]$ vacía: después de $"id"$ sólo puede venir '$=$' o $\$$.],
  ),
  caption: [Vectores de prueba.],
)

= Enlace al repositorio

#link("https://github.com/Yahir-Hernandez/practica06_compiladores")
