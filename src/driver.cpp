#include "driver.hpp"

#include <string_view>

#include "tabla_lalr.hpp"

namespace {

// Pila clásica s0 X1 s1 ... Xm sm: cada entrada guarda el estado y el símbolo con el que se
// llegó a él, junto con sus valores semánticos (subárbol abstracto y subárbol de reducciones).
struct EntradaPila {
    int estado;
    std::string_view simbolo;
    NodoPtr ast;
    NodoPtr reduccion;
};

std::string textoPila(const std::vector<EntradaPila>& pila) {
    std::string texto = std::to_string(pila.front().estado);
    for (size_t i = 1; i < pila.size(); ++i)
        texto += " " + std::string(pila[i].simbolo) + " " + std::to_string(pila[i].estado);
    return texto;
}

std::string textoEntrada(const std::vector<Token>& tokens, size_t desde) {
    std::string texto;
    for (size_t i = desde; i < tokens.size(); ++i) {
        if (!texto.empty()) texto += ' ';
        texto += nombreTerminal(tokens[i].tipo);
    }
    return texto;
}

std::string celdaAccion(int estado, Terminal t) {
    return "ACCION[" + std::to_string(estado) + ", " + std::string(nombreTerminal(t)) + "]";
}

// Los terminales esperados son las columnas no vacías de la fila del estado actual.
std::string mensajeError(int estado, const Token& token) {
    std::string esperados;
    for (int t = 0; t < NUM_TERMINALES; ++t) {
        if (ACCION[estado][t].tipo == TipoAccion::Error) continue;
        if (!esperados.empty()) esperados += ", ";
        esperados += nombreTerminal(static_cast<Terminal>(t));
    }
    const std::string encontrado =
        token.tipo == T_FIN ? "el fin de la entrada" : "'" + describirToken(token) + "'";
    return "Error sintáctico en " + std::to_string(token.linea) + ":" + std::to_string(token.columna) +
           ": no se esperaba " + encontrado + " (" + celdaAccion(estado, token.tipo) +
           " está vacía). Se esperaba: " + esperados + ".";
}

}  // namespace

ResultadoAnalisis analizar(const std::vector<Token>& tokens, bool registrarTraza) {
    ResultadoAnalisis resultado;
    std::vector<EntradaPila> pila;
    pila.push_back({0, "", nullptr, nullptr});
    size_t siguiente = 0;

    while (true) {
        const int estado = pila.back().estado;
        const Token& token = tokens[siguiente];
        const Accion accion = ACCION[estado][token.tipo];
        PasoTraza paso;
        if (registrarTraza) paso = {textoPila(pila), textoEntrada(tokens, siguiente), ""};

        switch (accion.tipo) {
            case TipoAccion::Desplazar:
                paso.accion = "desplazar a " + std::to_string(accion.valor);
                pila.push_back({accion.valor, nombreTerminal(token.tipo), nuevoNodo(describirToken(token)),
                                nuevoNodo(describirToken(token))});
                ++siguiente;
                break;

            case TipoAccion::Reducir: {
                const int regla = accion.valor;
                const Produccion& p = PRODUCCIONES[regla];
                // Se sacan |β| entradas; los valores quedan en el orden de la producción.
                std::vector<NodoPtr> valores(p.longitud);
                auto reduccion = nuevoNodo("[" + std::to_string(regla) + "] " + std::string(p.texto));
                reduccion->hijos.resize(p.longitud);
                for (int k = p.longitud - 1; k >= 0; --k) {
                    valores[k] = std::move(pila.back().ast);
                    reduccion->hijos[k] = std::move(pila.back().reduccion);
                    pila.pop_back();
                }
                const int expuesto = pila.back().estado;
                const int destino = IR_A[expuesto][p.izquierda];
                const std::string celdaIrA = "IR_A[" + std::to_string(expuesto) + ", " +
                                             std::string(nombreNoTerminal(p.izquierda)) + "]";
                paso.accion = "reducir r" + std::to_string(regla) + " (" + std::string(p.texto) + "), " +
                              celdaIrA + " = " + std::to_string(destino);
                if (destino == SIN_TRANSICION) {  // sólo ocurriría si la tabla estuviera mal capturada
                    resultado.error = "Tabla inconsistente: " + celdaIrA + " está vacía.";
                    if (registrarTraza) resultado.traza.push_back(std::move(paso));
                    return resultado;
                }
                pila.push_back({destino, nombreNoTerminal(p.izquierda), accionSemantica(regla, valores),
                                std::move(reduccion)});
                break;
            }

            case TipoAccion::Aceptar:
                paso.accion = "aceptar";
                resultado.aceptada = true;
                resultado.ast = std::move(pila.back().ast);
                resultado.reducciones = nuevoNodo("[" + std::to_string(REGLA_INICIAL) + "] " +
                                                      std::string(PRODUCCIONES[REGLA_INICIAL].texto),
                                                  std::move(pila.back().reduccion));
                break;

            case TipoAccion::Error:
                paso.accion = "error: " + celdaAccion(estado, token.tipo) + " vacía";
                resultado.error = mensajeError(estado, token);
                break;
        }

        if (registrarTraza) resultado.traza.push_back(std::move(paso));
        if (accion.tipo == TipoAccion::Aceptar || accion.tipo == TipoAccion::Error) {
            resultado.estadoFinal = estado;
            return resultado;
        }
    }
}
