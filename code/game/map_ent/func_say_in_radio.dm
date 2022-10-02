/obj/map_ent/func_say_in_radio
	name = "func_say_in_radio"
	icon_state = "func_say_in_radio"

	var/ev_message
	var/ev_name
	var/ev_verb
	var/ev_channel
	var/ev_is_ai
	var/ev_language_name
	var/list/ev_speak_emote

	var/mob/living/virtual_speaker
	var/obj/item/device/radio/virtual_radio // /obj/item/device/radio/proc/autosay(message, from, channel) //BS12 EDIT

/obj/map_ent/func_say_in_radio/Initialize(...)
	. = ..()
	virtual_speaker = new(src)
	virtual_radio = new(src)

/obj/map_ent/func_say_in_radio/Destroy()
	. = ..()
	QDEL_NULL(virtual_radio)
	QDEL_NULL(virtual_speaker)

/obj/map_ent/func_say_in_radio/activate()
	// If there's no name for VM OR there's no verb for them (if it AI, it's fine)
	// OR there's no channel OR there's no message to say, THEN abort
	if(!ev_name || !(ev_verb || ev_is_ai) || !ev_channel)
		util_crash_with("Vital information for [name] is missing. Important paramateres (see in code order): [english_list(ev_message, ev_name, ev_verb, ev_channel, ev_is_ai)]")

	if(!ev_is_ai)
		// set up VM
		virtual_speaker.name = ev_name
		virtual_speaker.real_name = ev_name
		if(length(ev_speak_emote))
			virtual_speaker.speak_emote = ev_speak_emote
	var/datum/language/speaking
	if(ev_language_name && (ev_language_name in all_languages))
		speaking = all_languages[ev_language_name]
	if(!ev_verb)
		ev_verb = "states"

	virtual_radio.autosay(ev_message, ev_is_ai ? ev_name : virtual_speaker, ev_channel, ev_verb, speaking)
