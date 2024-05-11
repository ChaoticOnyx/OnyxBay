#define EMITTER_DAMAGE_POWER_TRANSFER 450 //used to transfer power to containment field generators

/obj/machinery/power/emitter
	name = "emitter"
	desc = "A massive heavy industrial laser. This design is a fixed installation, capable of shooting in only one direction."
	description_info = "You must secure this in place with a wrench and weld it to the floor before using it. The emitter will only fire if it is installed above a cable endpoint. Clicking will toggle it on and off, at which point, so long as it remains powered, it will fire in a single direction in bursts of four."
	description_fluff = "Lasers like this one have been in use for ages, in applications such as mining, cutting, and in the startup sequence of many advanced space station and starship engines."
	description_antag = "This baby is capable of slicing through walls, sealed lockers, and people."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "emitter"
	anchored = 0
	density = 1
	obj_flags = OBJ_FLAG_ANCHOR_BLOCKS_ROTATION
	req_access = list(access_engine_equip)
	rad_resist_type = /datum/rad_resist/none

	var/id = null

	active_power_usage = 100 KILO WATTS

	var/efficiency = 0.6	// Energy efficiency. 60% at this time, so 50kW+1 load means 30kW+0,6 laser pulses.
	var/active = 0
	var/powered = 0
	var/fire_delay = 100
	var/max_burst_delay = 100
	var/min_burst_delay = 20
	var/burst_shots = 3
	var/last_shot = 0
	var/shot_number = 0
	var/state = 0
	var/locked = 0

	var/_wifi_id
	var/datum/wifi/receiver/button/emitter/wifi_receiver

/obj/machinery/power/emitter/anchored
	anchored = 1
	state = 2

/obj/machinery/power/emitter/Initialize()
	. = ..()
	if(state == 2 && anchored)
		connect_to_network()
		if(_wifi_id)
			wifi_receiver = new(_wifi_id, src)

	AddElement(/datum/element/simple_rotation)

/obj/machinery/power/emitter/Destroy()
	log_and_message_admins("deleted \the [src]")
	investigate_log("<font color='red'>deleted</font> at ([x],[y],[z])","singulo")
	qdel(wifi_receiver)
	wifi_receiver = null
	return ..()

/obj/machinery/power/emitter/on_update_icon()
	if(active && powernet && avail(active_power_usage))
		icon_state = "emitter_+a"
	else
		icon_state = "emitter"

/obj/machinery/power/emitter/attack_hand(mob/user)
	add_fingerprint(user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(!H.IsAdvancedToolUser())
			return
	activate(user)

/obj/machinery/power/emitter/proc/activate(mob/user)
	if(state == 2)
		if(!powernet)
			to_chat(user, "\The [src] isn't connected to a wire.")
			return 1
		if(!locked)
			var/area/A = get_area(src)
			if(active)
				active = 0
				to_chat(user, SPAN_NOTICE("You turn off \the [src]."))
				log_admin("[key_name(user)] turned off \the [src] at X:[x], Y:[y], Z:[z] Area: [A.name].")
				message_admins("[key_name_admin(user)] turned off \the [src].")
				investigate_log("turned <font color='red'>off</font> by [user.key]","singulo")
			else
				active = 1
				to_chat(user, SPAN_WARNING("You turn on \the [src]."))
				shot_number = 0
				fire_delay = get_initial_fire_delay()
				log_admin("[key_name(user)] turned on \the [src] at X:[x], Y:[y], Z:[z] Area: [A.name].")
				message_admins("[key_name_admin(user)] turned on \the [src].")
				investigate_log("turned <font color='green'>on</font> by [user.key]","singulo")
			update_icon()
		else
			to_chat(user, SPAN_WARNING("The controls are locked!"))
	else
		to_chat(user, SPAN_WARNING("\The [src] needs to be firmly secured to the floor first."))
		return 1

/obj/machinery/power/emitter/emp_act(severity)
	return 1

/obj/machinery/power/emitter/Process()
	if(stat & (BROKEN))
		return
	if(state != 2 || (!powernet && active_power_usage))
		active = 0
		update_icon()
		return
	if(((last_shot + fire_delay) <= world.time) && (active == 1))

		var/actual_load = draw_power(active_power_usage)
		if(actual_load >= active_power_usage) //does the laser have enough power to shoot?
			if(!powered)
				powered = 1
				update_icon()
				investigate_log("regained power and turned <font color='green'>on</font>","singulo")
		else
			if(powered)
				powered = 0
				update_icon()
				investigate_log("lost power and turned <font color='red'>off</font>","singulo")
			return

		last_shot = world.time
		if(shot_number < burst_shots)
			fire_delay = get_burst_delay()
			shot_number ++
		else
			fire_delay = get_rand_burst_delay()
			shot_number = 0

		//need to calculate the power per shot as the emitter doesn't fire continuously.
		var/burst_time = (min_burst_delay + max_burst_delay)/2 + 2*(burst_shots-1)
		var/power_per_shot = (active_power_usage * efficiency) * (burst_time/10) / burst_shots

		if(prob(35))
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(5, 1, src)
			s.start()

		var/obj/item/projectile/beam/emitter/A = get_emitter_beam()
		playsound(loc, A.fire_sound, 25, 1)
		A.damage = round(power_per_shot/EMITTER_DAMAGE_POWER_TRANSFER)
		A.pixel_x = 0
		A.pixel_y = 0
		A.launch(get_step(loc, dir))

/obj/machinery/power/emitter/attackby(obj/item/W, mob/user)

	if(isWrench(W))
		if(active)
			to_chat(user, "Turn off [src] first.")
			return
		switch(state)
			if(0)
				state = 1
				playsound(loc, 'sound/items/Ratchet.ogg', 75, 1)
				user.visible_message("[user.name] secures [src] to the floor.", \
					"You secure the external reinforcing bolts to the floor.", \
					"You hear a ratchet")
				anchored = 1
			if(1)
				state = 0
				playsound(loc, 'sound/items/Ratchet.ogg', 75, 1)
				user.visible_message("[user.name] unsecures [src] reinforcing bolts from the floor.", \
					"You undo the external reinforcing bolts.", \
					"You hear a ratchet")
				anchored = 0
			if(2)
				to_chat(user, "<span class='warning'>\The [src] needs to be unwelded from the floor.</span>")
		return

	if(isWelder(W))
		var/obj/item/weldingtool/WT = W
		if(active)
			to_chat(user, "Turn off [src] first.")
			return
		switch(state)
			if(0)
				to_chat(user, "<span class='warning'>\The [src] needs to be wrenched to the floor.</span>")
			if(1)
				user.visible_message("[user.name] starts to weld [src] to the floor.", \
						"You start to weld [src] to the floor.", \
						"You hear welding")
				if(WT.use_tool(src, user, delay = 2 SECONDS, amount = 1))
					if(QDELETED(src) || !user)
						return

					state = 2
					to_chat(user, "You weld [src] to the floor.")
					connect_to_network()
			if(2)
				user.visible_message("[user.name] starts to cut [src] free from the floor.", \
						"You start to cut [src] free from the floor.", \
						"You hear welding")
				if(WT.use_tool(src, user, delay = 2 SECONDS, amount = 1))
					if(QDELETED(src) || !user)
						return

					state = 1
					to_chat(user, "You cut [src] free from the floor.")
					disconnect_from_network()
		return

	if(istype(W, /obj/item/card/id) || istype(W, /obj/item/device/pda))
		if(emagged)
			to_chat(user, "<span class='warning'>The lock seems to be broken.</span>")
			return
		if(allowed(user))
			locked = !locked
			to_chat(user, "The controls are now [locked ? "locked." : "unlocked."]")
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")
		return
	..()
	return

/obj/machinery/power/emitter/emag_act(remaining_charges, mob/user)
	if(!emagged)
		locked = 0
		emagged = 1
		user.visible_message("[user.name] emags [src].","<span class='warning'>You short out the lock.</span>")
		return 1

/obj/machinery/power/emitter/proc/get_initial_fire_delay()
	return 100

/obj/machinery/power/emitter/proc/get_rand_burst_delay()
	return rand(min_burst_delay, max_burst_delay)

/obj/machinery/power/emitter/proc/get_burst_delay()
	return 2

/obj/machinery/power/emitter/proc/get_emitter_beam()
	return new /obj/item/projectile/beam/emitter(get_turf(src))
