/obj/item/weapon/reagent_containers/Neuromod
	name = "Neuromod"
	desc = "This is a neuromod."
	icon = 'icons/obj/psychotronics.dmi'
	icon_state = "neuromod"
	volume = 5
	w_class = ITEM_SIZE_TINY
	sharp = 0
	unacidable = 0

	var
		neuromod_data = null

/datum/NeuromodData
	var
		name = "name"
		desc = "Description"
		chance = 0

/datum/NeuromodData/LightRegeneration
	name = "neuromod: Light Regeneration"
	desc = "The neuromod changes skin structure and makes possible cure wounds just by light."
	chance = 25
