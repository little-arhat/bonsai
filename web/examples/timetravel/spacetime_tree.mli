open! Core_kernel

type 'a t [@@deriving sexp]

module Cursor : sig
  type t [@@deriving equal, sexp_of]
end

val create : 'a -> 'a t * Cursor.t
val append : 'a t -> Cursor.t -> 'a -> 'a t * Cursor.t
val find : 'a t -> Cursor.t -> 'a
val width : 'a t -> int
val height : 'a t -> int
val traverse : 'a t -> f:(data:'a -> cursor:Cursor.t -> children:'r list -> 'r) -> 'r
