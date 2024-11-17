type input = string
type 'a parser = input -> ('a * input) list

(*primitive parsers*)

let result (value: 'a) = function inp -> [(value, inp)]
let fail = function inp -> []
let item =
    function inp ->
        match inp with
        | "" -> []
        | _ -> let x  = String.sub inp 0 1 in
               let xs = String.sub inp 1 (String.length inp - 1) in
               [(x, xs)]

(*sequencing parsers*)
let bind (p: 'a parser) (f: 'a -> 'b parser): 'b parser =
    function inp ->
        p inp
        |> List.map (fun (v,inp') -> f v inp')
        |> List.flatten

let ( <+> ) = bind

let sat (check: string -> bool): string parser =
    item <+> (fun x -> if check x then result x else fail)

let char (x: string): string parser =
    sat (fun y -> x = y)

let digit: string parser = sat (fun x -> "0" <= x && x <= "9")
let lower: string parser = sat (fun x -> "a" <= x && x <= "z")
let upper: string parser = sat (fun x -> "A" <= x && x <= "Z")

let alter (p: 'a parser) (q: 'a parser): 'a parser = (*this is originally called "plus" in the paper*)
    function inp -> p inp @ q inp
let ( <|> ) = alter

let letter: string parser = lower  <|> upper
let alnum : string parser = letter <|> digit

let word: string parser =
    let rec w () =
        let new_word =
            letter <+> fun x ->
                w () <+> fun xs ->
                    result (x ^ xs)
        in
        new_word <|> result ""
    in
    w ()


let many (p: 'a parser): 'a parser =
   let rec m () =
       let many_p =
           p <+> fun x ->
               m () <+> fun xs ->
                   result (x ^ xs)
       in
       many_p <|> result ""
   in
   m ()


let many_list (p: 'a parser): 'a list parser =
    let rec m () =
        let many_p =
            p <+> fun x ->
                m () <+> fun xs ->
                    result (x :: xs)
        in
        many_p <|> result []
    in
    m ()

let ident: string parser =
    lower <+> fun x ->
        many alnum <+> fun xs ->
            result (x ^ xs)

let many1 (p: 'a parser): 'a parser =
    p <+> fun x ->
        many p <+> fun xs ->
            result (x ^ xs)

let many1_list (p: 'a parser): 'a list parser =
    p <+> fun x ->
        many_list p <+> fun xs ->
            result (x :: xs)

let nat: int parser =
    many1 digit <+> fun xs ->
        result (int_of_string xs)

let rec str (s: string): string parser =
    match s with
    | "" -> result ""
    | _ -> let x  = String.sub s 0 1 in
           let xs = String.sub s 1 (String.length s - 1) in
           char x <+> fun _ ->
               str xs <+> fun _ ->
                   result (x ^ xs)

(* monad signature *)
(*with the help of: https://cs3110.github.io/textbook/chapters/ds/monads.html*)
module type Monad = sig
    type 'a m
    val result : 'a -> 'a m
    val bind : 'a m -> ('a -> 'b m) -> 'b m
end

(*example for the instance Monad Parser*)
(*with the help of: https://discuss.ocaml.org/t/maybe-monad-in-ocaml/10221*)
module Monad_Parser: Monad = struct
    type 'a m = 'a parser
    let result v = function input -> [(v, input)]
    let bind p f =
        function inp ->
            p inp
            |> List.map (fun (v,inp') -> f v inp')
            |> List.flatten
end

(*outside of paper*)
let ignore_right_parser (p: 'a parser) (q: 'b parser): 'a parser =
    function inp ->
        let p_res = p inp in
        match p_res with
        | [] -> []
        | _ -> p_res
                |> List.map
                    (fun (v,inp') ->
                            let q_res = q inp' in
                            match q_res with
                            | [] -> []
                            | _  -> q_res
                                    |> List.map (fun (v',inp'') -> (v,inp''))
                    )
                |> List.flatten

let ignore_left_parser (p: 'a parser) (q: 'b parser): 'b parser =
    function inp ->
        let p_res = p inp in
        match p_res with
        | [] -> []
        | _ -> p_res
                   |> List.map (fun (_,inp') -> q inp')
                   |> List.flatten

let ( +> ) = ignore_left_parser
let ( <+ ) = ignore_right_parser

(* wrap over a parser to extract top result only *)
let top_result (p: 'a parser) =
    function inp ->
        match p inp with
        | [] -> []
        | (x, inp') :: _ -> [(x,inp')]

let optional (p: 'a parser): 'a parser =
    function inp ->
        match p inp with
        | [] -> result "" inp
        | (v, inp') :: _  -> result v inp'
