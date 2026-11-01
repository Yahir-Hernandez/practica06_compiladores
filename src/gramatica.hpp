#pragma once

#include <string_view>

// Terminales de la gramática. El orden coincide con las columnas de la tabla ACCION.
enum Terminal : int {
    T_IGUAL,      // =
    T_ASTERISCO,  // *
    T_ID,
    T_FIN,  // $
};
constexpr int NUM_TERMINALES = T_FIN + 1;

// No terminales. El orden coincide con las columnas de la tabla IR_A.
enum NoTerminal : int {
    NT_S,
    NT_L,
    NT_R,
    NT_S_PRIMA,  // S' nunca se reduce (se acepta), por eso no tiene columna en IR_A
};
constexpr int NUM_NO_TERMINALES = NT_S_PRIMA;

// Producción A -> X1 ... Xn. El motor sólo necesita A y n para reducir;
// el texto se usa en la traza y en el árbol de reducciones.
struct Produccion {
    NoTerminal izquierda;
    int longitud;
    std::string_view texto;
};

// Índices 1..6 = numeración de reglas del enunciado; el índice 0 no se usa.
constexpr int NUM_PRODUCCIONES = 7;
extern const Produccion PRODUCCIONES[NUM_PRODUCCIONES];
constexpr int REGLA_INICIAL = 1;  // S' -> S

std::string_view nombreTerminal(Terminal t);
std::string_view nombreNoTerminal(NoTerminal a);
