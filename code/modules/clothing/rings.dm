///////////////////////////////////////////////////////////////////////
//Rings

/obj/item/clothing/ring
	name = "ring"
	w_class = ITEM_SIZE_TINY
	icon = 'icons/obj/clothing/rings.dmi'
	slot_flags = SLOT_GLOVES
	gender = NEUTER
	species_restricted = list("exclude", SPECIES_DIONA)
	var/undergloves = 1
	blood_overlay_type = null
	coverage = 0

	drop_sound = SFX_DROP_RING
	pickup_sound = SFX_PICKUP_RING
