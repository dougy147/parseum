#!/bin/sh

set -xe

ocamlfind ocamlopt -I src/ -o parseum.native src/parseum.ml
ocamlfind ocamlc   -I src/ -o parseum.byte   src/parseum.ml
