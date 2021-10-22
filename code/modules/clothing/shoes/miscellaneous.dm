/obj/item/clothing/shoes/syndigaloshes
	desc = "A pair of brown shoes. They seem to have extra grip."
	name = "brown shoes"
	icon_state = "brown"
	permeability_coefficient = 0.05
	item_flags = ITEM_FLAG_NOSLIP
	origin_tech = list(TECH_ILLEGAL = 3)
	var/list/clothing_choices = list()
	siemens_coefficient = 0.5
	species_restricted = null

	armor = list(melee = 40, bullet = 40, laser = 40, energy = 35, bomb = 20, bio = 30, rad = 0)

/obj/item/clothing/shoes/mime
	name = "mime shoes"
	icon_state = "mime"

/obj/item/clothing/shoes/swat
	name = "\improper SWAT boots"
	desc = "When you want to turn up the heat."
	icon_state = "swat"
	force = 3
	armor = list(melee = 80, bullet = 60, laser = 60,energy = 25, bomb = 50, bio = 10, rad = 0)
	item_flags = ITEM_FLAG_NOSLIP
	siemens_coefficient = 0.4
	can_hold_knife = 1

/obj/item/clothing/shoes/combat //Basically SWAT shoes combined with galoshes.
	name = "combat boots"
	desc = "When you REALLY want to turn up the heat."
	icon_state = "swat"
	force = 5
	armor = list(melee = 80, bullet = 60, laser = 60,energy = 25, bomb = 50, bio = 10, rad = 0)
	item_flags = ITEM_FLAG_NOSLIP
	siemens_coefficient = 0.1
	can_hold_knife = 1

	cold_protection = FEET
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = FEET
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/shoes/dress
	name = "dress shoes"
	desc = "The height of fashion, and they're pre-polished!"
	icon_state = "laceups"
	siemens_coefficient = 1.0

/obj/item/clothing/shoes/sandal
	desc = "A pair of rather plain, wooden sandals."
	name = "sandals"
	icon_state = "wizard"
	species_restricted = null
	body_parts_covered = 0
	siemens_coefficient = 1.0

	wizard_garb = 1

	armor = list(melee = 10, bullet = 10, laser = 10, energy = 5, bomb = 10, bio = 3, rad = 0)

/obj/item/clothing/shoes/sandal/marisa
	desc = "A pair of magic, black shoes."
	name = "magic shoes"
	icon_state = "black"
	body_parts_covered = FEET

/obj/item/clothing/shoes/sandal/color
	name = "sandals"
	desc = "A pair of plain sandals."
	icon_state = "sandals"
	wizard_garb = 0

/obj/item/clothing/shoes/sandal/color/black
	name = "black sandals"
	color = "#3d3d3d"

/obj/item/clothing/shoes/sandal/color/grey
	name = "grey sandals"
	color = "#c4c4c4"

/obj/item/clothing/shoes/sandal/color/blue
	name = "blue sandals"
	color = "#4379cc"

/obj/item/clothing/shoes/sandal/color/pink
	name = "pink sandals"
	color = "#df20a6"

/obj/item/clothing/shoes/sandal/color/red
	name = "red sandals"
	color = "#ee1511"

/obj/item/clothing/shoes/sandal/color/green
	name = "green sandals"
	color = "#42a345"

/obj/item/clothing/shoes/sandal/color/orange
	name = "orange sandals"
	color = "#f9863e"


/obj/item/clothing/shoes/clown_shoes
	desc = "The prankster's standard-issue clowning shoes. Damn they're huge!"
	name = "clown shoes"
	icon_state = "clown"
	force = 0
	var/footstep = 1	//used for squeeks whilst walking
	species_restricted = null
	siemens_coefficient = 0.5 // these things are kinda rubberish, aint they?

	armor = list(melee = 35, bullet = 35, laser = 35,energy = 15, bomb = 25, bio = 15, rad = 0)

/obj/item/clothing/shoes/clown_shoes/New()
	..()
	slowdown_per_slot[slot_shoes]  = 0

/obj/item/clothing/shoes/clown_shoes/handle_movement(turf/walking, running)
	if(running)
		if(footstep >= 2)
			footstep = 0
			playsound(src, SFX_CLOWN, 50, 1) // this will get annoying very fast.
		else
			footstep++
	else
		playsound(src, SFX_CLOWN, 20, 1)

/obj/item/clothing/shoes/cult
	name = "boots"
	desc = "A pair of boots worn by the followers of Nar-Sie."
	icon_state = "cult"
	force = 2
	siemens_coefficient = 0.5

	armor = list(melee = 40, bullet = 40, laser = 40, energy = 15, bomb = 20, bio = 10, rad = 0)

	cold_protection = FEET
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = FEET
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE
	species_restricted = null

/obj/item/clothing/shoes/cyborg
	name = "cyborg boots"
	desc = "Shoes for a cyborg costume."
	icon_state = "boots"

/obj/item/clothing/shoes/slippers
	name = "bunny slippers"
	desc = "Fluffy!"
	icon_state = "slippers"
	force = 0
	species_restricted = null
	w_class = ITEM_SIZE_SMALL
	siemens_coefficient = 1.0

/obj/item/clothing/shoes/slippers_worn
	name = "worn bunny slippers"
	desc = "Fluffy..."
	icon_state = "slippers_worn"
	force = 0
	w_class = ITEM_SIZE_SMALL
	siemens_coefficient = 1.0

/obj/item/clothing/shoes/laceup
	name = "laceup shoes"
	desc = "The height of fashion, and they're pre-polished!"
	icon_state = "laceups"

/obj/item/clothing/shoes/swimmingfins
	desc = "Help you swim good."
	name = "swimming fins"
	icon_state = "flippers"
	item_flags = ITEM_FLAG_NOSLIP
	species_restricted = null

/obj/item/clothing/shoes/swimmingfins/New()
	..()
	slowdown_per_slot[slot_shoes] = 1

/obj/item/clothing/shoes/cheapboots
	name = "budget jackboots"
	desc = "Tall cheap-ass leatherlike boots with a hint of artificial shine."
	icon_state = "jackboots"
	can_hold_knife = 1
	cold_protection = FEET
	min_cold_protection_temperature = HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	cold_protection = FEET
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = FEET
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/shoes/cheapboots/work
	name = "workboots"
	icon_state = "workbootscheap"
	desc = "A pair of sham work boots. These have never been designed for use in industrial settings."
