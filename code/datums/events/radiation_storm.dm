#define STATE_ENTERED_BELT 1
#define STATE_EXITED_BELT  2

/datum/event/radiation_storm
	id = "radiation_storm"
	name = "Radiation Storm"
	description = "The entire station, with the exception of the technical rooms, will be in beta radiation"

	fire_only_once = TRUE
	mtth = 2 HOURS
	difficulty = 70
	blacklisted_maps = list(/datum/map/polar)

	var/list/affecting_z = list()
	var/target_energy = 0
	var/base_radlevel = 25
	var/state = 0
	var/list/rad_sources = list()

/datum/event/radiation_storm/New()
	. = ..()

	add_think_ctx("enter", CALLBACK(src, .proc/enter_belt), 0)
	add_think_ctx("exit", CALLBACK(src, .proc/exit_belt), 0)
	add_think_ctx("end", CALLBACK(src, .proc/end), 0)

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
			radiate(base_radlevel + rand(-10, 10))
		if(STATE_EXITED_BELT)
			base_radlevel -= 1
			radiate(base_radlevel)

	set_next_think(world.time + 2 SECONDS)

/datum/event/radiation_storm/proc/end()
	SSevents.evars["radiation_storm_running"] = FALSE
	set_next_think(0)
	revoke_maint_all_access()
	QDEL_LIST(rad_sources)

/datum/event/radiation_storm/proc/radiate(radiation_level = 25)
	for(var/z in GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION))
		SSradiation.z_radiate(locate(1, 1, z), radiation_level, 1)

	for(var/mob/living/carbon/C in GLOB.living_mob_list_)
		var/area/A = get_area(C)
		if(!A)
			continue
		if(A.area_flags & AREA_FLAG_RAD_SHIELDED)
			continue
		if(istype(C,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = C
			if(prob(5 * (0.01 * (100 - H.getarmor(null, "rad")))))
				if(prob(75))
					randmutb(H) // Applies bad mutation
					domutcheck(H, null, 1)
				else
					randmutg(H) // Applies good mutation
					domutcheck(H, null, 1)

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
