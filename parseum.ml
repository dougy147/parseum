type input = string
type 'a parser = input -> ('a * input) list

let result (value: 'a): 'a parser =
  function (inp: input) -> [(value , inp)]

let zero: 'a parser =
  function (inp: input) -> []

let item: string parser =
  function (inp: input) ->
    match inp with
    | "" -> []
    | _ ->
        let l = String.length inp in
        [(String.sub inp 0 1, String.sub inp 1 (l - 1))]

let bind (p: 'a parser) (f: 'a -> 'b parser): 'b parser =
  function (inp: input) ->
    List.map (fun (v, inp') -> f v inp') (p inp)
    |> List.flatten

let ( <*> ) = bind

let sat (p: string -> bool): string parser =
  item <*> fun x ->
    if p x then result x
    else zero

let char (x: string): string parser = sat (fun y -> x = y)
let digit: string parser = sat (fun x -> "0" <= x && x <= "9")
let lower: string parser = sat (fun x -> "a" <= x && x <= "z")
let upper: string parser = sat (fun x -> "A" <= x && x <= "Z")

let plus (p: 'a parser) (q: 'a parser): 'a parser =
  function (inp: input) -> p inp @ q inp

let ( ++ ) = plus

let letter: string parser = lower ++ upper
let alnum: string parser = lower ++ digit ++ upper

let word: string parser =
  let rec w () =
    let neWord = letter <*> fun x ->
                 w () <*> fun xs ->
                   result (x ^ xs)
    in
    neWord ++ result ""
  in
  w ()

(*p.13*)
(*let rec many (p: 'a parser): 'a list parser =*)
