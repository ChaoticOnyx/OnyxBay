GLOBAL_LIST_EMPTY(cwj_catalog_entries)
GLOBAL_LIST_EMPTY(cwj_catalog_entries_by_type)
GLOBAL_LIST_EMPTY(cwj_catalog_icons)

/proc/createCookingCatalogs()
	GLOB.cwj_catalog_entries = list()
	GLOB.cwj_catalog_entries_by_type = list()
	for(var/datum/cooking_with_jane/recipe/our_recipe in GLOB.cwj_recipe_list)
		if(our_recipe.appear_in_default_catalog && !(our_recipe.type in GLOB.cwj_catalog_entries_by_type))
			var/datum/catalog_entry/cooking/entry = new /datum/catalog_entry/cooking(our_recipe)
			GLOB.cwj_catalog_entries.Add(entry)
			GLOB.cwj_catalog_entries_by_type[our_recipe.type] = entry

/datum/computer_file/program/cook_catalog
	filename = "cook_catalog"
	filedesc = "Cooking Assistant"
	extended_desc = "Papa Louie's Cooking Assistant - an electronic catalog for cooking recipes."
	program_icon_state = "generic"
	program_key_state = "generic_key"
	size = 2
	available_on_ntnet = 1
	requires_ntnet = 0
	nanomodule_path = /datum/nano_module/program/cook_catalog
	usage_flags = PROGRAM_ALL

/datum/nano_module/program/cook_catalog
	name = "Papa Louie's Cooking Assistant"
	var/catalog_browse_stage = null
	var/catalog_search = ""
	var/datum/catalog_entry/cooking/selected_entry = null

/datum/nano_module/program/cook_catalog/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, datum/topic_state/state = GLOB.default_state)
	var/list/data = list()
	if(program)
		data = program.get_header_data()
	if(user.client && length(GLOB.cwj_catalog_icons))
		send_asset_list(user.client, GLOB.cwj_catalog_icons)
	data["catalog_browse_stage"] = catalog_browse_stage
	data["catalog_search"] = catalog_search ? catalog_search : "Search"
	if(catalog_browse_stage == "list")
		var/list/entries_data = list()
		for(var/datum/catalog_entry/cooking/E in GLOB.cwj_catalog_entries)
			if(!catalog_search || E.search_value(catalog_search))
				entries_data.Add(list(E.catalog_ui_data(user, ui_key)))
		data["entries"] = entries_data
	else if(catalog_browse_stage == "entry" && selected_entry)
		data += selected_entry.nano_ui_data(user, ui_key)
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "cooking_catalog.tmpl", name, 640, 700, state = state)
		ui.set_initial_data(data)
		ui.auto_update_layout = 1
		ui.open()

/datum/nano_module/program/cook_catalog/Topic(href, href_list)
	if(..())
		return 1
	if(href_list["greet"])
		catalog_browse_stage = "list"
		selected_entry = null
		return 1
	if(href_list["set_active_entry"])
		var/ID = text2path(href_list["set_active_entry"])
		var/datum/catalog_entry/cooking/E = GLOB.cwj_catalog_entries_by_type[ID]
		if(E)
			selected_entry = E
			catalog_browse_stage = "entry"
		return 1
	if(href_list["go_back_entry"])
		selected_entry = null
		catalog_browse_stage = "list"
		return 1
	if(href_list["catalog_search_run"])
		var/new_search = sanitize(input(usr, "Enter the value to search for.") as null|text)
		catalog_search = new_search ? new_search : ""
		return 1
	if(href_list["print_active"])
		if(selected_entry)
			selected_entry.print(src, usr)
		return 1
	return 0

/datum/catalog_entry/cooking
	var/datum/cooking_with_jane/recipe/recipe
	var/title
	var/description
	var/thing_nature = "Cooking Recipe"
	var/icon_file

/datum/catalog_entry/cooking/New(datum/cooking_with_jane/recipe/our_recipe)
	if(!istype(our_recipe))
		qdel(src)
		return
	recipe = our_recipe
	title = recipe.name
	description = recipe.description
	var/icon/I = null
	if(our_recipe.product_type)
		var/obj/P = our_recipe.product_type
		icon_file = sanitizeFileName("[our_recipe.product_type].png")
		I = icon(initial(P.icon), initial(P.icon_state), SOUTH, 1)
	else if(our_recipe.reagent_id)
		var/obj/item/reagent_containers/food/dollop/test_dollop = new(null, our_recipe.reagent_id, 1)
		icon_file = sanitizeFileName("[test_dollop.type]_[our_recipe.reagent_id].png")
		I = icon(test_dollop.icon, test_dollop.icon_state, SOUTH, 1)
		if(test_dollop.color)
			I.Blend(test_dollop.color, ICON_MULTIPLY)
		qdel(test_dollop)
	if(I && icon_file)
		register_asset(icon_file, I)
		GLOB.cwj_catalog_icons |= icon_file
		our_recipe.icon_image_file = icon_file

/datum/catalog_entry/cooking/proc/search_value(value)
	if(findtext(title, value))
		return TRUE
	if(findtext(thing_nature, value))
		return TRUE
	if(recipe.product_name && findtext(recipe.product_name, value))
		return TRUE
	if(recipe.reagent_name && findtext(recipe.reagent_name, value))
		return TRUE
	return FALSE

/datum/catalog_entry/cooking/proc/print(datum/nano_module/NM, mob/user)
	var/list/d = nano_ui_data(user)
	var/t = "<h1>[d["name"]]</h1>"
	t += "<p>[d["create_in"]]</p>"
	t += "<p>[d["description"]]</p>"
	t += "<h4>Specifications:</h4>"
	if(d["product_is_reagent"])
		t += "<p><b>Reagent Name:</b> [d["product_name"]]<br><b>Units Produced:</b> [d["product_count"]]</p>"
	else
		t += "<p><b>Product Name:</b> [d["product_name"]]<br><b>Product Count:</b> [d["product_count"]]</p>"
	if(d["recipe_guide"])
		t += "<h4>Recipe:</h4><div>[d["recipe_guide"]]</div>"
	NM.print_text(t, user, d["name"])

/datum/catalog_entry/cooking/proc/catalog_ui_data(mob/user, ui_key = "main")
	var/list/data = list()
	data["name"] = recipe.name
	data["id"] = recipe.type
	data["icon"] = icon_file
	data["product_is_reagent"] = 0
	if(recipe.product_name)
		data["product_name"] = recipe.product_name
		data["product_count"] = recipe.product_count
		if(recipe.reagent_name)
			data["byproduct_name"] = recipe.reagent_name
			data["byproduct_count"] = recipe.reagent_amount
		else
			data["byproduct_name"] = "None"
			data["byproduct_count"] = 0
	else if(recipe.reagent_name)
		data["product_name"] = recipe.reagent_name
		data["product_count"] = recipe.reagent_amount
		data["byproduct_name"] = "None"
		data["byproduct_count"] = 0
		data["product_is_reagent"] = 1
	else
		data["product_name"] = "ERROR"
		data["product_count"] = 0
		data["byproduct_name"] = "None"
		data["byproduct_count"] = 0
	return data

/datum/catalog_entry/cooking/proc/nano_ui_data(mob/user, ui_key = "main")
	var/list/data = catalog_ui_data(user, ui_key)
	data["print_avaliable"] = 1
	data["description"] = recipe.description
	data["recipe_guide"] = recipe.recipe_guide
	switch(recipe.cooking_container)
		if(PLATE)
			data["create_in"] = "Made with a debug-only serving plate."
		if(CUTTING_BOARD)
			data["create_in"] = "Made on a cutting board."
		if(PAN)
			data["create_in"] = "Made with a pan or skillet."
		if(POT)
			data["create_in"] = "Made in a cooking pot."
		if(BOWL)
			data["create_in"] = "Made in a prep bowl."
		if(DF_BASKET)
			data["create_in"] = "Made in a deep frying basket."
		if(AF_BASKET)
			data["create_in"] = "Made in an air frying basket."
		if(OVEN)
			data["create_in"] = "Made with an oven dish."
		if(GRILL)
			data["create_in"] = "Made on a grill grate."
		else
			data["create_in"] = "Made in a cooking container."
	return data
