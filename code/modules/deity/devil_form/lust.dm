#define SIN_LUST_BEGINNER 0
#define SIN_LUST_BLASPHEMER 3
#define SIN_LUST_SACRILEGE 6
#define SIN_LUST_ULTIMATE 10

/datum/modifier/sin/lust
	name = "Lust"

/datum/spell/hand/lust_suggestion
	name = "Suggestion"
	desc = "Dominate the mind of a victim, make them obey your will!"
	feedback = "LSS"
	school = "inferno"
	spell_flags = 0
	invocation_type = SPI_NONE
	spell_delay = 2 SECONDS
	icon_state = "devil_sugg"
	override_base = "const"
	charge_max = 2 MINUTES

/datum/spell/hand/lust_suggestion/cast_hand(atom/A, mob/user)
	var/mob/living/target = A
	if(!istype(target))
		return

	if(target == user)
		to_chat(user, SPAN_DANGER("You tried to dominate yourself, are you daft?!"))
		return

	var/command
	command = input(user, "Command your victim.", "Your command.") as text|null

	command = sanitizeSafe(command, extra = 0)

	user.say(command)

	show_browser(target, "<HTML><meta charset=\"utf-8\"><center>You feel a strong presence enter your mind. For a moment, you hear nothing but what it says, <b>and are compelled to follow its direction without question or hesitation:</b><br>[command]</center></BODY></HTML>", "window=vampiredominate")
	to_chat(target, SPAN("notice", "You feel a strong presence enter your mind. For a moment, you hear nothing but what it says, and are compelled to follow its direction without question or hesitation:"))
	to_chat(target, "<span style='color: green;'><i><em>[command]</em></i></span>")
	to_chat(user, SPAN("notice", "You command [target], and they will obey."))

/datum/spell/hand/lust_suggestion/after_spell(list/targets, mob/user, channel_duration)
	var/datum/godcultist/sinmind = user.mind?.godcultist
	if(!istype(sinmind))
		return

	sinmind.add_points(1)
