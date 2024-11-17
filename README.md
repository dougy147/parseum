Trying to understand this [paper](https://www.cs.nott.ac.uk/~pszgmh/monparsing.pdf) by implementing exposed concepts.
Made with my traditional bottom-up learning approach and a bit of _seum_ 🥲.

# Example use case

This is mostly a personal note for future improvements of `parseum`.

Compile both `parseum.ml` and `example/bnf.ml` with `sh build.sh example`.
Then start `utop -I ./src -I ./example`:

```ocaml
#load_rec "bnf.cmo";;
open Bnf;;
grammar "<letter> ::= \"a\" | \"b\" | \"c\"\n<word>::=<letter>|<word><letter>";;
- : ((string * string list list) list * string) list =
[([("letter", [["a"]; ["b"]; ["c"]]);
   ("word", [["letter"]; ["word"; "letter"]])],
  "")]
```

TODO: read from file.
TODO: print successful parsing properly.

# References
- [https://www.cs.nott.ac.uk/~pszgmh/monparsing.pdf](https://www.cs.nott.ac.uk/~pszgmh/monparsing.pdf)
