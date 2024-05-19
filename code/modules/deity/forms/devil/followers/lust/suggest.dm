
/datum/action/cooldown/spell/suggest
	name = "Sleight of Hand"
	desc = "Steal a random item from the victim's backpack."
	button_icon_state = "devil_suggest"
	click_to_activate = TRUE
	cooldown_time = 30 SECONDS
	spell_max_level = 2
	cast_range = 3
	var/spell_command

/datum/action/cooldown/spell/suggest/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)

/datum/action/cooldown/spell/suggest/before_cast(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE

	var/command
	if(spell_level == 1)
		command = tgui_input_text(owner, "Command your victim with a single word.", "Your command")
		command = sanitizeSafe(command)
		var/spaceposition = findtext_char(command, " ")
		if(spaceposition)
			command = copytext_char(command, 1, spaceposition + 1)
	else if(spell_level == 2)
		command = tgui_input_text(owner, "Command your victim.", "Your command")

	if(!command)
		cast_on.show_splash_text(owner, "cancelled!", "Spell [src] was cancelled!")
		return FALSE

	spell_command = command

	return TRUE

/datum/action/cooldown/spell/suggest/cast(mob/living/carbon/human/cast_on)
	owner.say(spell_command)

	if(cast_on.is_deaf() || !cast_on.say_understands(owner, owner.get_default_language()))
		cast_on.show_splash_text(owner, "can't understand!", SPAN_WARNING("Target does not understand you!"))
		return

	tgui_alert(cast_on, "You feel a strong presence enter your mind, silencing your thoughts and compelling to act without hesitation: [spell_command]!", "Dominated!")
	to_chat(cast_on, SPAN_DANGER("You feel a strong presence enter your mind, silencing your thoughts and compelling to act without hesitation: [spell_command]!"))
	to_chat(owner, SPAN_DANGER("You command [cast_on], and they will obey."))
