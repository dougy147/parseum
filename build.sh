#!/bin/bash

set -xe

ocamlfind ocamlopt -I ./src -o ./src/parseum.native ./src/parseum.ml
ocamlfind ocamlc   -I ./src -o ./src/parseum.byte   ./src/parseum.ml

if [[ -n $1 && $1 == "example" ]]; then
    pushd ./examples
    ocamlfind ocamlopt -I ../src -o bnf.native ../src/parseum.ml bnf.ml
    ocamlfind ocamlc   -I ../src -o bnf.byte   ../src/parseum.ml bnf.ml
    popd
fi
