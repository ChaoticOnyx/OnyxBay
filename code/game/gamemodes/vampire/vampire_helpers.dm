// Make a vampire, add initial powers.
/mob/proc/make_vampire()
	if(!ishuman(src))
		log_debug("Trying to make a nonhuman mob [name] / [real_name] ([key]) a vampire! Aborting.")
		return
	if(!mind)
		return

	var/mob/living/carbon/human/H = src
	if(!mind.vampire)
		mind.vampire = new /datum/vampire(H)
	// No powers to thralls. Ew.
	else if(mind.vampire.vamp_status & VAMP_ISTHRALL)
		return

	verbs += /datum/game_mode/vampire/verb/vampire_help
	mind.vampire.set_up_organs()
	mind.vampire.update_powers(FALSE)

	return TRUE

/mob/proc/unmake_vampire(keep_vampire_datum = FALSE)
	if(!ishuman(src))
		return
	var/mob/living/carbon/human/H = src

	if(mind?.vampire)
		if(mind.vampire.vamp_status & VAMP_FRENZIED)
			mind.vampire.stop_frenzy(TRUE)
		mind.vampire.unset_organs()
		mind.vampire.remove_powers()
		if(!keep_vampire_datum)
			qdel(mind.vampire)
		mind.vampire = null
	else // doing it the hard way, hopefully will never happen in practice
		H.does_not_breathe = 0
		H.restore_blood()
		H.status_flags &= ~UNDEAD
		H.remove_modifiers_of_type(/datum/modifier/trait/low_metabolism, TRUE)
		H.innate_heal = 1

		var/obj/item/organ/internal/heart/O = H.internal_organs_by_name[BP_HEART]
		if(O)
			O.max_damage = initial(O.max_damage)
			O.damage = min(O.damage, O.max_damage)
			O.min_bruised_damage = initial(O.min_bruised_damage)
			O.min_broken_damage = initial(O.min_bruised_damage)
			O.vital = initial(O.vital)
			O.pulse = PULSE_NORM
			O.think()

	verbs -= /datum/game_mode/vampire/verb/vampire_help

	return TRUE


// Make a vampire thrall
/mob/proc/make_vampire_thrall()
	if(!ishuman(src))
		log_debug("Trying to make a nonhuman mob [name] / [real_name] ([key]) a vampire thrall! Aborting.")
		return
	if(!mind)
		return

	var/datum/vampire/thrall/thrall = new()
	mind.vampire = thrall


/datum/vampire/proc/vampire_dominate_handler(ability = "suggestion")
	. = FALSE

	var/list/victims = list()
	for(var/mob/living/carbon/human/H in view(7, my_mob))
		if(my_mob == H)
			continue
		victims += H

	if(!victims.len)
		to_chat(my_mob, SPAN("warning", "No suitable targets."))
		return

	var/mob/living/carbon/human/T = input(my_mob, "Select Victim") as null|mob in victims

	if(!can_affect(T, TRUE, TRUE))
		return

	if(!(vamp_status & VAMP_FULLPOWER))
		to_chat(my_mob, SPAN("notice", "You begin peering into [T]'s mind, looking for a way to gain control."))

		if(!do_mob(my_mob, T, 50, incapacitation_flags = INCAPACITATION_DISABLED))
			to_chat(my_mob, SPAN("warning", "Your concentration is broken!"))
			return

		to_chat(my_mob, SPAN("notice", "You succeed in dominating [T]'s mind. They are yours to command."))
	else
		to_chat(my_mob, SPAN("notice", "You instantly dominate [T]'s mind, forcing them to obey your command."))

	var/command
	if(ability == "suggestion")
		command = input(my_mob, "Command your victim.", "Your command.") as text|null
	else if(ability == "order")
		command = input(my_mob, "Command your victim with single word.", "Your command.") as text|null

	if(!command)
		to_chat(my_mob, SPAN("alert", "Cancelled."))
		return

	if(ability == "suggestion")
		command = sanitizeSafe(command, extra = 0)
	else if(ability == "order")
		command = sanitizeSafe(command)
		var/spaceposition = findtext_char(command, " ")
		if(spaceposition)
			command = copytext_char(command, 1, spaceposition + 1)

	my_mob.say(command)

	if(T.is_deaf() || !T.say_understands(my_mob, my_mob.get_default_language()))
		to_chat(my_mob, SPAN("warning", "Target does not understand you!"))
		return

	admin_attack_log(my_mob, T, "used dominate on [key_name(T)]", "was dominated by [key_name(my_mob)]", "used dominate and issued the command of '[command]' to")

	show_browser(T, "<HTML><meta charset=\"utf-8\"><center>You feel a strong presence enter your mind. For a moment, you hear nothing but what it says, <b>and are compelled to follow its direction without question or hesitation:</b><br>[command]</center></BODY></HTML>", "window=vampiredominate")
	to_chat(T, SPAN("notice", "You feel a strong presence enter your mind. For a moment, you hear nothing but what it says, and are compelled to follow its direction without question or hesitation:"))
	to_chat(T, "<span style='color: green;'><i><em>[command]</em></i></span>")
	to_chat(my_mob, SPAN("notice", "You command [T], and they will obey."))

	return TRUE
