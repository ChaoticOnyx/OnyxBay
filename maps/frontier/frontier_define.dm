
/datum/map/frontier
	name = "Infiltrator"
	full_name = "SCS Inflitrator"
	path = "frontier"

	shuttle_types = list(
		/datum/shuttle/autodock/ferry/escape_pod/escape_pod3,
		/datum/shuttle/autodock/ferry/escape_pod/escape_pod5,
		/datum/shuttle/autodock/ferry/supply/drone,
		/datum/shuttle/autodock/ferry/elevator,
		/datum/shuttle/autodock/multi/antag/mining,
		/datum/shuttle/autodock/ferry/research,
		/datum/shuttle/autodock/ferry/engie,
		/datum/shuttle/autodock/ferry/mining,
		/datum/shuttle/autodock/multi/antag/rescue,
		/datum/shuttle/autodock/ferry/emergency/centcom,
		/datum/shuttle/autodock/ferry/administration,
		/datum/shuttle/autodock/multi/antag/syndicate,
		/datum/shuttle/autodock/multi/antag/elite_syndicate,
		/datum/shuttle/autodock/ferry/deathsquad,
		/datum/shuttle/autodock/multi/antag/merchant,
		/datum/shuttle/autodock/multi/antag/skipjack,
		/datum/shuttle/autodock/multi/antag/dropship,
		/datum/shuttle/autodock/multi/antag/train,
		/datum/shuttle/autodock/multi/antag/pick_up,
	)

	map_levels = list(
		new /datum/space_level/frontier_1,
		new /datum/space_level/frontier_2,
		new /datum/space_level/null_space,
	)

	station_name  = "SCS Infiltrator"
	station_short = "Infiltrator"
	dock_name     = "Kraken Base"
	boss_name     = "Syndicate"
	boss_short    = "Syndicate"
	company_name  = "Syndicate"
	company_short = "Syndicate"
	system_name   = "Procyon"

	emergency_shuttle_docked_message = "Reinforcment fleet is now in your sector. You have %ETA% before you will be completly surrounded"
	emergency_shuttle_leaving_dock = "It's too late. You are completly surrounded. Farewell, operative. It was good knowing you"

	emergency_shuttle_called_message = "Reinforcment fleet has been sent to your location by Nanotrasen. You have about %ETA% until they arrive. You are now on your own. We cannot risk with getting you out of there."
	emergency_shuttle_called_sound = null

	emergency_shuttle_recall_message = "You are now leaving the fleets sensors range. Well done, operative. We will meet you on the other end."

	command_report_sound = 'sound/AI/commandreport.ogg'
	grid_check_sound = 'sound/AI/poweroff.ogg'
	grid_restored_sound = 'sound/AI/poweron.ogg'
	meteor_detected_sound = 'sound/AI/meteors.ogg'
	radiation_detected_sound = 'sound/AI/radiation.ogg'
	space_time_anomaly_sound = 'sound/AI/spanomalies.ogg'
	unidentified_lifesigns_sound = 'sound/AI/aliens.ogg'

	electrical_storm_moderate_sound = null
	electrical_storm_major_sound = null

	evac_controller_type = /datum/evacuation_controller/shuttle

	station_networks = list(
		NETWORK_CIVILIAN_EAST,
		NETWORK_CIVILIAN_WEST,
		NETWORK_COMMAND,
		NETWORK_ENGINE,
		NETWORK_ENGINEERING,
		NETWORK_ENGINEERING_OUTPOST,
		NETWORK_EXODUS,
		NETWORK_MAINTENANCE,
		NETWORK_MEDICAL,
		NETWORK_MINE,
		NETWORK_RESEARCH,
		NETWORK_RESEARCH_OUTPOST,
		NETWORK_ROBOTS,
		NETWORK_PRISON,
		NETWORK_SECURITY,
		NETWORK_ALARM_ATMOS,
		NETWORK_ALARM_CAMERA,
		NETWORK_ALARM_FIRE,
		NETWORK_ALARM_MOTION,
		NETWORK_ALARM_POWER,
		NETWORK_THUNDER,
		NETWORK_TELECOM,
		NETWORK_MASTER
	)

	post_round_safe_areas = list (
		/area/centcom,
		/area/shuttle/escape/centcom,
		/area/shuttle/escape_pod1,
		/area/shuttle/escape_pod2,
		/area/shuttle/escape_pod3,
		/area/shuttle/escape_pod5,
		/area/shuttle/transport/centcom,
		/area/shuttle/administration/,
		/area/shuttle/specops/centcom,
	)

/turf/unsimulated/train
	name = "moving ground"
	desc = "Better not touch this!"

/turf/unsimulated/train/Crossed(atom/A)
	if(istype(A, /mob/living))
		var/mob/living/M = A
		M.gib()
		M.ghostize()
		return
	if(istype(A, /obj) && !istype(A, /obj/item/projectile))
		qdel(A)
		return

/turf/unsimulated/train/rock
	name = "impassable rock"
	opacity = 1
	icon = 'icons/turf/walls.dmi'
	icon_state = "rock-dark_old_train"

/turf/unsimulated/train/dust
	name = "asteroid plating"
	icon = 'icons/turf/floors.dmi'
	icon_state = "asteroidplating_train"

/turf/unsimulated/bigpit
	name = "bottomless pit"
	desc = "It's a ve-e-e-ery deep fall. No chance i can survive that, even more - have the strength to find a way back up again"
	icon = 'icons/turf/open_space.dmi'
	icon_state = "black_open"

/turf/unsimulated/bigpit/Crossed(atom/A)
	if(istype(A, /mob/living))
		var/mob/living/M = A
		M.ghostize()
		visible_message("<B>[M.name] falls down to their doom!</B>")
		qdel(A)
		return
	if(istype(A, /obj) && !istype(A, /obj/item/projectile))
		qdel(A)
		return

/obj/structure/antlion
	name = "spider detector"
	desc = "It is a device that tracks giant spider's activity via some cool and technological sensors and displays it by a scale of three lights. The more lights - the more spiders there are coming to get you"
	icon = 'maps/frontier/event.dmi'
	icon_state = "light_0"
	light_color = "FF0000"

/obj/structure/antlion/proc/set_lights(num)
	if(num > 3)
		num = 3
	if(num < 0 || num == null)
		num = 0
	icon_state = "light_[num]"
	var/alarms = list('sound/misc/cave_siren_loop1.ogg', 'sound/misc/cave_siren_loop2.ogg', 'sound/misc/cave_siren_loop3.ogg', 'sound/misc/cave_siren_loop4.ogg')
	if(num > 0)
		playsound(src.loc, pick(alarms), 100, 1)
		set_light(0.8, 1, 6)
	else
		set_light(0)

/obj/structure/ev_car
	name = "Emergency Repsonders ATV"
	desc = "All-Terrain-Vehicle commonly used by Emergency Repsonse Teams across the galaxy. Newer models have a gun installed on top"
	var/is_moving = FALSE
	icon_state = "car_idle"
	icon = 'maps/frontier/apc.dmi'
	density = 1
	anchored = 1

/obj/structure/ev_car/proc/_do_move()
	if(!is_moving)
		return
	if(forceMove(get_step(src, EAST)))
		for(var/obj/O in loc)
			if(O == src)
				continue
			if(!(istype(O, /obj/machinery) || istype(O, /obj/structure)))
				continue
			qdel(O)
			new /obj/effect/effect/smoke(get_turf(src))
		for(var/mob/M in loc)
			M.gib()
		if(istype(loc, /turf/simulated/wall))
			var/turf/simulated/wall/W = loc
			W.ChangeTurf(/turf/simulated/floor/plating)
			playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
		addtimer(CALLBACK(src, .proc/_do_move), 1)
		return
	_stop_moving()

/obj/structure/ev_car/proc/_start_moving()
	is_moving = TRUE
	icon_state = "car_moving"
	addtimer(CALLBACK(src, .proc/_do_move), 1)
	_focus_eyes()

/obj/structure/ev_car/proc/_stop_moving()
	is_moving = FALSE

/obj/structure/ev_car/proc/_teleported()
	_stop_moving()
	_focus_eyes()

/obj/structure/ev_car/proc/_focus_eyes()
	for(var/client/C in GLOB.clients)
		C.perspective = EYE_PERSPECTIVE
		C.eye = src

/obj/structure/ev_car/verb/_enter()
	set name = "Enter car"
	set category = "Object"
	set src in view(1)

	if(!ismob(usr))
		return

	var/mob/M = usr
	M.forceMove(src)
	M.reset_view(src)

/obj/map_ent/trigger_obj
	name = "trigger_obj"
	icon_state = "trigger_mob"

	var/ev_tag
	var/ev_triggered
	var/ev_enabled = TRUE

/obj/map_ent/trigger_obj/Initialize()
	. = ..()

	var/turf/T = get_turf(src)
	register_signal(T, SIGNAL_ENTERED, .proc/_on_enter)

/obj/map_ent/trigger_obj/Destroy()
	var/turf/T = get_turf(src)
	unregister_signal(T, SIGNAL_ENTERED)

	. = ..()

/obj/map_ent/trigger_obj/proc/_on_enter(turf/T, obj/O)
	if(!ev_enabled)
		return

	if(!istype(O))
		return

	ev_triggered = "\ref[O]"

	var/obj/map_ent/E = locate(ev_tag)

	if(!istype(E))
		util_crash_with("ev_tag is invalid")
		return

	E.activate()


/obj/effect/decal/cleanable/egraf
	name = "graffiti"
	icon = 'maps/frontier/event.dmi'

/obj/effect/decal/cleanable/egraf/traitors
	desc = "It is a writing on the wall. It says \"All Traitors Must Die!\""
	icon_state = "traitors"
/obj/effect/decal/cleanable/egraf/fuck
	desc = "Rude"
	icon_state = "fuck-off"
/obj/effect/decal/cleanable/egraf/observe
	desc = "This one looks like some social commentary"
	icon_state = "lair-observe"
/obj/effect/decal/cleanable/egraf/water
	desc = "You've heard this phrase before"
	icon_state = "lair-something_in_it"
/obj/effect/decal/cleanable/egraf/hello
	desc = "Hi!"
	icon_state = "lair-hello"
/obj/effect/decal/cleanable/egraf/melts
	desc = "Look like some sort of a crystal. This sparks a subtle resemblance in your head"
	icon_state = "lair-melts"
/obj/effect/decal/cleanable/egraf/tc11
	desc = "Some obscure drawing of an even more obscure machine. Though, it doesn't seem too alien to you. You may have seen it before"
	icon_state = "lair-tc11"
/obj/effect/decal/cleanable/egraf/senat
	desc = "Some drawings on the wall. The text is in Pan-Slavic, so you can't understand anything"
	icon_state = "senat"

obj/structure/sign/colony/poselok
	name = "Now Leaving Sign"
	desc = "Finnaly i can escape this fucking madhouse!"
	icon_state = "poselok"

obj/structure/portrait
	name = "Trasen's portrait"
	desc = "Nanotrasen's CEO. This is truly, a wondefrul picture. Everything is beautiful on it, the face, the sould and the mind."
	icon = 'maps/frontier/event.dmi'
	icon_state = "golden"

obj/structure/portrait/budget
	desc = "Nanotrasen's CEO."
	icon_state = "small"

obj/structure/portrait/kate
	name = "Employee of the month"
	desc = "This is the employee of the month. A person that gave their all to this project and made it possible. A lonely tear errupts from one of your eyes, as you look on this portrait and prevents you from reading the name of whoever this is"
	icon_state = "month"
