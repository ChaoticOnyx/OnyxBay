#define POWER_IDLE 0
#define POWER_UP 1
#define POWER_DOWN 2

#define GRAV_NEEDS_PLASTEEL 1
#define GRAV_NEEDS_WELDING 2
#define GRAV_NEEDS_WRENCH 3
#define GRAV_NEEDS_SCREWDRIVER 4

#define AREA_ERRNONE 0
#define AREA_STATION 1
#define AREA_SPACE 2
#define AREA_SPECIAL 3

//
// Abstract Generator
//

/obj/machinery/gravity_generator
	name = "gravitational generator"
	desc = "A device which produces a graviton field when set up."
	icon = 'icons/obj/machines/gravity_generator.dmi'
	anchored = 1
	density = 1
	use_power = 0
	unacidable = 1

	light_color = "#7de1e1"

	var/sprite_number = 0
	var/broken_state = 0

/obj/machinery/gravity_generator/update_icon()
	icon_state = "[broken_state]_[sprite_number]"

/obj/machinery/gravity_generator/proc/show_broken_info()
	return

/obj/machinery/gravity_generator/ex_act(severity)
	return

/obj/machinery/gravity_generator/emp_act(severity)
	return

/obj/machinery/gravity_generator/bullet_act(obj/item/projectile/P, def_zone)
	return

/obj/machinery/gravity_generator/blob_act(destroy, obj/effect/blob/source)
	return

/obj/machinery/gravity_generator/proc/take_damage(amount)
	return

//
// Generator which spawns with the station.
//

GLOBAL_VAR(station_gravity_generator)
/obj/machinery/gravity_generator/main/station/Initialize(mapload, ...)
	. = ..()
	GLOB.station_gravity_generator = src
	if(!mapload)
		update_connectected_areas_gravity()


/obj/machinery/gravity_generator/main/station/Destroy()
	if(GLOB.station_gravity_generator == src)
		GLOB.station_gravity_generator = null
	return ..()

//
// Main Generator with the main code
//

/obj/machinery/gravity_generator/main
	name = "gravitational generator panel"
	icon_state = "0_8"
	idle_power_usage = 0
	active_power_usage = 100000
	power_channel = ENVIRON
	sprite_number = 8
	use_power = POWER_USE_ACTIVE

	var/enabled = TRUE               // for switching gravity status in areas
	var/breaker = TRUE               // if true - charges the GG if it has power
	var/charging_state = POWER_IDLE  // check process()
	var/charge_count = 100           // % of current charge
	var/health = 1000

	var/list/parts = list()
	var/list/lights = list()
	var/list/connected_areas = list()
	var/datum/wires/gravity_generator/wires = null
	var/obj/machinery/gravity_generator/part/middle = null

	// Wires
	var/announcer = TRUE                  // if true - notifies about the switching of the state of the generator to the engineering channel
	var/power_supply = TRUE               // if false - will lose power after proc/update_power()
	var/can_toggle_breaker = TRUE
	var/emergency_shutoff_button = FALSE  // if true - shows an additional option with emergency generator shutdown

/obj/machinery/gravity_generator/main/Initialize()
	. = ..()
	setup_parts()
	update_icon()
	add_areas()
	wires = new(src)

/obj/machinery/gravity_generator/main/Destroy()
	QDEL_NULL(wires)
	for(var/obj/machinery/gravity_generator/part/P in parts)
		P.main_part = null
		parts -= P
		if(!QDELETED(P))
			qdel(P)
	middle = null
	lights = null
	connected_areas = null
	update_connectected_areas_gravity()
	return ..()

/obj/machinery/gravity_generator/main/examine(mob/user)
	. = ..()
	if(panel_open)
		. += "\nThe maintenance hatch is open."
	. += "[show_broken_info()]"

/obj/machinery/gravity_generator/main/show_broken_info()
	switch(broken_state)
		if(GRAV_NEEDS_PLASTEEL)
			. += "\nIt requires ten plasteel to repair."
		if(GRAV_NEEDS_WELDING)
			. += "\nIt requires a welder to repair."
		if(GRAV_NEEDS_WRENCH)
			. += "\nIt requires a wrench to repair."
		if(GRAV_NEEDS_SCREWDRIVER)
			. += "\nIt requires a screwdriver to repair."

/obj/machinery/gravity_generator/main/ex_act(severity)
	switch(severity)
		if(1)
			take_damage(rand(750, 1250))
		if(2)
			take_damage(rand(350, 500))
		if(3)
			take_damage(rand(50, 150))

/obj/machinery/gravity_generator/main/emp_act(severity)
	if(!breaker || stat & (BROKEN|NOPOWER))
		return
	if(prob(80 / severity))
		set_state(FALSE)

/obj/machinery/gravity_generator/main/bullet_act(obj/item/projectile/P, def_zone)
	switch(P.damage_type)
		if(BRUTE)
			take_damage(P.damage)
		if(BURN)
			take_damage(P.damage)

/obj/machinery/gravity_generator/main/blob_act(destroy, obj/effect/blob/source)
	if(destroy)
		take_damage(rand(500, 1000))
	else
		take_damage(rand(50, 150))

/obj/machinery/gravity_generator/main/take_damage(amount)
	var/new_health = max(0, health - amount)
	update_health(new_health)
	update_icon()

/obj/machinery/gravity_generator/main/proc/set_broken_state(state)
	broken_state = state
	for(var/obj/machinery/gravity_generator/part/P in parts)
		P.broken_state = state

/obj/machinery/gravity_generator/main/proc/update_health(new_health)
	if(new_health == health)
		return
	health = new_health
	switch(health)
		if(0)
			charge_count = 0
			enabled = FALSE
			visible_message(SPAN_WARNING("\The [src] breaks apart!"))
			set_broken_state(GRAV_NEEDS_PLASTEEL)
			stat |= BROKEN
			set_state(FALSE)
			update_gravity_status()
			update_power()
		if(1 to 249)
			set_broken_state(GRAV_NEEDS_WELDING)
		if(250 to 499)
			set_broken_state(GRAV_NEEDS_WRENCH)
		if(500 to 749)
			set_broken_state(GRAV_NEEDS_SCREWDRIVER)

/obj/machinery/gravity_generator/main/proc/setup_parts()
	var/turf/our_turf = get_turf(src)
	// 9x9 block obtained from the bottom middle of the block
	var/list/spawn_turfs = block(locate(our_turf.x - 1, our_turf.y + 2, our_turf.z), locate(our_turf.x + 1, our_turf.y, our_turf.z))
	var/count = 10
	for(var/turf/T in spawn_turfs)
		count--
		if(T == our_turf) // Skip our turf.
			continue
		var/obj/machinery/gravity_generator/part/P = new(T)
		if(count == 5)
			middle = P
		if(count <= 3) // Their sprite is the top part of the generator
			P.density = 0
			P.layer = MOB_LAYER + 0.1
		if(count in list(2, 5, 7, 9))
			lights += P
		P.sprite_number = count
		P.main_part = src
		parts += P

// Fixing the gravity generator.
/obj/machinery/gravity_generator/main/attackby(obj/item/I, mob/user)
	switch(broken_state)
		if(GRAV_NEEDS_PLASTEEL)
			if(istype(I, /obj/item/stack/material/plasteel) || broken_state != GRAV_NEEDS_PLASTEEL)
				var/obj/item/stack/material/plasteel/PS = I
				if(PS.amount < 10)
					to_chat(user, SPAN_WARNING("You need 10 sheets of plasteel."))
					return
				user.visible_message(SPAN_NOTICE("[user] begins to add plasteel to the destroyed frame."),
									SPAN_NOTICE("You begin to add plasteel to the destroyed frame."))

				playsound(loc, 'sound/machines/click.ogg', 75, 1)
				if(!do_after(user, 15 SECONDS, middle) || PS.amount < 10)
					return
				PS.use(10)
				health += 250
				user.visible_message(SPAN_NOTICE("[user] replaced the destroyed frame."),
									SPAN_NOTICE("You replaced the destroyed frame."))
				playsound(loc, 'sound/machines/click.ogg', 75, 1)
				set_broken_state(GRAV_NEEDS_WELDING)
				update_icon()
				return

		if(GRAV_NEEDS_WELDING)
			if(isWelder(I))
				user.visible_message(SPAN_NOTICE("[user] begins to weld the damaged parts."),
									SPAN_NOTICE("You begin to weld the damaged parts."))

				playsound(loc, 'sound/items/Welder2.ogg', 50, 1)
				var/obj/item/weapon/weldingtool/WT = I
				if(!do_after(user, 15 SECONDS, middle) || !WT.remove_fuel(1, user) || broken_state != GRAV_NEEDS_WELDING)
					return
				health += 250
				user.visible_message(SPAN_NOTICE("[user] fixed the damaged parts."),
									SPAN_NOTICE("You fixed the damaged parts."))
				playsound(loc, 'sound/items/Welder2.ogg', 50, 1)
				set_broken_state(GRAV_NEEDS_WRENCH)
				update_icon()
				return

		if(GRAV_NEEDS_WRENCH)
			if(isWrench(I))
				user.visible_message(SPAN_NOTICE("[user] screws the parts back."),
									SPAN_NOTICE("You begin to screw the parts back."))

				playsound(loc, 'sound/items/Ratchet.ogg', 75, 1)
				if(!do_after(user, 15 SECONDS, middle) || broken_state != GRAV_NEEDS_WRENCH)
					return
				health += 250
				user.visible_message(SPAN_NOTICE("[user] screwed the parts back."),
									SPAN_NOTICE("You screwed the parts back."))
				playsound(loc, 'sound/items/Ratchet.ogg', 75, 1)
				set_broken_state(GRAV_NEEDS_SCREWDRIVER)
				update_icon()
				return TRUE

		if(GRAV_NEEDS_SCREWDRIVER)
			if(isScrewdriver(I))
				user.visible_message(SPAN_NOTICE("[user] begins to attach the details in the desired order."),
									SPAN_NOTICE("You begin to attach the details in the desired order."))

				playsound(loc, 'sound/items/Screwdriver.ogg', 75, 1)
				if(!do_after(user, 15 SECONDS, middle) || broken_state != GRAV_NEEDS_SCREWDRIVER)
					return
				health += max(initial(health), health + 250)
				user.visible_message(SPAN_NOTICE("[user] attached the details."),
									SPAN_NOTICE("You have attached the details."))
				playsound(loc, 'sound/items/Screwdriver.ogg', 75, 1)
				stat &= ~BROKEN
				set_broken_state(0)
				update_icon()
				return

	if(isCrowbar(I))
		if(!do_after(user, 5 SECONDS, middle))
			return
		playsound(loc, 'sound/items/Crowbar.ogg', 50, 1)
		panel_open = !panel_open
		update_icon()
		to_chat(user, SPAN_NOTICE("You [panel_open ? "open" : "close "] the maintenance hatch."))
		return

	attack_hand(user)

/obj/machinery/gravity_generator/part/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/gravity_generator/main/attack_ai(mob/user)
	if(stat & (BROKEN|NOPOWER))
		return

	ui_interact(user)

/obj/machinery/gravity_generator/main/attack_hand(mob/user)
	if(stat & BROKEN)
		to_chat(user, SPAN_WARNING("\The [src] is broken!"))
		return
	if(wires && panel_open)
		wires.Interact(user)
	if(stat & NOPOWER)
		return

	ui_interact(user)

/obj/machinery/gravity_generator/main/CanUseTopic(mob/user)
	if(!power_supply)
		return STATUS_CLOSE
	if(stat & EMPED)
		return STATUS_CLOSE
	return ..()

// Interaction
/obj/machinery/gravity_generator/main/ui_interact(mob/user, ui_key, datum/nanoui/ui, force_open, datum/nanoui/master_ui, datum/topic_state/state)
	var/data[0]

	data["enabled"] = enabled
	data["charging_state"] = charging_state
	data["charger_count"] = charge_count
	data["breaker"] = breaker
	data["emergency_shutoff_button"] = emergency_shutoff_button

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "gravity_generator.tmpl", "Gravitational Generator Panel", 500, 300, state = state)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/gravity_generator/main/OnTopic(mob/user, href_list, datum/topic_state/state)
	if(href_list["gentoggle"])
		if(!can_toggle_breaker || !power_supply || stat & NOPOWER)
			to_chat(user, SPAN_WARNING("You pressed a button, but it doesn’t seem to respond."))
			return
		set_state(breaker ? FALSE : TRUE)

	else if(href_list["eshutoff"])
		if(!emergency_shutoff_button)
			return
		if(!charge_count)
			to_chat(user, SPAN_WARNING("\The [middle] discharged!"))
			return

		user.visible_message(SPAN_WARNING("[user] starts to press a lot of buttons on \the [src]!"),
                             SPAN_NOTICE("You start to press many buttons on \the [src], as if you know what you are doing."))
		if(do_after(user, 15 SECONDS, src))
			emergency_shutoff()

/obj/machinery/gravity_generator/main/proc/emergency_shutoff()
	if(!charge_count)
		return

	var/charge = charge_count
	var/was_enabled = enabled
	charge_count = 0
	stat ^= EMPED
	enabled = FALSE
	breaker = FALSE
	charging_state = POWER_IDLE
	update_use_power(POWER_USE_IDLE)
	visible_message(SPAN_DANGER("\The [src] makes a large whirring noise!"))

	for(var/i = 0, i <= 3, i++)
		switch(i)
			if(0)
				set_light(8, 1,"#b30f00")
			if(1)
				set_light(8, 0.75,"#b30f00")
			if(2)
				set_light(8, 0.5,"#b30f00")
			if(3)
				set_light(8, 0.25,"#b30f00")

		playsound(loc, 'sound/effects/EMPulse.ogg', 100, 1)
		sleep(25)

	stat ^= EMPED
	if(was_enabled)
		update_gravity_status()
	update_icon()

	if(announcer)
		GLOB.global_announcer.autosay("Alert! Gravitational Generator has been discharged! Gravitation is disabled.", get_announcement_computer("Gravity Generator Alert System"))

	SSradiation.radiate(src, 3 * charge)
	playsound(loc, 'sound/effects/EMPulse.ogg', 100, 1)
	empulse(loc, 7 * (charge * 0.01), 14 * (charge * 0.01))

/obj/machinery/gravity_generator/main/update_icon()
	. = ..()
	overlays.Cut()
	for(var/obj/machinery/gravity_generator/part/P in lights)
		P.overlays.Cut()

	var/console
	if(power_supply && !(stat & (BROKEN|NOPOWER)))
		if(charging_state == POWER_IDLE)
			console = charge_count ? "console_charged" : "console_discharged"
		else
			console = "console_charging"
		overlays += console
		if(breaker)
			for(var/obj/machinery/gravity_generator/part/P in lights)
				P.overlays += "[P.sprite_number]_light"

	if(!panel_open)
		if(power_supply && !(stat & BROKEN|NOPOWER))
			overlays += "keyboard_on"
		else
			overlays += "keyboard_off"

	var/overlay_state
	switch(charge_count)
		if(0 to 20)
			overlay_state = null
			set_light(0,0,"#000000")
		if(21 to 40)
			overlay_state = "startup"
			set_light(4,0.2,"#6496fa")
		if(41 to 60)
			overlay_state = "idle"
			set_light(6,0.5,"#7d9bff")
		if(61 to 80)
			overlay_state = "activating"
			set_light(6,0.8,"#7dc3ff")
		if(81 to 100)
			overlay_state = "activated"
			set_light(8,1,"#7de1e1")

	if(middle)
		middle.overlays.Cut()
		if(overlay_state)
			middle.overlays += overlay_state

	for(var/obj/machinery/gravity_generator/part/P in parts)
		P.update_icon()

/obj/machinery/gravity_generator/main/power_change()
	. = ..()
	update_power()

// Set the state of the gravity.
/obj/machinery/gravity_generator/main/proc/set_state(new_state)
	breaker = new_state
	update_power()

// Set the charging state based on power/breaker/power_supply(wires) status.
/obj/machinery/gravity_generator/main/proc/update_power()
	var/good_state = FALSE
	if(breaker && power_supply && !(stat & (NOPOWER|BROKEN)))
		good_state = TRUE

	update_use_power(good_state ? POWER_USE_ACTIVE : POWER_USE_IDLE)
	if(good_state && charge_count < 100)
		charging_state = POWER_UP
	else if(!good_state && charge_count > 0)
		charging_state = POWER_DOWN
	else
		charging_state = POWER_IDLE

	update_icon()
	investigate_log("is now [charging_state == POWER_UP ? "charging" : "discharging"].", "gravity")

// Charge/Discharge and turn on/off gravity when you reach 0/100 percent.
// Also emit radiation and handle the overlays.
/obj/machinery/gravity_generator/main/Process()
	if(stat & BROKEN)
		return

	if(charge_count > 0)
		SSradiation.radiate(src, 30 * (charge_count * 0.01))

	if(charging_state != POWER_IDLE)
		update_icon()
		if(prob(75))
			playsound(loc, 'sound/effects/EMPulse.ogg', 50, 1)

	switch(charging_state)
		if(POWER_UP)
			charge_count = min(100, charge_count + 2)
			if(charge_count >= 100)
				set_state(TRUE)
				if(enabled)
					return
				enabled = TRUE
				update_gravity_status()
				playsound(loc, 'sound/effects/alert.ogg', 50, 1)
				if(announcer)
					GLOB.global_announcer.autosay("Gravitational Generator has been fully charged. Gravitation is enabled!", get_announcement_computer("Gravity Generator Alert System"))

		if(POWER_DOWN)
			charge_count = max(0, charge_count - 2)
			if(charge_count <= 0)
				set_state(FALSE)
				if(!enabled)
					return
				enabled = FALSE
				update_gravity_status()
				playsound(loc, 'sound/effects/alert.ogg', 50, 1)
				if(announcer)
					GLOB.global_announcer.autosay("Alert! Gravitational Generator has been discharged! Gravitation is disabled.", get_announcement_computer("Gravity Generator Alert System"))
			else if(announcer && charge_count <= 50 && charge_count % 5 == 0)
				GLOB.global_announcer.autosay("Danger! Gravitational Generator discharges detected! Charge status at [charge_count]%", get_announcement_computer("Gravity Generator Alert System"), "Engineering")


/obj/machinery/gravity_generator/main/proc/update_gravity_status()
	shake_everyone()
	update_connectected_areas_gravity()

/obj/machinery/gravity_generator/main/proc/shake_everyone()
	for(var/area/A in connected_areas)
		for(var/mob/living/L in A)
			if(L.client && !L.stat)
				shake_camera(L, 5, 1)

/obj/machinery/gravity_generator/main/proc/update_connectected_areas_gravity()
	for(var/area/A in connected_areas)
		A.gravitychange(enabled ? TRUE : FALSE)

/obj/machinery/gravity_generator/main/proc/add_areas()
	var/list/areas = area_repository.get_areas_by_z_level()
	for(var/i in areas)
		var/area/A = areas[i]
		if(is_station_area(A))
			connected_areas += A

//
// Part generator which is mostly there for looks
//

/obj/machinery/gravity_generator/part
	var/obj/machinery/gravity_generator/main/main_part = null

/obj/machinery/gravity_generator/part/Destroy()
	if(!QDELETED(main_part))
		main_part.parts -= src
		QDEL_NULL(main_part)
	return ..()

/obj/machinery/gravity_generator/part/examine(mob/user)
	. = ..()
	. += "[main_part.show_broken_info()]"

/obj/machinery/gravity_generator/part/attackby(obj/item/I, mob/user)
	return main_part.attackby(I, user)

/obj/machinery/gravity_generator/part/bullet_act(obj/item/projectile/P)
	return main_part.bullet_act(P)

/obj/machinery/gravity_generator/part/blob_act(destroy, obj/effect/blob/source)
	return main_part.blob_act(destroy, source)

#undef POWER_IDLE
#undef POWER_UP
#undef POWER_DOWN

#undef GRAV_NEEDS_SCREWDRIVER
#undef GRAV_NEEDS_WELDING
#undef GRAV_NEEDS_PLASTEEL
#undef GRAV_NEEDS_WRENCH

#undef AREA_ERRNONE
#undef AREA_STATION
#undef AREA_SPACE
#undef AREA_SPECIAL
