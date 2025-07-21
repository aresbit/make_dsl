%{ 
  open Ast

  let errorf fmt =
    let b = Buffer.create 17 in
    let f = Format.formatter_of_buffer b in
    Format.kfprintf (fun _ -> failwith (Buffer.contents b)) f fmt

  let parse_error msg =
    errorf "Parse error: %s" msg
%}

%token EQUAL COLON NEWLINE TAB EOF
%token <string> WORD VAR

%start file
%type <Ast.t> file

%%

file:
  | statements EOF { List.rev $1 }
;

statements:
  | { [] }
  | statements statement { $2 :: $1 }
  | statements NEWLINE { $1 }
;

statement:
  | assignment { $1 }
  | rule { $1 }
;

assignment:
  | WORD EQUAL expression_list { Assign($1, List.rev $3) }
;

rule:
  | target COLON dependency_list NEWLINE action_list { Rule($1, List.rev $3, List.rev $5) }
  | target COLON dependency_list { Rule($1, List.rev $3, []) }
;

target:
  | WORD { $1 }
  | VAR { "$" ^ $1 } (* 重新添加$前缀用于显示 *)
;

dependency_list:
  | { [] }
  | dependency_list dependency { $2 :: $1 }
;

dependency:
  | WORD { $1 }
  | VAR { "$" ^ $1 }
;

action_list:
  | { [] }
  | action_list action_line { $2 :: $1 }
;

action_line:
  | TAB action_tokens NEWLINE { String.concat " " (List.rev $2) }
;

action_tokens:
  | { [] }
  | action_tokens action_token { $2 :: $1 }
;

action_token:
  | WORD { $1 }
  | VAR { "$(" ^ $1 ^ ")" }
;

expression_list:
  | { [] }
  | expression_list expression { $2 :: $1 }
;

expression:
  | WORD { Word($1) }
  | VAR { Var($1) }
;