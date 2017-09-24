(*
 * Copyright (c) 2017 Bobby Priambodo
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *)

let range i j =
  let rec aux n acc =
    if n < i then acc else aux (n-1) (n :: acc)
  in aux j []

module type POOLABLE = sig
  type resource
  val min : int
  val max : int
  val create : unit -> resource
end

module type POOL = sig
  type resource
  val acquire : unit -> (resource, string) result
  val release : resource -> unit
end

module Make (P : POOLABLE) : POOL with type resource = P.resource = struct
  type resource = P.resource

  type state = {
    all_resources : resource list ;
    free_resources : resource list ;
  }

  let state = ref {
      all_resources = [] ;
      free_resources = [] ;
    }

  let acquire () =
    match !state.free_resources with
    | [] ->
      if (List.length !state.all_resources < P.max) then begin
        let r = P.create () in
        let _ = state := { !state with all_resources = r :: !state.all_resources} in
        Ok r
      end else Error "Maximum number of pooled resource reached."
    | r::rest ->
      state := { !state with free_resources = rest };
      Ok r

  let release r =
    state := { !state with free_resources = r :: !state.free_resources }

  let _ =
    let resources = List.map (fun _ -> P.create ()) (range 1 P.min) in
    state := {
      all_resources = resources ;
      free_resources = resources ;
    }
end
