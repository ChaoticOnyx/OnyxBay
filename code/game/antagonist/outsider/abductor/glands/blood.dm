/*
TODO That's thing should change the blood reagent, but... We don't even have the ability to change the blood reagent.
REVIEW Does we need this thing?
*/
/obj/item/organ/internal/heart/gland/blood
	abductor_hint = "pseudonuclear hemo-destabilizer. Periodically randomizes the abductee's bloodcolor."
	cooldown_low = 1200
	cooldown_high = 1800
	uses = -1
	mind_control_uses = 3
	mind_control_duration = 1500

/obj/item/organ/internal/heart/gland/blood/activate()
	if(!ishuman(owner) || !owner.dna.species)
		return
	var/mob/living/carbon/human/H = owner
	var/datum/species/species = H.dna.species
	to_chat(H, SPAN_WARNING("You feel your blood heat up for a moment."))
	species.blood_color = get_random_colour()
