/mob/living/tts
	name = "text-to-speech module"

/obj/item/mcu_module/tts
	name = "text-to-speech module"
	desc = "A text-to-speech module, may synthesize speech in many languages."
	icon_state = "tts"

	var/mob/living/tts/__speaker = null

/obj/item/mcu_module/tts/Initialize()
	. = ..()
	
	__speaker = new(src)

/obj/item/mcu_module/tts/Destroy()
	if(!QDELETED(__speaker))
		qdel(__speaker)

	. = ..()

/obj/item/mcu_module/tts/think()
	ready = TRUE

/obj/item/mcu_module/tts/__reset(attached)
	set_next_think(0)
	ready = TRUE

/obj/item/mcu_module/tts/proc/__speak_function()
	if(!ready)
		return Z_SCRIPT_FUNCTION_ERROR

	var/datum/language/language = null

	switch(args[1])
		if(TTS_LANG_GALCOM)
			language = all_languages[LANGUAGE_GALCOM]
		if(TTS_LANG_EAL)
			language = all_languages[LANGUAGE_EAL]
		if(TTS_LANG_SOL_COMMON)
			language = all_languages[LANGUAGE_SOL_COMMON]
		if(TTS_LANG_UNATHI)
			language = all_languages[LANGUAGE_UNATHI]
		if(TTS_LANG_SIIK_MAAS)
			language = all_languages[LANGUAGE_SIIK_MAAS]
		if(TTS_LANG_SKRELLIAN)
			language = all_languages[LANGUAGE_SKRELLIAN]
		if(TTS_LANG_ROOTLOCAL)
			language = all_languages[LANGUAGE_ROOTLOCAL]
		if(TTS_LANG_ROOTGLOBAL)
			language = all_languages[LANGUAGE_ROOTGLOBAL]
		if(TTS_LANG_LUNAR)
			language = all_languages[LANGUAGE_LUNAR]
		if(TTS_LANG_GUTTER)
			language = all_languages[LANGUAGE_GUTTER]
		if(TTS_LANG_INDEPENDENT)
			language = all_languages[LANGUAGE_INDEPENDENT]
		if(TTS_LANG_SPACER)
			language = all_languages[LANGUAGE_SPACER]
		if(TTS_LANG_ROBOT)
			language = all_languages[LANGUAGE_ROBOT]
		if(TTS_LANG_DRONE)
			language = all_languages[LANGUAGE_DRONE]
		else
			return Z_SCRIPT_FUNCTION_ERROR

	var/text = args[2]
	var/len = length_char(text)

	__speaker.name = name
	__speaker.say(text, language)
	ready = FALSE

	set_next_think(world.time + (len * config.mcu.tts_cooldown_per_char))

	return Z_SCRIPT_FUNCTION_OK
