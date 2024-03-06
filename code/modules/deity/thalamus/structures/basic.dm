/obj/structure/deity/thalamus
	icon = 'icons/obj/cult.dmi'

/datum/deity_power/structure/thalamus/siphon
	name = "Nutrient syphon"
	desc = "An organ whose purpose is to extract nutrients from the air.."
	health_max = 300
	power_path = /obj/structure/deity/thalamus/nutrient_syphon
	resource_cost = list(/datum/deity_resource/thalamus/nutrients = 5)

/obj/structure/deity/thalamus/nutrient_syphon
	name = "nutrient syphon"
	desc = "Extracts vitamins and minerals straight from the air"
	icon_state = "syphon"

/datum/deity_power/structure/thalamus/articulation_organ
	name = "Articulation organ"
	desc = "A small mouth used to talk to lesser beings."
	power_path = /obj/structure/deity/thalamus/articulation_organ
	build_time = 30
	resource_cost = list(/datum/deity_resource/thalamus/nutrients = 10)

/obj/structure/deity/thalamus/articulation_organ
	name = "articulation organ"
	desc = "A organic facsimile to a mouth without teeth."
	icon_state = "mouth"

/datum/deity_power/structure/thalamus/nerve_cluster
	name = "Nerve Cluster"
	desc = "A mass of twitching nerves used to grow your organs faster"
	power_path = /obj/structure/deity/thalamus/nerve_cluster
	build_time = 30
	resource_cost = list(/datum/deity_resource/thalamus/nutrients = 20)

/obj/structure/deity/thalamus/nerve_cluster
	name = "nerve cluster"
	desc = "A cluster of nerve endings sprouting from the floor"
	icon_state = "nerves"

/datum/deity_power/structure/thalamus/sight_organ
	desc = "An eye to see the world, inside and out."
	power_path = /obj/structure/deity/thalamus/sight_organ
	build_time = 10
	resource_cost = list(/datum/deity_resource/thalamus/nutrients = 5)

/obj/structure/deity/thalamus/sight_organ
	name = "sight organ"
	desc = "An eye on a stalk... it seems to look about the room."
	icon_state = "eye"

/datum/deity_power/structure/thalamus/wall
	name = "Wall"
	desc = "A maw to let things in or keep them out"
	power_path = /obj/structure/deity/thalamus/wall
	resource_cost = list(
		/datum/deity_resource/thalamus/nutrients = 10,
	)

/obj/structure/deity/thalamus/wall
	name = "wall"
	desc = "A neck high wall made of teeth and meat"
	icon_state = "wall"

/obj/structure/deity/thalamus/wall/activate()
	if(density)
		density = 0
		icon_state = "wall_opened"
		flick("growth_maw_open", src)
	else
		density = 1
		icon_state = "wall_closed"
		flick("growth_maw_close", src)
