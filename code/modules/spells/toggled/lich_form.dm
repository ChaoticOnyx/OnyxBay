/datum/spell/toggled/lich_form
	name = "Lich form"
	desc = "Reveal your true form"
	feedback = "LF"
	school = "necromancy"
	spell_flags = INCLUDEUSER
	invocation = "none"
	invocation_type = SPI_NONE
	need_target = FALSE
	icon_state = "undead_lichform"

/datum/spell/toggled/lich_form/activate()
	. = ..()
	if(!.)
		return

	var/mob/living/carbon/human/H = holder

	H.add_mutation(MUTATION_SKELETON)
	H.add_mutation(MUTATION_CLUMSY)
	for(var/obj/item/organ/external/head/h in H.organs)
		h.status |= ORGAN_DISFIGURED
	H.update_body(TRUE)
	return

/datum/spell/toggled/lich_form/deactivate(no_message = TRUE)
	. = ..()
	if(!.)
		return

	var/mob/living/carbon/human/H = holder

	H.remove_mutation(MUTATION_SKELETON)
	for(var/obj/item/organ/external/head/h in H.organs)
		h.status ^= ORGAN_DISFIGURED
	H.update_body(TRUE)
	return
