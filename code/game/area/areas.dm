// Areas.dm



// ===
/area
	var/global/global_uid = 0
	var/uid
	var/area_flags

/area/New()
	icon_state = ""
	uid = ++global_uid

	if(!requires_power)
		power_light = 0
		power_equip = 0
		power_environ = 0

	if(dynamic_lighting)
		luminosity = 0
	else
		luminosity = 1

	..()

/area/Initialize()
	. = ..()
	if(!requires_power || !apc)
		power_light = 0
		power_equip = 0
		power_environ = 0
	power_change()		// all machines set to current power level, also updates lighting icon

	switch(gravity_state)
		if(AREA_GRAVITY_NEVER)
			has_gravity = 0
		if(AREA_GRAVITY_ALWAYS)
			has_gravity = 1

/area/proc/get_contents()
	return contents

/area/proc/get_cameras()
	var/list/cameras = list()
	for (var/obj/machinery/camera/C in src)
		cameras += C
	return cameras

/area/proc/is_shuttle_locked()
	return 0

/area/proc/atmosalert(danger_level, alarm_source)
	if (danger_level == 0)
		atmosphere_alarm.clearAlarm(src, alarm_source)
	else
		atmosphere_alarm.triggerAlarm(src, alarm_source, severity = danger_level)

	//Check all the alarms before lowering atmosalm. Raising is perfectly fine.
	for (var/obj/machinery/alarm/AA in src)
		if (!(AA.stat & (NOPOWER|BROKEN)) && !AA.shorted && AA.report_danger_level)
			danger_level = max(danger_level, AA.danger_level)

	if(danger_level != atmosalm)
		if (danger_level < 1 && atmosalm >= 1)
			//closing the doors on red and opening on green provides a bit of hysteresis that will hopefully prevent fire doors from opening and closing repeatedly due to noise
			air_doors_open()
		else if (danger_level >= 2 && atmosalm < 2)
			air_doors_close()

		atmosalm = danger_level
		for (var/obj/machinery/alarm/AA in src)
			AA.update_icon()

		return 1
	return 0

/area/proc/air_doors_close()
	if(!air_doors_activated)
		air_doors_activated = 1
		if(!all_doors)
			return
		for(var/obj/machinery/door/firedoor/E in all_doors)
			if(!E.blocked)
				if(E.operating)
					E.nextstate = FIREDOOR_CLOSED
				else if(!E.density)
					spawn(0)
						E.close()

/area/proc/air_doors_open()
	if(air_doors_activated)
		air_doors_activated = 0
		if(!all_doors)
			return
		for(var/obj/machinery/door/firedoor/E in all_doors)
			if(!E.blocked)
				if(E.operating)
					E.nextstate = FIREDOOR_OPEN
				else if(E.density)
					spawn(0)
						if(E.can_safely_open())
							E.open()


/area/proc/fire_alert()
	if(!fire)
		fire = TRUE	//used for firedoor checks
		update_icon()
		mouse_opacity = 0
		set_lighting_mode(LIGHTMODE_ALARM, TRUE)
		if(!all_doors)
			return
		for(var/obj/machinery/door/firedoor/D in all_doors)
			if(!D.blocked)
				if(D.operating)
					D.nextstate = FIREDOOR_CLOSED
				else if(!D.density)
					spawn()
						D.close()

/area/proc/fire_reset()
	if (fire)
		fire = FALSE	//used for firedoor checks
		update_icon()
		mouse_opacity = 0
		set_lighting_mode(LIGHTMODE_ALARM, FALSE)
		if(!all_doors)
			return
		for(var/obj/machinery/door/firedoor/D in all_doors)
			if(!D.blocked)
				if(D.operating)
					D.nextstate = FIREDOOR_OPEN
				else if(D.density)
					spawn(0)
					D.open()

/area/proc/readyalert()
	if(!eject)
		eject = 1
		update_icon()
	return

/area/proc/readyreset()
	if(eject)
		eject = 0
		update_icon()
	return

/area/proc/partyalert()
	if (!( party ))
		party = 1
		update_icon()
		mouse_opacity = 0
	return

/area/proc/partyreset()
	if (party)
		party = 0
		mouse_opacity = 0
		update_icon()
		for(var/obj/machinery/door/firedoor/D in src)
			if(!D.blocked)
				if(D.operating)
					D.nextstate = FIREDOOR_OPEN
				else if(D.density)
					spawn(0)
					D.open()
	return

/area/update_icon()
	if ((eject || party) && (!requires_power||power_environ))//If it doesn't require power, can still activate this proc.
		/*else if(atmosalm && !fire && !eject && !party)
			icon_state = "bluenew"*/
		if(eject && !party)
			icon_state = "red"
		else if(party && !eject)
			icon_state = "party"
		else
			icon_state = "blue-red"
	else
	//	new lighting behaviour with obj lights
		icon_state = null

/area/proc/set_lightswitch(new_switch)
	if(lightswitch != new_switch)
		lightswitch = new_switch
		for(var/obj/machinery/light_switch/L in src)
			L.sync_state()
		update_icon()
		power_change()

/area/proc/set_lighting_mode(mode, state)
	if(!mode)
		CRASH("Missing 'mode' arg.")

	if(state)
		enabled_lighting_modes |= mode
	else if(mode in enabled_lighting_modes)
		enabled_lighting_modes -= mode

	var/power_channel = LIGHT
	var/old_lighting_mode = lighting_mode

	if(LIGHTMODE_EMERGENCY in enabled_lighting_modes)
		lighting_mode = LIGHTMODE_EMERGENCY
		power_channel = ENVIRON
	else if(LIGHTMODE_RADSTORM in enabled_lighting_modes)
		lighting_mode = LIGHTMODE_RADSTORM
	else if(LIGHTMODE_EVACUATION in enabled_lighting_modes)
		lighting_mode = LIGHTMODE_EVACUATION
	else if(LIGHTMODE_ALARM in enabled_lighting_modes)
		lighting_mode = LIGHTMODE_ALARM
	else
		lighting_mode = null

	if(old_lighting_mode == lighting_mode)
		return

	for(var/obj/machinery/light/L in src)
		L.set_mode(lighting_mode)
		L.update_power_channel(power_channel)

var/list/mob/living/forced_ambiance_list = new

/area/Entered(A)
	if(!istype(A,/mob/living))	return

	var/mob/living/L = A
	if(!L.ckey)	return

	if(!L.lastarea)
		L.lastarea = get_area(L.loc)
	var/area/newarea = get_area(L.loc)
	var/area/oldarea = L.lastarea
	if(oldarea.has_gravity != newarea.has_gravity)
		if(newarea.has_gravity == 1 && L.m_intent == M_RUN) // Being ready when you change areas allows you to avoid falling.
			thunk(L)
		L.update_floating()

	L.lastarea = newarea
	play_ambience(L)

/area/proc/play_ambience(mob/living/L, custom_period = 1 MINUTES)
	if(!L.client) //Why play the ambient without a client?
		return
	// Ambience goes down here -- make sure to list each area seperately for ease of adding things in later, thanks! Note: areas adjacent to each other should have the same sounds to prevent cutoff when possible.- LastyScratch
	if(!(L && L.get_preference_value(/datum/client_preference/play_ambiance) == GLOB.PREF_YES))
		return

	// If we previously were in an area with force-played ambiance, stop it.
	if(L in forced_ambiance_list)
		sound_to(L, sound(null, channel = 1))
		forced_ambiance_list -= L

	var/turf/T = get_turf(L)
	var/hum = 0
	if(!L.ear_deaf && !always_unpowered && power_environ)
		for(var/obj/machinery/atmospherics/unary/vent_pump/vent in src)
			if(vent.can_pump())
				hum = 1
				break

	if(hum)
		if(L.client && !L.client.ambience_playing)
			L.client.ambience_playing = 1
			L.playsound_local(T,sound('sound/ambience/vents.ogg', repeat = 1, wait = 0, volume = 20, channel = 2))
	else
		if(L.client && L.client.ambience_playing)
			L.client.ambience_playing = 0
			sound_to(L, sound(null, channel = 2))

	if(forced_ambience)
		if(forced_ambience.len)
			var/S = get_sfx(pick(forced_ambience))
			forced_ambiance_list |= L
			L.playsound_local(T,sound(S, repeat = 1, wait = 0, volume = 30, channel = 1))
		else
			sound_to(L, sound(null, channel = 1))
	else if(src.ambience.len && prob(35) && (world.time >= L.client.played + custom_period))
		var/S = get_sfx(pick(ambience))
		L.playsound_local(T, sound(S, repeat = 0, wait = 0, volume = 30, channel = 1))
		L.client.played = world.time

/area/proc/gravitychange(new_state = 0)
	if(gravity_state in list(AREA_GRAVITY_NEVER, AREA_GRAVITY_ALWAYS))
		return

	has_gravity = new_state
	for(var/mob/M in src)
		if(has_gravity)
			thunk(M)
		M.update_floating()

/area/proc/thunk(mob)
	if(istype(get_turf(mob), /turf/space)) // Can't fall onto nothing.
		return

	if(istype(mob,/mob/living/carbon/human/))
		var/mob/living/carbon/human/H = mob
		if(istype(H.shoes, /obj/item/clothing/shoes/magboots) && (H.shoes.item_flags & ITEM_FLAG_NOSLIP))
			return
		if(H.species?.can_overcome_gravity(H))
			return
		H.AdjustStunned(1)
		H.AdjustWeakened(1)
		to_chat(mob, SPAN("warning", "The sudden appearance of gravity makes you fall to the floor!"))

/area/proc/prison_break()
	var/obj/machinery/power/apc/theAPC = get_apc()
	if(theAPC && theAPC.operating)
		for(var/obj/machinery/power/apc/temp_apc in src)
			temp_apc.overload_lighting(70)
		for(var/obj/machinery/door/airlock/temp_airlock in src)
			temp_airlock.prison_open()
		for(var/obj/machinery/door/window/temp_windoor in src)
			temp_windoor.open()

/area/proc/has_gravity()
	return has_gravity

/area/space/has_gravity()
	return 0

/proc/has_gravity(atom/AT)
	var/area/A = get_area(AT)
	if(A?.has_gravity())
		return TRUE
	return FALSE

/area/proc/get_dimensions()
	var/list/res = list("x"=1,"y"=1)
	var/list/min = list("x"=world.maxx,"y"=world.maxy)
	for(var/turf/T in src)
		res["x"] = max(T.x, res["x"])
		res["y"] = max(T.y, res["y"])
		min["x"] = min(T.x, min["x"])
		min["y"] = min(T.y, min["y"])
	res["x"] = res["x"] - min["x"] + 1
	res["y"] = res["y"] - min["y"] + 1
	return res

/area/proc/has_turfs()
	return !!(locate(/turf) in src)

