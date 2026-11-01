# Práctica 6: parser LALR(1) para asignaciones con apuntadores

Motor (driver) de un parser LALR(1) escrito en C++17, que reutiliza la arquitectura de la práctica 5
(pila de estados, tablas ACCION/IR_A, acciones semánticas y árbol de reducciones). Las tablas LALR(1)
se calcularon a mano (ver `practica06.typ`) y están codificadas en `src/tabla_lalr.cpp`.

Gramática aumentada:

```
1. S' -> S
2. S  -> L = R
3. S  -> R
4. L  -> * R
5. L  -> id
6. R  -> L
```

## Compilación y pruebas

Se requiere un compilador con C++17 (g++ o clang++) y `make`.

```bash
make          # genera ./lalr
make test     # ejecuta los 10 casos de tests/casos (5 válidos v*, 5 inválidos i*)
make reporte  # compila practica06.pdf y ValidacionSaid.pdf (requiere typst)
make clean    # borra build/, temp/, ./lalr y los PDF generados
```

## Uso

La entrada es una lista de tokens: `*`, `=` e `id`. Cualquier otro identificador (`p`, `ptr_1`) también
es el token `id` y su nombre se conserva en el AST.

```bash
./lalr tests/casos/v04_asignacion_deref.txt   # analiza un archivo
./lalr -e "* id = id"                          # analiza el texto dado
echo "* * p = * q" | ./lalr                    # lee la entrada estándar
./lalr -t -r -e "* id = id"                    # con traza de la pila y árbol de reducciones
```

| Opción | Efecto |
|--------|--------|
| `-e TEXTO` | analiza `TEXTO` en lugar de un archivo |
| `-t` | muestra la traza de la pila: contenido, entrada restante y acción de cada paso |
| `-r` | muestra el árbol de reducciones (la regla aplicada en cada nodo) |
| `-h` | ayuda |

Si la cadena es válida, el programa imprime `Resultado: ACEPTADA`, el estado final y el AST; si no,
imprime `Resultado: RECHAZADA`, el estado en el que se detectó el error y la celda de ACCION vacía.
