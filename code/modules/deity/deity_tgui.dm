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
		var/static/icon/form_icon = new /icon('icons/mob/deity.dmi', "neomorph")
		var/list/form_data = list(
			"name" = form.name,
			"icon" = icon2base64html(form_icon),
			"desc" = form.desc,
		)

		data["forms"] += list(form_data)

	data["user"] = list(
			"class"           = form?.type,
			"name"            = user.name,
		)


	if(!form)
		return data

	data["buildings"] = list()
	for(var/datum/deity_power/structure/struct in form?.buildables)
		//var/static/icon/building_icon = path2icon(struct.building_type_to_build)
		var/list/building_data = list(
			"name" = struct._get_name(),
			//"icon" = icon2base64html(building_icon),
			"desc" = struct.desc,
			"type" = struct.type
		)

		data["buildings"] += list(building_data)

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
