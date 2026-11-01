# Práctica 6: parser LALR(1) para asignaciones con apuntadores

Motor (driver) de un parser LALR(1) escrito en C++17.

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
make          
make test     # ejecuta los 10 casos de tests
make reporte  
make clean    
```

## Uso

La entrada es una lista de tokens: `*`, `=` e `id`. Cualquier otro identificador también
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


