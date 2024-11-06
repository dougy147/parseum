Trying to understand this [paper](https://www.cs.nott.ac.uk/~pszgmh/monparsing.pdf) by implementing exposed concepts.
Made with my traditional bottom-up learning approach and a bit of _seum_ 🥲.

# Example use case

This is mostly a personal note for future improvements of `parseum`.

Compile both `parseum.ml` and `example/bnf.ml` with `sh build.sh && cd ./examples && sh build.sh`.
Then start `utop -I ./src -I ./example`:

```utop
#load "parseum.cmo";;
#load "bnf.cmo";;
Bnf.grammar "<letter> ::= \"a\" | \"b\" | \"c\"\n<word> ::= <letter> | <word><letter>";;
- : (((string * (string list list * string list)) list *
      (string * (string list list * string list))) *
     string)
    list
=
[(([("letter", ([["a"]; ["b"]], ["c"]))],
   ("word", ([["letter"]], ["word"; "letter"]))),
  "")]
```

TODO: fix overnesting.

# References
- [https://www.cs.nott.ac.uk/~pszgmh/monparsing.pdf](https://www.cs.nott.ac.uk/~pszgmh/monparsing.pdf)
