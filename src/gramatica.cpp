#include "gramatica.hpp"

// Gramática aumentada; el índice de cada producción es su número de regla en el enunciado.
const Produccion PRODUCCIONES[NUM_PRODUCCIONES] = {
    {NT_S_PRIMA, 0, ""},  // sin uso: las reglas empiezan en 1
    {NT_S_PRIMA, 1, "S' -> S"},
    {NT_S, 3, "S -> L = R"},
    {NT_S, 1, "S -> R"},
    {NT_L, 2, "L -> * R"},
    {NT_L, 1, "L -> id"},
    {NT_R, 1, "R -> L"},
};

std::string_view nombreTerminal(Terminal t) {
    static constexpr std::string_view NOMBRES[NUM_TERMINALES] = {"=", "*", "id", "$"};
    return NOMBRES[t];
}

std::string_view nombreNoTerminal(NoTerminal a) {
    static constexpr std::string_view NOMBRES[NUM_NO_TERMINALES + 1] = {"S", "L", "R", "S'"};
    return NOMBRES[a];
}
