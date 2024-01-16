/datum/event/gravity
	id = "gravity"
	name = "Gravity Failure"
	description = "The gravity generator will be turned off for a while"

	mtth = 2 HOURS
	difficulty = 40

/datum/event/gravity/New()
	. = ..()

	add_think_ctx("announce", CALLBACK(src, nameof(.proc/announce)), 0)

/datum/event/gravity/get_mtth()
	. = ..()
	. -= (SSevents.triggers.roles_count["Engineer"] * (11 MINUTES))
	. = max(1 HOUR, .)

/datum/event/gravity/on_fire()
	var/obj/machinery/gravity_generator/main/GG = GLOB.station_gravity_generator
	if(!GG)
		log_debug("The gravity generator was not found while trying to start an event.")
		return

	GG.set_state(FALSE)
	set_next_think_ctx("announce", world.time + (rand(30, 60) SECONDS))

/datum/event/gravity/proc/announce()
	SSannounce.play_announce(/datum/announce/gravity_failure)
