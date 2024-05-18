/**
 * Weather datum. Causes weather to effect a given Z-level.
 *
 */

#define STARTUP_STAGE   1
#define MAIN_STAGE      2
#define WIND_DOWN_STAGE 3
#define END_STAGE       4

/datum/weather
	/// Name of this weather, shown in alerts, reports e.t.c.
	var/name = "weather"
	/// Description.
	var/desc = "a generic weather that should not be seen by you."
	/// Message spammed in chat before this weather effect is applied, "wind-up" phase.
	var/foreshadowing_message = "Bluespace wind begins to pick up."
	/// Cooldown until the weather begins.
	var/foreshadowing_duration = 30 SECONDS
	/// Sound played
	var/foreshadowing_sound
	/// Overlay applied to all tiles on z-level.
	var/foreshadowing_overlay

	/// Displayed in chat once the weather begins in earnest
	var/weather_message = "Bluespace wind begins to blow ferociously!"
	/// In deciseconds, how long the weather lasts
	var/weather_duration = 2 MINUTES
	/// See above - this is the lowest possible duration
	var/weather_duration_lower = 2 MINUTES
	/// See above - this is the highest possible duration
	var/weather_duration_upper = 3 MINUTES
	/// Looping sound while weather is occuring
	var/weather_sound
	/// Area overlay while the weather is occuring
	var/weather_overlay
	/// Color to apply to the area while weather is occuring
	var/weather_color = null

	/// Displayed once the weather is over
	var/end_message = "Bluespace wind relents its assault."
	/// Duration of the "wind-down" phase.
	var/end_duration = 30 SECONDS
	/// Sound that plays while weather is ending
	var/end_sound
	/// Area overlay while weather is ending
	var/end_overlay

	/// Types of area to affect
	var/list/affected_areas = list(
		/area
	)
	/// TRUE value protects areas with outdoors marked as false, regardless of area type
	var/protect_indoors = FALSE
	/// Areas to be affected by the weather, calculated when the weather begins
	var/list/impacted_areas = list()
	/// Areas that were protected by either being outside or underground
	var/list/outside_areas = list()
	/// Areas that are protected and excluded from the affected areas.
	var/list/protected_areas = list()
	/// The list of z-levels that this weather is actively affecting
	var/impacted_z_levels

	/// Since it's above everything else, this is the layer used by default. TURF_LAYER is below mobs and walls if you need to use that.
	var/overlay_layer = ABOVE_PROJECTILE_LAYER
	/// Plane for the overlay
	var/overlay_plane = DEFAULT_PLANE

	/// The stage of the weather, from 1-4
	var/stage = END_STAGE

	/// Reference to the weather controller
	var/datum/weather_controller/weather_controller
	/// A type of looping sound to be played for people outside the active weather
	var/datum/looping_sound/sound_active_outside
	/// A type of looping sound to be played for people inside the active weather
	var/datum/looping_sound/sound_active_inside
	/// A type of looping sound to be played for people outside the winding up/ending weather
	var/datum/looping_sound/sound_weak_outside
	/// A type of looping sound to be played for people inside the winding up/ending weather
	var/datum/looping_sound/sound_weak_inside
	/// Whether the areas should use a blend multiplication during the main weather, for stuff like fulltile storms
	var/multiply_blend_on_main_stage = FALSE
	/// Chance of YOU'VE BEEN THUNDERSTRUCK
	var/thunder_chance = 0
	/// Whether the main stage will block vision
	var/opacity_in_main_stage = FALSE

/datum/weather/New(datum/weather_controller/weather_controller)
	..()
	src.weather_controller = weather_controller
	weather_controller.current_weathers[type] = src

	if(sound_active_outside)
		sound_active_outside = new sound_active_outside(list(), FALSE, TRUE, channel = SOUND_CHANNEL_WEATHER)
	if(sound_active_inside)
		sound_active_inside = new sound_active_inside(list(), FALSE, TRUE, channel = SOUND_CHANNEL_WEATHER)
	if(sound_weak_outside)
		sound_weak_outside = new sound_weak_outside(list(), FALSE, TRUE, channel = SOUND_CHANNEL_WEATHER)
	if(sound_weak_inside)
		sound_weak_inside = new sound_weak_inside(list(), FALSE, TRUE, channel = SOUND_CHANNEL_WEATHER)

	add_think_ctx("weather_ctx", CALLBACK(src, nameof(.proc/weather_ctx)), world.time + 1)

/datum/weather/Destroy()
	LAZYREMOVE(weather_controller.current_weathers, type)
	weather_controller = null
	return ..()

/datum/weather/think()
	if(stage != MAIN_STAGE)
		return

	if(prob(thunder_chance))
		thunderstruck()

	for(var/i in GLOB.living_mob_list_)
		var/mob/living/L = i
		if(can_weather_act(L))
			weather_act(L)

	set_next_think(world.time + 5 SECONDS)

/datum/weather/proc/weather_ctx()
	switch(stage)
		if(STARTUP_STAGE)
			start()

		if(MAIN_STAGE)
			wind_down()

		if(WIND_DOWN_STAGE)
			end()

/// Announces the beginning of the weather.
/datum/weather/proc/foreshadow()
	if(stage == STARTUP_STAGE)
		return

	stage = STARTUP_STAGE
	var/list/affectareas = list()
	for(var/V in get_areas(affected_areas, TRUE))
		affectareas += V

	for(var/V in protected_areas)
		affectareas -= get_areas(V)

	for(var/V in affectareas)
		var/area/A = V
		var/turf/vturf = locate(A.x, A.y, A.z)
		if(!vturf)
			continue

		if(vturf.z != weather_controller.z_level)
			continue

		if(protect_indoors && !(A.area_flags & AREA_FLAG_ALLOW_WEATHER))
			protected_areas |= A
			continue

		impacted_areas |= A

	weather_duration = rand(weather_duration_lower, weather_duration_upper)
	update_areas()
	for(var/M in GLOB.player_list)
		var/turf/mob_turf = get_turf(M)
		if(mob_turf?.z != weather_controller.z_level)
			continue

		if(foreshadowing_message)
			to_chat(M, foreshadowing_message)

	set_next_think_ctx("weather_ctx", world.time + foreshadowing_duration)

	if(sound_active_outside)
		sound_active_outside.output_atoms = outside_areas
	if(sound_active_inside)
		sound_active_inside.output_atoms = impacted_areas
	if(sound_weak_outside)
		sound_weak_outside.output_atoms = outside_areas
		sound_weak_outside.start()
	if(sound_weak_inside)
		sound_weak_inside.output_atoms = impacted_areas
		sound_weak_inside.start()

/datum/weather/proc/start()
	if(stage >= MAIN_STAGE)
		return

	stage = MAIN_STAGE
	update_areas()
	for(var/M in GLOB.player_list)
		var/turf/mob_turf = get_turf(M)
		if(mob_turf?.z != weather_controller.z_level)
			continue

		if(weather_message)
			to_chat(M, weather_message)

	set_next_think(world.time + 5 SECONDS)
	set_next_think_ctx("weather_ctx", world.time + weather_duration)

	if(sound_weak_outside)
		sound_weak_outside.stop()
	if(sound_weak_inside)
		sound_weak_inside.stop()
	if(sound_active_outside)
		sound_active_outside.start()
	if(sound_active_inside)
		sound_active_inside.start()

/datum/weather/proc/wind_down()
	if(stage >= WIND_DOWN_STAGE)
		return

	stage = WIND_DOWN_STAGE
	update_areas()
	for(var/M in GLOB.player_list)
		var/turf/mob_turf = get_turf(M)
		if(mob_turf?.z != weather_controller.z_level)
			continue

		if(end_message)
			to_chat(M, end_message)

	set_next_think_ctx("weather_ctx", world.time + end_duration)

	if(sound_active_outside)
		sound_active_outside.stop()
	if(sound_active_inside)
		sound_active_inside.stop()
	if(sound_weak_outside)
		sound_weak_outside.start()
	if(sound_weak_inside)
		sound_weak_inside.start()

/// Ends this weather fully. Removes sounds, effects and other shit.
/datum/weather/proc/end()
	if(stage == END_STAGE)
		return TRUE

	stage = END_STAGE
	update_areas()
	if(sound_weak_outside)
		sound_weak_outside.start()
	if(sound_weak_inside)
		sound_weak_inside.start()
	if(sound_active_outside)
		qdel(sound_active_outside)
	if(sound_active_inside)
		qdel(sound_active_inside)
	if(sound_weak_outside)
		sound_weak_outside.stop()
		qdel(sound_weak_outside)
	if(sound_weak_inside)
		sound_weak_inside.stop()
		qdel(sound_weak_inside)

	qdel_self()

/// Returns TRUE if the living mob can be affected by weather.
/datum/weather/proc/can_weather_act(mob/living/L)
	var/turf/mob_turf = get_turf(L)
	if(mob_turf.z != !weather_controller.z_level)
		return

	if(!(get_area(L) in impacted_areas))
		return

	return TRUE

/// Override to affect the mob with this weather.
/datum/weather/proc/weather_act(mob/living/L)
	return

/// Thunder, ah
/datum/weather/proc/thunderstruck()
	var/picked_sound = GET_SFX(SFX_THUNDER)
	for(var/i in 1 to impacted_areas.len)
		var/atom/thing = impacted_areas[i]
		DIRECT_OUTPUT(thing, sound(picked_sound, volume = 65))

	for(var/i in 1 to outside_areas.len)
		var/atom/thing = outside_areas[i]
		DIRECT_OUTPUT(thing, sound(picked_sound, volume = 35))

/// Updates overlays on impacted areas.
/datum/weather/proc/update_areas()
	for(var/area/N in impacted_areas)
		if(stage == MAIN_STAGE && multiply_blend_on_main_stage)
			N.blend_mode = BLEND_MULTIPLY
		else
			N.blend_mode = BLEND_OVERLAY
		if(stage == MAIN_STAGE && opacity_in_main_stage)
			N.set_opacity(TRUE)
		else
			N.set_opacity(FALSE)
		N.layer = overlay_layer
		N.plane = overlay_plane
		N.icon = 'icons/effects/weather_effects.dmi'
		N.color = weather_color
		set_area_icon_state(N)
		if(stage == END_STAGE)
			N.color = null
			N.icon = 'icons/turf/areas.dmi'
			N.layer = initial(N.layer)
			N.plane = initial(N.plane)
			N.set_opacity(FALSE)

/datum/weather/proc/set_area_icon_state(area/Area)
	switch(stage)
		if(STARTUP_STAGE)
			Area.icon_state = foreshadowing_overlay
		if(MAIN_STAGE)
			Area.icon_state = weather_overlay
		if(WIND_DOWN_STAGE)
			Area.icon_state = end_overlay
		if(END_STAGE)
			Area.icon_state = ""

#undef STARTUP_STAGE
#undef MAIN_STAGE
#undef WIND_DOWN_STAGE
#undef END_STAGE
