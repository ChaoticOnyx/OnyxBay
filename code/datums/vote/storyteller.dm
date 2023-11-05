/datum/vote/storyteller
	name = "storyteller"

	force_show_panel = TRUE

/datum/vote/storyteller/can_run(mob/creator, automatic)
	if(!automatic && !is_admin(creator))
		return FALSE // Must be an admin.

	return ..()

/datum/vote/storyteller/setup_vote(mob/creator, automatic)
	initiator = (!automatic && istype(creator)) ? creator.ckey : "the server"

	for(var/datum/storyteller_character/C in GLOB.all_storytellers)
		if(!C.can_be_voted_for)
			continue
		choices += C
		display_choices[C] = "[C.name] - [C.desc]"

	choices += "Random"
	display_choices["Random"] = "Random"

/datum/vote/storyteller/report_result()
	if(..())
		return TRUE

	if(result[1] == "Random")
		SSstoryteller.character = pick(choices - "Random")
		log_and_message_admins("Storyteller's character was changed to [SSstoryteller.character.name].")
		return

	SSstoryteller.character = result[1]
