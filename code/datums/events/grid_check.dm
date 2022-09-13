/datum/event/grid_check
	id = "grid_check"
	name = "Grid Check"
	description = "The station will be de-energized for a while"

	mtth = 3 HOURS

/datum/event/grid_check/get_mtth()
	. = ..()
	. -= (SSevents.triggers.roles_count["Engineer"] * (18 MINUTES))
	. = max(1 HOUR, .)

/datum/event/grid_check/on_fire()
	power_failure(0, EVENT_LEVEL_MODERATE, GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION))

	addtimer(CALLBACK(src, .proc/announce), 30 SECONDS)

/datum/event/grid_check/proc/announce()
	GLOB.using_map.grid_check_announcement()
