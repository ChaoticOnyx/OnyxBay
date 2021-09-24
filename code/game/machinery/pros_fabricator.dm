/obj/machinery/organ_printer/pros_fabricator
	name = "Prosthetics Fabricator"
	desc = "It's a machine that prints replacement organs."

	icon = 'icons/obj/robotics.dmi'
	icon_state = "prosfab-idle"
	layer = BELOW_OBJ_LAYER

	density = 1
	anchored = 1

	req_access = list(access_robotics)

	component_types = list(
		/obj/item/weapon/circuitboard/pros_fabricator,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/console_screen,
		/obj/item/weapon/stock_parts/matter_bin = 2
	)

	// Power
	use_power = POWER_USE_IDLE
	idle_power_usage = 20
	active_power_usage = 5000

	// Resources
	var/list/materials = list(MATERIAL_STEEL = 0, MATERIAL_GLASS = 0, MATERIAL_PLASTIC = 0)
	var/res_max_amount = 100000

	var/datum/research/files

	var/manufacturer = null
	var/list/manufacturer_list = list()
	var/list/valid_manufacturer_list = list()

	var/pros_gender = null
	var/pros_gender_list = list(MALE, FEMALE)

	var/pros_build = null
	var/list/pros_build_list = list()

	var/species = null
	var/list/species_list = list()

	var/sync_message = ""

	icon_state_overlay_parent = "prosfab"

/obj/machinery/organ_printer/pros_fabricator/Initialize()
	. = ..()

	get_genders()
	get_species()
	update_builds_list()

	for(var/A in all_robolimbs)
		var/datum/robolimb/R = all_robolimbs[A]

		if(!R.unavailable_to_build)
			manufacturer_list += R.company

	update_pros_list()

	files = new /datum/research
	update_categories()

/obj/machinery/organ_printer/pros_fabricator/remove_objects_from_machine(turf/T)
	for(var/f in materials)
		eject_materials(f, -1)

	if(T)
		for(var/obj/item/weapon/disk/limb/D in contents)
			D.forceMove(T)

/obj/machinery/organ_printer/pros_fabricator/special_attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/weapon/disk/limb))
		var/obj/item/weapon/disk/limb/D = O

		for(var/A = 1 to length(D.company))
			if(!D.company[A] || !(D.company[A] in all_robolimbs))
				to_chat(user, SPAN("warning", "This disk seems to be corrupted!"))
				return

			if(D.company[A] in manufacturer_list)
				to_chat(user, SPAN("warning", "Fabricator already contains [D.company[A]] blueprints."))
				return

		to_chat(user, SPAN("notice", "Installing blueprint files from [D.name]..."))

		if(do_after(user, 50, src))
			flick("prosfab-disk", src)
			to_chat(user, SPAN("notice",  "Blueprint files successfully installed!"))
			user.drop_from_inventory(O)
			O.forceMove(src)
			manufacturer_list += D.company
			update_pros_list()

		return


	if(istype(O, /obj/item/stack/material))

		var/obj/item/stack/material/stack = O

		var/material = stack.material.name
		var/stack_singular = "[stack.material.use_name] [stack.material.sheet_singular_name]" // eg "steel sheet", "wood plank"
		var/stack_plural = "[stack.material.use_name] [stack.material.sheet_plural_name]" // eg "steel sheets", "wood planks"
		var/amnt = stack.perunit

		if(stack.uses_charge)
			return

		if(!(material in materials))
			to_chat(user, SPAN("warning", "\The [src] does not accept [stack_plural]!"))
			return

		if(materials[material] + amnt <= res_max_amount)
			if(stack && stack.get_amount() >= 1)
				var/count = 0
				flick("prosfab-loading", src)
				count = min(stack.amount, round((res_max_amount - materials[material]) / amnt))
				materials[material] += amnt * count
				stack.use(count)
				to_chat(user, "You insert [count] [count==1 ? stack_singular : stack_plural] into the fabricator.")

			update_busy()

		else
			to_chat(user, "The fabricator cannot hold more [stack_plural].")
		return

	return TRUE

/obj/machinery/organ_printer/pros_fabricator/proc/eject_materials(material, amount)
	var/recursive = amount == -1 ? 1 : 0
	material = lowertext(material)
	var/mattype

	switch(material)
		if(MATERIAL_STEEL)
			mattype = /obj/item/stack/material/steel
		if(MATERIAL_GLASS)
			mattype = /obj/item/stack/material/glass
		if(MATERIAL_PLASTIC)
			mattype = /obj/item/stack/material/plastic
		else
			return

	var/obj/item/stack/material/S = new mattype(loc)

	if(amount <= 0)
		amount = S.max_amount
	var/ejected = min(round(materials[material] / S.perunit), amount)
	S.amount = ejected
	if(S.amount <= 0)
		qdel(S)
		return
	materials[material] -= ejected * S.perunit
	if(recursive && materials[material] >= S.perunit)
		eject_materials(material, -1)
	update_busy()

// Queue manipulations.
/obj/machinery/organ_printer/pros_fabricator/add_to_queue(index)
	var/datum/design/D = files.known_designs[index]
	queue += D
	update_busy()

/obj/machinery/organ_printer/pros_fabricator/remove_from_queue(index)
	if(index == 1)
		progress = 0
	queue.Cut(index, index + 1)
	update_busy()

/obj/machinery/organ_printer/pros_fabricator/get_queue_names()
	. = list()
	for(var/i = 2 to queue.len)
		var/datum/design/D = queue[i]
		. += D.name

// Build checks and etc.
/obj/machinery/organ_printer/pros_fabricator/can_build(datum/design/D)
	for(var/M in D.materials)
		if(materials[M] <= D.materials[M] * mat_efficiency)
			return 0
	return 1

/obj/machinery/organ_printer/pros_fabricator/check_build()
	if(!queue.len)
		progress = 0
		return

	var/datum/design/D = queue[1]
	if(!can_build(D))
		progress = 0
		return

	if(D.time > progress)
		return

	for(var/M in D.materials)
		materials[M] = max(0, materials[M] - D.materials[M] * mat_efficiency)

	if(D.build_path)
		flick("prosfab-finish", src)
		var/obj/new_item = D.Fabricate(get_step(get_turf(src), src.dir), src)
		visible_message("\The [src] pings, indicating that \the [D] is complete.", "You hear a ping.")
		if(mat_efficiency != 1)
			if(istype(new_item, /obj/) && new_item.matter && new_item.matter.len > 0)
				for(var/i in new_item.matter)
					new_item.matter[i] = new_item.matter[i] * mat_efficiency
		remove_from_queue(1)

// Getters and other stuff...
/obj/machinery/organ_printer/pros_fabricator/get_build_options()
	. = list()
	for(var/i = 1 to files.known_designs.len)
		var/datum/design/D = files.known_designs[i]
		if(D.build_path && (D.build_type & PROSFAB))
			. += list(list("name" = D.name, "id" = i, "category" = D.category, "resources" = get_design_resources(D), "time" = get_design_time(D)))

/obj/machinery/organ_printer/pros_fabricator/proc/get_design_resources(datum/design/D)
	var/list/F = list()
	for(var/T in D.materials)
		F += "[capitalize(T)]: [D.materials[T] * mat_efficiency]"
	return english_list(F, and_text = ", ")

/obj/machinery/organ_printer/pros_fabricator/get_design_time(datum/design/D)
	return time2text(round(10 * D.time / speed), "mm:ss")

/obj/machinery/organ_printer/pros_fabricator/proc/get_materials()
	. = list()
	for(var/T in materials)
		. += list(list("mat" = capitalize(T), "amt" = materials[T]))

/obj/machinery/organ_printer/pros_fabricator/proc/get_species()
	species_list = list()
	for(var/N in playable_species)
		var/datum/species/S = all_species[N]
		if(S.spawn_flags & SPECIES_NO_FBP_CONSTRUCTION)
			continue
		if(!species)
			species = N
		species_list += N

/obj/machinery/organ_printer/pros_fabricator/proc/get_genders()
	if(!pros_gender)
		pros_gender = pros_gender_list[1]

/obj/machinery/organ_printer/pros_fabricator/proc/update_categories()
	categories = list()
	if(files)
		for(var/datum/design/D in files.known_designs)
			if(!D.build_path || !(D.build_type & PROSFAB))
				continue
			categories |= D.category
	if(!category || !(category in categories))
		category = categories[1]

/obj/machinery/organ_printer/pros_fabricator/proc/update_pros_list()
	manufacturer = null
	valid_manufacturer_list = list()

	var/datum/robolimb/R
	for(var/A in manufacturer_list)
		R = all_robolimbs[A]

		if(species in R.restricted_to)
			if(!manufacturer)
				manufacturer = R.company

			valid_manufacturer_list += list(list("id" = A, "company" = R.company))

/obj/machinery/organ_printer/pros_fabricator/proc/update_builds_list()
	pros_build = null
	pros_build_list = list()

	var/datum/species/S = all_species[species]

	var/list/datum_build_list = S.get_body_build_datum_list(pros_gender)

	for(var/datum/body_build/BB in datum_build_list)
		pros_build_list += BB.name

	if(!pros_build)
		pros_build = pros_build_list[1]

// Sync.
/obj/machinery/organ_printer/pros_fabricator/proc/sync()
	sync_message = "Error: no console found."
	for(var/obj/machinery/computer/rdconsole/RDC in get_area_all_atoms(get_area(src)))
		if(!RDC.sync)
			continue
		for(var/datum/tech/T in RDC.files.known_tech)
			files.AddTech2Known(T)
		for(var/datum/design/D in RDC.files.known_designs)
			files.AddDesign2Known(D)
		files.RefreshResearch()
		sync_message = "Sync complete."
	update_categories()

// NanoUI stuff.

/obj/machinery/organ_printer/pros_fabricator/ui_interact(mob/user, ui_key, datum/nanoui/ui, force_open, datum/nanoui/master_ui, datum/topic_state/state)
	user.set_machine(src)
	var/list/data = list()

	var/datum/design/current = length(queue) ? queue[1] : null
	if(current)
		data["current"] = current.name

	data["queue"] = get_queue_names()
	data["buildable"] = get_build_options()

	data["gender"] = pros_gender
	data["gender_types"] = pros_gender_list

	data["species"] = species
	data["species_types"] = species_list

	data["body_build"] = pros_build
	data["body_build_types"] = pros_build_list

	data["category"] = category
	data["categories"] = categories

	data["manufacturer"] = manufacturer
	data["manufacturers"] = valid_manufacturer_list

	data["materials"] = get_materials()
	data["maxres"] = res_max_amount

	data["sync"] = sync_message

	if(current)
		data["builtperc"] = round((progress / current.time) * 100)

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "prosfab.tmpl", "Prosthetics Fabricator", 620, 550 )
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/organ_printer/pros_fabricator/Topic(href, href_list)
	. = ..()

	if(href_list["gender"])
		if(href_list["gender"] in pros_gender_list)
			pros_gender = href_list["gender"]
			update_builds_list()

	if(href_list["species"])
		if(href_list["species"] in species_list)
			species = href_list["species"]
			update_pros_list()
			update_builds_list()

	if(href_list["body_build"])
		if(href_list["body_build"] in pros_build_list)
			pros_build = href_list["body_build"]

	if(href_list["manufacturer"])
		if(href_list["manufacturer"] in all_robolimbs)
			manufacturer = href_list["manufacturer"]

	if(href_list["eject"])
		eject_materials(href_list["eject"], text2num(href_list["amount"]))

	if(href_list["sync"])
		sync()
	else
		sync_message = ""

	return TOPIC_REFRESH
