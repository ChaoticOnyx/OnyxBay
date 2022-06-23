// The numbers are important.
// The next state is computed by addition 1 to the current state (or starting from 0).
#define WEATHER_NORMAL 0
#define WEATHER_STORM_INCOMING 1
#define WEATHER_STORM 2

/datum/component/polar_weather
	dupe_mode = COMPONENT_DUPE_UNIQUE

	var/current_state = WEATHER_NORMAL
	var/last_weather_change

	var/static/states = list(
		"[WEATHER_NORMAL]" = 240 SECONDS,
		"[WEATHER_STORM_INCOMING]" = 240 SECONDS,
		"[WEATHER_STORM]" = 240 SECONDS
	)

	// The current day time is between 0 and `day_duration`.
	var/day_duration = 1 HOUR

	// Keep current light color.
	var/light_color
	var/light_gradient = list(
		"#7d6e57" = 0.2,
		"#ffffff" = 0.3,
		"#29160d" = 0.7,
		"#000000" = 0.9
	)

/datum/component/polar_weather/Initialize()
	. = ..()

	if(!istype(parent, /datum/map))
		return COMPONENT_INCOMPATIBLE

	last_weather_change = -world.time
	START_PROCESSING(SSprocessing, src)

/datum/component/polar_weather/proc/_update_state()
	var/old_state = current_state

	if(current_state == null || current_state >= length(states) - 1)
		current_state = 0
	else
		current_state += 1

	last_weather_change = world.time
	log_debug("The weather has changed state from [old_state] to [current_state]")

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
					if(WEATHER_STORM_INCOMING)
						if(!prob(40))
							return

						sfx_to_play = SFX_WEATHER_OUT_STORM_INCOMING
					if(WEATHER_STORM)
						if(!prob(70))
							return

						sfx_to_play = SFX_WEATHER_OUT_STORM
			if(ENVIRONMENT_ROOM)
				switch(current_state)
					if(WEATHER_NORMAL)
						if(!prob(15))
							return

						sfx_to_play = SFX_WEATHER_IN_NORMAL
					if(WEATHER_STORM_INCOMING)
						if(!prob(30))
							return

						sfx_to_play = SFX_WEATHER_IN_STORM_INCOMING
					if(WEATHER_STORM)
						if(!prob(45))
							return

						sfx_to_play = SFX_WEATHER_IN_STORM
		
		if(!sfx_to_play)
			continue
		
		var/sound/S = sound(GET_SFX(sfx_to_play), FALSE, FALSE, SOUND_CHANNEL_WEATHER)
		C.mob.playsound_local(get_turf(M), S, 20, FALSE)

/datum/component/polar_weather/proc/update_lighting()
	var/day_time = world.time % day_duration
	var/normalized_time = day_time / day_duration

	if(!light_color)
		light_color = light_gradient[1]

	// Update color
	var/new_light_color

	for(var/C in light_gradient)
		var/start_from = light_gradient[C]

		if(normalized_time >= start_from)
			new_light_color = C
	
	if(!new_light_color || new_light_color == light_color)
		return

	light_color = new_light_color
	var/list/target_levels = GLOB.using_map.get_levels_with_trait(ZTRAIT_GLOBAL_DYNAMIC_LIGHTING)

	for(var/level in target_levels)
		log_debug("Updating lighting on level [level] to color [light_color]")
		for(var/turf/T in block(locate(1, 1, level), locate(world.maxx, world.maxy, level)))
			var/area/A = get_area(T)

			if(A.environment_type == ENVIRONMENT_OUTSIDE)
				T.set_light(1, 1, 1.25, l_color = light_color)

/datum/component/polar_weather/Process()
	var/duration = states["[current_state]"]
	THROTTLE_SHARED(state_cd, duration, last_weather_change)

	if(state_cd)
		_update_state()

	THROTTLE(sound_cd, 10 SECONDS)

	if(sound_cd)
		_play_sounds()
	
	THROTTLE(light_cd, 5 SECOND)
	
	if(light_cd)
		update_lighting()

/datum/component/polar_weather/Destroy()
	STOP_PROCESSING(SSprocessing, src)

	..()

#undef WEATHER_NORMAL
#undef WEATHER_STORM_INCOMING
#undef WEATHER_STORM
