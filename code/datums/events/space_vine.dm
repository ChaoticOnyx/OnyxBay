/datum/event2/space_vine
	id = "space_vine"
	name = "Space Vines"
	description = "The station begins to overgrow with some space vines"

	mtth = 3 HOURS

/datum/event2/space_vine/get_mtth()
	. = ..()
	. -= (SSevents.triggers.roles_count["Engineer"] * (8 MINUTES))
	. = max(1 HOUR, .)

/datum/event2/space_vine/on_fire()
	spacevine_infestation()

	addtimer(CALLBACK(null, /proc/level_seven_announcement), 1 MINUTE)	
