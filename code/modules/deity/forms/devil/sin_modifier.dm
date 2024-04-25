/datum/modifier/sin
	var/sin_stage = SIN_STAGE_BEGINNER

/datum/modifier/sin/New()
	. = ..()
	set_next_think(world.time + 10 MINUTES)

/datum/modifier/sin/think()
	var/datum/godcultist/godcultist = holder.mind?.godcultist
	if(!istype(godcultist))
		holder.remove_modifiers_of_type(/datum/modifier/sin)

	godcultist.points++

/datum/modifier/sin/proc/check_stage(spent_points)
	sin_stage = Clamp(spent_points, SIN_STAGE_BEGINNER, SIN_STAGE_SACRILEGE)
