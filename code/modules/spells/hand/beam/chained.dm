/datum/spell/hand/beam/chained/send_beam(atom/origin, atom/to_beam, bounces = max_beam_bounces)
	origin.Beam(to_beam, icon_state = "lightning[rand(1,12)]", time = beam_duration)

	if(bounces >= 1)
		playsound(to_beam, 50, vary = TRUE, extrarange = -1)
		// Chain continues shortly after. If they extinguish themselves in this time, the chain will stop anyways.
		addtimer(CALLBACK(src, nameof(.proc/continue_beam), to_beam, bounces), beam_duration * 0.5)

/datum/spell/hand/beam/chained/proc/continue_beam(mob/living/carbon/beamed, bounces)
	var/mob/living/carbon/to_beam_next = get_target(beamed)
	if(isnull(to_beam_next)) // No target = no chain
		return

	// Chain again! Recursively
	send_beam(beamed, to_beam_next, bounces - 1)

/datum/spell/hand/beam/chained/proc/get_target(atom/center)
	var/list/possibles = list()
	var/list/priority_possibles = list()
	for(var/mob/living/carbon/to_check in view(target_radius, center))
		if(to_check == center || to_check == holder)
			continue

		possibles += to_check

	if(!length(possibles))
		return null

	return length(priority_possibles) ? pick(priority_possibles) : pick(possibles)
