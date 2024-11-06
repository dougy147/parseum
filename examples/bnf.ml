open Parseum

let opt_spaces = many (char " ")
let s = opt_spaces

let non_terminal =
    char "<" *> word <* char ">"

let terminal =
    char "\"" *> word <* char "\""

let rule_name = non_terminal

let subexp = many (s *> (non_terminal ++ terminal) <* s)

let expression = many (subexp <* char "|") <*> subexp

let rule =
    rule_name <* s *> prefix "::=" <* s <*> expression

let grammar =
    many (rule <* prefix "\n") <*> rule
