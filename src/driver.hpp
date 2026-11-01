#pragma once

#include <string>
#include <vector>

#include "ast.hpp"
#include "lexer.hpp"

// Una fila de la traza: contenido de la pila y de la entrada antes de ejecutar la acción.
struct PasoTraza {
    std::string pila;
    std::string entrada;
    std::string accion;
};

struct ResultadoAnalisis {
    bool aceptada = false;
    NodoPtr ast;         // árbol abstracto construido por las acciones semánticas
    NodoPtr reducciones;  // árbol con la regla usada en cada reducción
    std::vector<PasoTraza> traza;
    std::string error;
    int estadoFinal = 0;  // estado en el tope de la pila al aceptar o detectar el error
};

// Motor LR: interpreta las tablas ACCION e IR_A sobre la lista de tokens (que termina en $).
ResultadoAnalisis analizar(const std::vector<Token>& tokens, bool registrarTraza);
