/obj/machinery/bioprinter
	name = "Bioprinter"
	desc = "It's a machine that prints replacement organs."

	icon = 'icons/obj/surgery.dmi'
	icon_state = "bioprinter"
	layer = BELOW_OBJ_LAYER

	req_access = list(access_medical)

	density = 1
	anchored = 1

	// Power
	use_power = POWER_USE_IDLE
	idle_power_usage = 20
	active_power_usage = 5000

	// Resources
	var/speed = 1
	var/mat_efficiency = 1

	var/max_stored_matter = 100000
	var/stored_matter = 0

	var/list/amount_list = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat = 20000,
		/obj/item/weapon/reagent_containers/food/snacks/rawcutlet = 5000
		)

	// DNA stuff
	var/loaded_dna

	var/time = 20
	var/progress = 0

	var/busy = FALSE
	var/list/queue = list()

	var/list/products = list(
		BP_HEART   = list("Heart", "Organs", /obj/item/organ/internal/heart,      5600),
		BP_LUNGS   = list("Lungs", "Organs", /obj/item/organ/internal/lungs,      5600),
		BP_KIDNEYS = list("Kidneys", "Organs", /obj/item/organ/internal/kidneys,    5600),
		BP_EYES    = list("Eyes", "Organs", /obj/item/organ/internal/eyes,       5600),
		BP_LIVER   = list("Liver", "Organs", /obj/item/organ/internal/liver,      5600),
		BP_STOMACH = list("Stomach", "Organs", /obj/item/organ/internal/stomach,    5600),
		)

	var/category = null
	var/list/categories = list()

/obj/machinery/bioprinter/Initialize()
	..()

	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/bioprinter(src)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(src)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(src)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(src)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(src)
	component_parts += new /obj/item/device/healthanalyzer(src)

	RefreshParts()

	update_categories()

/obj/machinery/bioprinter/RefreshParts()
	max_stored_matter = 0

	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		max_stored_matter += M.rating * 100000

	var/T = 0
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		T += M.rating
	mat_efficiency = 1 - (T - 1) / 4

	for(var/obj/item/weapon/stock_parts/micro_laser/M in component_parts)
		T += M.rating
	speed = T / 2

/obj/machinery/bioprinter/Destroy()
	var/turf/T = get_turf(src)

	if(T)
		// Splits out meat from deconstructed bioprinter.
		while(stored_matter >= amount_list[/obj/item/weapon/reagent_containers/food/snacks/meat])
			stored_matter -= amount_list[/obj/item/weapon/reagent_containers/food/snacks/meat]
			new /obj/item/weapon/reagent_containers/food/snacks/meat(T)

		for(var/obj/I in contents)
			if(istype(I, /obj/item/weapon/disk/biolimb))
				I.forceMove(T)

	..()

/obj/machinery/bioprinter/Process()
	..()
	if(stat)
		return
	if(busy)
		update_use_power(POWER_USE_ACTIVE)
		progress += speed
		check_build()
	else
		update_use_power(POWER_USE_IDLE)
	update_icon()

/obj/machinery/bioprinter/update_icon()
	overlays.Cut()
	icon_state = initial(icon_state)

	if(panel_open)
		overlays.Add(image(icon, "[icon_state]_panel"))
	else
		return
	if(busy)
		icon_state = "[icon_state]_work"

/obj/machinery/bioprinter/proc/update_busy()
	if(queue.len)
		if(can_print(queue[1]))
			busy = TRUE
		else
			busy = FALSE
	else
		busy = FALSE

/obj/machinery/bioprinter/attackby(obj/item/O, mob/user)

	if(busy)
		to_chat(user, SPAN("warning", "The [src] is busy. Please wait for completion of previous operation."))
		return 1

	if(default_deconstruction_screwdriver(user, O))
		return

	if(default_deconstruction_crowbar(user, O))
		return

	if(default_part_replacement(user, O))
		return

	if(istype(O, /obj/item/weapon/disk/biolimb))

		for(var/obj/I in contents)
			if(istype(I, O))
				to_chat(user, SPAN("warning", "Bioprinter already contains advanced blueprints."))
				return

		to_chat(user, SPAN("notice", "Installing blueprint files..."))
		if(do_after(user, 50, src))
			to_chat(user, SPAN("notice", "Installed advanced blueprints!"))
			user.drop_from_inventory(O)
			contents += O
			var/obj/item/weapon/disk/biolimb/B = O
			products += B.products
			update_categories()

		return

	// Load with matter for printing.
	for(var/path in amount_list)
		if(istype(O, path))

			if(max_stored_matter == stored_matter)
				to_chat(user, "<span class='warning'>\The [src] is too full.</span>")
				return

			stored_matter += min(amount_list[path], max_stored_matter - stored_matter)
			user.drop_item()

			to_chat(user, SPAN("info", "The [src] processes \the [O]."))
			qdel(O)

			update_busy()

			return

	// DNA sample from syringe or dna sampler.
	if(istype(O, /obj/item/weapon/reagent_containers/syringe) || istype(O, /obj/item/weapon/reagent_containers/dna_sampler))
		var/obj/item/weapon/reagent_containers/S = O

		//Grab some blood
		var/datum/reagent/blood/injected = locate() in S.reagents.reagent_list

		if(injected && injected.data)
			loaded_dna = injected.data
			to_chat(user, SPAN("info", "You inject the blood sample into the bioprinter."))

			get_owner_name()

		return

	return ..()

/obj/machinery/bioprinter/emag_act(remaining_charges, mob/user)
	switch(emagged)
		if(0)
			playsound(src.loc, 'sound/effects/computer_emag.ogg', 25)
			emagged = 0.5
			visible_message("\icon[src] <b>[src]</b> beeps: \"DB error \[Code 0x00F1\]\"")
			sleep(10)
			visible_message("\icon[src] <b>[src]</b> beeps: \"Attempting auto-repair\"")
			sleep(15)
			visible_message("\icon[src] <b>[src]</b> beeps: \"User DB corrupted \[Code 0x00FA\]. Truncating data structure...\"")
			sleep(30)
			visible_message("\icon[src] <b>[src]</b> beeps: \"User DB truncated. Please contact your [GLOB.using_map.company_name] system operator for future assistance.\"")
			req_access = null
			emagged = 1
			return 1
		if(0.5)
			visible_message("\icon[src] <b>[src]</b> beeps: \"DB not responding \[Code 0x0003\]...\"")
		if(1)
			visible_message("\icon[src] <b>[src]</b> beeps: \"No records in User DB\"")

// Categories, build options & material getters.
/obj/machinery/bioprinter/proc/update_categories()
	categories = list()
	category = null

	for(var/A in products)
		if(!(products[A][2] in categories))
			categories += products[A][2]

	if(!category)
		category = categories[1]

/obj/machinery/bioprinter/proc/get_build_options()
	. = list()
	for(var/A in products)
		. += list(list("name" = products[A][1], "id" = A, "category" = products[A][2], "resources" = products[A][4] * mat_efficiency))

// Queue manipulations.
/obj/machinery/bioprinter/proc/get_queue_names()
	. = list()
	for(var/i = 2 to queue.len)
		. += queue[i]

/obj/machinery/bioprinter/proc/add_to_queue(index)
	queue += products[index][1]
	update_busy()

/obj/machinery/bioprinter/proc/remove_from_queue(index)
	if(index == 1)
		progress = 0
	queue.Cut(index, index + 1)
	update_busy()

// Printing.
/obj/machinery/bioprinter/proc/can_print(choice)
	if(!loaded_dna)
		visible_message("\icon[src] <b>[src]</b> beeps: \"No DNA saved. Insert a blood sample.\"")
		return 0

	for(var/A in products)
		if(products[A][1] == choice)
			choice = lowertext(A)

	if(stored_matter < products[choice][4] * mat_efficiency)
		visible_message("\icon[src] <b>[src]</b> beeps: \"Not enough matter stored to construct chosen item.\"")
		return 0

	return 1

/obj/machinery/bioprinter/proc/check_build()
	if(!queue.len)
		progress = 0
		return

	if(time > progress)
		return

	var/choice = queue[1]

	if(!can_print(choice))
		progress = 0
		return

	for(var/A in products)
		if(products[A][1] == queue[1])
			choice = A

	stored_matter = max(0, stored_matter - products[choice][4] * mat_efficiency)

	if(choice)
		print_organ(choice)
		remove_from_queue(1)

/obj/machinery/bioprinter/proc/print_organ(choice)
	var/obj/item/organ/O
	var/weakref/W = loaded_dna["donor"]
	var/mob/living/carbon/human/H = W.resolve()

	if(H && istype(H))
		if(H.species && H.species.has_organ[choice])
			var/new_organ = H.species.has_organ[choice]
			O = new new_organ(get_turf(src))
			O.status |= ORGAN_CUT_AWAY
			O.dir = SOUTH
		else
			var/new_organ = products[choice][3]
			O = new new_organ(get_turf(src))
			O.status |= ORGAN_CUT_AWAY
			O.dir = SOUTH

		O.set_dna(H.dna)

		// This is a very hacky way of doing of what organ/New() does if it has an owner.
		if(O.species)
			O.w_class = max(O.w_class + mob_size_difference(O.species.mob_size, MOB_MEDIUM), 1)

	visible_message(SPAN("info", "\The [src] churns for a moment, injects its stored DNA into the biomass, then spits out \a [O]."))
	return O

/obj/machinery/bioprinter/proc/get_owner_name()
	. = list()

	if(loaded_dna)
		var/weakref/W = loaded_dna["donor"]
		var/mob/living/carbon/human/H = W.resolve()

		. += list(list("dna_name" = H.real_name, "dna_species" = H.species))

/obj/machinery/bioprinter/attack_hand(user)
	if(..(user))
		return

	if(!allowed(user))
		return

	ui_interact(user)

/obj/machinery/bioprinter/ui_interact(mob/user, ui_key, datum/nanoui/ui, force_open, datum/nanoui/master_ui, datum/topic_state/state)
	var/data[0]

	var/current = queue.len ? queue[1] : null

	if(current)
		data["current"] = current

	if(loaded_dna)
		data["dna"] = get_owner_name()

	data["queue"] = get_queue_names()
	data["buildable"] = get_build_options()

	data["category"] = category
	data["categories"] = categories

	data["amt"] = stored_matter
	data["maxres"] = max_stored_matter

	if(current)
		data["builtperc"] = round((progress / time) * 100)

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "bioprinter.tmpl", "Bioprinter UI", 410, 510 )
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/bioprinter/Topic(href, href_list, datum/topic_state/state)
	if(..())
		return

	if(href_list["build"])
		add_to_queue(lowertext(href_list["build"]))

	if(href_list["remove"])
		remove_from_queue(text2num(href_list["remove"]))

	if(href_list["category"])
		if(href_list["category"] in categories)
			category = href_list["category"]

	return 1

/obj/item/weapon/disk/biolimb
	name = "Limb Blueprints"
	desc = "A disk containing the blueprints for organic body parts."
	icon = 'icons/obj/cloning.dmi'
	icon_state = "datadisk0"
	w_class = ITEM_SIZE_TINY

	var/list/products = list(
		BP_L_ARM   = list("Left Arm", "Limbs",  /obj/item/organ/external/arm,        10125),
		BP_R_ARM   = list("Right Arm", "Limbs",  /obj/item/organ/external/arm/right,  10125),
		BP_L_HAND  = list("Left Hand", "Limbs",  /obj/item/organ/external/hand,       3375),
		BP_R_HAND  = list("Right Hand", "Limbs",  /obj/item/organ/external/hand/right, 3375),
		BP_L_LEG   = list("Left Leg", "Limbs",  /obj/item/organ/external/leg,        10125),
		BP_R_LEG   = list("Right Leg", "Limbs",  /obj/item/organ/external/leg/right,  10125),
		BP_L_FOOT  = list("Left Foot", "Limbs",  /obj/item/organ/external/foot,       3375),
		BP_R_FOOT  = list("Right Foot", "Limbs",  /obj/item/organ/external/foot/right, 3375)
	)
