(* src/main.ml - 修复后的主驱动程序 *)

let read_file filename =
  let ic = open_in filename in
  let len = in_channel_length ic in
  let buf = Bytes.create len in
  really_input ic buf 0 len;
  close_in ic;
  Bytes.to_string buf

let compile_file input_file output_file =
  try
    Printf.printf "Compiling %s to %s\n" input_file output_file;
    
    (* 读取输入文件 *)
    let content = read_file input_file in
    
    (* 创建词法分析器缓冲区 *)
    let lexbuf = Lexing.from_string content in
    Lexing.set_filename lexbuf input_file;
    
    (* 解析文件 *)
    let ast = Parser.file Lexer.token lexbuf in
    Printf.printf "Successfully parsed %d statements\n" (List.length ast);
    
    (* 构建语义模型 *)
    let (env, rules) = Semantic.build_semantic_model ast in
    Printf.printf "Built semantic model with %d variables and %d rules\n" 
      (Semantic.StringMap.cardinal env) (List.length rules);
    
    (* 生成OCaml代码 *)
    let ocaml_file = 
      try Filename.chop_extension output_file ^ ".ml"
      with Invalid_argument _ -> output_file ^ ".ml" in
    Codegen.write_ocaml_file ocaml_file env rules;
    
    (* 编译OCaml到可执行文件 *)
    let compile_cmd = 
      Printf.sprintf "ocamlc -o %s unix.cma -I +unix %s" output_file ocaml_file
    in
    Printf.printf "Running: %s\n" compile_cmd;
    let status = Sys.command compile_cmd in
    
    if status = 0 then begin
      Printf.printf "Successfully compiled %s\n" output_file;
      Printf.printf "You can now run: ./%s\n" output_file;
      (* 保留.ml文件用于调试 *)
    end else begin
      Printf.eprintf "Failed to compile OCaml code (exit code: %d)\n" status;
      Printf.eprintf "Generated OCaml file: %s\n" ocaml_file;
      exit 1
    end
    
  with
  | Sys_error msg -> 
      Printf.eprintf "File error: %s\n" msg; exit 1
  | Parsing.Parse_error -> 
      Printf.eprintf "Parse error in %s\n" input_file; exit 1
  | Failure msg -> 
      Printf.eprintf "Compilation failed: %s\n" msg; exit 1
  | exn -> 
      Printf.eprintf "Unexpected error: %s\n" (Printexc.to_string exn); exit 1

let usage () =
  Printf.eprintf "Usage: %s <makefile> [output]\n" Sys.argv.(0);
  Printf.eprintf "  <makefile>  Input Makefile to compile\n";
  Printf.eprintf "  [output]    Output executable name (optional)\n";
  Printf.eprintf "\nExample:\n";
  Printf.eprintf "  %s Makefile build\n" Sys.argv.(0);
  exit 1

let () =
  if Array.length Sys.argv < 2 then usage ();
  
  let input_file = Sys.argv.(1) in
  let output_file = 
    if Array.length Sys.argv > 2 then Sys.argv.(2)
    else 
      let base = try Filename.chop_extension (Filename.basename input_file) 
                 with Invalid_argument _ -> Filename.basename input_file in
      base ^ "_build"
  in
  
  if not (Sys.file_exists input_file) then begin
    Printf.eprintf "Error: Input file '%s' does not exist\n" input_file;
    exit 1
  end;
  
  compile_file input_file output_file