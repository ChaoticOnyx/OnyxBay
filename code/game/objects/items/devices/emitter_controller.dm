/obj/item/device/t_scanner/emitter_controller 
    var/control_mode = FALSE
    var/active = FALSE
    var/list/modes = list("activate", "deactivate", "toggle lock")
    var/cur_mode = "activate"
    var/_wifi_id
    var/datum/wifi/sender/emitter/wifi_sender = new
    var/list/allowed_to_control = list(/obj/machinery/power/emitter, /obj/machinery/power/emitter/gyrotron)

/obj/item/device/t_scanner/emitter_controller/Initialize()
    . = ..()
    _wifi_id = "[rand(1, 100)]"
    wifi_sender = new (_wifi_id)
    verbs -= /obj/item/device/t_scanner/emitter_controller/verb/toggle_mode

/obj/item/device/t_scanner/emitter_controller/attack_self(mob/user)
    if(control_mode)
        if(!wifi_sender)
            to_chat(user, SPAN("notice","Contoller are not connected to any emitter."))
            return
        wifi_sender.activate(cur_mode, user)
        playsound(src.loc, 'sound/effects/compbeep3.ogg', 50)
    else
        ..()

/obj/item/device/t_scanner/emitter_controller/verb/toggle_mode(mob/user)
    set name = "Toggle Mode"
    set category = "Object"
    set desc = "Toggles mode of connected devices."
    var/new_index = modes.Find(cur_mode)
    if(!new_index)
        new_index = 0
    else
        new_index = new_index == modes.len ? 1 : new_index+1
    cur_mode = modes[new_index]
    to_chat(user, SPAN("notice","Your current mode is [cur_mode]."))


/obj/item/device/t_scanner/emitter_controller/attackby(obj/item/W, mob/user) 
    if(isScrewdriver(W))
        control_mode = !control_mode
        if(control_mode)
            verbs += /obj/item/device/t_scanner/emitter_controller/verb/toggle_mode
        else
            verbs -= /obj/item/device/t_scanner/emitter_controller/verb/toggle_mode
        playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
    else
        ..()

/obj/item/device/t_scanner/emitter_controller/resolve_attackby(atom/A, mob/user)
    if(!control_mode)
        ..()
        return
    if(!is_type_in_list(A, allowed_to_control))
        return
    var/obj/machinery/power/emitter/E = A
    if(isnull(E.wifi_receiver))
        E.wifi_receiver = new(_wifi_id, E)
    else
        E.wifi_receiver.id = _wifi_id

    wifi_sender.connect_device(E.wifi_receiver)
    playsound(src.loc, 'sound/effects/compbeep1.ogg', 50)
    if(wifi_sender.connected_devices.len > 3) // Device can hold 4 emitters at max.
        wifi_sender.disconnect_device(wifi_sender.connected_devices[1])
        wifi_sender.connected_devices[1].id = null

  

    
