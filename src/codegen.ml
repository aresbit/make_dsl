(* Code generation for Makefile DSL to OCaml - Based on SUPPORTED_SYNTAX.md *)

open Semantic

(* OCaml code generation *)
let ocaml_of_var_def (name : string) (var_def : var_def) : string =
  let rec gen_expr var_def =
    match var_def with
    | VarLiteral words -> 
        let quoted = List.map (fun w -> Printf.sprintf "\"%s\"" w) words in
        Printf.sprintf "[%s]" (String.concat "; " quoted)
    | VarRef var_name ->
        Printf.sprintf "var_%s ()" var_name
    | VarConcat vars ->
        let parts = List.map gen_expr vars in
        Printf.sprintf "List.flatten [%s]" (String.concat "; " parts)
  in
  Printf.sprintf "let rec var_%s () = %s" name (gen_expr var_def)

let ocaml_of_rule (Rule (target, deps, actions)) : string =
  let target_str = Printf.sprintf "\"%s\"" target in
  let deps_str = String.concat "; " (List.map (fun d -> Printf.sprintf "\"%s\"" d) deps) in
  let actions_str = String.concat "; " (List.map (fun a -> Printf.sprintf "\"%s\"" a) actions) in
  Printf.sprintf "Rule (%s, [%s], [%s])" target_str deps_str actions_str

let generate_ocaml_code (env : env) (rules : rule list) : string =
  let var_decls = 
    StringMap.fold (fun name var_def acc ->
      ocaml_of_var_def name var_def :: acc
    ) env []
    |> List.rev
  in
  
  let header = [
    "(* Auto-generated Makefile DSL compiler output *)";
    "(* Based on SUPPORTED_SYNTAX.md *)";
    "open Sys";
    "open Unix";
    ""; 
    "type file = string";
    "and actions = string list";
    "and rule = Rule of (file * file list * actions)";
    "";
    "let rec newer a b =";
    "  try";
    "    let st_a = Unix.stat a in";
    "    let st_b = Unix.stat b in";
    "    st_a.Unix.st_mtime > st_b.Unix.st_mtime";
    "  with Unix.Unix_error _ -> true";
    ""; 
    "let run cmd =";
    "  Printf.printf \"Running: %s\\n\" cmd;";
    "  let status = Sys.command cmd in";
    "  if status <> 0 then failwith (Printf.sprintf \"Command failed: %s\" cmd)";
    "";
    "let exists file =";
    "  try Sys.file_exists file && not (Sys.is_directory file)";
    "  with Sys_error _ -> false";
    "";
    "let needs_update target deps =";
    "  not (exists target) || List.exists (fun dep -> not (exists dep) || newer dep target) deps";
    "";
    "let execute_rule (Rule (target, deps, actions)) =";
    "  if needs_update target deps then begin";
    "    List.iter run actions";
    "  end";
    "";
  ] in
  
  let main_function = [
    "let () =";
    "  let rules = [";
  ] @ 
    (List.map (fun rule -> "    " ^ ocaml_of_rule rule ^ ";") rules) @
    ["  ] in";
    "  List.iter execute_rule rules";
  ] in
  
  String.concat "\n" (header @ var_decls @ [""] @ main_function)

(* Generate OCaml source file *)
let write_ocaml_file (filename : string) (env : env) (rules : rule list) : unit =
  let code = generate_ocaml_code env rules in
  let oc = open_out filename in
  output_string oc code;
  close_out oc