/obj/machinery/pros_printer
	name = "Surgical Printer"
	desc = "It's a machine that prints prosthetic organs."

	icon = 'icons/obj/surgery.dmi'
	icon_state = "roboprinter"
	layer = BELOW_OBJ_LAYER

	density = 1
	anchored = 1

	component_types = list(
		/obj/item/weapon/circuitboard/pros_printer,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/matter_bin = 2
	)

	// Power
	use_power = POWER_USE_IDLE
	idle_power_usage = 20
	active_power_usage = 5000

	// Resources
	var/matter_type = MATERIAL_STEEL
	var/stored_matter = 0
	var/max_stored_matter = 10000

	// Printing stuff
	var/busy = 	FALSE
	var/print_delay = 100

	var/category = null
	var/list/categories = list()

/obj/machinery/pros_printer/Initialize()
	. = ..()

/obj/machinery/pros_printer/Destroy()
	var/obj/item/stack/material/steel/S
	var/amnt = S.perunit
	if(stored_matter >= amnt)
		new S(get_turf(src), Floor(stored_matter/amnt))
	return ..()

/obj/machinery/pros_printer/update_icon()
	overlays.Cut()
	if(panel_open)
		overlays.Add(image(icon, "_panel"))
	if(busy)
		overlays.Add(image(icon, "_work"))

/obj/machinery/pros_printer/attackby(obj/item/O, mob/user)
	if(default_deconstruction_screwdriver(user, O))
		updateUsrDialog()
		return

	if(default_deconstruction_crowbar(user, O))
		return

	if(istype(O, /obj/item/stack/material) && O.get_material_name() == matter_type)
		var/obj/item/stack/material/S = O
		var/amnt = S.perunit

		if((max_stored_matter-stored_matter) < amnt)
			to_chat(user, SPAN("warning", "\The [src] is too full."))
			return

		var/space_left = max_stored_matter - stored_matter
		var/sheets_to_take = min(S.amount, Floor(space_left/amnt))

		if(sheets_to_take <= 0)
			to_chat(user, SPAN("warning", "\The [src] is too full."))
			return

		stored_matter = min(max_stored_matter, stored_matter + (sheets_to_take*amnt))
		to_chat(user, SPAN("info", "\The [src] processes \the [O]. Levels of stored matter now: [stored_matter]"))
		S.use(sheets_to_take)
		return

	return ..()

// Printing checks.
/obj/machinery/pros_printer/proc/check_print(choice)
	if(!choice || busy || (stat & (BROKEN|NOPOWER)))
		return

	var/datum/printer/recipe/R = GLOB.printer_recipes[choice]

	if(!can_print(R))
		return

	// Machine starts printing.
	update_use_power(POWER_USE_ACTIVE)
	busy = TRUE
	update_icon()

	sleep(print_delay)

	// Machine finishes printing.
	update_use_power(POWER_USE_IDLE)
	busy = FALSE
	update_icon()

	if(!choice || !src || (stat & (BROKEN|NOPOWER)))
		return

	stored_matter -= R.matter
	print_organ(R)

	return

/obj/machinery/pros_printer/proc/can_print(datum/printer/recipe/R)
	if(stored_matter < R.matter)
		visible_message(SPAN("notice", "\The [src] displays a warning: 'Not enough matter. [stored_matter] stored and [R.matter] needed.'"))
		return 0
	return 1

/obj/machinery/pros_printer/proc/print_organ(datum/printer/recipe/R)
	var/obj/item/organ/O = new R.build_path(get_turf(src))

	O.species = all_species[SPECIES_HUMAN]

	O.robotize("Unbranded")

	O.status |= ORGAN_CUT_AWAY
	O.dir = SOUTH

	visible_message(SPAN("notice", "\The [src] churns for a moment, then spits out \a [O]."))
	return O

// Getters.
/obj/machinery/pros_printer/proc/get_categories()
	categories = GLOB.printer_categories
	category = categories[1]

/obj/machinery/pros_printer/proc/get_build_options()
	. = list()
	for(var/i = 1 to GLOB.printer_recipes.len)
		var/datum/printer/recipe/R = GLOB.printer_recipes[i]
		if(R.build_path)
			. += list(list("name" = R.name, "id" = i, "category" = R.category, "resources" = R.matter))

// NanoUI stuff.
/obj/machinery/pros_printer/attack_hand(user)
	if(..())
		return
	if(!allowed(user))
		return
	ui_interact(user)

/obj/machinery/pros_printer/ui_interact(mob/user, ui_key, datum/nanoui/ui, force_open, datum/nanoui/master_ui, datum/topic_state/state)
	user.set_machine(src)
	var/list/data = list()

	if(!category)
		get_categories()

	data["maxres"] = max_stored_matter
	data["amt"] = stored_matter

	data["category"] = category
	data["categories"] = categories

	data["buildable"] = get_build_options()

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "surgprinter.tmpl", "Surgical Priner UI", 360, 410)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/pros_printer/Topic(href, href_list)
	if(href_list["category"])
		if(href_list["category"] in categories)
			category = href_list["category"]

	if(href_list["build"])
		check_print(text2num(href_list["build"]))

	return TOPIC_REFRESH
