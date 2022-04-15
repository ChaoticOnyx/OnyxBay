/client/verb/settings()
	set category = "OOC"
	set name = "Settings"

	settings.tgui_interact(mob)

/datum/player_settings
	var/client/owner

/datum/player_settings/New(client/owner)
	src.owner = owner

/datum/player_settings/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "PlayerSettings", "Settings")
		ui.open()

/datum/player_settings/tgui_data(mob/user)
	var/list/data = list(
		"preferences" = list(),
		"themes" = list()
	)

	for(var/datum/client_preference/client_pref in get_client_preferences())
		if(!client_pref.may_set(owner))
			continue

		var/selected_option = owner.get_preference_value(client_pref.key)
		var/list/preferences_data = list(
			"description" = client_pref.description,
			"key" = client_pref.key,
			"category" = client_pref.category,
			"options" = client_pref.get_options(owner),
			"selectedOption" = selected_option
		)

		data["preferences"] += list(preferences_data)

	for(var/style in all_ui_styles)
		data["themes"] += list(list(
			"name" = style,
			"selected" = owner.prefs.UI_style == style
		))

	return data

/datum/player_settings/tgui_act(action, params)
	. = ..()

	if(.)
		return

	switch(action)
		if("set_preference")
			var/key = params["key"]
			var/value = params["value"]

			if(key && value)
				owner.set_preference(key, value)
				tgui_update()

			return TRUE
		if("set_ui")
			var/style = params["style"]
			var/color = params["color"]
			var/alpha = params["alpha"]

			if(style && color && alpha)
				owner.prefs.UI_style = style
				owner.prefs.UI_style_alpha = alpha
				owner.prefs.UI_style_color = color
				owner.update_ui()
				SScharacter_setup.queue_preferences_save(owner.prefs)
				tgui_update()

			return TRUE

/datum/player_settings/tgui_state(mob/user)
	return GLOB.tgui_always_state
