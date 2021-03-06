open! Core_kernel
open! Async_kernel
open! Import
open Incr.Let_syntax
include To_incr_dom_intf

let create_generic unpacked ~action_type_id ~input ~old_model ~model ~inject =
  let%map snapshot =
    Bonsai.Expert.eval ~input ~old_model ~model ~inject ~action_type_id unpacked
  and model = model in
  let apply_action incoming_action _state ~schedule_action:_ =
    let schedule_event = Vdom.Event.Expert.handle_non_dom_event_exn in
    Bonsai.Expert.Snapshot.apply_action snapshot ~schedule_event incoming_action
  in
  let view, extra = Bonsai.Expert.Snapshot.result snapshot in
  Incr_dom.Component.create_with_extra ~extra ~apply_action model view
;;

let convert_generic
      (type input model action extra)
      (unpacked : (input, model, action, Vdom.Node.t * extra) Bonsai.Expert.unpacked)
      ~(action_type_id : action Type_equal.Id.t)
  : (module S
      with type Model.t = model
       and type Input.t = input
       and type Extra.t = extra)
  =
  (module struct
    module Input = struct
      type t = input
    end

    module Model = struct
      type t = model
    end

    module Action = struct
      type t = action

      let sexp_of_t = Type_equal.Id.to_sexp action_type_id
    end

    module Extra = struct
      type t = extra
    end

    let create ~input ~old_model ~model ~inject =
      create_generic unpacked ~action_type_id ~input ~old_model ~model ~inject
    ;;
  end)
;;

let convert_with_extra component =
  let (T (unpacked, action_type_id)) = Bonsai.Expert.reveal component in
  convert_generic unpacked ~action_type_id
;;

let convert component = convert_with_extra (Bonsai.map component ~f:(fun r -> r, ()))
