/obj/item/LifeformScanDisk
	name = "lifeform scan disk"
	desc = "Contains all about lifeform. Insert in a destructor and get a new technologies."
	icon = 'icons/obj/psychotronics.dmi'
	icon_state = "lifeformscandisk"
	item_state = "card-id"
	w_class = ITEM_SIZE_SMALL
	origin_tech = null

/obj/item/neuromodDataDisk
	name = "neuromod data disk"
	desc = "Contains neuro data for production neuromods."
	icon = 'icons/obj/psychotronics.dmi'
	icon_state = "lifeformscandisk"
	item_state = "card-id"
	w_class = ITEM_SIZE_SMALL
	origin_tech = null

	var/datum/neuromodData/neuromod_data = null

/obj/item/neuromodDataDisk/proc/ToList()
	var/list/N = list()

	N["reference"] = "\ref[src]"
	N["name"] = name
	N["desc"] = desc

	if (neuromod_data)
		N["neuromod_data"] = neuromod_data.ToList()
	else
		N["neuromod_data"] = null

	return N

/obj/item/neuromodDataDisk/LightRegenerationDisk/New(loc, ...)
	..()

	neuromod_data = new /datum/neuromodData/LightRegeneration