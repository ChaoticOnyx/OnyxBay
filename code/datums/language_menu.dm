/datum/language_menu
	var/mob/living/owner

/datum/language_menu/New(mob/owner)
	if(!istype(owner))
		qdel_self()

	src.owner = owner

/datum/language_menu/Destroy(force)
	owner = null
	return ..()

/datum/language_menu/tgui_state(mob/user)
	return GLOB.language_menu_state

/datum/language_menu/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LanguageMenu")
		ui.open()

/datum/language_menu/tgui_data(mob/user)
	var/list/data = list()

	var/admin = check_rights(R_ADMIN, FALSE, user)

	data["isAdmin"] = admin
	data["isSilicon"] = issilicon(owner)

	data["languagePrefix"] = owner.get_language_prefix()
	data["currentLanguage"] = owner.default_language?.name

	data["languages"] = list()
	for(var/language_key in all_languages)
		var/datum/language/language_entry = all_languages[language_key]

		if(language_entry.language_flags & NONGLOBAL) // This one shouldn't be seen...
			continue

		var/avaliable = (language_entry in owner.languages)
		if(!avaliable && !admin)
			continue

		var/list/language_data = list(
			"key" = language_entry.key,
			"name" = language_entry.name,
			"desc" = language_entry.desc,
			"index" = language_key,
			"shorthand" = language_entry.shorthand,
			"canSpeak" = owner.can_speak(language_entry),
			"isKnown" = avaliable,
		)

		if(issilicon(owner))
			var/mob/living/silicon/silicon = owner
			language_data["isSynthesized"] = (language_entry in silicon.speech_synthesizer_langs)

		data["languages"] += list(language_data)

	return data

/datum/language_menu/tgui_act(action, params)
	. = ..()

	if(.)
		return

	switch(action)
		if("choose_language")
			var/language_key = params["value"]
			if(isnull(language_key))
				return

			var/datum/language/chosen_language = all_languages[language_key]
			if(isnull(chosen_language))
				return

			if(chosen_language.language_flags & NONGLOBAL)
				return

			if(owner.default_language == chosen_language)
				owner.set_default_language(null) // Resetting language
			else
				owner.set_default_language(chosen_language)

			return TRUE

		if("remove_language")
			if(!check_rights(R_ADMIN, FALSE, usr?.client))
				return

			var/language_key = params["value"]
			if(isnull(language_key))
				return

			owner.remove_language(language_key)
			return TRUE

		if("add_language")
			if(!check_rights(R_ADMIN, FALSE, usr?.client))
				return

			var/language_key = params["value"]
			if(isnull(language_key))
				return

			owner.add_language(language_key)
			return TRUE
