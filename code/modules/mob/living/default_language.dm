/mob/living
	var/datum/language/default_language

/mob/living/proc/set_default_language(datum/language/language)
	if(only_species_language && language != all_languages[species_language])
		show_splash_text(src, "can't speak", SPAN_NOTICE("You can only speak your species language, [src.species_language]."))
		return FALSE

	if(isnull(language))
		show_splash_text(src, "now speaking in native", SPAN_NOTICE("You will now speak whatever your standard default language is if you do not specify one when speaking."))
	else if(language == all_languages[species_language])
		show_splash_text(src, "now speaking [language]", SPAN_NOTICE("You will now speak your standard default language, [language], if you do not specify a language when speaking."))
	else
		if(language && !can_speak(language))
			return

		show_splash_text(src, "now speaking [language]", SPAN_NOTICE("You will now speak [language] if you do not specify a language when speaking."))

	default_language = language

/mob/living/verb/check_default_language()
	set name = "Check Default Language"
	set category = "IC"

	if(default_language)
		to_chat(src, SPAN_NOTICE("You are currently speaking [default_language] by default."))
	else
		to_chat(src, SPAN_NOTICE("Your current default language is your species or mob type default."))

/mob/living/proc/visible_emote(act_desc)
	visible_message("<B>[src]</B> [act_desc]")

/mob/living/proc/audible_emote(act_desc)
	audible_message("<B>[src]</B> [act_desc]")
