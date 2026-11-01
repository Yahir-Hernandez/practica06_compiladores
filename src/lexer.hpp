#pragma once

#include <stdexcept>
#include <string>
#include <vector>

#include "gramatica.hpp"

struct Token {
    Terminal tipo;
    std::string lexema;
    int linea;
    int columna;
};

class ErrorLexico : public std::runtime_error {
public:
    ErrorLexico(const std::string& mensaje, int linea, int columna)
        : std::runtime_error(mensaje), linea(linea), columna(columna) {}

    int linea;
    int columna;
};

// Convierte la entrada en la lista de tokens que consume el motor LR, terminada en $.
// '*' y '=' son símbolos; cualquier identificador ("id", "x", "ptr_1") es el terminal id.
std::vector<Token> tokenizar(const std::string& texto);

// "id x" si el lexema es un nombre propio; para los demás tokens, su nombre.
std::string describirToken(const Token& token);
