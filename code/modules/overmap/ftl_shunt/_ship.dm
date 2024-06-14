//Generic console base for consoles that interact with the overmap
//If you are looking for the Dradis console look in nsv13/modules/overmap/radar.dm
//If you're looking for the FTL navigation computer look in nsv13/modules/overmap/starmap.dm
//Yes beeps are here because reasons

/obj/machinery/computer/ship
	name = "Ship console"
	var/obj/structure/overmap/linked
	var/position = null
	var/can_sound = TRUE
	var/sound_cooldown = 10 SECONDS
	var/list/ui_users = list()

/obj/machinery/computer/ship/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/ship/LateInitialize()
	has_overmap()

/obj/machinery/computer/ship/tgui_state(mob/user)
	return GLOB.tgui_default_state

/obj/machinery/computer/ship/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	tgui_interact(user)

/obj/machinery/computer/ship/proc/relay_sound(sound, message)
	if(!can_sound)
		return
	if(message)
		visible_message(message)
	if(sound)
		playsound(src, sound, 100, 1)
		can_sound = FALSE

/obj/machinery/computer/ship/proc/reset_sound()
	can_sound = TRUE

/obj/machinery/computer/ship/proc/has_overmap()
	linked = get_overmap()
	if(linked)
		set_position(linked)
	return linked

/obj/machinery/computer/ship/proc/set_position(obj/structure/overmap/OM)
	return

/obj/machinery/computer/ship/tgui_interact(mob/user)
	if(isobserver(user))
		return FALSE

	if(!has_overmap())
		playsound(loc, 'sound/signals/error27.ogg', 100, 1)
		to_chat(user, SPAN_WARNING("A warning flashes across [src]'s screen: Unable to locate thrust parameters, no registered ship stored in microprocessor."))
		return FALSE

	if((position & OVERMAP_USER_ROLE_PILOT) && linked.ai_controlled)
		playsound(loc, 'sound/signals/error27.ogg', 100, 1)
		to_chat(user, SPAN_WARNING("A warning flashes across [src]'s screen: Automated flight protocols are still active. Unable to comply."))
		return FALSE

	if(!position)
		return TRUE

	ui_users += user
	return linked.start_piloting(user, position)

/obj/machinery/computer/ship/Destroy()
	for(var/mob/living/M in ui_users)
		ui_close(M)
		linked?.stop_piloting(M)

	linked = null
	ui_users.Cut()
	return ..()

/obj/machinery/computer/ship/viewscreen
	name = "Seegson model M viewscreen"
	desc = "A large CRT monitor which shows an exterior view of the ship."
	icon_screen = "starmap"
	idle_power_usage = 15
	mouse_over_pointer = MOUSE_HAND_POINTER
	pixel_y = 26
	density = FALSE
	anchored = TRUE
	req_access = null
	var/obj/machinery/computer/ship/dradis/minor/internal_dradis

/obj/machinery/computer/ship/viewscreen/Initialize(mapload)
	. = ..()
	internal_dradis = new(src)

/obj/machinery/computer/ship/viewscreen/examine(mob/user)
	. = ..()
	if(!linked)
		return
	if(isobserver(user))
		var/mob/observer/ghost/G = user
		G.ManualFollow(linked)
		return

	linked.observe_ship(user)
	internal_dradis.attack_hand(user)

/obj/machinery/computer/ship/viewscreen/tgui_interact(mob/user)
	if(!has_overmap())
		return

	if(isobserver(user))
		var/mob/observer/ghost/G = user
		G.ManualFollow(linked)
		return

	linked.start_piloting(user, OVERMAP_USER_ROLE_OBSERVER)
