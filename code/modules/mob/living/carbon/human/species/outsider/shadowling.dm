/datum/species/shadowling
	name = SPECIES_SHADOWLING
	name_plural = "Shadowlings"

	icobase = 'icons/mob/human_races/r_shadowling.dmi'

	default_language = LANGUAGE_SHADOW
	language = LANGUAGE_SHADOW
	name_language = LANGUAGE_SHADOW
	unarmed_types = list(/datum/unarmed_attack/claws/strong, /datum/unarmed_attack/bite/sharp)
	darksight_range = 8
	darksight_tint = DARKTINT_GOOD
	has_organ = list()
	siemens_coefficient = 0
	has_fine_manipulation = FALSE

	oxy_mod = 0
	toxins_mod = 0
	radiation_mod = 0
	metabolism_mod = 0

	blood_color = "#222222"
	flesh_color = "#000000"

	remains_type = /obj/effect/decal/cleanable/ash
	death_message = "dissolves into ash..."

	species_flags = SPECIES_FLAG_NO_SCAN | SPECIES_FLAG_NO_SLIP | SPECIES_FLAG_NO_BLOCK | SPECIES_FLAG_NO_POISON | SPECIES_FLAG_NO_BLOOD | SPECIES_FLAG_NO_EMBED | SPECIES_FLAG_NO_FIRE | SPECIES_FLAG_NO_ANTAG_TARGET
	spawn_flags = SPECIES_IS_RESTRICTED
	appearance_flags = HAS_EYE_COLOR

	genders = list(NEUTER)

/datum/species/shadowling/handle_post_spawn(mob/living/carbon/human/H)
	H.real_name = get_random_name()
	H.SetName(H.real_name)
	H.r_eyes = 220
	H.b_eyes = 0
	H.g_eyes = 0
	H.update_eyes()
	..()
//	if(H.mind && !GLOB.shadowlings.is_antagonist(H.mind))
//		GLOB.shadowlings.add_antagonist(H.mind, TRUE)

/datum/species/shadowling/handle_death(mob/living/carbon/human/H)
	H.dust()

/datum/species/shadowling/handle_environment_special(mob/living/carbon/human/H)
	if(H.InStasis() || H.is_ic_dead() || H.isSynthetic())
		return

	var/light_amount = 0
	if(isturf(H.loc))
		var/turf/T = H.loc
		light_amount = T.get_lumcount() * 10

	if(light_amount > 2)
		H.take_overall_damage(0, 5) // Light sucks! It burns and blinds us!
		H.eye_blurry += 2
		if(prob(20))
			to_chat(H, SPAN_WARNING("<font size='3'>[pick("The light is burning you!", "The light! It burns!", "There's too much light around!", "You can't handle this light for much longer!")]</font>"))
	else
		H.heal_overall_damage(2, 2) // On the other hand, the cold embrace of darkness heals!

/datum/species/shadowling/hug(mob/living/carbon/human/H,mob/living/target)
	H.visible_message(SPAN_NOTICE("[H] envelops [target] in its shadows for a moment."), \
					  SPAN_NOTICE("You envelop [target] in your shadows for a moment."))

/datum/species/shadowling/is_eligible_for_antag_spawn(antag_id)
	return FALSE // No need to be more antagous than we already are
