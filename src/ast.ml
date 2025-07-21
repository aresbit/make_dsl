(* Abstract Syntax Tree for Makefile DSL - Based on SUPPORTED_SYNTAX.md *)

type expr = 
  | Word of string
  | Var of string
  | Spec of string

type stmt = 
  | Assign of string * expr list
  | Rule of string * string list * string list

type t = stmt list

(* Helper functions *)
let string_of_expr = function
  | Word s -> s
  | Var s -> "$" ^ s
  | Spec s -> s

let string_of_stmt = function
  | Assign (name, exprs) -> 
      name ^ " = " ^ String.concat " " (List.map string_of_expr exprs)
  | Rule (target, deps, actions) -> 
      target ^ ": " ^ String.concat " " deps ^ 
      (if actions = [] then "" else "\n\t" ^ String.concat " " actions)

let string_of_program stmts =
  String.concat "\n" (List.map string_of_stmt stmts)