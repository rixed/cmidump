open Format

let want_magic = ref false
let want_crc = ref false
let want_name = ref false
let want_flags = ref false
let want_sig = ref false
let simplify_sig = ref false

(* Stolen from env.ml - would be great if exported *)
type flags = Rectypes

let print_flags flags =
	let flag_name = function
	| Rectypes -> "Rectypes" in
	printf "@[Flags@ =@ [@[" ;
	List.iter (fun f -> printf "%s@ " (flag_name f)) flags ;
	printf "]@]@]@."

let print_magic m =
	printf "@[Cmi magic number@ =@ %s (%s)@]@."
		m (if m = Config.cmi_magic_number then "OK" else "Wrong!")

let print_name name = printf "@[Name@ =@ %s@]@." name

let print_crcs crcs =
	let print_crc (modname, crc) = printf "@[%s [%s]@]@ " modname (String.escaped crc) in
	printf "@[CRCs = @[" ; List.iter print_crc crcs ; printf "@]@]@."

let print_sig sign =
	fprintf std_formatter "@[Signature@ =@ @[<1>%a@]@]@."
		Printtyp.signature
		(if !simplify_sig then (Typemod.simplify_signature sign) else sign)

(* Reading persistent structures from .cmi files - Stolen from typing/env.ml
 * We'd rather use this instead of Env.read_signature so that we get all
 * components of the cmi files, not just signature *)

let process_cmi_file filename =
	let show_sig = !want_sig ||
		(not !want_magic && not !want_crc && not !want_name && not !want_flags) in
	let ic = open_in_bin filename in
	let magic_len = String.length (Config.cmi_magic_number) in
	let buffer = String.create magic_len in
	really_input ic buffer 0 magic_len ;
	let (name, sign) = input_value ic in
	let crcs = input_value ic in
	let flags = input_value ic in
	close_in ic ;
	if !want_magic then print_magic buffer ;
	if !want_name  then print_name name ;
	if !want_crc   then print_crcs crcs ;
	if !want_flags then print_flags flags ;
	if show_sig    then print_sig sign

let process_file fname =
	if Filename.check_suffix fname "cmi" then process_cmi_file fname
	else printf "Don't know what to do with file '%s'\n" fname

let _ =
	Arg.parse [
		"-magic",    Arg.Set want_magic,   " Display cmi magic number" ;
		"-name",     Arg.Set want_name,    " Display module name" ;
		"-crc",      Arg.Set want_crc,     " Display CRC" ;
		"-flags",    Arg.Set want_flags,   " Display flags" ;
		"-sig",      Arg.Set want_sig,     " Display signature" ;
		"-simplify", Arg.Set simplify_sig, " Do not simplify the signature" ]
		process_file
		"Syntax :
	cmidump [options] files...
Shows the content of cmi files.
If no option is given, shows only the signature.
Possible options :
"
