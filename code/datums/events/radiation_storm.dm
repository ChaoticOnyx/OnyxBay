#define STATE_ENTERED_BELT 1
#define STATE_EXITED_BELT  2

/datum/event/radiation_storm
	id = "radiation_storm"
	name = "Radiation Storm"
	description = "The entire station, with the exception of the technical rooms, will be in beta radiation"

	fire_only_once = TRUE
	mtth = 4 HOURS
	blacklisted_maps = list(/datum/map/polar)

	var/list/affecting_z = list()
	var/target_energy = 0
	var/state = 0
	var/list/rad_sources = list()

/datum/event/radiation_storm/get_conditions_description()
	. = "<em>Radiation Storm</em> should not be <em>running</em>.<br>"

/datum/event/radiation_storm/check_conditions()
	. = SSevents.evars["radiation_storm_running"] != TRUE

/datum/event/radiation_storm/get_mtth()
	. = ..()
	. -= (SSevents.triggers.roles_count["Medical"] * (22 MINUTES))
	. = max(1 HOUR, .)

/datum/event/radiation_storm/on_fire()
	SSevents.evars["radiation_storm_running"] = TRUE
	affecting_z = GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION)
	command_announcement.Announce("High levels of beta rays detected in proximity of the [station_name()]. Please evacuate into one of the shielded maintenance tunnels.", "[station_name()] Sensor Array", new_sound = GLOB.using_map.radiation_detected_sound, zlevels = affecting_z)
	make_maint_all_access()

	for(var/area/A in GLOB.hallway)
		A.set_lighting_mode(LIGHTMODE_RADSTORM, TRUE)

	target_energy = BETA_PARTICLE_ENERGY * rand(5, 10)
	addtimer(CALLBACK(src, .proc/enter_belt), 30 SECONDS)

/datum/event/radiation_storm/proc/enter_belt()
	command_announcement.Announce("The [station_name()] has entered the beta rays belt. Please remain in a sheltered area until we have passed the belt.", "[station_name()] Sensor Array", zlevels = affecting_z)
	radiate()
	state = STATE_ENTERED_BELT

	addtimer(CALLBACK(src, .proc/exit_belt), rand(1, 3) MINUTES)
	set_next_think(world.time)

/datum/event/radiation_storm/proc/exit_belt()
	command_announcement.Announce("The [station_name()] has passed the beta rays belt. Please allow for up to one minute while radiation levels dissipate, and report to the infirmary if you experience any unusual symptoms. Maintenance will lose all access again shortly.", "[station_name()] Sensor Array", zlevels = affecting_z)

	for(var/area/A in GLOB.hallway)
		A.set_lighting_mode(LIGHTMODE_RADSTORM, FALSE)

	addtimer(CALLBACK(src, .proc/end), 1 MINUTE)
	state = STATE_EXITED_BELT

/datum/event/radiation_storm/think()
	switch(state)
		if(STATE_ENTERED_BELT)
			for(var/datum/radiation_source/rad_source in rad_sources)
				rad_source.info.energy += target_energy * 0.15
				rad_source.info.energy = Clamp(rad_source.info.energy, 0, target_energy)
		if(STATE_EXITED_BELT)
			for(var/datum/radiation_source/rad_source in rad_sources)
				rad_source.info.energy -= rad_source.info.energy - (rad_source.info.energy * 0.1)
				rad_source.info.energy = Clamp(rad_source.info.energy, 0, target_energy)

	set_next_think(world.time + 2 SECONDS)

/datum/event/radiation_storm/proc/end()
	SSevents.evars["radiation_storm_running"] = FALSE
	set_next_think(0)
	revoke_maint_all_access()
	QDEL_LIST(rad_sources)

/datum/event/radiation_storm/proc/radiate()
	rad_sources = list()

	for(var/z in GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION))
		rad_sources += SSradiation.z_radiate(locate(1, 1, z), new /datum/radiation(50 KILO CURIE, RADIATION_BETA_PARTICLE, target_energy * 0.1), TRUE)

/datum/event/radiation_storm/syndicate
	id = "radiation_storm_syndicate"
	name = "Radiation Storm (Fake)"

	hide = TRUE
	triggered_only = TRUE
	fire_only_once = FALSE

/datum/event/radiation_storm/syndicate/think()
	return

/datum/event/radiation_storm/syndicate/radiate()
	return

#undef STATE_ENTERED_BELT
#undef STATE_EXITED_BELT
