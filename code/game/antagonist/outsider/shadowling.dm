GLOBAL_DATUM_INIT(shadowlings, /datum/antagonist/shadowling, new)

/datum/antagonist/shadowling
	id = MODE_SHADOWLING
	role_text = "Shadowling"
	role_text_plural = "Shadowlings"
	welcome_text = "Stay in the shadows and avoid the light. Use say \",s message\" to communicate with other shadowlings."
	flags = ANTAG_OVERRIDE_MOB | ANTAG_IMPLANT_IMMUNE
	mob_path = /mob/living/carbon/human/shadowling
	antaghud_indicator = "hudshadowling"

	faction = "shadowling"
	faction_invisible = FALSE

/datum/antagonist/changeling/update_antag_mob(datum/mind/player)
	if(!ishuman(player.current) || player.current.isSynthetic())
		return ..()

	var/mob/living/carbon/human/H = player.current
	for(var/obj/item/I in H)
		H.drop(I)
	H.set_species(SPECIES_SHADOWLING)
	return player.current

/datum/antagonist/changeling/create_objectives(datum/mind/shadowling)
	if(!..())
		return

	var/datum/objective/survive/survive = new
	survive.owner = shadowling
	shadowling.objectives |= survive
