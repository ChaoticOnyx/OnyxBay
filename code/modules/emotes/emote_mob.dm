/mob
	var/list/default_emotes
	var/list/current_emotes

	var/list/next_emote_use
	var/list/next_audio_emote_produce

/mob/Initialize(mapload)
	. = ..()
	load_default_emotes()

/mob/proc/load_default_emotes()
	if(!islist(default_emotes))
		return

	default_emotes = sortAssoc(default_emotes)
	for(var/path in default_emotes)
		var/datum/emote/E = GLOB.all_emotes[path]
		set_emote(E.key, E)
		if(!isnull(E.statpanel_proc))
			grant_verb(src, E.statpanel_proc)

	default_emotes = null

/mob/living/carbon/load_default_emotes()
	if(species)
		default_emotes += species.default_emotes

	return ..()

/mob/proc/clear_emotes()
	for(var/datum/emote/E in GLOB.all_emotes)
		clear_emote(E.key)
		if(!isnull(E.statpanel_proc))
			revoke_verb(src, E.statpanel_proc)

/mob/proc/get_emote(key)
	return LAZYACCESS(current_emotes, key)

/mob/proc/set_emote(key, datum/emote/emote)
	LAZYSET(current_emotes, key, emote)

/mob/proc/clear_emote(key)
	LAZYREMOVE(current_emotes, key)

/mob/proc/emote(act, intentional = FALSE, target)
	var/splitpoint = findtext_char(act, " ")
	if(splitpoint < 0)
		return

	var/tempstr = act
	act = copytext_char(tempstr, 1, splitpoint)
	var/message = copytext_char(tempstr, splitpoint + 1, 0)

	var/datum/emote/emote = get_emote(act)
	if(!emote)
		return

	if(!emote.can_emote(src, intentional, target))
		return

	emote.do_emote(src, act, intentional, target, message)

/mob/proc/add_synth_emotes()
	for(var/path in subtypesof(/datum/emote/synth))
		var/datum/emote/E = GLOB.all_emotes[path]
		set_emote(E.key, E)
		if(!isnull(E.statpanel_proc))
			grant_verb(src, E.statpanel_proc)

/// A simple emote - just the message, and it's type. For anything more complex use datumized emotes.
/mob/proc/custom_emote(message_type = VISIBLE_MESSAGE, message, intentional = FALSE)
	log_emote("[key_name(src)] : [message]")

	var/user_name = "<b>[src]</b>"

	var/end_char = message[length(message)]
	if(end_char != "." && end_char != "?" && end_char != "!" && end_char != "\"")
		message += "."

	if(findtext(message, "^"))
		message = "[capitalize(replacetext(message, regex(@"\^+", "g"), user_name))]"
	else
		message = "[user_name] [message]"

	if(message_type & VISIBLE_MESSAGE)
		visible_message(message, checkghosts = /datum/client_preference/staff/ghost_sight)
	else
		audible_message(message, checkghosts = /datum/client_preference/staff/ghost_sight)
