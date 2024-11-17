open Parseum

type terminal_t = string
type non_terminal_t = string
type subexpr_t = string list
type expr_t = subexpr_t list
type rule_t = non_terminal_t * (expr_t list)
type grammar_t = rule_t list

let ws: string Parseum.parser =
    top_result (many (char " "))

let non_terminal: non_terminal_t Parseum.parser =
    top_result (ws +> char "<" +> (many1 alnum) <+ char ">" <+ ws)

let rewrite_symbol: string Parseum.parser =
    top_result (ws +> str "::=" <+ ws)

let terminal: terminal_t Parseum.parser =
    top_result (ws +> (optional (char "\"")) +> many1 alnum <+ (optional (char "\"")) <+ ws)

let subexpr =
    top_result (ws +> many1_list ( terminal <|> non_terminal ) <+ ws)

let alternative =
    ws +> char "|" <+ ws

let expr =
    top_result (many_list (subexpr <+ alternative) <+> fun x -> subexpr <+> fun xs -> result (x @ [xs]))

let rule =
    top_result (non_terminal <+> fun identifier ->
        rewrite_symbol <+> fun rewrite_symbol ->
            expr <+> fun expression ->
                result (identifier,expression))

let grammar =
    top_result (many_list (rule <+ str "\n")) <+> fun x ->
        rule <+> fun xs ->
            result (x @ [xs])
