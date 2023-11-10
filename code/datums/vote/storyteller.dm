/datum/vote/storyteller
	name = "Select Storyteller"

/datum/vote/storyteller/can_be_initiated(mob/by_who, forced)
	if(!forced && !is_admin(by_who))
		return FALSE // Must be an admin.

	return ..()

/datum/vote/storyteller/New()
	. = ..()
	for(var/datum/storyteller_character/C in list_values(GLOB.all_storytellers))
		if(!C.can_be_voted_for)
			continue
		default_choices += "[C.name]"

	default_choices += "Random"

/datum/vote/storyteller/finalize_vote(winning_option)
	if(..())
		return TRUE

	if(winning_option == "Random")
		SSstoryteller.character = pick(choices - "Random")
		log_and_message_admins("Storyteller's character was changed to [SSstoryteller.character.name].")
		return
	SSstoryteller.character = GLOB.all_storytellers[winning_option]
