/mob/living/carbon/alien/Stat()
	. = ..()
	if(. && statpanel("Status") && adult_form)
		stat("Growth", "[round(amount_grown)]/[max_grown]")

/mob/living/carbon/alien/verb/evolve()

	set name = "Moult"
	set desc = "Moult your skin and become an adult."
	set category = "Abilities"

	if(stat != CONSCIOUS)
		return

	if(!adult_form)
		verbs -= /mob/living/carbon/alien/verb/evolve
		return

	if(handcuffed)
		to_chat(src, SPAN("warning", "You cannot evolve when you are cuffed."))
		return

	if(amount_grown < max_grown)
		to_chat(src, SPAN("warning", "You are not fully grown."))
		return

	if(istype(src.loc, /obj/machinery/atmospherics/pipe))
		to_chat(src, SPAN("warning", "You cannot evolve right here."))
		return

	// confirm_evolution() handles choices and other specific requirements.
	var/new_species = confirm_evolution()
	if(!new_species || !adult_form )
		return

	var/mob/living/carbon/adult = new adult_form(src.loc)
	adult.set_species(new_species)
	adult.faction = faction
	show_evolution_blurb()
	// TODO: drop a moulted skin. Ew.

	transfer_languages(src, adult)

	var/call_namepick = (mind && can_namepick_as_adult) ? TRUE : FALSE
	if(mind)
		mind.transfer_to(adult)
	else
		adult.key = src.key

	for(var/obj/item/I in contents)
		drop(I)

	for(var/datum/language/L in languages)
		adult.add_language(L.name)

	qdel(src)
	if(call_namepick)
		var/newname = sanitize(input(adult, "You have become an adult. Choose a name for yourself.", "Adult Name") as null|text, MAX_NAME_LEN)
		if(!newname)
			adult.fully_replace_character_name("[src.adult_name] ([instance_num])")
		else
			adult.fully_replace_character_name(newname)

/mob/living/carbon/alien/proc/update_progression()
	if(amount_grown < max_grown)
		amount_grown++
	return

/mob/living/carbon/alien/proc/confirm_evolution()
	return

/mob/living/carbon/alien/proc/show_evolution_blurb()
	return
