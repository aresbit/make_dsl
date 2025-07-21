module StringMap = Map.Make(String)

type file = string
and actions = string list
and rule = Rule of (file * file list * actions)

and var_def = 
  | VarLiteral of string list
  | VarRef of string
  | VarConcat of var_def list

and env = var_def StringMap.t

(* 变量求值 *)
let rec eval_var (env : env) (var : var_def) : string list =
  match var with
  | VarLiteral l -> l
  | VarRef name -> 
      (match StringMap.find_opt name env with
      | Some v -> eval_var env v
      | None -> ["$(" ^ name ^ ")"])  (* 未定义变量保持原样 *)
  | VarConcat vars ->
      List.flatten (List.map (eval_var env) vars)

(* 解析表达式为变量定义 *)
let expr_to_var_def (expr : Ast.expr) : var_def =
  match expr with
  | Ast.Word s -> VarLiteral [s]
  | Ast.Var s -> VarRef s
  | Ast.Spec s -> VarLiteral [s]

let exprs_to_var_def (exprs : Ast.expr list) : var_def =
  match exprs with
  | [] -> VarLiteral []
  | [e] -> expr_to_var_def e
  | es -> VarConcat (List.map expr_to_var_def es)

(* 展开变量引用 *)
let expand_var_refs (env : env) (text : string) : string =
  let var_pattern = Str.regexp "\\$\\([A-Za-z_][A-Za-z0-9_]*\\)\\|\\$(\\([A-Za-z_][A-Za-z0-9_]*\\))" in
  Str.global_substitute var_pattern (fun s ->
    let matched = Str.matched_string s in
    let var_name = 
      if String.get matched 1 = '(' then
        String.sub matched 2 (String.length matched - 3)
      else
        String.sub matched 1 (String.length matched - 1)
    in
    match StringMap.find_opt var_name env with
    | Some var_def -> String.concat " " (eval_var env var_def)
    | None -> matched
  ) text

(* 构建语义模型 *)
let build_semantic_model (stmts : Ast.t) : (env * rule list) =
  let rec build env rules = function
    | [] -> (env, List.rev rules)
    | stmt :: rest ->
        match stmt with
        | Ast.Assign (name, exprs) ->
            let var_def = exprs_to_var_def exprs in
            let new_env = StringMap.add name var_def env in
            build new_env rules rest
        | Ast.Rule (target, deps, actions) ->
            (* 展开目标、依赖和动作中的变量引用 *)
            let expanded_target = expand_var_refs env target in
            let expanded_deps = List.map (expand_var_refs env) deps in
            let expanded_actions = List.map (expand_var_refs env) actions in
            let rule = Rule (expanded_target, expanded_deps, expanded_actions) in
            build env (rule :: rules) rest
  in
  build StringMap.empty [] stmts

(* 依赖图分析 *)
let build_dependency_graph (rules : rule list) : (file, file list) Hashtbl.t =
  let graph = Hashtbl.create 17 in
  List.iter (fun (Rule (target, deps, _)) ->
    Hashtbl.replace graph target deps
  ) rules;
  graph

(* 拓扑排序 *)
let topological_sort (rules : rule list) : rule list =
  let graph = Hashtbl.create 17 in
  let rule_map = Hashtbl.create 17 in
  
  (* 构建图和规则映射 *)
  List.iter (fun (Rule (target, deps, _) as rule) ->
    Hashtbl.replace graph target deps;
    Hashtbl.replace rule_map target rule
  ) rules;
  
  let visited = Hashtbl.create 17 in
  let temp = Hashtbl.create 17 in
  let result = ref [] in
  
  let rec visit target =
    if Hashtbl.mem temp target then
      failwith (Printf.sprintf "Circular dependency involving %s" target)
    else if not (Hashtbl.mem visited target) then begin
      Hashtbl.add temp target ();
      let deps = try Hashtbl.find graph target with Not_found -> [] in
      List.iter visit deps;
      Hashtbl.remove temp target;
      Hashtbl.add visited target ();
      if Hashtbl.mem rule_map target then
        result := (Hashtbl.find rule_map target) :: !result
    end
  in
  
  List.iter (fun (Rule (target, _, _)) -> visit target) rules;
  !result