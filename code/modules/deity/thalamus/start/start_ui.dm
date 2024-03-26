/datum/deity_form/thalamus/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ThalamusStart", "Start Menu")
		ui.open()

/datum/deity_form/thalamus/tgui_data(mob/user)
	var/list/data = list(
		points = 200
	)

	for(var/datum/thalamus_start/spawn_loc/option in spawn_options)
		var/list/spawn_loc = list(
			"name" = option.name,
			"tooltip" = option.tooltip,
			"price" = option.price,
			"type" = option.type,
			"selected" = option.selected
		)

		if(option.selected)
			data["points"] -= option.price

		data["spawnLocs"] += list(spawn_loc)

	for(var/datum/thalamus_start/spawn_opt/option in spawn_options)
		var/list/spawn_opt = list(
			"name" = option.name,
			"tooltip" = option.tooltip,
			"price" = option.price,
			"type" = option.type,
			"selected" = option.selected
		)

		if(option.selected)
			data["points"] -= option.price

		data["spawnOptions"] += list(spawn_opt)

	return data

/datum/deity_form/thalamus/tgui_state()
	return GLOB.tgui_always_state

/datum/deity_form/thalamus/tgui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("chooseOption")
			var/datum/thalamus_start/selected_option
			for(var/datum/thalamus_start/option in spawn_options)
				if(option.type != text2path(params["option"]))
					continue

				selected_option = option
				break

			selected_option.selected = !selected_option.selected

			if(istype(selected_option, /datum/thalamus_start/spawn_loc))
				for(var/datum/thalamus_start/spawn_loc/spawn_loc in spawn_options)
					if(spawn_loc != selected_option)
						spawn_loc.selected = FALSE

			return TRUE

		if("deploy")
			for(var/datum/thalamus_start/spawn_loc/spawn_loc in spawn_options)
				if(!spawn_loc.selected)
					continue

				spawn_loc.deploy(deity)

			return TRUE
