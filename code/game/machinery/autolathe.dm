/obj/machinery/autolathe
	name = "autolathe"
	desc = "It produces items using metal and glass."
	icon_state = "autolathe"
	layer = BELOW_OBJ_LAYER
	density = 1
	anchored = 1
	idle_power_usage = 10
	active_power_usage = 2000
	clicksound = 'sound/effects/using/console/press2.ogg'
	clickvol = 30

	var/list/machine_recipes
	var/list/stored_material =  list(MATERIAL_STEEL = 0, MATERIAL_GLASS = 0)
	var/list/storage_capacity = list(MATERIAL_STEEL = 0, MATERIAL_GLASS = 0)
	var/show_category = "All"

	var/hacked = 0
	var/disabled = 0
	var/shocked = 0
	var/busy = 0

	var/mat_efficiency = 1
	var/build_time = 50

	var/datum/wires/autolathe/wires = null

	component_types = list(
		/obj/item/circuitboard/autolathe,
		/obj/item/stock_parts/matter_bin = 3,
		/obj/item/stock_parts/manipulator,
		/obj/item/stock_parts/console_screen
	)

/obj/machinery/autolathe/Initialize()
	. = ..()
	wires = new(src)

/obj/machinery/autolathe/Destroy()
	qdel(wires)
	wires = null
	return ..()

/obj/machinery/autolathe/proc/update_recipe_list()
	if(!machine_recipes)
		machine_recipes = autolathe_recipes

/obj/machinery/autolathe/tgui_data(mob/user)
	update_recipe_list()

	var/list/data = list(
		"storage" = list(),
		"category" = list(
			"selected" = show_category,
			"total" = autolathe_categories + "All"
		),
		"recipes" = list()
	)

	for(var/material in stored_material)
		data["storage"] += list(list(
			"name" = material,
			"count" = stored_material[material],
			"capacity" = storage_capacity[material],
			"icon" = icon2base64html(get_icon_for_material(material))
			))

	var/index = 0
	for(var/datum/autolathe/recipe/R in machine_recipes)
		index++

		if(R.hidden && !hacked || (show_category != "All" && show_category != R.category))
			continue

		var/list/recipe_data = list(
			"name" = R.name,
			"index" = index,
			"can_make" = TRUE,
			"category" = R.category,
			"hidden" = R.hidden == null ? FALSE : TRUE,
			"required" = list(),
			"icon" = icon2base64html(R.path),
			"multipliers" = list()
		)

		var/max_sheets = 0

		if(!R.resources || !R.resources.len)
			continue

		for(var/material in R.resources)
			var/sheets = round(stored_material[material] / round(R.resources[material] * mat_efficiency))

			if(!max_sheets || max_sheets > sheets)
				max_sheets = sheets
			if(!isnull(stored_material[material]) && stored_material[material] < round(R.resources[material] * mat_efficiency))
				recipe_data["can_make"] = FALSE

			recipe_data["required"] += list(list(
				"name" = material,
				"count" = round(R.resources[material] * mat_efficiency)
			))

			// Build list of multipliers for sheets.
			if(R.is_stack)
				var/obj/item/stack/R_stack = R.path
				max_sheets = min(max_sheets, initial(R_stack.max_amount))
				// do not allow lathe to print more sheets than the max amount that can fit in one stack
				if(max_sheets && max_sheets > 0)
					for(var/i = 5; i < max_sheets; i *= 2) //5, 10, 20, 40...
						recipe_data["multipliers"] += i

					recipe_data["multipliers"] += max_sheets

		data["recipes"] += list(recipe_data)

	return data

/obj/machinery/autolathe/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "Autolathe", "Autolathe Control Panel")
		ui.open()

/obj/machinery/autolathe/attackby(obj/item/O, mob/user)
	if(busy)
		to_chat(user, SPAN("notice", "\The [src] is busy. Please wait for completion of previous operation."))
		return

	if(default_deconstruction_screwdriver(user, O))
		updateUsrDialog()
		return
	if(default_deconstruction_crowbar(user, O))
		return
	if(default_part_replacement(user, O))
		return

	if(stat)
		return

	if(panel_open)
		// Don't eat multitools or wirecutters used on an open lathe.
		if(isMultitool(O) || isWirecutter(O))
			attack_hand(user)
			return

	if(O.loc != user && !(istype(O,/obj/item/stack)))
		return 0

	if(is_robot_module(O))
		return 0

	//Resources are being loaded.
	var/obj/item/eating = O
	if(!issilicon(user) && !user.canUnEquip(eating))
		to_chat(user, "You can't place that item inside \the [src].")
		return
	if(!eating.matter)
		to_chat(user, "\The [eating] does not contain significant amounts of useful materials and cannot be accepted.")
		return
	if(!istype(eating, /obj/item/stack))
		user.unEquip(eating, target = loc)
		if(eating.loc != loc)
			return

	var/filltype = 0       // Used to determine message.
	var/total_used = 0     // Amount of material used.
	var/mass_per_sheet = 0 // Amount of material constituting one sheet.

	for(var/material in eating.matter)

		if(isnull(stored_material[material]) || isnull(storage_capacity[material]))
			continue

		if(stored_material[material] >= storage_capacity[material])
			continue

		var/total_material = eating.matter[material]

		//If it's a stack, we eat multiple sheets.
		if(istype(eating,/obj/item/stack))
			var/obj/item/stack/stack = eating
			total_material *= stack.get_amount()

		if(stored_material[material] + total_material > storage_capacity[material])
			total_material = storage_capacity[material] - stored_material[material]
			filltype = 1
		else
			filltype = 2

		stored_material[material] += total_material
		total_used += total_material
		mass_per_sheet += eating.matter[material]

	if(!filltype)
		to_chat(user, SPAN("notice", "\The [src] is full. Please remove material from the autolathe in order to insert more."))
		return
	else if(filltype == 1)
		to_chat(user, "You fill \the [src] to capacity with \the [eating].")
	else
		to_chat(user, "You fill \the [src] with \the [eating].")

	if(eating.matter.Find("steel"))
		if(panel_open)
			flick("autolathe_o_t", src)
		else
			flick("autolathe_o", src) // Plays metal insertion animation. Work out a good way to work out a fitting animation. ~Z
	else if(eating.matter.Find("glass"))
		if(panel_open)
			flick("autolathe_r_t", src)
		else
			flick("autolathe_r", src)

	if(istype(eating,/obj/item/stack))
		var/obj/item/stack/stack = eating
		stack.use(max(1, round(total_used/mass_per_sheet))) // Always use at least 1 to prevent infinite materials.
	else
		qdel(O)

	updateUsrDialog()
	return

/obj/machinery/autolathe/attack_hand(mob/user)
	if(..())
		return TRUE

	if(disabled && !panel_open)
		to_chat(user, SPAN("danger", "\The [src] is disabled!"))
		return TRUE

	if(shocked)
		shock(user, 50)

	if(panel_open)
		var/datum/browser/hack_panel = new(user, "hack_panel", "Maintenance Panel", 400, 400)
		hack_panel.set_content(wires.GetInteractWindow())
		hack_panel.open()

	tgui_interact(user)

/obj/machinery/autolathe/tgui_act(action, params)
	. = ..()

	if(.)
		return

	switch(action)
		if("change_category")
			var/choice = params["category"]
			if(!choice || !(choice in autolathe_categories + "All"))
				return TRUE
			show_category = choice
			tgui_update()
			return TRUE
		if("make")
			if(!machine_recipes)
				return TRUE

			var/index = text2num(params["make"])
			var/multiplier = text2num(params["multiplier"])
			var/datum/autolathe/recipe/making

			if(index > 0 && index <= machine_recipes.len)
				making = machine_recipes[index]

			// Exploit detection, not sure if necessary after rewrite.
			if(!making || multiplier < 0 || multiplier > 100 || multiplier == null)
				log_and_message_admins("tried to exploit an autolathe to duplicate an item!", usr)
				return TRUE

			busy = TRUE
			update_use_power(POWER_USE_ACTIVE)

			// Check if we still have the materials.
			for(var/material in making.resources)
				if(!isnull(stored_material[material]))
					if(stored_material[material] < round(making.resources[material] * mat_efficiency) * multiplier)
						busy = FALSE
						update_use_power(POWER_USE_IDLE)
						tgui_update()
						return TRUE

			// Consume materials.
			for(var/material in making.resources)
				if(!isnull(stored_material[material]))
					stored_material[material] = max(0, stored_material[material] - round(making.resources[material] * mat_efficiency) * multiplier)

			updateUsrDialog()
			// Fancy autolathe animation.
			flick("autolathe_n", src)

			sleep(build_time)

			busy = FALSE
			update_use_power(POWER_USE_IDLE)

			// Sanity check.
			if(!making || QDELETED(src))
				tgui_update()
				return TRUE

			// Create the desired item.
			var/obj/item/I = new making.path(loc)
			if(multiplier > 1 && istype(I, /obj/item/stack))
				var/obj/item/stack/S = I
				S.amount = multiplier
				S.update_icon()

			tgui_update()


/obj/machinery/autolathe/update_icon()
	icon_state = (panel_open ? "autolathe_t" : "autolathe")

// Updates overall lathe storage size.
/obj/machinery/autolathe/RefreshParts()
	..()
	var/mb_rating = 0
	var/man_rating = 0
	for(var/obj/item/stock_parts/P in component_parts)
		if(ismatterbin(P))
			mb_rating += P.rating
		else if(ismanipulator(P))
			man_rating += P.rating

	storage_capacity[MATERIAL_STEEL] = mb_rating  * 25000
	storage_capacity[MATERIAL_GLASS] = mb_rating  * 12500
	build_time = 50 / man_rating
	mat_efficiency = 1.1 - man_rating * 0.1 // Normally, price is 1.25 the amount of material, so this shouldn't go higher than 0.8. Maximum rating of parts is 3

/obj/machinery/autolathe/dismantle()

	for(var/mat in stored_material)
		var/material/M = get_material_by_name(mat)
		if(!istype(M))
			continue
		var/obj/item/stack/material/S = new M.stack_type(get_turf(src))
		if(stored_material[mat] > S.perunit)
			S.amount = round(stored_material[mat] / S.perunit)
		else
			qdel(S)
	..()
	return 1