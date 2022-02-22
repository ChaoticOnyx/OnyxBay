
/obj/item/reagent_containers/glass/bottle/big/compost
	name = "compost bottle"
	starting_label = "compost"

/obj/item/reagent_containers/glass/bottle/big/compost/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/toxin/fertilizer/compost, 90)
	update_icon()


/obj/item/reagent_containers/glass/bottle/eznutrient
	name = "\improper EZ NUtrient bottle"
	desc = "A small bottle of EZ NUtrient. It's extra nutritious!"
	icon_state = "fertilizer1"
	lid_state = "lid_fertilizer1"
	matter = list(MATERIAL_PLASTIC = 2000)
	use_filling_states = FALSE
	default_name = null
	default_desc = null

/obj/item/reagent_containers/glass/bottle/eznutrient/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/toxin/fertilizer/eznutrient, 60)
	update_icon()


/obj/item/reagent_containers/glass/bottle/left4zed
	name = "\improper Left-4-Zed bottle"
	desc = "A small bottle of Left-4-Zed. It helps plants to mutate!"
	icon_state = "fertilizer2"
	lid_state = "lid_fertilizer2"
	matter = list(MATERIAL_PLASTIC = 2000)
	use_filling_states = FALSE
	default_name = null
	default_desc = null

/obj/item/reagent_containers/glass/bottle/left4zed/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/toxin/fertilizer/left4zed, 60)
	update_icon()


/obj/item/reagent_containers/glass/bottle/robustharvest
	name = "\improper Robust Harvest"
	desc = "A small bottle of Robust Harvest. Causes high yield!"
	icon_state = "fertilizer3"
	lid_state = "lid_fertilizer3"
	matter = list(MATERIAL_PLASTIC = 2000)
	use_filling_states = FALSE
	default_name = null
	default_desc = null

/obj/item/reagent_containers/glass/bottle/robustharvest/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/toxin/fertilizer/robustharvest, 60)
	update_icon()


/obj/item/reagent_containers/glass/bottle/mutogrow
	name = "\improper Mut'o'Grow"
	desc = "A small bottle of Mut'o'Grow. Randomly changes the DNA structure of plants. Warning: ingestion may (and will) cause severe poisoning!"
	icon_state = "mutagen"
	lid_state = "lid_mutagen"
	matter = list(MATERIAL_STEEL = 2000)
	use_filling_states = FALSE
	default_name = null
	default_desc = null

/obj/item/reagent_containers/glass/bottle/mutogrow/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/mutagen/industrial, 60)
	update_icon()
