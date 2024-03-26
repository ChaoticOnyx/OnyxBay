/datum/deity_power/structure/thalamus/converter
	name = "Converter"
	desc = "An immunity building organ: turns pesky foreign agents into loyal thralls"
	power_path = /obj/structure/deity/altar/thalamus_converter
	resource_cost = list(
		/datum/deity_resource/thalamus/nutrients = 30
	)
	//building_requirements = list(/obj/structure/chorus/biter = 1)

/obj/structure/deity/altar/thalamus_converter
	name = "parasite adapter"
	desc = "An odd tentacle with a disgusting looking claw at the end"
	icon_state = "converter"
	icon = 'icons/obj/thalamus.dmi'
