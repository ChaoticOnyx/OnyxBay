/obj/item/weapon/reagent_containers/neuromod
	name = "neuromod"
	desc = "This is a neuromod."
	icon = 'icons/obj/psychotronics.dmi'
	icon_state = "neuromod"
	volume = 5
	w_class = ITEM_SIZE_TINY
	sharp = 0
	unacidable = 0

	var/datum/neuromodData/neuromod_data = null

/obj/item/weapon/reagent_containers/neuromod/proc/ToList()
	var/list/N = list()

	N["reference"] = "\ref[src]"

	if (neuromod_data)
		N["neuromod_data"] = neuromod_data.ToList()
	else
		N["neuromod_data"] = 0

	return N

/obj/item/weapon/reagent_containers/neuromod/New(loc, neuromod_data, ...)
	src.neuromod_data = neuromod_data

	..()

/obj/item/weapon/reagent_containers/neuromod/Destroy()
	QDEL_NULL(neuromod_data)
	..()

/datum/neuromodData
	var/name = "Name"
	var/desc = "Description"
	var/chance = 0
	var/research_time = 100

/datum/neuromodData/proc/ToList()
	var/list/N = list()

	N["reference"] = "\ref[src]"
	N["name"] = name
	N["desc"] = desc
	N["type"] = type
	N["research_time"] = research_time

	return N

/datum/neuromodData/LightRegeneration
	name = "Light Regeneration"
	desc = "The neuromod changes skin structure and makes possible cure wounds just by light."
	chance = 25
