/datum/event/space_vine
	id = "space_vine"
	name = "Space Vines"
	description = "The station begins to overgrow with some space vines"

	mtth = 2 HOURS

/datum/event/space_vine/New()
	. = ..()
	
	add_think_ctx("announce", CALLBACK(null, /proc/level_seven_announcement), 0)

/datum/event/space_vine/get_mtth()
	. = ..()
	. -= (SSevents.triggers.roles_count["Engineer"] * (8 MINUTES))
	. = max(1 HOUR, .)

/datum/event/space_vine/on_fire()
	spacevine_infestation()

	set_next_think_ctx("announce", world.time + (1 MINUTE))
