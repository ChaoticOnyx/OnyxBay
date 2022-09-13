/datum/vote/storyteller
	name = "storyteller"

/datum/vote/storyteller/can_run(mob/creator, automatic)
	if(!automatic && !is_admin(creator))
		return FALSE // Must be an admin.

	return ..()

/datum/vote/storyteller/setup_vote(mob/creator, automatic)
	initiator = (!automatic && istype(creator)) ? creator.ckey : "the server"

	for(var/datum/storyteller_character/C in GLOB.all_storytellers)
		choices += C
		display_choices[C] = "[C.name] - [C.desc]"

		if(C == SSstoryteller.character)
			display_choices[C] += " (current)"

/datum/vote/storyteller/report_result()
	if(..())
		return TRUE

	SSstoryteller.character = result[1]
