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

(** A generic resource pool library for OCaml.

    [Pool] uses functors to describe the resource needed to be pooled, including
    what the type is, how to create it, and what the minimum and maximum number
    of pooled resource you can have.

    {e Release %%VERSION%% }  *)

(** [POOLABLE] is an abstract interface that describes the poolable resource. *)
module type POOLABLE = sig

  type resource
  (** The type of the resource. *)

  val min : int
  (** The minimum number of resource the pool should have at all time. *)

  val max : int
  (** The maximum number of resource the pool should have at all time. *)

  val create : unit -> resource
  (** A way to create the resource. *)

end

(** [POOL] is an abstract interface for the pool. *)
module type POOL = sig

  type resource
  (** The type of the resource. Will be the same as the one in [POOLABLE]. *)

  val acquire : unit -> (resource, string) result
  (** Acquire a pooled resource. Will return an [Error msg] if the maximum
      number of resource is met. *)

  val release : resource -> unit
  (** Release a  resource back to the pool. *)

end

(** Functor to make a [POOL] given a [POOLABLE] resource. *)
module Make :
  functor (P : POOLABLE) ->
    POOL with type resource = P.resource
