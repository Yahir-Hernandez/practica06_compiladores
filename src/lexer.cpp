#include "lexer.hpp"

#include <cctype>

namespace {

bool esLetra(char c) { return std::isalpha(static_cast<unsigned char>(c)) || c == '_'; }
bool esAlfanumerico(char c) { return std::isalnum(static_cast<unsigned char>(c)) || c == '_'; }

}  // namespace

std::vector<Token> tokenizar(const std::string& texto) {
    std::vector<Token> tokens;
    int linea = 1;
    int columna = 1;
    for (size_t i = 0; i < texto.size();) {
        const char c = texto[i];
        if (c == '\n') {
            ++linea;
            columna = 1;
            ++i;
        } else if (std::isspace(static_cast<unsigned char>(c))) {
            ++columna;
            ++i;
        } else if (c == '*' || c == '=') {
            tokens.push_back({c == '*' ? T_ASTERISCO : T_IGUAL, std::string(1, c), linea, columna});
            ++columna;
            ++i;
        } else if (esLetra(c)) {
            size_t fin = i;
            while (fin < texto.size() && esAlfanumerico(texto[fin])) ++fin;
            tokens.push_back({T_ID, texto.substr(i, fin - i), linea, columna});
            columna += static_cast<int>(fin - i);
            i = fin;
        } else {
            size_t n = 1;  // muestra el carácter UTF-8 completo
            while (i + n < texto.size() && (static_cast<unsigned char>(texto[i + n]) & 0xC0) == 0x80) ++n;
            throw ErrorLexico("carácter inesperado '" + texto.substr(i, n) + "'", linea, columna);
        }
    }
    tokens.push_back({T_FIN, "$", linea, columna});
    return tokens;
}

std::string describirToken(const Token& token) {
    if (token.tipo == T_ID && token.lexema != "id") return "id " + token.lexema;
    return std::string(nombreTerminal(token.tipo));
}
