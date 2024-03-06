/datum/god_form/thalamus
	name = "Thalamus"
	desc = "The fuck am i doing?"
	form_state = "thalamus"

	buildables = list(/datum/deity_power/structure/devil_teleport)

	phenomena = list(/datum/deity_power/phenomena/conversion)

	boons = list()

	resources = list(/datum/deity_resource/souls)

	evolution_packages = list(
		/datum/evolution_package/thalamus/basic,
		/datum/evolution_package/thalamus/basic_defense,
		/datum/evolution_package/thalamus/basic_convert
	)

/datum/god_form/thalamus/setup_form(mob/living/deity/D)
	. = ..()

/datum/random_map/droppod/thalamus
