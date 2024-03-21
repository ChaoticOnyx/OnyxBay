var/global/list/rad_collectors = list()

/obj/machinery/power/rad_collector
	name = "Hawking Collector Array"
	desc = "A device which uses Hawking radiation and plasma to produce power. WARNING: Working with temperature 400C and higher can break the device"
	icon = 'icons/obj/singularity.dmi'
	icon_state = "ca"
	anchored = 0
	density = 1
	req_access = list(access_engine_equip)
	var/obj/item/tank/plasma/P = null
	var/last_power = 0
	var/last_temp_dif = 0
	var/last_power_new = 0
	var/active = 0
	var/locked = 0
	var/drainratio = 1

	var/health = 100
	var/max_safe_temp = 400 CELSIUS
	var/melted

/obj/machinery/power/rad_collector/New()
	..()
	rad_collectors += src

/obj/machinery/power/rad_collector/Destroy()
	rad_collectors -= src
	. = ..()

/obj/machinery/power/rad_collector/Process()
	if((stat & BROKEN) || melted)
		return
	var/turf/T = get_turf(src)
	if(T)
		var/datum/gas_mixture/our_turfs_air = T.return_air()
		if(our_turfs_air.temperature > max_safe_temp)
			health -= ((our_turfs_air.temperature - max_safe_temp) / 10)

	//so that we don't zero out the meter if the SM is processed first.
	last_power = last_power_new
	last_power_new = 0

	if(P && active)
		if(health <= 0)
			collector_break()

		var/list/sources = SSradiation.get_sources_in_range(src)
		for(var/datum/radiation_source/source in sources)
			if(source.info.radiation_type != RADIATION_HAWKING)
				continue

			var/datum/radiation/R = source.travel(src)
			var/total_energy = R.energy * R.activity

			receive_pulse(total_energy)

	if(P)
		var/datum/gas_mixture/M = P.return_air()
		if(M.gas["plasma"] == 0)
			investigate_log("<font color='red'>out of fuel</font>.","singulo")
			eject()
		else
			M.adjust_gas("plasma", -0.001 * drainratio)
	return


/obj/machinery/power/rad_collector/attack_hand(mob/user)
	if(anchored)
		if((stat & BROKEN) || melted)
			to_chat(user, SPAN_WARNING("The [src] is completely destroyed!"))
			return
		if(!locked)
			toggle_power()
			user.visible_message("[user.name] turns the [name] [active? "on":"off"].", \
			"You turn the [name] [active? "on":"off"].")
			investigate_log("turned [active?"<font color='green'>on</font>":"<font color='red'>off</font>"] by [user.key]. [P?"Fuel: [round(P.air_contents.gas["plasma"]/0.29)]%":"<font color='red'>It is empty</font>"].","singulo")
			return
		else
			to_chat(user, SPAN_WARNING("The controls are locked!"))
			return


/obj/machinery/power/rad_collector/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/tank/plasma))
		if(!anchored)
			to_chat(user, "<span class='warning'>The [src] needs to be secured to the floor first.</span>")
			return 1
		if(P)
			to_chat(user, "<span class='warning'>There's already a plasma tank loaded.</span>")
			return 1
		if(!user.drop(W, src))
			return 1
		P = W
		update_icon()
		return 1
	else if(isCrowbar(W))
		if(P && !locked)
			eject()
			return 1
	else if(isWrench(W))
		if(P)
			to_chat(user, "<span class='notice'>Remove the plasma tank first.</span>")
			return 1
		for(var/obj/machinery/power/rad_collector/R in get_turf(src))
			if(R != src)
				to_chat(user, "<span class='warning'>You cannot install more than one collector on the same spot.</span>")
				return 1
		playsound(loc, 'sound/items/Ratchet.ogg', 75, 1)
		anchored = !anchored
		user.visible_message("[user.name] [anchored? "secures":"unsecures"] the [name].", \
			"You [anchored? "secure":"undo"] the external bolts.", \
			"You hear a ratchet")
		if(anchored && !(stat & BROKEN))
			connect_to_network()
		else
			disconnect_from_network()
		return 1
	else if(istype(W, /obj/item/card/id)||istype(W, /obj/item/device/pda))
		if (allowed(user))
			if(active)
				locked = !locked
				to_chat(user, "The controls are now [locked ? "locked." : "unlocked."]")
			else
				locked = 0 //just in case it somehow gets locked
				to_chat(user, "<span class='warning'>The controls can only be locked when the [src] is active</span>")
		else
			to_chat(user, "<span class='warning'>Access denied!</span>")
		return 1
	return ..()

/obj/machinery/power/rad_collector/_examine_text(mob/user, distance)
	. = ..()
	if (distance <= 3 && !(stat & BROKEN))
		. += "\nSensor readings:"
		. += "\nPower rate: [fmt_siunit(last_power, "W/s", 3)]"
		if(P?.air_contents)
			. += "\nTank temperature: [P.air_contents.temperature]K"
		else
			. += "\nTank temperature: N/A"
		. += "\nEntropy drift: [last_temp_dif] K/s"

/obj/machinery/power/rad_collector/ex_act(severity)
	switch(severity)
		if(2, 3)
			eject()
	return ..()

/obj/machinery/power/rad_collector/proc/collector_break()
	if(P?.air_contents)
		var/turf/T = get_turf(src)
		if(T)
			T.assume_air(P.return_air())
			audible_message(SPAN_DANGER("\The [P] detonates, sending shrapnel flying!"), splash_override = "*KA-BOOM*")
			fragmentate(T, 2, 4, list(/obj/item/projectile/bullet/pellet/fragment/tank/small = 3, /obj/item/projectile/bullet/pellet/fragment/tank = 1))
			explosion(T, -1, -1, 0)
			QDEL_NULL(P)
	disconnect_from_network()
	stat |= BROKEN
	melted = TRUE
	anchored = FALSE
	active = FALSE
	desc += " This one is destroyed beyond repair."
	update_icon()

/obj/machinery/power/rad_collector/return_air()
	if(P)
		return P.return_air()

/obj/machinery/power/rad_collector/proc/eject()
	locked = 0
	var/obj/item/tank/plasma/Z = P
	if (!Z)
		return
	Z.forceMove(get_turf(src))
	Z.reset_plane_and_layer()
	P = null
	if(active)
		toggle_power()
	else
		update_icon()

/obj/machinery/power/rad_collector/proc/receive_pulse(pulse_strength)
	if(P && active)
		var/power_produced = P.air_contents.gas["plasma"] * (pulse_strength * 150 MEGA WATT)
		add_avail(power_produced)
		last_power_new = power_produced

		var/turf/T = get_turf(src)
		var/datum/gas_mixture/air_gas = T.return_air()
		var/datum/gas_mixture/plasma_gas = P.return_air()
		last_temp_dif = max((power_produced / (1500000 KELVIN)) - 0.4, 0)

		if(last_temp_dif == 0)
			return

		plasma_gas.add_thermal_energy(plasma_gas.get_thermal_energy_change(plasma_gas.temperature + last_temp_dif))
		if(plasma_gas.temperature > air_gas.temperature)
			var/new_temp = air_gas.temperature + last_temp_dif
			air_gas.add_thermal_energy(air_gas.get_thermal_energy_change(new_temp))

	return

/obj/machinery/power/rad_collector/on_update_icon()
	if(melted)
		icon_state = "ca_melt"
	else if(active)
		icon_state = "ca_on"
	else
		icon_state = "ca"
	ClearOverlays()
	if(P)
		AddOverlays(image('icons/obj/singularity.dmi', "ptank"))
	if(stat & (NOPOWER|BROKEN))
		return
	if(active)
		AddOverlays(image('icons/obj/singularity.dmi', "on"))


/obj/machinery/power/rad_collector/proc/toggle_power()
	active = !active
	if(active)
		icon_state = "ca_on"
		flick("ca_active", src)
	else
		icon_state = "ca"
		flick("ca_deactive", src)
	update_icon()
	return
