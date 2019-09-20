/obj/item/weapon/reagent_containers/neuromod
	name = "neuromod"
	desc = "This is a neuromod."
	icon = 'icons/obj/psychotronics.dmi'
	icon_state = "neuromod"
	volume = 5
	w_class = ITEM_SIZE_TINY
	sharp = 0
	unacidable = 0

	var
		datum/neuromodData/neuromod_data = null

	proc
		ToList()
			var/list/N = list()

			N["reference"] = "\ref[src]"

			if (neuromod_data)
				N["neuromod_data"] = neuromod_data.ToList()
			else
				N["neuromod_data"] = 0

			return N

	New(loc, neuromod_data, ...)
		src.neuromod_data = neuromod_data

		..()

	Destroy()
		qdel(neuromod_data)
		neuromod_data = null

		..()

/datum/neuromodData
	var
		name = "Name"
		desc = "Description"
		chance = 0
		research_time = 100

	proc
		ToList()
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
