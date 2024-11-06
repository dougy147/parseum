#!/bin/bash

set -xe

ocamlfind ocamlopt -I ./src -o ./src/parseum.native ./src/parseum.ml
ocamlfind ocamlc   -I ./src -o ./src/parseum.byte   ./src/parseum.ml
