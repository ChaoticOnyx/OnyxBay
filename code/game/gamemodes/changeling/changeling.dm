/datum/game_mode/changeling
	name = "Changeling"
	round_description = "There are alien changelings onboard. Do not let the changelings succeed!"
	extended_round_description = "Life always finds a way. However, life can sometimes take a more disturbing route. \
		Humanity's extensive knowledge of xeno-biological specimens has made them confident and arrogant. Yet \
		something slipped past their eyes. Something dangerous. Something alive. Most frightening of all, \
		however, is that this something is someone. An unknown alien specimen has incorporated itself into \
		the crew. Its unique biology allows it to manipulate its own or anyone else's DNA. \
		With the ability to copy faces, voices, animals, but also change the chemical make up of your own body, \
		its existence is a threat to not only your personal safety but the lives of everyone on board. \
		No one knows where it came from. No one knows who it is or what it wants. One thing is for \
		certain though... there is never just one of them. Good luck."
	config_tag = "changeling"
	required_players = 2
	required_enemies = 1
	end_on_antag_death = 0
	antag_scaling_coeff = 10
	antag_tags = list(MODE_CHANGELING)


// Makes us a changeling. Called when one becomes an antag.
// !!ALSO CALLED DURING /datum/mind/transfer_to() via /datum/changeling/transfer_to()!!
/mob/proc/make_changeling()
	if(!mind)
		return FALSE
	if(!mind.changeling)
		mind.changeling = new /datum/changeling(src)

	var/datum/changeling/changeling = mind.changeling

	verbs += /datum/changeling/proc/EvolutionMenu
	add_language(LANGUAGE_LING)

	// Adding a biostructure if we still don't have one.
	if(isliving(src) && !istype(src, /mob/living/carbon/brain))
		var/obj/item/organ/internal/biostructure/BIO = locate() in contents
		if(!BIO)
			BIO = new /obj/item/organ/internal/biostructure(src)
			BIO.change_host(src)
			log_debug("New changeling biostructure spawned in [name] / [real_name] ([key]).")

	changeling.reset_my_mob(src) // Just to be sure.
	changeling.update_changeling_powers()
	ability_master?.toggle_open(2)

	faction = "changeling"

	// Changeling acquires our mob's known languages.
	for(var/language in languages)
		changeling.absorbed_languages |= language

	// If called by a human, acquire their DNA.
	var/mob/living/carbon/human/H = src
	if(istype(H))
		var/datum/absorbed_dna/newDNA = new(H.real_name, H.dna, H.species.name, H.languages, H.modifiers, H.flavor_texts)
		changeling.absorbDNA(newDNA)

	return TRUE
