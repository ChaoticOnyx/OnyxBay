/datum/deity_form/thalamus
	name = "Thalamus"
	desc = "The fuck am i doing?"
	form_state = "thalamus"

	buildables = list(
		/datum/deity_power/structure/thalamus/siphon,
		/datum/deity_power/structure/thalamus/articulation_organ,
		/datum/deity_power/structure/thalamus/nerve_cluster,
		/datum/deity_power/structure/thalamus/sight_organ,
		/datum/deity_power/structure/thalamus/door,
		/datum/deity_power/structure/thalamus/converter,
		/datum/deity_power/structure/thalamus/tendril,
		/datum/deity_power/structure/thalamus/trap,
	)

	phenomena = list(/datum/deity_power/phenomena/release_lymphocytes)

	boons = list()

	resources = list(
		/datum/deity_resource/thalamus/nutrients = 200,
		/datum/deity_resource/thalamus/special = 10
	)

	evolution_categories = list(
		/datum/evolution_category/thalamus/defense,
		/datum/evolution_category/thalamus/conversion
	)

	var/list/spawn_options = list()
	var/spawn_points = 200

/datum/deity_form/thalamus/setup_form(mob/living/deity/D)
	. = ..()

	for(var/path in subtypesof(/datum/thalamus_start/spawn_loc))
		spawn_options += new path()

	for(var/path in subtypesof(/datum/thalamus_start/spawn_opt))
		spawn_options += new path()

	tgui_interact(D)
