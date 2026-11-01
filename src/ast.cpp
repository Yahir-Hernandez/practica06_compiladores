#include "ast.hpp"

NodoPtr accionSemantica(int regla, std::vector<NodoPtr>& v) {
    switch (regla) {
        case 2:  // S -> L = R: el '=' queda como raíz de la asignación
            return nuevoNodo("Asignación (=)", std::move(v[0]), std::move(v[2]));
        case 3:  // S -> R
            return nuevoNodo("Expresión", std::move(v[0]));
        case 4:  // L -> * R
            return nuevoNodo("Deref (*)", std::move(v[1]));
        default:  // reglas unitarias (5 L -> id, 6 R -> L): el valor sube sin cambios
            return std::move(v[0]);
    }
}

namespace {

void imprimirRama(const Nodo& nodo, const std::string& prefijo, bool ultimo, std::ostream& salida) {
    salida << prefijo << (ultimo ? "└── " : "├── ") << nodo.etiqueta << '\n';
    const std::string prefijoHijos = prefijo + (ultimo ? "    " : "│   ");
    for (size_t i = 0; i < nodo.hijos.size(); ++i)
        imprimirRama(*nodo.hijos[i], prefijoHijos, i + 1 == nodo.hijos.size(), salida);
}

}  // namespace

void imprimirArbol(const Nodo& raiz, std::ostream& salida) {
    salida << raiz.etiqueta << '\n';
    for (size_t i = 0; i < raiz.hijos.size(); ++i)
        imprimirRama(*raiz.hijos[i], "", i + 1 == raiz.hijos.size(), salida);
}
