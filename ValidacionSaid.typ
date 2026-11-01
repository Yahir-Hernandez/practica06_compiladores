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
      #text(size: 13pt, weight: "semibold")[Anexo: Ejercicios de Validación]
      #v(0.2em)
      #text(size: 10.5pt)[Auditoría de lookaheads, fusiones de kernels y transiciones]
      #v(0.5em)
      #text(size: 10pt, style: "italic")[
        Apis Lorenzana Said
      ]
    ],
    image("/imgs/ciencias.png", width: 2.5cm),
  ),
)

#let mal(x) = text(fill: rgb("#c0392b"), weight: "bold", x)
#let rojo = rgb("#f8d7da")

#let tabla-estilo = (
  inset: 6pt,
  align: center + horizon,
  stroke: 0.6pt + luma(120),
)


= Gramática

Mi dígito es $D = 5$, que es impar, así que la producción (4) es $L -> \& R$:

#align(center, grid(
  columns: 3,
  column-gutter: 2.5em,
  row-gutter: 0.6em,
  [(1) $S' -> S$], [(2) $S -> L = R$], [(3) $S -> R$],
  [(4) $L -> \& R$], [(5) $L -> "id"$], [(6) $R -> L$],
))


Para obtener $I_0$ apliqué la cerradura a $[S' -> .S, \$]$. Por cada ítem $[A -> alpha . B beta, a]$
agregué $[B -> . gamma, b]$ con $b in "First"(beta a)$:

#figure(
  table(
    columns: (auto, auto, auto, 1fr),
    ..tabla-estilo,
    fill: (_, y) => if y == 0 { luma(220) } else if calc.even(y) { luma(245) },
    table.header[*Ítem que se expande*][*$beta a$*][*$"First"(beta a)$*][*Ítems agregados*],
    [$[S' -> .S, \$]$], [$\$$], [${\$}$], [$[S -> .L = R, \$]$, $[S -> .R, \$]$],
    [$[S -> .L = R, \$]$], [$= R \$$], [${=}$], [$[L -> .\& R, =]$, $[L -> ."id", =]$],
    [$[S -> .R, \$]$], [$\$$], [${\$}$], [$[R -> .L, \$]$],
    [$[R -> .L, \$]$], [$\$$], [${\$}$], [$[L -> .\& R, \$]$, $[L -> ."id", \$]$],
  ),
  caption: [Cerradura de $[S' -> .S, \$]$.],
)

$ I_0 = { [S' -> .S, \$], [S -> .L = R, \$], [S -> .R, \$], [L -> .\& R, =\/\$], [L -> ."id", =\/\$], [R -> .L, \$] } $

Para $I_2 = "Goto"(I_0, L)$ basta avanzar el punto en los dos ítems que tienen $L$ enfrente. La cerradura
no agrega nada, porque después del punto queda un terminal o nada:
$ I_2 = { [S -> L . = R, \$], [R -> L ., \$] } $

Con el operador $\&$, $"Goto"(I_0, \&)$ da el kernel $[L -> \& . R, =\/\$]$. Como después de $R$ no hay
nada, la cerradura pasa los mismos lookaheads:
$ I_4 = { [L -> \& . R, =\/\$], [R -> .L, =\/\$], [L -> .\& R, =\/\$], [L -> ."id", =\/\$] } $
Con otro $\&$ se regresa al mismo kernel, así que $"Goto"(I_4, \&) = I_4$, y al leer $R$ se llega a
$I_7 = {[L -> \& R ., =\/\$]}$. Del lado derecho de la asignación pasa lo mismo, pero sólo con $\$$:
$"Goto"(I_6, \&) = I_11 = {[L -> \& . R, \$], [R -> .L, \$], [L -> .\& R, \$], [L -> ."id", \$]}$, con
$"Goto"(I_11, \&) = I_11$ y $"Goto"(I_11, R) = I_13 = {[L -> \& R ., \$]}$.

Los ítems de $I_0$ e $I_2$ del extracto coinciden con los míos (salvo el $*$ en lugar de $\&$). Los tres
errores son estos:

+ *Se llama $I_9$ a ${[L -> \& . R, \$]}$.* Ese estado es $I_11 = "Goto"(I_6, \&)$; $I_9$ es
  $"Goto"(I_6, R) = {[S -> L = R ., \$]}$. Como $"Goto"$ es una función, cada transición tiene un único
  destino determinado por sus ítems. Con esa confusión, $"IR_A"[6, R]$ llevaría a un estado que desplaza
  en vez de reducir $S -> L = R$, y ninguna asignación se aceptaría.

+ *No se fusionan $I_4$ e $I_11$.* El núcleo de un estado son sus ítems sin el lookahead, y los dos
  tienen el mismo: ${L -> \& . R}$. El '$=$' en el que difieren es un lookahead, no parte del núcleo. La
  regla LALR(1) obliga a unirlos en $[L -> \& . R, =\/\$]$; si no se hace, la tabla sigue siendo la
  LR(1) canónica de 14 estados.

+ *Se pone _Reduce 6_ en $"ACCION"[2, =]$.* En LR(1) se reduce con $a$ sólo si $[A -> alpha ., a]$ está
  en el estado. En $I_2$ el ítem es $[R -> L ., \$]$, porque viene de $[S -> .R, \$]$ con
  $"First"(epsilon \$) = {\$}$. Meter r6 bajo '$=$' es usar $"Follow"(R)$, que es el criterio de SLR(1),
  y crea un conflicto s6/r6 que en LALR(1) no existe.

Para el fallo tipo A cambié el lookahead de un ítem de segundo nivel de la cerradura de $I_0$
($S' -> S$, luego $S -> R$, luego $R -> L$): usé $"Follow"(R) = {=, \$}$ en lugar de
$"First"(epsilon \$) = {\$}$. El ítem queda #mal($[R -> .L, =\/\$]$), y el error se arrastra a
$I_2 = {[S -> L . = R, \$], #mal($[R -> L ., =\/\$]$)}$.

Para el fallo tipo B fusioné $I_3 = {[S -> R ., \$]}$ con $I_("7,13") = {[L -> \& R ., =\/\$]}$ en un
estado $J$. Se parecen porque los dos son un solo ítem completo que termina en $R .$ y se alcanzan
leyendo $R$, pero son producciones distintas con el punto en otra posición. $J$ reduce r3 y r4 con
$\$$, lo que da un conflicto reducción/reducción falso.

#figure(
  diagram(
    node-stroke: 0.8pt + black,
    node-fill: white,
    edge-stroke: 0.8pt + black,
    spacing: (20mm, 14mm),

    node((2, 0), $I_0$, name: <i0>, shape: circle),
    node((0, 1), $I_1$, name: <i1>, shape: circle),
    node((2, 1), $I_2$, name: <i2>, shape: circle, stroke: 1.2pt + rgb("#c0392b")),
    node((3.5, 1), $I_("4,11")$, name: <i4>, shape: circle),
    node((1, 2.3), $J$, name: <j>, shape: circle, stroke: 1.2pt + rgb("#c0392b")),
    node((3.5, 2.3), $I_("8,10")$, name: <i8>, shape: circle),
    node((0, 3.5), $I_9$, name: <i9>, shape: circle),
    node((2, 3.5), $I_6$, name: <i6>, shape: circle),
    node((5, 2.3), $I_("5,12")$, name: <i5>, shape: circle),

    edge(<i0>, <i1>, "->", $S$),
    edge(<i0>, <i2>, "->", $L$),
    edge(<i0>, <j>, "->", text(fill: rgb("#c0392b"), $R$)),
    edge(<i0>, <i4>, "->", $\&$),
    edge(<i0>, <i5>, "->", $"id"$, bend: 40deg),
    edge(<i2>, <i6>, "->", $=$),
    edge(<i4>, <i4>, "->", $\&$, bend: 130deg),
    edge(<i4>, <j>, "->", text(fill: rgb("#c0392b"), $R$)),
    edge(<i4>, <i8>, "->", $L$),
    edge(<i4>, <i5>, "->", $"id"$),
    edge(<i6>, <i9>, "->", $R$),
    edge(<i6>, <i8>, "->", $L$),
    edge(<i6>, <i4>, "->", $\&$),
    edge(<i6>, <i5>, "->", $"id"$, bend: -20deg),
  ),
  caption: [Autómata LALR(1) con los dos fallos.],
)

#block(breakable: false, figure(
  table(
    columns: (auto, auto, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    ..tabla-estilo,
    fill: (x, y) => if y <= 1 { luma(220) } else if (x, y) in ((2, 4), (5, 5)) { rojo } else if calc.even(y) { luma(245) },
    table.header(
      table.cell(rowspan: 2)[*Estado*],
      table.cell(rowspan: 2)[*Estados LR(1)*],
      table.cell(colspan: 4)[*ACCION*],
      table.cell(colspan: 3)[*IR_A*],
      [$=$], [$\&$], [$"id"$], [$\$$], [$S$], [$L$], [$R$],
    ),
    [0], [$I_0$], [], [s4], [s5], [], [1], [2], mal[J],
    [1], [$I_1$], [], [], [], [acc], [], [], [],
    [2], [$I_2$], mal[s6 / r6], [], [], [r6], [], [], [],
    [J], [$I_3, I_7, I_13$], [r4], [], [], mal[r3 / r4], [], [], [],
    [4], [$I_4, I_11$], [], [s4], [s5], [], [], [8], mal[J],
    [5], [$I_5, I_12$], [r5], [], [], [r5], [], [], [],
    [6], [$I_6$], [], [s4], [s5], [], [], [8], [9],
    [8], [$I_8, I_10$], [r6], [], [], [r6], [], [], [],
    [9], [$I_9$], [], [], [], [r2], [], [], [],
  ),
  caption: [Tabla LALR(1) con los dos fallos.],
))


Partí de la colección LR(1) con el fallo A ya aplicado y agrupé los estados por núcleo, tomando cada
ítem como el par (producción, posición del punto):

#figure(
  table(
    columns: (auto, auto, auto),
    ..tabla-estilo,
    align: (left + horizon, center + horizon, center + horizon),
    fill: (_, y) => if y == 0 { luma(220) } else if y == 4 or y == 8 { rojo } else if calc.even(y) { luma(245) },
    table.header[*Núcleo*][*Estados*][*Lookaheads unidos*],
    [${(S' -> S, 0), dots}$], [$I_0$], [—],
    [${(S' -> S, 1)}$], [$I_1$], [${\$}$],
    [${(S -> L = R, 1), (R -> L, 1)}$], [$I_2$], [#mal[${=, \$}$]],
    [${(S -> R, 1)}$], [$I_3$], [${\$}$],
    [${(L -> \& R, 1), dots}$], [$I_4, I_11$], [${=, \$}$],
    [${(L -> "id", 1)}$], [$I_5, I_12$], [${=, \$}$],
    [${(S -> L = R, 2), dots}$], [$I_6$], [${\$}$],
    [${(L -> \& R, 2)}$], [$I_7, I_13$], [${=, \$}$],
    [${(R -> L, 1)}$], [$I_8, I_10$], [${=, \$}$],
    [${(S -> L = R, 3)}$], [$I_9$], [${\$}$],
  ),
  caption: [Agrupación por núcleo.],
)

Aquí ya se ve que la fusión B es inválida: $(S -> R, 1)$ y $(L -> \& R, 2)$ son núcleos distintos, y el
algoritmo sólo une estados con el núcleo idéntico, así que nunca produciría $J$. El fallo A no aparece
en este paso porque sólo cambia un lookahead y los núcleos quedan iguales.

Después construí ACCION. Se desplaza con $[A -> alpha . a beta, b]$, se reduce con $[A -> alpha ., a]$
en la columna $a$, y si una celda recibe dos acciones el algoritmo declara que la gramática no es
LALR(1). Las colisiones salen de estos ítems:

#figure(
  table(
    columns: (auto, 1fr, 1fr, auto),
    ..tabla-estilo,
    align: (center + horizon, left + horizon, left + horizon, center + horizon),
    fill: (_, y) => if y == 0 { luma(220) } else { rojo.lighten(40%) },
    table.header[*Celda*][*Acción 1*][*Acción 2*][*Tipo*],
    [$[2, =]$],
    [$s 6$ por $[S -> L . = R, \$]$],
    [$r 6$ por #mal($[R -> L ., =]$), que viene de #mal($[R -> .L, =]$) en $I_0$],
    [S/R],
    [$[J, \$]$],
    [$r 3$ por $[S -> R ., \$]$ de $I_3$],
    [$r 4$ por $[L -> \& R ., \$]$ de $I_13$],
    [R/R],
  ),
  caption: [Traza de las colisiones.],
)

Es decir, $"ACCION"[2, =] = {s 6} union {r 6}$ y $"ACCION"[J, \$] = {r 3} union {r 4}$. Como la gramática
sí es LALR(1) (la tabla correcta no tiene conflictos), las colisiones vienen de los fallos. Si se rastrea
la primera, el '$=$' de $[R -> L ., =]$ viene de $[R -> .L, =]$ en $I_0$, que salió de expandir
$[S -> .R, \$]$ con $"First"(epsilon \$) = {\$}$. Ahí no hay forma de obtener '$=$', así que el error está
justo en esa cerradura.

Por último, en IR_A el algoritmo pide que el destino de cada transición sea la unión de los estados que
comparten núcleo con $"Goto"(I, X)$. En el autómata corrupto, $"IR_A"[0, R]$ e $"IR_A"[4, R]$ apuntan los dos a $J$, aunque
$"Goto"(I_0, R) = I_3$ y $"Goto"(I_4, R) = I_7$ tienen núcleos distintos. Eso confirma que la fusión B
rompe la construcción.
