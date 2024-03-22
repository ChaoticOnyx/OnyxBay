/datum/language_menu
	var/mob/living/owner

/datum/language_menu/New(mob/owner)
	if(istype(owner))
		src.owner = owner
	else
		qdel_self()

	return ..()

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
	var/list/data = list(
		"defaultLanguage" = owner.default_language?.name,
		"adminMode" = check_rights(R_ADMIN, FALSE, user.client),
		"languages" = list(),
		"isSilicon" = issilicon(owner)
	)


	for(var/datum/language/L in owner.languages)
		var/list/lang_data = list(
			"name" = L.name,
			"shorthand" = L.shorthand,
			"prefix" = owner.get_language_prefix(),
			"key" = L.key,
			"desc" = L.desc,
			"can_speak" = owner.can_speak(L)
		)
		if(issilicon(owner))
			var/mob/living/silicon/silicon = owner
			lang_data["synthesizer"] = (L in silicon.speech_synthesizer_langs)

		data["languages"] += list(lang_data)

	return data

/datum/language_menu/tgui_act(action, params)
	. = ..()

	if(.)
		return

	switch(action)
		if("choose_language")
			var/datum/language/new_lang
			for(var/datum/language/L in owner.languages)
				if(L.name != params["language"])
					continue

				new_lang = L

			if(new_lang.language_flags & NONGLOBAL)
				return

			if(!owner.can_speak(new_lang))
				return

			if(owner.default_language == new_lang)
				owner.set_default_language(null) // Resetting language
			else
				owner.set_default_language(new_lang)
			return TRUE

		if("remove_language")
			if(!check_rights(R_ADMIN, FALSE, usr?.client))
				return

			owner.remove_language(params["language"])
			return TRUE
