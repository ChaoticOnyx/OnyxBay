/mob/living/deity
	var/page = 0

/mob/living/deity/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Deity", name)
		ui.open()

/mob/living/deity/tgui_state()
	return GLOB.tgui_always_state

/mob/living/deity/tgui_data(mob/user)
	var/list/data = list()

	data["page"] = page

	data["forms"] = list()
	for(var/datum/god_form/form in GLOB.deity_forms)
		var/icon/form_icon = new /icon("icon" = 'icons/mob/deity.dmi', "icon_state" = form.form_state)
		var/list/form_data = list(
			"name" = form.name,
			"icon" = icon2base64html(form_icon),
			"desc" = form.desc,
		)

		data["forms"] += list(form_data)

	data["user"] = list(
			"form" = form?.type,
			"name" = user.name,
		)


	if(!form)
		return data

	var/list/powers = form.buildables
	powers.Add(form.boons)
	powers.Add(form.phenomena)

	data["items"] = list()
	for(var/datum/deity_power/power in form?.buildables)
		var/list/building_data = list(
			"name" = power._get_name(),
			"icon" = icon2base64html(power._get_image()),
			"desc" = power.desc,
			"type" = power.type
		)

		data["items"] += list(building_data)

	data["evolutionItems"] = list()
	for(var/datum/evolution_category/cat in form?.evolution_categories)
		var/list/cat_data = list(
			"name" = cat.name
			//"desc" = cat.desc,
			//"icon" = cat.icon,
		)

		for(var/datum/evolution_package/pack in cat.items)
			var/list/pack_data = list(
				"name" = pack.name,
				"desc" = pack.desc,
				"icon" = pack.icon,
				"tier" = pack.tier,
				"unlocked" = pack.unlocked
			)
			cat_data["packages"] += list(pack_data)

		data["evolutionItems"] += list(cat_data)

	return data

/mob/living/deity/tgui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("change_page")
			page = params["page"]
			return TRUE

		if("choose_form")
			set_form(params["path"])
			return TRUE

		if("select_building")
			set_selected_power(text2path(params["building_type"]), form.buildables)
			return TRUE

		if("select_boon")
			set_selected_power(text2path(params["building_type"]), form.boons)
			return TRUE

		if("select_phenomenon")
			set_selected_power(text2path(params["building_type"]), form.phenomena)
			return TRUE

/mob/living/deity/verb/choose_form()
	set name = "Choose Form"
	set category = "Godhood"

	tgui_interact(src)

/mob/living/deity/proc/open_building_menu()
	tgui_interact(src)
