#pragma once

#include "gramatica.hpp"

enum class TipoAccion : unsigned char { Error, Desplazar, Reducir, Aceptar };

// Celda de ACCION: "s j" desplaza e ir al estado j, "r k" reduce por la regla k.
struct Accion {
    TipoAccion tipo;
    int valor;  // estado destino (Desplazar) o número de regla (Reducir)
};

constexpr int NUM_ESTADOS = 10;
constexpr int SIN_TRANSICION = -1;

// Tablas LALR(1) calculadas a mano (sección "Tabla de análisis LALR(1)" del reporte).
extern const Accion ACCION[NUM_ESTADOS][NUM_TERMINALES];
extern const int IR_A[NUM_ESTADOS][NUM_NO_TERMINALES];
