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

let get_result_exn r =
  match r with
  | Ok v -> v
  | Error _ -> failwith "Not ok"

let test_acquiring () =
  let module DummyPool = Pool.Make(struct
      type resource = int
      let min = 1
      let max = 3
      let create () = 42
    end) in
  match DummyPool.acquire () with
  | Ok num -> Alcotest.(check int) "same ints" 42 num
  | Error _ -> Alcotest.fail "Should not error"

let test_acquiring_overflow () =
  let module DummyPool = Pool.Make(struct
      type resource = int
      let min = 1
      let max = 3
      let create () = 42
    end) in
  (* Exhaust the maximum number (3) of pool *)
  let _ = DummyPool.acquire () in
  let _ = DummyPool.acquire () in
  let _ = DummyPool.acquire () in
  match DummyPool.acquire () with
  | Ok num -> Alcotest.fail "Should not be ok"
  | Error _ -> Alcotest.(check pass) "overflow" 0 0

let test_releasing () =
  let module DummyPool = Pool.Make(struct
      type resource = int
      let min = 1
      let max = 3
      let create () = 42
    end) in
  (* Exhaust the maximum number (3) of pool *)
  let _ = DummyPool.acquire () in
  let _ = DummyPool.acquire () in
  let r = DummyPool.acquire () in
  (* Release one of the resource *)
  let () = r |> get_result_exn |> DummyPool.release in
  match DummyPool.acquire () with
  | Ok num -> Alcotest.(check int) "same ints" 42 num
  | Error _ -> Alcotest.fail "Should not error"

let test_set = [
  "Acquiring", `Quick, test_acquiring ;
  "Acquiring overflow", `Quick, test_acquiring_overflow ;
  "Releasing", `Quick, test_releasing ;
]

let _ =
  Alcotest.run "Pool" [
    "test_set", test_set
  ]
