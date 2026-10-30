#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

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
#block(
  width: 100%,
  height: 1cm,
  fill: rgb("#e23d3d"),
  inset: 10pt,
  text(weight: "black", size: 17pt,"AQUI FALTA COMPLETAR")
)