/datum/admin_secret_item/random_event/trigger_cortical_borer_infestation
	name = "Trigger a Cortical Borer infestation"

/datum/admin_secret_item/random_event/trigger_cortical_borer_infestation/execute(mob/user)
	. = ..()
	if(.)
		return GLOB.borers.attempt_random_spawn()
