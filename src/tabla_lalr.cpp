#include "tabla_lalr.hpp"

namespace {

constexpr Accion s(int estado) { return {TipoAccion::Desplazar, estado}; }
constexpr Accion r(int regla) { return {TipoAccion::Reducir, regla}; }
constexpr Accion acc{TipoAccion::Aceptar, 0};
constexpr Accion err{TipoAccion::Error, 0};

}  // namespace

// Estados LALR(1) tras fusionar kernels del autómata LR(1):
//   4 = I4 ∪ I11,  5 = I5 ∪ I12,  7 = I7 ∪ I13,  8 = I8 ∪ I10.
// Las reducciones sólo aparecen en los lookaheads de cada ítem [A -> α·, a].
const Accion ACCION[NUM_ESTADOS][NUM_TERMINALES] = {
    //        =      *      id     $
    /* 0 */ {err,   s(4),  s(5),  err},
    /* 1 */ {err,   err,   err,   acc},
    /* 2 */ {s(6),  err,   err,   r(6)},  // SLR: s6/r6 en '='; en LR(1) el ítem es [R -> L·, $]
    /* 3 */ {err,   err,   err,   r(3)},
    /* 4 */ {err,   s(4),  s(5),  err},
    /* 5 */ {r(5),  err,   err,   r(5)},
    /* 6 */ {err,   s(4),  s(5),  err},
    /* 7 */ {r(4),  err,   err,   r(4)},
    /* 8 */ {r(6),  err,   err,   r(6)},
    /* 9 */ {err,   err,   err,   r(2)},
};

// SIN_TRANSICION (-1) marca las celdas vacías.
const int IR_A[NUM_ESTADOS][NUM_NO_TERMINALES] = {
    //        S    L    R
    /* 0 */ {1,   2,   3},
    /* 1 */ {-1,  -1,  -1},
    /* 2 */ {-1,  -1,  -1},
    /* 3 */ {-1,  -1,  -1},
    /* 4 */ {-1,  8,   7},
    /* 5 */ {-1,  -1,  -1},
    /* 6 */ {-1,  8,   9},
    /* 7 */ {-1,  -1,  -1},
    /* 8 */ {-1,  -1,  -1},
    /* 9 */ {-1,  -1,  -1},
};
