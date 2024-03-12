
/datum/spell/toggled/hamstring_magic
	name = "Hamstring Magic"
	desc = "You push your hamstrings to the limit."
	feedback = "HM"

	spell_flags = INCLUDEUSER
	invocation = "SEMIMEMBRANOSUS! SEMITENDINOSUS! BICEPS FEMORIS!"
	invocation_type = SPI_SHOUT
	need_target = FALSE

	icon_state = "wiz_hamstring"

/datum/spell/toggled/hamstring_magic/activate()
	. = ..()
	if(!.)
		return

	var/mob/living/carbon/human/H = holder
	H.add_movespeed_modifier(/datum/movespeed_modifier/hamstring_magic)
	invocation_type = SPI_NONE
	return

/datum/spell/toggled/hamstring_magic/deactivate(no_message = TRUE)
	. = ..()
	if(!.)
		return

	var/mob/living/carbon/human/H = holder
	H.remove_movespeed_modifier(/datum/movespeed_modifier/hamstring_magic)
	invocation_type = SPI_SHOUT
	return

/datum/spell/toggled/immaterial_form/think()
	if(toggled)
		var/mob/living/carbon/human/H = holder
		H.remove_nutrition(3)

	return ..()
