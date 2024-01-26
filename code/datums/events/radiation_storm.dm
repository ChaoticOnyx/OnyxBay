#define STATE_ENTERED_BELT 1
#define STATE_EXITED_BELT  2

/datum/event/radiation_storm
	id = "radiation_storm"
	name = "Radiation Storm"
	description = "The entire station, with the exception of the technical rooms, will be in beta radiation"

	fire_only_once = TRUE
	mtth = 2 HOURS
	difficulty = 70


	var/list/affecting_z = list()
	var/target_energy = 0
	var/state = 0
	var/list/rad_sources = list()

/datum/event/radiation_storm/New()
	. = ..()

	add_think_ctx("enter", CALLBACK(src, nameof(.proc/enter_belt)), 0)
	add_think_ctx("exit", CALLBACK(src, nameof(.proc/exit_belt)), 0)
	add_think_ctx("end", CALLBACK(src, nameof(.proc/end)), 0)

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
	SSannounce.play_station_announce(/datum/announce/radiation_detected)
	make_maint_all_access()

	for(var/area/A in GLOB.hallway)
		A.set_lighting_mode(LIGHTMODE_RADSTORM, TRUE)

	target_energy = BETA_PARTICLE_ENERGY * rand(5, 10)
	set_next_think_ctx("enter", world.time + (30 SECONDS))

/datum/event/radiation_storm/proc/enter_belt()
	SSannounce.play_station_announce(/datum/announce/radiation_start)
	radiate()
	state = STATE_ENTERED_BELT

	set_next_think_ctx("exit", world.time + (rand(1, 3) MINUTES))
	set_next_think(world.time)

/datum/event/radiation_storm/proc/exit_belt()
	SSannounce.play_station_announce(/datum/announce/radiation_end)

	for(var/area/A in GLOB.hallway)
		A.set_lighting_mode(LIGHTMODE_RADSTORM, FALSE)

	set_next_think_ctx("end", world.time + (1 MINUTE))
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
