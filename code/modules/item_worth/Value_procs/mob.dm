/mob/living/carbon/human/Value(base)
	. = ..()
	if(species)
		. *= species.rarity_value
