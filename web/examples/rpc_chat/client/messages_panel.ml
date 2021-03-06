open! Core_kernel
open! Async_kernel
open! Bonsai_web
open Bonsai_chat_common

module Input = struct
  type t =
    { current_room : Room.t
    ; messages : Message.t list
    }
  [@@deriving fields]

  let create = Fields.create
end

let view_message { Message.room = _; author; contents } =
  Vdom.Node.div [] [ Vdom.Node.textf "%s: %s" author contents ]
;;

let view { Input.current_room; messages } =
  Vdom.Node.div
    [ Vdom.Attr.id "messages-list" ]
    [ Vdom.Node.h1 [] [ Vdom.Node.text (Room.to_string current_room) ]
    ; Vdom.Node.div [] (List.map messages ~f:view_message)
    ]
;;

let component = Bonsai.pure ~f:view
