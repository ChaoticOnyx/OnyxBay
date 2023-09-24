#define WEATHER_NORMAL 0
#define WEATHER_SNOWFALL 1
#define WEATHER_SNOWSTORM 2

#define SNOWFALL_TEMP 203.15 // -70C
#define SNOWSTORM_TEMP 153.15 // -120C

/datum/component/polar_weather
	dupe_mode = COMPONENT_DUPE_UNIQUE

	var/current_state = WEATHER_NORMAL
	var/next_state = null
	var/next_state_change = null
	var/was_weather_message = FALSE
	var/light_initialized = FALSE
	var/list/turfs_to_process

/datum/component/polar_weather/Initialize()
	. = ..()

	if(!istype(parent, /datum/map))
		return COMPONENT_INCOMPATIBLE

	_update_state()
	set_next_think(world.time)
	add_think_ctx("sound", CALLBACK(src, nameof(.proc/sound_think)), world.time)

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
					if(WEATHER_SNOWFALL)
						if(!prob(40))
							return

						sfx_to_play = SFX_WEATHER_OUT_STORM_INCOMING
					if(WEATHER_SNOWSTORM)
						if(!prob(70))
							return

						sfx_to_play = SFX_WEATHER_OUT_STORM
			if(ENVIRONMENT_ROOM)
				switch(current_state)
					if(WEATHER_NORMAL)
						if(!prob(15))
							return

						sfx_to_play = SFX_WEATHER_IN_NORMAL
					if(WEATHER_SNOWFALL)
						if(!prob(30))
							return

						sfx_to_play = SFX_WEATHER_IN_STORM_INCOMING
					if(WEATHER_SNOWSTORM)
						if(!prob(45))
							return

						sfx_to_play = SFX_WEATHER_IN_STORM

		if(!sfx_to_play)
			continue

		var/sound/S = sound(GET_SFX(sfx_to_play), FALSE, FALSE, SOUND_CHANNEL_WEATHER)
		C.mob.playsound_local(get_turf(M), S, 20, FALSE)

/datum/component/polar_weather/proc/_update_state()
	var/list/station_levels = GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION)
	for(var/level in station_levels)
		var/datum/space_level/L = GLOB.using_map.map_levels[level]

		if(current_state == WEATHER_SNOWSTORM)
			L.add_trait(ZTRAIT_SNOWSTORM)
			L.remove_trait(ZTRAIT_SNOWFALL)
		else if(current_state == WEATHER_SNOWFALL)
			L.add_trait(ZTRAIT_SNOWFALL)
			L.remove_trait(ZTRAIT_SNOWSTORM)
		else
			L.remove_trait(ZTRAIT_SNOWSTORM)
			L.remove_trait(ZTRAIT_SNOWFALL)

	var/light_color
	var/weather_overlay
	switch(current_state)
		if(WEATHER_NORMAL)
			weather_overlay = "nothing"
		if(WEATHER_SNOWFALL)
			weather_overlay = "light_snow"
		if(WEATHER_SNOWSTORM)
			weather_overlay = "snow_storm"


	var/list/impacted_areas = area_repository.get_areas_by_z_level(list(/proc/is_outside_area))
	for(var/A in impacted_areas)
		var/area/impacted_area = impacted_areas[A]
		impacted_area.icon = 'icons/effects/effects.dmi'
		impacted_area.icon_state = weather_overlay
		if(!light_initialized)
			turfs_to_process = get_area_turfs(impacted_area)

		for(var/turf/T in turfs_to_process)

			// Set lighting
			if(!light_initialized)
				T.set_light(0.95, 1, 1.25, l_color = light_color)

			// Update temperature
			var/datum/gas_mixture/M = T.return_air()
			var/thermal_energy = 0
			var/new_temperature = 243.15
			if(current_state == WEATHER_NORMAL)
				new_temperature = initial(T.temperature)
			else if(current_state == WEATHER_SNOWFALL)
				new_temperature = SNOWFALL_TEMP
			else
				new_temperature = SNOWSTORM_TEMP

			if(istype(T, /turf/unsimulated))
				T.temperature = new_temperature
				continue

			thermal_energy = M.get_thermal_energy_change(new_temperature)
			M.add_thermal_energy(thermal_energy)
	light_initialized = TRUE

/datum/component/polar_weather/proc/_weather_announce()
	switch(next_state)
		if(WEATHER_NORMAL)
			SSannounce.play_station_announce(/datum/announce/weather_normal)
		if(WEATHER_SNOWFALL)
			SSannounce.play_station_announce(/datum/announce/weather_snowfall)
		if(WEATHER_SNOWSTORM)
			SSannounce.play_station_announce(/datum/announce/weather_snowstorm)

/datum/component/polar_weather/think()
	if(GAME_STATE < RUNLEVEL_GAME)
		set_next_think(world.time + 1 MINUTE)
		return

	if(next_state_change == null)
		next_state_change = world.time + rand(10 MINUTES, 14 MINUTES)
		was_weather_message = FALSE

		if(current_state == WEATHER_NORMAL)
			if(prob(30))
				next_state = WEATHER_NORMAL
			else
				next_state = prob(90) ? WEATHER_SNOWFALL : WEATHER_SNOWSTORM
		else if(current_state == WEATHER_SNOWFALL)
			next_state = prob(5) ? WEATHER_SNOWSTORM : WEATHER_NORMAL
		else
			next_state = WEATHER_NORMAL

	if(!was_weather_message && world.time >= next_state_change - 2 MINUTES)
		was_weather_message = TRUE
		_weather_announce()

	if(next_state_change != null && world.time >= next_state_change)
		next_state_change = null
		current_state = next_state
		_update_state()

	set_next_think(world.time + 1 MINUTE)

/datum/component/polar_weather/proc/sound_think()
	_play_sounds()
	set_next_think_ctx("sound", world.time + 10 SECONDS)

#undef WEATHER_NORMAL
#undef WEATHER_SNOWFALL
#undef WEATHER_SNOWSTORM
#undef SNOWFALL_TEMP
#undef SNOWSTORM_TEMP
