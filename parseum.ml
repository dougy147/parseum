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

let ( <-> ) = bind

let sat (p: string -> bool): string parser =
  item <-> fun x ->
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
    let neWord = letter <-> fun x ->
                 w () <-> fun xs ->
                   result (x ^ xs)
    in
    neWord ++ result ""
  in
  w ()

(*p.13*)
(* I still don't understand monad notation *)
(*str (x:xs) = [x:xs | _ <- char x, _ <- str xs] *)
let rec str (s: string): string parser =
    match s with
    | "" -> result ""
    | _ -> let x  = String.sub s 0 1 in
           let xs = String.sub s 1 (String.length s - 1) in
           char x <-> fun _ ->
           str xs <-> fun _ ->
               result (x ^ xs)

let prefix = str

let ( *> ) (p: 'a parser) (q: 'b parser): 'b parser =
    function (inp: input) ->
        match p inp with
        | [] -> []
        | (_, inp') :: _ -> q inp'

let ( <* ) (p: 'a parser) (q: 'b parser): 'a parser =
    function (inp: input) ->
        match p inp with
        | [] -> []
        | (x, inp') :: _ ->
                match q inp' with
                | [] -> []
                | (_, inp'') :: _ -> [(x, inp'')]

(* [""] is the monad comprehension syntax for: result "" *)
(*
many :: Parser a -> Parser [a]
many p = [x:xs | x <- p, xs <- many p] ++ [[]]
*)
let many (p: 'a parser): 'a list parser =
  let rec m () =
    let newElem = p <-> fun x ->
                 m () <-> fun xs ->
                   result (x :: xs)
    in
    newElem ++ result []
  in
  m ()
