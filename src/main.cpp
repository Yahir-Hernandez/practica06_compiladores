#include <algorithm>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <optional>
#include <sstream>
#include <string>

#include "driver.hpp"
#include "lexer.hpp"

namespace {

constexpr int SALIDA_ACEPTADA = 0;
constexpr int SALIDA_RECHAZADA = 1;
constexpr int SALIDA_USO = 2;

struct Opciones {
    std::optional<std::string> texto;
    std::optional<std::string> archivo;
    bool traza = false;
    bool reducciones = false;
};

void imprimirUso(std::ostream& salida) {
    salida << "Uso: ./lalr [opciones] [archivo]\n"
              "Analiza asignaciones con apuntadores con el parser LALR(1). Sin archivo ni -e, lee la\n"
              "entrada estándar. La entrada es una lista de tokens: * id = id (cualquier nombre es id).\n"
              "  -e TEXTO  analiza TEXTO en lugar de un archivo\n"
              "  -t        muestra la traza de la pila (desplazamientos y reducciones)\n"
              "  -r        muestra el árbol de reducciones (regla aplicada en cada nodo)\n"
              "  -h        muestra esta ayuda\n";
}

std::optional<Opciones> leerOpciones(int argc, char* argv[]) {
    Opciones opciones;
    for (int i = 1; i < argc; ++i) {
        const std::string arg = argv[i];
        if (arg == "-e" && i + 1 < argc) {
            opciones.texto = argv[++i];
        } else if (arg == "-t") {
            opciones.traza = true;
        } else if (arg == "-r") {
            opciones.reducciones = true;
        } else if (arg.size() > 1 && arg[0] == '-') {
            return std::nullopt;
        } else if (!opciones.archivo) {
            opciones.archivo = arg;
        } else {
            return std::nullopt;
        }
    }
    if (opciones.texto && opciones.archivo) return std::nullopt;
    return opciones;
}

std::optional<std::string> leerEntrada(const Opciones& opciones) {
    if (opciones.texto) return opciones.texto;
    std::ostringstream contenido;
    if (!opciones.archivo) {
        contenido << std::cin.rdbuf();
        return contenido.str();
    }
    std::ifstream archivo(*opciones.archivo, std::ios::binary);
    if (!archivo) return std::nullopt;
    contenido << archivo.rdbuf();
    return contenido.str();
}

void imprimirTraza(const std::vector<PasoTraza>& traza, std::ostream& salida) {
    size_t anchoPila = 4;
    size_t anchoEntrada = 7;
    for (const PasoTraza& paso : traza) {
        anchoPila = std::max(anchoPila, paso.pila.size());
        anchoEntrada = std::max(anchoEntrada, paso.entrada.size());
    }
    salida << std::left << std::setw(6) << "Paso" << std::setw(anchoPila + 3) << "Pila"
           << std::setw(anchoEntrada + 3) << "Entrada" << "Acción\n";
    for (size_t i = 0; i < traza.size(); ++i) {
        salida << std::setw(6) << i + 1 << std::setw(anchoPila + 3) << traza[i].pila
               << std::setw(anchoEntrada + 3) << traza[i].entrada << traza[i].accion << '\n';
    }
    salida << std::right << '\n';
}

}  // namespace

int main(int argc, char* argv[]) {
    if (argc == 2 && std::string(argv[1]) == "-h") {
        imprimirUso(std::cout);
        return SALIDA_ACEPTADA;
    }
    const std::optional<Opciones> opciones = leerOpciones(argc, argv);
    if (!opciones) {
        imprimirUso(std::cerr);
        return SALIDA_USO;
    }
    const std::optional<std::string> entrada = leerEntrada(*opciones);
    if (!entrada) {
        std::cerr << "No se pudo abrir el archivo '" << *opciones->archivo << "'.\n";
        return SALIDA_USO;
    }

    std::vector<Token> tokens;
    try {
        tokens = tokenizar(*entrada);
    } catch (const ErrorLexico& error) {
        std::cout << "Resultado: RECHAZADA\n";
        std::cerr << "Error léxico en " << error.linea << ":" << error.columna << ": " << error.what() << ".\n";
        return SALIDA_RECHAZADA;
    }

    std::cout << "Tokens:";
    for (const Token& token : tokens) std::cout << ' ' << describirToken(token);
    std::cout << "\n\n";

    const ResultadoAnalisis resultado = analizar(tokens, opciones->traza);
    if (opciones->traza) imprimirTraza(resultado.traza, std::cout);

    if (!resultado.aceptada) {
        std::cout << "Resultado: RECHAZADA (estado final " << resultado.estadoFinal << ")\n";
        std::cerr << resultado.error << '\n';
        return SALIDA_RECHAZADA;
    }
    std::cout << "Resultado: ACEPTADA (estado final " << resultado.estadoFinal << ")\n\nAST:\n";
    imprimirArbol(*resultado.ast, std::cout);
    if (opciones->reducciones) {
        std::cout << "\nÁrbol de reducciones:\n";
        imprimirArbol(*resultado.reducciones, std::cout);
    }
    return SALIDA_ACEPTADA;
}
