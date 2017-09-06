
(*
 * Copyright (C) 2015 Citrix Systems Inc
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *)

open Lwt
open Iso
open Astring
open Cohttp
open Cohttp_lwt_unix

let whitelist = [
    "blktap"
  ; "blktap-devel"
  ; "forkexecd"
  ; "forkexecd-devel"
  ; "gdk"
  ; "gdk-devel"
  ; "gpumon"
  ; "message-switch"
  ; "message-switch-devel"
  ; "oasis"
  ; "ocaml"
  ; "ocaml-async"
  ; "ocaml-async-devel"
  ; "ocaml-async-extra"
  ; "ocaml-async-extra-devel"
  ; "ocaml-async-kernel"
  ; "ocaml-async-kernel-devel"
  ; "ocaml-async-rpc-kernel"
  ; "ocaml-async-rpc-kernel-devel"
  ; "ocaml-async-unix"
  ; "ocaml-async-unix-devel"
  ; "ocaml-backtrace"
  ; "ocaml-backtrace-devel"
  ; "ocaml-base64"
  ; "ocaml-base64-devel"
  ; "ocaml-biniou"
  ; "ocaml-biniou-devel"
  ; "ocaml-bin-prot"
  ; "ocaml-bin-prot-devel"
  ; "ocaml-bisect-ppx"
  ; "ocaml-bisect-ppx-devel"
  ; "ocaml-camlp4"
  ; "ocaml-camlp4-devel"
  ; "ocaml-cdrom"
  ; "ocaml-cdrom-devel"
  ; "ocaml-cmdliner"
  ; "ocaml-cmdliner-devel"
  ; "ocaml-cohttp"
  ; "ocaml-cohttp-devel"
  ; "ocaml-comparelib"
  ; "ocaml-comparelib-devel"
  ; "ocaml-compiler-libs"
  ; "ocaml-conduit"
  ; "ocaml-conduit-devel"
  ; "ocaml-core"
  ; "ocaml-core-devel"
  ; "ocaml-core-kernel"
  ; "ocaml-core-kernel-devel"
  ; "ocaml-crc"
  ; "ocaml-crc-devel"
  ; "ocaml-cstruct"
  ; "ocaml-cstruct-devel"
  ; "ocaml-ctypes"
  ; "ocaml-ctypes-devel"
  ; "ocaml-custom-printf"
  ; "ocaml-custom-printf-devel"
  ; "ocaml-easy-format"
  ; "ocaml-easy-format-devel"
  ; "ocaml-enumerate"
  ; "ocaml-enumerate-devel"
  ; "ocaml-fd-send-recv"
  ; "ocaml-fd-send-recv-devel"
  ; "ocaml-fieldslib"
  ; "ocaml-fieldslib-devel"
  ; "ocaml-findlib"
  ; "ocaml-findlib-devel"
  ; "ocaml-gnt"
  ; "ocaml-gnt-devel"
  ; "ocaml-herelib"
  ; "ocaml-herelib-devel"
  ; "ocaml-inotify"
  ; "ocaml-inotify-devel"
  ; "ocaml-io-page"
  ; "ocaml-io-page-devel"
  ; "ocaml-ipaddr"
  ; "ocaml-ipaddr-devel"
  ; "ocaml-lwt"
  ; "ocaml-lwt-devel"
  ; "ocaml-mirage-profile"
  ; "ocaml-mirage-profile-devel"
  ; "ocaml-mirage-types"
  ; "ocaml-mirage-types-devel"
  ; "ocaml-nbd"
  ; "ocaml-nbd-devel"
  ; "ocaml-netdev"
  ; "ocaml-netdev-devel"
  ; "ocaml-netlink"
  ; "ocaml-netlink-devel"
  ; "ocaml-obuild"
  ; "ocaml-ocamldoc"
  ; "ocaml-oclock"
  ; "ocaml-oclock-devel"
  ; "ocaml-ocplib-endian"
  ; "ocaml-ocplib-endian-devel"
  ; "ocaml-odn"
  ; "ocaml-opasswd"
  ; "ocaml-opasswd-devel"
  ; "ocaml-ounit"
  ; "ocaml-ounit-devel"
  ; "ocaml-pa-bench"
  ; "ocaml-pa-bench-devel"
  ; "ocaml-pa-ounit"
  ; "ocaml-pa-ounit-devel"
  ; "ocaml-pa-pipebang"
  ; "ocaml-pa-pipebang-devel"
  ; "ocaml-pa-structural-sexp"
  ; "ocaml-pa-structural-sexp-devel"
  ; "ocaml-pa-test"
  ; "ocaml-pa-test-devel"
  ; "ocaml-pci"
  ; "ocaml-pci-devel"
  ; "ocaml-qmp"
  ; "ocaml-qmp-devel"
  ; "ocaml-re"
  ; "ocaml-react"
  ; "ocaml-re-devel"
  ; "ocaml-rpc"
  ; "ocaml-rpc-devel"
  ; "ocaml-rrdd-plugin"
  ; "ocaml-rrdd-plugin-devel"
  ; "ocaml-rrd-transport"
  ; "ocaml-rrd-transport-devel"
  ; "ocaml-runtime"
  ; "ocaml-sexplib"
  ; "ocaml-sexplib-devel"
  ; "ocaml-sha"
  ; "ocaml-sha-devel"
  ; "ocaml-ssl"
  ; "ocaml-ssl-devel"
  ; "ocaml-stdext"
  ; "ocaml-stdext-devel"
  ; "ocaml-stringext"
  ; "ocaml-stringext-devel"
  ; "ocaml-systemd"
  ; "ocaml-systemd-devel"
  ; "ocaml-tapctl"
  ; "ocaml-tapctl-devel"
  ; "ocaml-tar"
  ; "ocaml-tar-devel"
  ; "ocaml-type-conv"
  ; "ocaml-typerep"
  ; "ocaml-typerep-devel"
  ; "ocaml-uri"
  ; "ocaml-uri-devel"
  ; "ocaml-uuidm"
  ; "ocaml-uuidm-devel"
  ; "ocaml-uutf"
  ; "ocaml-uutf-devel"
  ; "ocaml-variantslib"
  ; "ocaml-variantslib-devel"
  ; "ocaml-vhd"
  ; "ocaml-vhd-devel"
  ; "ocaml-xcp-idl"
  ; "ocaml-xcp-idl-devel"
  ; "ocaml-xcp-inventory"
  ; "ocaml-xcp-inventory-devel"
  ; "ocaml-xcp-rrd"
  ; "ocaml-xcp-rrd-devel"
  ; "ocaml-xen-api-client"
  ; "ocaml-xen-api-client-devel"
  ; "ocaml-xen-api-libs-transitional"
  ; "ocaml-xen-api-libs-transitional-devel"
  ; "ocaml-xenops"
  ; "ocaml-xenops-devel"
  ; "ocaml-xenstore"
  ; "ocaml-xenstore-clients"
  ; "ocaml-xenstore-clients-devel"
  ; "ocaml-xenstore-devel"
  ; "ocaml-xmlm"
  ; "ocaml-xmlm-devel"
  ; "ocaml-yojson"
  ; "ocaml-yojson-devel"
  ; "omake"
  ; "opam"
  ; "optcomp"
  ; "rrdd-plugins"
  ; "squeezed"
  ; "systemd"
  ; "systemd-devel"
  ; "systemd-libs"
  ; "vhd-tool"
  ; "xapi"
  ; "xapi-test-utils"
  ; "xapi-test-utils-devel"
  ; "xcp-networkd"
  ; "xcp-rrdd"
  ; "xen-devel"
  ; "xen-dom0-libs"
  ; "xen-dom0-libs-devel"
  ; "xen-hypervisor"
  ; "xen-installer-files"
  ; "xen-libs"
  ; "xen-libs-devel"
  ; "xen-ocaml-devel"
  ; "xen-ocaml-libs"
  ; "xenops-cli"
  ; "xenopsd"
  ; "xenopsd-devel"
  ; "xenserver-release"
  ; "xs-opam-repo"
]

module Iso = Isofs.Make(Block)(Io_page)

exception Error
let (>>*=) m f = match m with
  | `Error e -> fail Error
  | `Ok x -> f x

let ok = `Ok ()

let (>>|=) m f = m >>= fun x -> x >>*= f

let (//) x y = x ^"/"^ y

let mkdir_safe dir perm =
  Lwt.catch
    (fun () -> Lwt_unix.mkdir dir perm)
    (function | Unix.Unix_error (Unix.EEXIST, _, _) -> Lwt.return ()
              | e -> fail e)

(** create a directory, and create parent if doesn't exist *)
let mkdir_p dir perm =
  Printf.printf "mkdir_p %s %d\n" dir perm;
  let rec p_mkdir dir =
    let p_name = Filename.dirname dir in
    (if p_name <> "/" && p_name <> "." 
     then p_mkdir p_name
     else Lwt.return ()) >>= fun () ->
    mkdir_safe dir perm in
 p_mkdir dir >>= fun () -> Lwt.return ok

(* Dump a list of cstructs into a file f *)
let cstrs_to_file cstrs f =
  Lwt_unix.openfile f [Lwt_unix.O_RDWR; Lwt_unix.O_CREAT] 0o644
  >>= fun fd ->
  Lwt_list.iter_s (
    fun cstr -> Lwt_cstruct.write fd cstr
      >>= fun _ -> Lwt.return ())
    cstrs
  >>= fun () ->
  Lwt_unix.close fd

let default_filtermap = function
  | `Directory name -> Some name
  | `File name -> Some name

(* Sync an iso filesystem to a local filesystem. Optionally maps dir names and filenames *)
let sync ?(filtermap=default_filtermap) iso entries lrelpath irelpath =
  mkdir_p lrelpath 0o755
  >>|= fun () -> 
  let rec inner entries lrelpath irelpath = 
    Lwt_list.fold_left_s
      (fun acc f ->
         match f with
         | (name, Isofs.Directory d) ->
           acc >>*= fun () ->
           (match filtermap (`Directory name) with
            | Some name' ->
              mkdir_p (Filename.concat lrelpath name') 0o755
              >>|= fun () ->
              inner
                d.Isofs.d_contents
                (Filename.concat lrelpath name')
                (Filename.concat irelpath name)
            | None -> 
              Lwt.return ok)
         | (name, Isofs.File f) ->
           acc >>*= fun () ->
           (match filtermap (`File name) with
            | Some name' ->
              let ipath = Filename.concat irelpath name in
              Iso.KV_RO.size iso ipath
              >>|= fun size ->
              Iso.KV_RO.read iso ipath 0 (Int64.to_int size)
              >>|= fun result ->
              let filename = Filename.concat lrelpath name' in
              Printf.printf "%s\n" filename;
              cstrs_to_file result filename >>= fun () ->
              Lwt.return ok
            | None ->
              Lwt.return ok)
      ) ok entries
  in inner entries lrelpath irelpath

let filter_file file extension =
  let is_whitelisted pkg =
    let pkg_name = Re_str.replace_first (Re_str.regexp "^\\(.*\\)-[^-]*-[^-]*$") "\\1" pkg in
    Printf.printf "Checking for package in whitelist: %s\n%!" pkg_name;
    List.mem pkg_name whitelist
  in
  if String.is_suffix extension file then begin
    if is_whitelisted file
    then Some file
    else (Printf.printf "%s skipped due to whitelist.\n%!" file; None)
  end else (Printf.printf "%s skipped due to wrong extension (not %s).\n%!" file extension; None)

let create_tree root binpkg_iso sources_iso =
  let rpmsdir = Filename.concat root "domain0/RPMS" in
  let srpmsdir = Filename.concat root "domain0/SRPMS" in
  Block.connect binpkg_iso
  >>|= fun b ->
  Iso.connect b
  >>|= fun iso ->
  (* Sync binpkg.iso to RPMS dir locally, skipping the 'repodata'
     directory *)
  sync ~filtermap:(
    function
    | `Directory "repodata" -> None
    | `Directory x -> Some x
    | `File x -> filter_file x ".rpm")
    iso iso.Iso.entries rpmsdir "/"
  >>|= fun () ->
  Block.connect sources_iso
  >>|= fun b ->
  Iso.connect b
  >>|= fun iso ->
  (* Sync sources.iso to SRPMS dir locally, flattening the dir
     hierarchy and skipping any file that doesn't look like an SRPM *)
  sync ~filtermap:(
    function
    | `Directory x -> Some "/"
    | `File x -> filter_file x ".src.rpm")
    iso iso.Iso.entries srpmsdir "/"
  >>|= fun () ->
  Lwt.return ok

let check th =
  th >>= function
  | Lwt_unix.WEXITED x when x=0 -> Lwt.return ok
  | _ -> Lwt.return (`Error `Bad)

let get uri filename =
  let open Cohttp in
  let open Cohttp_lwt_unix in
  let so_far = ref 0 in
  let last_percentage = ref (-1) in
  Client.call `GET (Uri.of_string uri)
  >>= fun (res, body) ->
  let status = Response.status res in
  let res_sexp = Response.sexp_of_t res in
  Printf.printf "Response: %s\n%!" (Sexplib.Sexp.to_string res_sexp);
  let headers = Response.headers res in
  let len =
    match Header.get headers "content-length" with
    | Some len ->
      Printf.printf "Got content-length: %s\n%!" len;
      Some (int_of_string len)
    | None ->
      Printf.printf "No content-length\n%!";
      None
  in
  match Code.is_success (Code.code_of_status status) with
  | false ->
    Printf.fprintf stderr "Got bad return code fetching \"%s\": %s"
      uri (Code.string_of_status status);
    exit 1
  | true ->
    Lwt_io.with_file ~mode:Lwt_io.output filename
      (fun chan -> Lwt_stream.iter_s
          (fun s ->
             so_far := !so_far + (String.length s);
             (match len with
             | Some i ->
               let percent = (100 * !so_far) / i in
               if !last_percentage <> percent then begin
                 if percent mod 10 = 0 then
                   Printf.printf "%d%%%!" percent;
                   if percent = 100 then Printf.printf "\n%!"
                 else
                   Printf.printf ".%!";
                 last_percentage := percent
               end
             | None -> ());
             Lwt_io.write chan s)
          (Cohttp_lwt_body.to_stream body)) >>= fun () ->
    match len with
    | Some i ->
      if !so_far != i
      then begin
        Printf.fprintf stderr "Receieved size <> content-length: (%d <> %d)\n%!" (!so_far) i;
        exit 1
      end;
      Lwt.return ok
    | None ->
      Lwt.return ok
        

let with_downloaded_isos uri_base source_iso f =
  let binpkg_uri = Printf.sprintf "%s/binpkg.iso" uri_base in
  let binpkg_fname = Filename.temp_file "binpkg" "iso" in
  let sources_uri = Printf.sprintf "%s/%s" uri_base source_iso in
  let sources_fname = Filename.temp_file "source" "iso" in

  Printf.printf "Downloading %s\n%!" binpkg_uri;
  get binpkg_uri binpkg_fname
  >>|= fun () ->
  Printf.printf "Downloading %s\n%!" sources_uri;
  get sources_uri sources_fname
  >>|= fun () ->
  f (binpkg_fname, sources_fname)
  >>= fun x ->
  Lwt_unix.unlink binpkg_fname
  >>= fun () -> 
  Lwt_unix.unlink sources_fname
  >>= fun () ->
  Lwt.return x
  
let run root branch source_iso s3bin =
  with_downloaded_isos branch source_iso
    (fun (binpkg_iso, sources_iso) ->
      Printf.printf "Running createtree\n%!";
      create_tree root binpkg_iso sources_iso
      >>|= fun () ->
      Printf.printf "Running createrepo\n%!";
      check (Lwt_unix.system (Printf.sprintf "createrepo %s/domain0" root))
      >>|= fun _ ->
      Printf.printf "Running s3cmd sync\n%!";
      check (Lwt_unix.system (Printf.sprintf "s3cmd sync --delete-removed %s %s" root s3bin))
      >>|= fun _ -> Lwt.return ok)

let get_http_body url =
  Client.get (Uri.of_string url)
  >>= fun (res,body) ->
  let ok = 
    if not (res |> Response.status |> Code.code_of_status |> Code.is_success)
    then
      (
        Printf.fprintf stderr "Bad response: %s\n" (res |> Response.status |> Code.string_of_status);
        Lwt.return (`Error `Bad_response)
      )
    else Lwt.return (`Ok ())
  in
  ok
  >>|= fun () ->
  (Cohttp_lwt_body.to_string body >>= fun s -> Lwt.return (`Ok s))

let get_env_var var =
  try Sys.getenv var
  with Not_found -> failwith ("The " ^ var ^ " environment variable must be defined.")

let get_last_successful_build branch =
  let branch_path = Re_str.global_replace (Re_str.regexp "/") "%252F" branch in
  let url =
    let path = "job/xenserver-specs/job/" ^ branch_path ^ "/api/json?tree=lastSuccessfulBuild[number]" in
    (get_env_var "JENKINS_URL") // path
  in
  get_http_body url
  >>|= fun body ->
  let open Yojson.Basic in
  Lwt.catch
    (fun () ->
      `Ok (from_string body
          |> Util.member "lastSuccessfulBuild"
          |> Util.member "number"
          |> to_string)
      |> Lwt.return)
    (fun exn ->
      let msg = Printf.sprintf "Error: Getting latest build number failed for branch %s: %s\n%!" branch (Printexc.to_string exn) in
      Lwt_io.eprintl msg >>= fun () ->
      `Error msg |> Lwt.return)

let print_whitelist () =
  Printf.printf "Using whitelist:\n%!";
  List.iter (fun x -> Printf.printf "%s\n%!" x) whitelist

let best_effort_upload branch f =
  Lwt.catch
    (fun () -> f () >>|= fun () -> Lwt.return_unit)
    (fun exn ->
      Lwt_io.eprintlf "Error: Failed to upload branch %s: %s" branch (Printexc.to_string exn))

let _ =
  let carbon   = "http://coltrane.uk.xensource.com/usr/groups/build/carbon" in
  let artifactory = (get_env_var "ARTIFACTORY_URL") // "xs-local-assembly/xenserver" in
  let uuid     = String.concat ~sep:"-" in
  let s3bucket   = "s3://xapi-repos/" in

  print_whitelist ();

  Lwt_main.run (

    let branch = "team/ring3/master" in
    best_effort_upload branch
      (fun () -> get_last_successful_build branch >>|= fun n ->
      run (uuid ["1337ab6c";"77ab";"9c8c";"a91f";"38fba8bee8dd"])
        (artifactory // branch // n ) "source-retail.iso"
        s3bucket) >>= fun () ->

    let branch = "release/falcon/lcm" in
    best_effort_upload branch
      (fun () -> get_last_successful_build branch >>|= fun n ->
      run (uuid ["fa7c0ea9";"9d31";"50bb";"a8d6";"8ae367ef2f14"])
        (artifactory // branch // n ) "source-retail.iso"
        s3bucket) >>= fun () ->

    let branch = "feature/CBT" in
    best_effort_upload branch
      (fun () -> get_last_successful_build branch >>|= fun n ->
      run (uuid ["fea762e7";"cb70";"4be9";"ef86";"43ae89f91cd2"])
        (artifactory // branch // n ) "source-retail.iso"
        s3bucket) >>= fun () ->

    let branch = "release/honolulu/lcm" in
    best_effort_upload branch
      (fun () -> get_last_successful_build branch >>|= fun n ->
        run (uuid ["449e52a4";"271a";"483a";"baa7";"24bf362866f7"])
          (artifactory // branch // n) "source.iso"
          s3bucket) >>= fun () ->

    let branch = "dundee-bugfix/xe-phase-3-latest/xe-phase-3" in
    best_effort_upload branch
      (fun () -> run (uuid ["d8bc8edf";"e8c2";"4b6d";"b82f";"24d6742ea8bc"])
        (carbon // branch) "source.iso"
        s3bucket)
    )

