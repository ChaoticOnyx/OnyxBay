/obj/item/clothing/gloves/color
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "white"
	armor = list(melee = 10, bullet = 5, laser = 5, energy = 0, bomb = 0, bio = 0)

	item_state_slots = list(
		slot_l_hand_str = "lgloves",
		slot_r_hand_str = "lgloves",
		)

/obj/item/clothing/gloves/color/modified
	item_flags = ITEM_FLAG_PREMODIFIED

/obj/item/clothing/gloves/color/white
	color = COLOR_WHITE

/obj/item/clothing/gloves/color/purple
	color = COLOR_PURPLE

/obj/item/clothing/gloves/color/white/modified
	item_flags = ITEM_FLAG_PREMODIFIED

/obj/item/clothing/gloves/rainbow
	name = "rainbow gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "rainbow"
	armor = list(melee = 10, bullet = 5, laser = 5, energy = 0, bomb = 0, bio = 0)

/obj/item/clothing/gloves/color/long_evening_gloves
	name = "long evening gloves"
	desc = "A pair of long gloves for ladies wearing evening dresses."
	icon_state = "long_evening_gloves"

/obj/item/clothing/gloves/color/fingerless_gloves
	name = "fingerless gloves"
	desc = "A pair of fingerless gloves, they look like they belong to a soul hungry for rebellion."
	icon_state = "color_fingerless"
	body_parts_covered = NO_BODYPARTS	//fingerless gloves don't prevent from leaving fingerprints
	clipped = TRUE
	species_restricted = list("exclude", SPECIES_VOX)
	coverage = 0.5

/obj/item/clothing/gloves/rainbow/modified
	item_flags = ITEM_FLAG_PREMODIFIED
