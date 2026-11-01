CXX ?= g++
CXXFLAGS ?= -std=c++17 -Wall -Wextra -Wpedantic -O2

FUENTES := $(wildcard src/*.cpp)
OBJETOS := $(FUENTES:src/%.cpp=build/%.o)

lalr: $(OBJETOS)
	$(CXX) $(CXXFLAGS) -o $@ $^

build/%.o: src/%.cpp $(wildcard src/*.hpp) | build
	$(CXX) $(CXXFLAGS) -c -o $@ $<

build:
	mkdir -p build

test: lalr
	./tests/run.sh

REPORTES := practica06.pdf ValidacionSaid.pdf

reporte: $(REPORTES)

%.pdf: %.typ imgs/*
	typst compile $< $@

clean:
	rm -rf build temp lalr $(REPORTES)

.PHONY: test reporte clean
