#define FIREALARM_NOCIRCUIT	0
#define FIREALARM_NOWIRES	1
#define FIREALARM_COMPLETE	2

/obj/machinery/firealarm
	name = "fire alarm"
	desc = "<i>\"In case of emergency press HERE\"</i>. Or shoot."
	icon = 'icons/obj/monitors.dmi'
	base_icon_state = "fire"
	icon_state = "fire"
	var/activated = FALSE
	var/detecting = TRUE
	var/time = 10
	var/timing = 0
	anchored = TRUE
	var/last_activated = 0
	idle_power_usage = 2 WATTS
	active_power_usage = 6 WATTS
	power_channel = STATIC_ENVIRON
	layer = ABOVE_WINDOW_LAYER
	var/wiresexposed = FALSE
	var/buildstage = FIREALARM_COMPLETE

	var/static/status_overlays = FALSE
	var/static/list/alarm_overlays
	var/mutable_appearance/seclevel_overlay // There's a whole system for different seclevels across different maps so let's just leave it like this until I figure out what the fuck

/obj/machinery/firealarm/New(loc, dir, atom/frame)
	..(loc)

	if(dir)
		set_dir(dir)

	if(istype(frame))
		buildstage = FIREALARM_NOCIRCUIT
		wiresexposed = TRUE
		icon_state = "fire_b0"
		ClearOverlays()
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -24 : 24)
		pixel_y = (dir & 3)? (dir ==1 ? -24 : 24) : 0
		frame.transfer_fingerprints_to(src)
	GLOB.firealarm_list += src

/obj/machinery/firealarm/Initialize()
	. = ..()
	if(z in GLOB.using_map.get_levels_with_trait(ZTRAIT_CONTACT))
		update_icon()

/obj/machinery/firealarm/Destroy()
	GLOB.firealarm_list -= src
	ClearOverlays()
	QDEL_NULL(seclevel_overlay)
	return ..()

/obj/machinery/firealarm/examine(mob/user, infix)
	. = ..()

	if(detecting && !wiresexposed)
		var/decl/security_state/security_state = decls_repository.get_decl(GLOB.using_map.security_state)
		. += "The current alert level is <span style='color:[security_state.current_security_level.light_color_alarm];'>[security_state.current_security_level.name]</span>."

/obj/machinery/firealarm/on_update_icon()
	if(!status_overlays)
		status_overlays = TRUE
		generate_overlays()

	if(!seclevel_overlay)
		var/image/SO = image(icon, "seclevel-null")
		SO.alpha = 200
		seclevel_overlay = SO

	ClearOverlays()

	if(wiresexposed)
		switch(buildstage)
			if(2)
				icon_state="fire_b2"
			if(1)
				icon_state="fire_b1"
			if(0)
				icon_state="fire_b0"
		set_light(0)
		return

	if(stat & BROKEN)
		icon_state = "firex"
		set_light(0)
		return

	icon_state = "fire"

	if(stat & NOPOWER)
		set_light(0)
		return

	AddOverlays(alarm_overlays[activated+1])
	AddOverlays(alarm_overlays[activated+3])

	if(!detecting)
		return

	if(z in GLOB.using_map.get_levels_with_trait(ZTRAIT_CONTACT))
		var/decl/security_state/security_state = decls_repository.get_decl(GLOB.using_map.security_state)
		var/decl/security_level/sl = security_state.current_security_level

		set_light(sl.light_max_bright, sl.light_inner_range, sl.light_outer_range, 2, sl.light_color_alarm)
		seclevel_overlay.icon = sl.icon
		seclevel_overlay.icon_state = sl.overlay_alarm
		AddOverlays(seclevel_overlay)
		AddOverlays(emissive_appearance(sl.icon, "[sl.overlay_alarm]_ea"))

/obj/machinery/firealarm/proc/generate_overlays()
	alarm_overlays = new
	alarm_overlays.len = 4
	alarm_overlays[1] = image(icon, "fire0")
	alarm_overlays[2] = image(icon, "fire1")
	alarm_overlays[1].alpha = 200
#define OVERLIGHT_IMAGE(a, b) a=emissive_appearance(icon, b, cache = FALSE);
	OVERLIGHT_IMAGE(alarm_overlays[3], "fire_ea0")
	OVERLIGHT_IMAGE(alarm_overlays[4], "fire_ea1")
#undef OVERLIGHT_IMAGE

/obj/machinery/firealarm/fire_act(datum/gas_mixture/air, temperature, volume)
	if(!detecting)
		return ..()

	if(temperature > (200 CELSIUS))
		alarm()

	return ..()

/obj/machinery/firealarm/bullet_act(obj/item/projectile/proj)
	if(!wiresexposed)
		. = alarm()
		if(.)
			visible_message(SPAN("danger", "\The [proj] hits and activates [src]!"))
		else
			visible_message(SPAN("danger", "\The [proj] hits [src]!"))

/obj/machinery/firealarm/emp_act(severity)
	if(prob(50/severity))
		alarm(rand(30/severity, 60/severity))
	..()

/obj/machinery/firealarm/attackby(obj/item/W, mob/user)
	if(isScrewdriver(W) && buildstage == FIREALARM_COMPLETE)
		wiresexposed = !wiresexposed
		update_icon()
		return

	if(wiresexposed)
		switch(buildstage)
			if(2)
				if(isMultitool(W))
					src.detecting = !( src.detecting )
					user.visible_message(SPAN("danger", "\The [user] has [detecting ? "reconnected" : "disconnected"] [src]'s detecting unit!"),\
										SPAN("danger", "You have [detecting ? "reconnected" : "disconnected"] [src]'s detecting unit."))
				else if(isWirecutter(W))
					user.visible_message(SPAN("danger", "\The [user] has cut the wires inside \the [src]!"),\
										SPAN("danger", "You have cut the wires inside \the [src]."))
					new /obj/item/stack/cable_coil(get_turf(src), 5)
					playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1)
					buildstage = FIREALARM_NOWIRES
					update_icon()
			if(1)
				if(isCoil(W))
					var/obj/item/stack/cable_coil/C = W
					if (C.use(5))
						user.visible_message(SPAN("notice", "\The [user] wired \the [src].</span>"), SPAN("notice", "You wire \the [src]."))
						buildstage = FIREALARM_COMPLETE
					else
						to_chat(user, SPAN("warning", "You need 5 pieces of cable to wire \the [src]."))
				else if(isCrowbar(W))
					to_chat(user, SPAN("danger", "You pry out the circuit!"))
					playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
					if(do_after(user, 20, src))
						var/obj/item/firealarm_electronics/circuit = new /obj/item/firealarm_electronics()
						circuit.dropInto(user.loc)
						buildstage = FIREALARM_NOCIRCUIT
						update_icon()
			if(0)
				if(istype(W, /obj/item/firealarm_electronics))
					user.visible_message(user, SPAN("notice", "You insert the circuit!"))
					qdel(W)
					buildstage = FIREALARM_NOWIRES
					update_icon()

				else if(isWrench(W))
					user.visible_message(SPAN("danger", "\The [user] removes \the [src] assembly from the wall!"),\
										SPAN("danger", "You remove \the [src] assembly from the wall!"))
					new /obj/item/frame/fire_alarm(get_turf(user))
					playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
					qdel(src)
		return

	alarm()

	return ..()

/obj/machinery/firealarm/think()
	if(stat & (NOPOWER|BROKEN))
		timing = FALSE
		return

	if(timing)
		if(time > 0)
			time--
		else
			alarm()
			timing = FALSE
			time = 0
		updateDialog()
		set_next_think(world.time + 1 SECOND)

	if(locate(/obj/fire) in loc)
		alarm()

/obj/machinery/firealarm/attack_ai(mob/user)
	return ui_interact(user)

/obj/machinery/firealarm/AltClick(mob/user)
	return ui_interact(user)

/obj/machinery/firealarm/attack_hand(mob/user)
	. = ..()
	if (.)
		return .

	if(wiresexposed)
		return .

	playsound(src.loc, SFX_USE_BUTTON, 50, 1)

	if(!activated)
		alarm()
		user.visible_message(SPAN("danger", "\The [user] pressed \the [src]!"), SPAN("danger", "You pressed \the [src]!"))
	else
		if(last_activated + 5 SECOND < world.time)
			reset()
			user.visible_message(SPAN("danger", "\The [user] pressed \the [src]!"), SPAN("danger", "You pressed \the [src]!"))
		else
			user.visible_message(SPAN("danger", "\The [user] pressed \the [src]!"), SPAN("warning", "You pressed \the [src] but it didn't respond!"))

	return .

/obj/machinery/firealarm/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, datum/topic_state/state = GLOB.outside_state)
	var/data[0]
	var/decl/security_state/security_state = decls_repository.get_decl(GLOB.using_map.security_state)

	data["seclevel"] = security_state.current_security_level.name
	data["time"] = round(src.time)
	data["timing"] = timing
	var/area/A = get_area(src)
	data["active"] = A.fire

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "fire_alarm.tmpl", "Fire Alarm", 240, 330, state = state)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/firealarm/OnTopic(user, href_list)
	if (href_list["status"] == "reset")
		if(last_activated + 5 SECOND < world.time)
			reset()
		else
			to_chat(user, SPAN("warning", "Wait for 5 seconds after [src] activation!"))
		return TOPIC_REFRESH
	else if (href_list["status"] == "alarm")
		alarm()
		return TOPIC_REFRESH
	if (href_list["timer"] == "set")
		time = between(0, input(user, "Enter time delay", "Fire Alarm Timer", time) as num, 60)
	else if (href_list["timer"] == "start")
		if(!timing)
			set_next_think(world.time)
			timing = TRUE
			return TOPIC_REFRESH
	else if (href_list["timer"] == "stop")
		timing = FALSE
		return TOPIC_REFRESH

/obj/machinery/firealarm/CanUseTopic(user)
	if(wiresexposed)
		return STATUS_CLOSE
	return ..()

/obj/machinery/firealarm/proc/reset()
	activated = FALSE
	var/area/area = get_area(src)
	for(var/obj/machinery/firealarm/FA in area)
		fire_alarm.clearAlarm(loc, FA)
	update_icon()
	return TRUE

/obj/machinery/firealarm/proc/alarm(duration = 0)
	if(activated)
		return FALSE
	last_activated = world.time
	activated = TRUE
	var/area/area = get_area(src)
	for(var/obj/machinery/firealarm/FA in area)
		fire_alarm.triggerAlarm(loc, FA, duration)
	update_icon()
	playsound(src, 'sound/machines/fire_alarm.ogg', 25, 0)
	return TRUE

/*
FIRE ALARM CIRCUIT
Just a object used in constructing fire alarms
*/
/obj/item/firealarm_electronics
	name = "fire alarm electronics"
	icon = 'icons/obj/monitors.dmi'
	icon_state = "fire_electronics"
	desc = "A circuit. It has a label on it, it says \"Can handle heat levels up to 40 degrees celsius!\"."
	w_class = ITEM_SIZE_SMALL
	matter = list(MATERIAL_STEEL = 50, MATERIAL_GLASS = 50)

/obj/machinery/firealarm/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if((buildstage == FIREALARM_NOCIRCUIT) && (the_rcd.upgrade & RCD_UPGRADE_SIMPLE_CIRCUITS))
		return list("delay" = 2 SECONDS, "cost" = 1)

	return FALSE

/obj/machinery/firealarm/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, list/rcd_data)
	switch(rcd_data["[RCD_DESIGN_MODE]"])
		if(RCD_WALLFRAME)
			show_splash_text(user, "circuit installed", SPAN("notice", "You install the circuit into \the [src]!"))
			buildstage = FIREALARM_NOWIRES
			update_icon()
			return TRUE

	return FALSE
