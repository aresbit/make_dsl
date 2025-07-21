{
  open Parser
  open Lexing

  let incr_line lexbuf = 
    let pos = lexbuf.lex_curr_p in
    lexbuf.lex_curr_p <- { pos with 
      pos_lnum = pos.pos_lnum + 1;
      pos_bol = pos.pos_cnum;
    }

  let errorf fmt =
    let b = Buffer.create 17 in
    let f = Format.formatter_of_buffer b in
    Format.kfprintf (fun _ -> failwith (Buffer.contents b)) f fmt

  let lex_error lexbuf msg =
    let pos = lexbuf.lex_curr_p in
    errorf "%s:%d:%d: %s" pos.pos_fname pos.pos_lnum (pos.pos_cnum - pos.pos_bol) msg
    
  (* 提取变量名，去除$()包装 *)
  let extract_var_name s =
    if String.length s > 3 && String.get s 0 = '$' && String.get s 1 = '(' && String.get s (String.length s - 1) = ')' then
      String.sub s 2 (String.length s - 3)
    else s
}

let blank = [' ' '\t' '\r']
let newline = '\n' | "\r\n"
let comment = '#' [^ '\n' '\r']*

let var_name = ['a'-'z' 'A'-'Z' '_']['a'-'z' 'A'-'Z' '_' '0'-'9']*
let word = [^ ' ' '\t' '\n' '\r' '$' ':' '#' '=' '(' ')' ]+
let dollar_var = '$' '(' var_name ')'
let simple_var = '$' var_name

rule token = parse
  | ' ' { token lexbuf }
  | '\t' { TAB }
  | newline { incr_line lexbuf; NEWLINE }
  | comment { token lexbuf }
  | "=" { EQUAL }
  | ":" { COLON }
  | "\\" blank* newline { incr_line lexbuf; token lexbuf } (* 行继续符 *)
  | dollar_var { 
      let s = Lexing.lexeme lexbuf in
      VAR (extract_var_name s)
    }
  | simple_var { 
      let s = Lexing.lexeme lexbuf in
      VAR (String.sub s 1 (String.length s - 1)) (* 去除$前缀 *)
    }
  | var_name { WORD(Lexing.lexeme lexbuf) }
  | word { WORD(Lexing.lexeme lexbuf) }
  | eof { EOF }