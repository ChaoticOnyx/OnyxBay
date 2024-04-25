/datum/deity_form/thalamus
	name = "Thalamus"
	desc = "The fuck am i doing?"
	form_state = "thalamus"

	buildables = list(
		/datum/deity_power/structure/thalamus/siphon,
		/datum/deity_power/structure/thalamus/articulation_organ,
		/datum/deity_power/structure/thalamus/nerve_cluster,
		/datum/deity_power/structure/thalamus/sight_organ,
		/datum/deity_power/structure/thalamus/door,
		/datum/deity_power/structure/thalamus/converter,
		/datum/deity_power/structure/thalamus/tendril,
		/datum/deity_power/structure/thalamus/trap,
	)
	phenomena = list(/datum/deity_power/phenomena/release_lymphocytes)
	boons = list()
	resources = list(
		/datum/deity_resource/thalamus/nutrients = 200,
		/datum/deity_resource/thalamus/special = 10
	)
	evo_holder = /datum/evolution_holder/thalamus

	var/list/spawn_options = list()
	var/spawn_points = 200

/datum/deity_form/thalamus/setup_form(mob/living/deity/D)
	. = ..()

	for(var/path in subtypesof(/datum/thalamus_start/spawn_loc))
		spawn_options += new path()

	for(var/path in subtypesof(/datum/thalamus_start/spawn_opt))
		spawn_options += new path()

/datum/deity_form/thalamus/proc/spawn_options_data(mob/user)
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

/datum/deity_form/thalamus/proc/tgui_spawn_act(action, list/params)
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

/datum/evolution_holder/thalamus
	evolution_categories = list(
		/datum/evolution_category/thalamus/defense,
		/datum/evolution_category/thalamus/conversion
	)
