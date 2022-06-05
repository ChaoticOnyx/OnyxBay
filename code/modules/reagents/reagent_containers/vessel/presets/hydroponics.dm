
/obj/item/reagent_containers/vessel/bottle/chemical/big/compost
	name = "compost bottle"
	start_label = "compost"
	startswith = list(/datum/reagent/toxin/fertilizer/compost)

/obj/item/reagent_containers/vessel/plastic/eznutrient
	name = "\improper EZ NUtrient bottle"
	desc = "A small bottle of EZ NUtrient. It's extra nutritious!"
	icon_state = "fertilizer1"
	force = 7.0
	mod_weight = 0.65
	mod_reach = 0.5
	mod_handy = 0.65
	startswith = list(/datum/reagent/toxin/fertilizer/eznutrient)

/obj/item/reagent_containers/vessel/plastic/left4zed
	name = "\improper Left-4-Zed bottle"
	desc = "A small bottle of Left-4-Zed. It helps plants to mutate!"
	icon_state = "fertilizer2"
	force = 7.0
	mod_weight = 0.65
	mod_reach = 0.5
	mod_handy = 0.65
	startswith = list(/datum/reagent/toxin/fertilizer/left4zed)

/obj/item/reagent_containers/vessel/plastic/robustharvest
	name = "\improper Robust Harvest"
	desc = "A small bottle of Robust Harvest. Causes high yield!"
	icon_state = "fertilizer3"
	force = 7.0
	mod_weight = 0.65
	mod_reach = 0.5
	mod_handy = 0.65
	startswith = list(/datum/reagent/toxin/fertilizer/robustharvest)

/obj/item/reagent_containers/vessel/plastic/mutogrow
	name = "\improper Mut'o'Grow"
	desc = "A small bottle of Mut'o'Grow. Randomly changes the DNA structure of plants. Warning: ingestion may (and will) cause severe poisoning!"
	icon_state = "mutagen"
	force = 7.5
	mod_weight = 0.65
	mod_reach = 0.5
	mod_handy = 0.65
	matter = list(MATERIAL_STEEL = 2000) // Well plastic but actually steel
	startswith = list(/datum/reagent/mutagen/industrial)
