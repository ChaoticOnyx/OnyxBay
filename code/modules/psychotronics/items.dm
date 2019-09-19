/obj/item/LifeformScanDisk
	name = "lifeform scan disk"
	desc = "Contains all about lifeform. Insert in a destructor and get a new technologies."
	icon = 'icons/obj/psychotronics.dmi'
	icon_state = "lifeformscandisk"
	item_state = "card-id"
	w_class = ITEM_SIZE_SMALL
	origin_tech = null

/obj/item/NeuromodDataDisk
	name = "neuromod data disk"
	desc = "Contains neuro data for production neuromods."
	icon = 'icons/obj/psychotronics.dmi'
	icon_state = "lifeformscandisk"
	item_state = "card-id"
	w_class = ITEM_SIZE_SMALL
	origin_tech = null

	var
		datum/NeuromodData/neuromod_data = null