#!/bin/bash

set -xe

ocamlfind ocamlopt -I ../src -o bnf.native ../src/parseum.ml bnf.ml
ocamlfind ocamlc   -I ../src -o bnf.byte   ../src/parseum.ml bnf.ml
