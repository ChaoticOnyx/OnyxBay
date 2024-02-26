/obj/machinery/button/minigame
	name = "Ready Declaration Device"
	desc = "This device is used to declare ready. If all devices in an area are ready, the event will begin!"

	icon = 'icons/obj/monitors.dmi'
	icon_state = "auth_off"

	var/area/current_area
	var/disabled = FALSE

/obj/machinery/button/minigame/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/button/minigame/LateInitialize()
	current_area = get_area(loc)
	if(isnull(current_area))
		log_debug("[src] has no area.")
		qdel(src)
		return

/obj/machinery/button/minigame/on_update_icon()
	icon_state = "auth_[active ? "on" : "off"]"

/obj/machinery/button/minigame/attackby(obj/item/W, mob/user)
	return

/obj/machinery/button/minigame/attack_ai(mob/user)
	return

/obj/machinery/button/minigame/activate(mob/living/user)
	if(disabled)
		show_splash_text(user, "event already started")
		return

	active = !active
	update_icon()

	var/buttons_total = 0
	var/buttons_ready = 0
	for(var/obj/machinery/button/minigame/button in current_area)
		buttons_total++

		if(button.active)
			buttons_ready++

	if(buttons_total == buttons_ready)
		inititate_event()

/obj/machinery/button/minigame/proc/inititate_event()
	disabled = TRUE

	for(var/obj/structure/window/basic/window in current_area)
		qdel(window)

	for(var/mob/participant in current_area)
		to_chat(participant, SPAN_DANGER("FIGHT!"))
