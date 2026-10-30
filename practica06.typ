#let placeholder = align(
  center,
  block(
    width: 90%,
    height: 30em,
    inset: 10em,
    stroke: 1pt + black,
    text(
      "Image placeholder",
      weight: "bold",
      size: 2em,
    )
  )
)

= Proceso Analítico LALR(1)

#placeholder

== Resumen de estado del automata LALR(1)
#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 10pt,
  align: top,

  box(stroke: 0.5pt, inset: 8pt, radius: 4pt, width: 100%)[
    $
      I_0 & = { \
        & [S' -> .S, \$], \
        & [S -> .L=R, \$], \
        & [S -> .R, \$], \
        & [L -> .*R, =\/\$], \
        & [L -> ."id", =\/\$], \
        & [R -> .L, \$] \
        & }
    $
  ],

  box(stroke: 0.5pt, inset: 8pt, radius: 4pt, width: 100%)[
    $
      I_1 & = "Goto"(I_0, S) = { \
        & [S' -> S., \$] \
        & }
    $
  ],

  box(stroke: 0.5pt, inset: 8pt, radius: 4pt, width: 100%)[
    $
      I_2 & = "Goto"(I_0, L) = { \
        & [S -> L.=R, \$], \
        & [R -> L., \$] \
        & }
    $
  ],

  box(stroke: 0.5pt, inset: 8pt, radius: 4pt, width: 100%)[
    $
      I_3 & = "Goto"(I_0, R) = { \
        & [S -> R., \$] \
        & }
    $
  ],

  box(stroke: 0.5pt, inset: 8pt, radius: 4pt, width: 100%)[
    $
      I_4 & = "Goto"(I_0, *) = { \
        & [L -> *.R, =\/\$], \
        & [R -> .L, =\/\$], \
        & [L -> .*R, =\/\$], \
        & [L -> ."id", =\/\$] \
        & }
    $
  ],

  box(stroke: 0.5pt, inset: 8pt, radius: 4pt, width: 100%)[
    $
      I_5 & = "Goto"(I_0, "id") = { \
        & [L -> "id"., =\/\$] \
        & }
    $
  ],

  box(stroke: 0.5pt, inset: 8pt, radius: 4pt, width: 100%)[
    $
      I_6 & = "Goto"(I_2, =) = { \
        & [S -> L=.R, \$], \
        & [R -> .L, \$], \
        & [L -> .*R, \$], \
        & [L -> ."id", \$] \
        & }
    $
  ],

  box(stroke: 0.5pt, inset: 8pt, radius: 4pt, width: 100%)[
    $
      I_7 & = "Goto"(I_4, R) = { \
        & [L -> *R., =\/\$] \
        & }
    $
  ],

  box(stroke: 0.5pt, inset: 8pt, radius: 4pt, width: 100%)[
    $
      I_8 & = "Goto"(I_4, L) = { \
        & [R -> L., =\/\$] \
        & }
    $
  ],

  box(stroke: 0.5pt, inset: 8pt, radius: 4pt, width: 100%)[
    $
      I_9 & = "Goto"(I_6, R) = { \
        & [S -> L=R., \$] \
        & }
    $
  ],

  box(stroke: 0.5pt, inset: 8pt, radius: 4pt, width: 100%)[
    $
      I_10 & = "Goto"(I_6, L) = { \
        & [R -> L., \$] \
        & }
    $
  ],

  box(stroke: 0.5pt, inset: 8pt, radius: 4pt, width: 100%)[
    $
      I_11 & = "Goto"(I_6, *) = { \
        & [L -> *.R, \$], \
        & [R -> .L, \$], \
        & [L -> .*R, \$], \
        & [L -> ."id", \$] \
        & }
    $
  ],

  box(stroke: 0.5pt, inset: 8pt, radius: 4pt, width: 100%)[
    $
      I_12 & = "Goto"(I_6, "id") = { \
        & [L -> "id"., \$] \
        & }
    $
  ],

  box(stroke: 0.5pt, inset: 8pt, radius: 4pt, width: 100%)[
    $
      I_13 & = "Goto"(I_11, R) = { \
        & [L -> *R., \$] \
        & }
    $
  ],
)



