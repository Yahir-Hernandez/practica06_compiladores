#pragma once

#include <memory>
#include <ostream>
#include <string>
#include <vector>

struct Nodo;
using NodoPtr = std::unique_ptr<Nodo>;

struct Nodo {
    std::string etiqueta;
    std::vector<NodoPtr> hijos;
};

template <typename... Hijos>
NodoPtr nuevoNodo(std::string etiqueta, Hijos&&... hijos) {
    auto nodo = std::make_unique<Nodo>();
    nodo->etiqueta = std::move(etiqueta);
    (nodo->hijos.push_back(std::forward<Hijos>(hijos)), ...);
    return nodo;
}

// Acción semántica de la regla k: recibe los valores de los |β| símbolos que se sacan
// de la pila (de izquierda a derecha) y devuelve el subárbol abstracto de A.
NodoPtr accionSemantica(int regla, std::vector<NodoPtr>& valores);

// Dibuja el árbol con ramas ├── └── │, un nodo por línea.
void imprimirArbol(const Nodo& raiz, std::ostream& salida);
