#define WEATHER_NORMAL 0
#define WEATHER_BLUESPACE_CONVERGENCE 1
#define WEATHER_BLUESPACE_EXIT 2

#define CONVERGENCE_TEMP 203.15 // -70C
#define EXIT_TEMP 153.15 // -120C

/datum/announcement/priority/ams
	title = "Autonomous Meteorological Station"
	announcement_type = "Autonomous Meteorological Station"

/datum/component/polar_weather
	dupe_mode = COMPONENT_DUPE_UNIQUE

	var/current_state = WEATHER_NORMAL
	var/next_state = null
	var/next_state_change = null
	var/was_weather_message = FALSE
	var/datum/announcement/priority/ams/AMS = new
	var/list/things_list = list()

/datum/component/polar_weather/Initialize()
	. = ..()

	if(!istype(parent, /datum/map))
		return COMPONENT_INCOMPATIBLE

	_update_state()
	START_PROCESSING(SSprocessing, src)

/datum/component/polar_weather/proc/_play_sounds()
	for(var/client/C in GLOB.clients)
		var/mob/M = C.mob
		var/area/A = get_area(M)

		if(!A || C.get_preference_value(/datum/client_preference/play_ambiance) == GLOB.PREF_NO)
			continue

		var/list/sounds = C.SoundQuery()

		if(!C)
			continue
		
		var/is_playing_some = FALSE

		for(var/sound/S in sounds)
			if(S.channel == SOUND_CHANNEL_WEATHER)
				is_playing_some = TRUE
				break

		if(is_playing_some)
			continue

		var/sfx_to_play = null

		switch(A.environment_type)
			if(ENVIRONMENT_NONE)
				continue
			if(ENVIRONMENT_OUTSIDE)
				switch(current_state)
					if(WEATHER_NORMAL)
						if(!prob(20))
							return

						sfx_to_play = SFX_WEATHER_OUT_NORMAL
					if(WEATHER_BLUESPACE_CONVERGENCE)
						if(!prob(40))
							return

						sfx_to_play = SFX_WEATHER_OUT_STORM_INCOMING
					if(WEATHER_BLUESPACE_EXIT)
						if(!prob(70))
							return

						sfx_to_play = SFX_WEATHER_OUT_STORM
			if(ENVIRONMENT_ROOM)
				switch(current_state)
					if(WEATHER_NORMAL)
						if(!prob(15))
							return

						sfx_to_play = SFX_WEATHER_IN_NORMAL
					if(WEATHER_BLUESPACE_CONVERGENCE)
						if(!prob(30))
							return

						sfx_to_play = SFX_WEATHER_IN_STORM_INCOMING
					if(WEATHER_BLUESPACE_EXIT)
						if(!prob(45))
							return

						sfx_to_play = SFX_WEATHER_IN_STORM
		
		if(!sfx_to_play)
			continue
		
		var/sound/S = sound(GET_SFX(sfx_to_play), FALSE, FALSE, SOUND_CHANNEL_WEATHER)
		C.mob.playsound_local(get_turf(M), S, 20, FALSE)

/datum/component/polar_weather/proc/_update_state()
	QDEL_LIST(things_list)

	var/list/station_levels = GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION)
	for(var/level in station_levels)
		var/datum/space_level/L = GLOB.using_map.map_levels[level]

		if(current_state == WEATHER_BLUESPACE_EXIT)
			L.add_trait(ZTRAIT_BLUESPACE_EXIT)
			L.remove_trait(ZTRAIT_BLUESPACE_CONVERGENCE)
		else if(current_state == WEATHER_BLUESPACE_CONVERGENCE)
			L.add_trait(ZTRAIT_BLUESPACE_CONVERGENCE)
			L.remove_trait(ZTRAIT_BLUESPACE_EXIT)
		else
			L.remove_trait(ZTRAIT_BLUESPACE_EXIT)
			L.remove_trait(ZTRAIT_BLUESPACE_CONVERGENCE)

	var/light_color
	switch(current_state)
		if(WEATHER_NORMAL)
			light_color = "#ffffff"
		if(WEATHER_BLUESPACE_CONVERGENCE)
			light_color = "#091035"
		if(WEATHER_BLUESPACE_EXIT)
			light_color = "#0508c4"

	var/list/lighting_levels = GLOB.using_map.get_levels_with_trait(ZTRAIT_POLAR_WEATHER)
	for(var/level in lighting_levels)
		log_debug("Updating lighting on level [level] to color [light_color]")
		for(var/turf/simulated/T in block(locate(1, 1, level), locate(world.maxx, world.maxy, level)))
			var/area/A = get_area(T)

			if(A.environment_type == ENVIRONMENT_OUTSIDE)
				// Set lighting
				T.set_light(1, 1, 1.25, l_color = light_color)

				// Update temperature
				var/datum/gas_mixture/M = T.return_air()
				var/thermal_energy = 0
				
				if(current_state == WEATHER_NORMAL)
					thermal_energy = M.get_thermal_energy_change(initial(T.temperature))
				else if(current_state == WEATHER_BLUESPACE_CONVERGENCE)
					thermal_energy = M.get_thermal_energy_change(CONVERGENCE_TEMP)
				else
					thermal_energy = M.get_thermal_energy_change(EXIT_TEMP)
				
				M.add_thermal_energy(thermal_energy)

				// Spawn things
				if(current_state == WEATHER_BLUESPACE_EXIT && prob(5))
					var/mob/living/simple_animal/hostile/bluespace_thing/BT = new(T)
					things_list += BT
			else if(A.environment_type == ENVIRONMENT_ROOM && istype(T, /turf/simulated/floor/natural/frozenground))
				T.set_light(1, 1, 1.25, l_color = light_color)

/datum/component/polar_weather/proc/_weather_announce()
	switch(next_state)
		if(WEATHER_NORMAL)
			AMS.Announce("Weather forecast: cloudless weather is expected and the temperature is -30 Celsius.", "Autonomous Meteorological Station", do_newscast = TRUE)
		if(WEATHER_BLUESPACE_CONVERGENCE)
			AMS.Announce("Weather forecast: Bluespace Convergence is expected, the temperature will drop to -70 Celsius.", "Autonomous Meteorological Station", do_newscast = TRUE)
		if(WEATHER_BLUESPACE_EXIT)
			AMS.Announce("Weather forecast: Bluespace Exit is expected, the temperature will drop to -120 Celsius.", "Autonomous Meteorological Station", do_newscast = TRUE)

/datum/component/polar_weather/Process()
	if(GAME_STATE < RUNLEVEL_GAME)
		return

	if(next_state_change == null)
		next_state_change = world.time + rand(10 MINUTES, 14 MINUTES)
		was_weather_message = FALSE
		
		if(current_state == WEATHER_NORMAL)
			if(prob(30))
				next_state = WEATHER_NORMAL
			else
				next_state = prob(90) ? WEATHER_BLUESPACE_CONVERGENCE : WEATHER_BLUESPACE_EXIT
		else if(current_state == WEATHER_BLUESPACE_CONVERGENCE)
			next_state = prob(5) ? WEATHER_BLUESPACE_EXIT : WEATHER_NORMAL
		else
			next_state = WEATHER_NORMAL

	if(!was_weather_message && world.time >= next_state_change - 4 MINUTES)
		was_weather_message = TRUE
		_weather_announce()

	if(next_state_change != null && world.time >= next_state_change)
		next_state_change = null
		current_state = next_state
		_update_state()

	THROTTLE(sound_cd, 10 SECONDS)

	if(sound_cd)
		_play_sounds()

/datum/component/polar_weather/Destroy()
	STOP_PROCESSING(SSprocessing, src)

	..()

#undef WEATHER_NORMAL
#undef WEATHER_BLUESPACE_CONVERGENCE
#undef WEATHER_BLUESPACE_EXIT
#undef CONVERGENCE_TEMP
#undef EXIT_TEMP
