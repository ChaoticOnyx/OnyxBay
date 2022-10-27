/obj/machinery/firealarm
	name = "fire alarm"
	desc = "<i>\"In case of emergency press HERE\"</i>. Or shoot."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "fire"
	var/activated = 0
	var/detecting = 1
	anchored = 1
	idle_power_usage = 2 WATTS
	active_power_usage = 6 WATTS
	power_channel = STATIC_ENVIRON
	layer = ABOVE_WINDOW_LAYER
	var/wiresexposed = 0
	var/buildstage = 2 // 2 = complete, 1 = no wires,  0 = circuit gone
	var/image/alarm_overlay
	var/image/seclevel_overlay

/obj/machinery/firealarm/_examine_text(mob/user)
	. = ..()
	var/decl/security_state/security_state = decls_repository.get_decl(GLOB.using_map.security_state)
	. += "\nThe current alert level is [security_state.current_security_level.name]."

/obj/machinery/firealarm/update_icon()
	if(!alarm_overlay)
		alarm_overlay = image(icon, "fire[activated]")
		alarm_overlay.plane = EFFECTS_ABOVE_LIGHTING_PLANE
		alarm_overlay.layer = ABOVE_LIGHTING_LAYER

	if(!seclevel_overlay)
		seclevel_overlay = image(icon, "seclevel-null")
		seclevel_overlay.plane = EFFECTS_ABOVE_LIGHTING_PLANE
		seclevel_overlay.layer = ABOVE_LIGHTING_LAYER

	overlays.Cut()

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

	if(stat & NOPOWER)
		set_light(0)
		return

	icon_state = "fire"

	alarm_overlay.icon_state = "fire[activated]"
	overlays += alarm_overlay

	if(!detecting)
		return

	if(z in GLOB.using_map.get_levels_with_trait(ZTRAIT_CONTACT))
		var/decl/security_state/security_state = decls_repository.get_decl(GLOB.using_map.security_state)
		var/decl/security_level/sl = security_state.current_security_level

		set_light(sl.light_max_bright, sl.light_inner_range, sl.light_outer_range, 2, sl.light_color_alarm)
		seclevel_overlay.icon = sl.icon
		seclevel_overlay.icon_state = sl.overlay_alarm
		overlays += seclevel_overlay

/obj/machinery/firealarm/fire_act(datum/gas_mixture/air, temperature, volume)
	if(!detecting)
		return

	if(temperature > (200 CELSIUS))
		alarm()	// added check of detector status here
	return

/obj/machinery/firealarm/bullet_act()
	if(!wiresexposed)
		return alarm()

/obj/machinery/firealarm/emp_act(severity)
	if(prob(50/severity))
		alarm(rand(30/severity, 60/severity))
	..()

/obj/machinery/firealarm/attackby(obj/item/W as obj, mob/user as mob)
	if(isScrewdriver(W) && buildstage == 2)
		wiresexposed = !wiresexposed
		update_icon()
		return

	if(wiresexposed)
		switch(buildstage)
			if(2)
				if(isMultitool(W))
					src.detecting = !( src.detecting )
					if (src.detecting)
						user.visible_message("<span class='notice'>\The [user] has reconnected [src]'s detecting unit!</span>", "<span class='notice'>You have reconnected [src]'s detecting unit.</span>")
					else
						user.visible_message("<span class='notice'>\The [user] has disconnected [src]'s detecting unit!</span>", "<span class='notice'>You have disconnected [src]'s detecting unit.</span>")
				else if(isWirecutter(W))
					user.visible_message("<span class='notice'>\The [user] has cut the wires inside \the [src]!</span>", "<span class='notice'>You have cut the wires inside \the [src].</span>")
					new /obj/item/stack/cable_coil(get_turf(src), 5)
					playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1)
					buildstage = 1
					update_icon()
			if(1)
				if(istype(W, /obj/item/stack/cable_coil))
					var/obj/item/stack/cable_coil/C = W
					if (C.use(5))
						to_chat(user, "<span class='notice'>You wire \the [src].</span>")
						buildstage = 2
					else
						to_chat(user, "<span class='warning'>You need 5 pieces of cable to wire \the [src].</span>")
				else if(isCrowbar(W))
					to_chat(user, "You pry out the circuit!")
					playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
					if(do_after(user, 20, src))
						var/obj/item/firealarm_electronics/circuit = new /obj/item/firealarm_electronics()
						circuit.dropInto(user.loc)
						buildstage = 0
						update_icon()
			if(0)
				if(istype(W, /obj/item/firealarm_electronics))
					to_chat(user, "You insert the circuit!")
					qdel(W)
					buildstage = 1
					update_icon()

				else if(isWrench(W))
					to_chat(user, "You remove the fire alarm assembly from the wall!")
					new /obj/item/frame/fire_alarm(get_turf(user))
					playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
					qdel(src)
		return

	..()
	alarm()

	return

/obj/machinery/firealarm/Process()//Note: this processing was mostly phased out due to other code, and only runs when needed
	if(stat & (NOPOWER|BROKEN))
		return

	if(!detecting)
		return

	if(locate(/obj/fire) in loc)
		alarm()

/obj/machinery/firealarm/attack_ai(mob/user)
	if(!activated)
		alarm()
	else
		reset()

/obj/machinery/firealarm/attack_hand(mob/user)
	. = ..()
	if (.)
		return .

	if(wiresexposed)
		return .

	playsound(src.loc, SFX_USE_BUTTON, 50, 1)

	if(!activated)
		alarm()
	else
		to_chat(user, "You push \the [src]...")
		if(do_after(user, 50, src))
			reset()

	return .

/obj/machinery/firealarm/proc/reset()
	activated = 0
	var/area/area = get_area(src)
	for(var/obj/machinery/firealarm/FA in area)
		fire_alarm.clearAlarm(loc, FA)
	update_icon()
	return

/obj/machinery/firealarm/proc/alarm(duration = 0)
	if(activated)
		return
	activated = 1
	var/area/area = get_area(src)
	for(var/obj/machinery/firealarm/FA in area)
		fire_alarm.triggerAlarm(loc, FA, duration)
	update_icon()
	playsound(src, 'sound/machines/fire_alarm.ogg', 25, 0)
	return

/obj/machinery/firealarm/New(loc, dir, atom/frame)
	..(loc)

	if(dir)
		src.set_dir(dir)

	if(istype(frame))
		buildstage = 0
		wiresexposed = 1
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
	..()

/*
FIRE ALARM CIRCUIT
Just a object used in constructing fire alarms
*/
/obj/item/firealarm_electronics
	name = "fire alarm electronics"
	icon = 'icons/obj/doors/door_assembly.dmi'
	icon_state = "door_electronics"
	desc = "A circuit. It has a label on it, it says \"Can handle heat levels up to 40 degrees celsius!\"."
	w_class = ITEM_SIZE_SMALL
	matter = list(MATERIAL_STEEL = 50, MATERIAL_GLASS = 50)
