
//Stargazers are the telepathic branch of jellypeople, able to project psychic messages and to link minds with willing participants.

/datum/species/promethean/stargazer
	name = SPECIES_STARGAZER
	name_plural = "Stargazers"
	icobase = 'icons/mob/human_races/prometheans/r_stargazer.dmi'
	/// Special "project thought" telepathy action for stargazers.
	appearance_flags = HAS_SKIN_COLOR | HAS_EYE_COLOR | HAS_HAIR_COLOR | RADIATION_GLOWS


/datum/species/promethean/stargazer/handle_post_spawn(mob/living/carbon/H)
	. = ..()
	H.AddComponent(/datum/component/mind_linker, network_name = "Slime Link")
	spawn(1)
		H.update_action_buttons()

//Species datums don't normally implement destroy, but JELLIES SUCK ASS OUT OF A STEEL STRAW
/datum/species/promethean/stargazer/on_species_loss(mob/living/carbon/human/H)
	var/datum/component/mind_linker/ML = H.get_component(/datum/component/mind_linker)
	ML.project_action.Remove(H)
	ML.master_speech.Remove(H)
	ML.linker_action.Remove(H)
	spawn(1)
		H.update_action_buttons()
	..()
