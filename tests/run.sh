#!/usr/bin/env bash
# Ejecuta cada caso de tests/casos y compara la salida (stdout + stderr) con tests/esperado.
# Los casos v* deben aceptarse (código 0) y los i* rechazarse (código 1).
set -u
cd "$(dirname "$0")/.."

mkdir -p temp
pasaron=0
fallaron=0

for caso in tests/casos/*; do
    nombre=$(basename "$caso")
    base=${nombre%.*}
    obtenido=temp/$base.out
    ./lalr "$caso" >"$obtenido" 2>&1
    codigo=$?

    codigo_esperado=0
    [[ $base == i* ]] && codigo_esperado=1

    if [[ $codigo -eq $codigo_esperado ]] && diff -u "tests/esperado/$base.out" "$obtenido" >temp/$base.diff; then
        printf 'ok    %s\n' "$base"
        pasaron=$((pasaron + 1))
    else
        printf 'FALLO %s (código %d, esperado %d; ver temp/%s.diff)\n' "$base" "$codigo" "$codigo_esperado" "$base"
        fallaron=$((fallaron + 1))
    fi
done

printf '\n%d pruebas, %d pasaron, %d fallaron\n' $((pasaron + fallaron)) "$pasaron" "$fallaron"
[[ $fallaron -eq 0 ]]
