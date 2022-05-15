// GENERIC PRINTER - DO NOT USE THIS OBJECT.
// Flesh and robot printers are defined below this object.

/obj/machinery/organ_printer
	name = "organ printer"
	desc = "It's a machine that prints organs."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "bioprinter"

	layer = BELOW_OBJ_LAYER
	anchored = 1
	density = 1
	idle_power_usage = 40
	active_power_usage = 300

	var/stored_matter = 0
	var/max_stored_matter = 0
	var/print_delay = 100
	var/printing
	var/datum/browser/printer_menu

	// These should be subtypes of /obj/item/organ
	var/list/products = list(
		BP_HEART   = list("Heart",       /obj/item/organ/internal/heart,     25),
		BP_LUNGS   = list("Lungs",      /obj/item/organ/internal/lungs,      25),
		BP_KIDNEYS = list("Kidneys",    /obj/item/organ/internal/kidneys,    20),
		BP_EYES    = list("Eyes",       /obj/item/organ/internal/eyes,       20),
		BP_LIVER   = list("Liver",      /obj/item/organ/internal/liver,      25),
		BP_STOMACH = list("Stomach",    /obj/item/organ/internal/stomach,    25),
		BP_L_ARM   = list("Left Arm",   /obj/item/organ/external/arm,        65),
		BP_R_ARM   = list("Right Arm",  /obj/item/organ/external/arm/right,  65),
		BP_L_HAND  = list("Left Hand",  /obj/item/organ/external/hand,       40),
		BP_R_HAND  = list("Right Hand", /obj/item/organ/external/hand/right, 40),
		BP_L_LEG   = list("Left Leg",   /obj/item/organ/external/leg,        65),
		BP_R_LEG   = list("Right Leg",  /obj/item/organ/external/leg/right,  65),
		BP_L_FOOT  = list("Left Foot",  /obj/item/organ/external/foot,       40),
		BP_R_FOOT  = list("Right Foot", /obj/item/organ/external/foot/right, 40)
		)

/obj/machinery/organ_printer/attackby(obj/item/O, mob/user)
	if(default_deconstruction_screwdriver(user, O))
		updateUsrDialog()
		return
	if(default_deconstruction_crowbar(user, O))
		return
	if(default_part_replacement(user, O))
		return
	return ..()

/obj/machinery/organ_printer/update_icon()
	overlays.Cut()
	if(panel_open)
		overlays += "bioprinter_panel_open"
	if(printing)
		overlays += "bioprinter_working"

/obj/machinery/organ_printer/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/stock_parts/matter_bin(src)
	component_parts += new /obj/item/stock_parts/matter_bin(src)
	component_parts += new /obj/item/stock_parts/manipulator(src)
	component_parts += new /obj/item/stock_parts/manipulator(src)
	RefreshParts()

/obj/machinery/organ_printer/_examine_text(mob/user)
	. = ..()
	. += "\n<span class='notice'>It is loaded with [stored_matter]/[max_stored_matter] matter units.</span>"

/obj/machinery/organ_printer/RefreshParts()
	print_delay = initial(print_delay)
	max_stored_matter = 0
	for(var/obj/item/stock_parts/matter_bin/bin in component_parts)
		max_stored_matter += bin.rating * 50
	for(var/obj/item/stock_parts/manipulator/manip in component_parts)
		print_delay -= (manip.rating-1)*10
	print_delay = max(0,print_delay)
	. = ..()

/obj/machinery/organ_printer/attack_hand(mob/user)
	if(printing || (stat & (BROKEN|NOPOWER)))
		return
	show_printer_menu(user)
	printer_menu.open()

/obj/machinery/organ_printer/proc/show_printer_menu(mob/user)
	add_fingerprint(user)
	if(stat & (NOPOWER|BROKEN) || !Adjacent(user))
		user.unset_machine()
		return

	var/dat = "<B>Loaded matter:</B> [stored_matter]/[max_stored_matter]."
	dat += "<HR>Printing menu:"
	for(var/entry in products)
		dat += "<BR><a href='?src=\ref[src];item=[entry]'>[products[entry][1]]</a> - [products[entry][3]] matter"

	user.set_machine(src)
	if(!printer_menu || printer_menu.user != user)
		printer_menu = new /datum/browser(user, "disposal", "<B>[src]</B>", 360, 410)
		printer_menu.set_content(dat)
	else
		printer_menu.set_content(dat)
		printer_menu.update()
	return

/*obj/machinery/organ_printer/CanUseTopic(user, state, href_list)
	if((user.stat || user.restrained()) || !Adjacent(user))
		return STATUS_CLOSE
	return ..()*/

/obj/machinery/organ_printer/OnTopic(user, href_list)
	if(href_list["item"]) // receives list(name, type, cost)
		var/choice = href_list["item"]
		if(!choice || printing || (stat & (BROKEN|NOPOWER)))
			return
		if(!can_print(choice))
			return

		update_use_power(POWER_USE_ACTIVE)
		printing = 1
		update_icon()

		sleep(print_delay)

		update_use_power(POWER_USE_IDLE)
		printing = 0
		update_icon()

		if(!choice || !src || (stat & (BROKEN|NOPOWER)))
			return

		stored_matter -= products[choice][3]
		print_organ(choice)
		for(var/mob/M in viewers(1, src.loc))
			if((M.client && M.machine == src))
				show_printer_menu(M)
		return

/obj/machinery/organ_printer/proc/can_print(choice)
	if(stored_matter < products[choice][3])
		visible_message("<span class='notice'>\The [src] displays a warning: 'Not enough matter. [stored_matter] stored and [products[choice][3]] needed.'</span>")
		return 0
	return 1

/obj/machinery/organ_printer/proc/print_organ(choice)
	var/new_organ = products[choice][2]
	var/obj/item/organ/O = new new_organ(get_turf(src))
	O.status |= ORGAN_CUT_AWAY
	O.dir = SOUTH // TODO: refactor external organ's /New, /update_icon and more so they'll generate proper icons upon being spawned outside a mob
	return O
// END GENERIC PRINTER

// ROBOT ORGAN PRINTER
/obj/machinery/organ_printer/robot
	name = "prosthetic organ fabricator"
	desc = "It's a machine that prints prosthetic organs."
	icon_state = "roboprinter"

	var/matter_amount_per_sheet = 10
	var/matter_type = MATERIAL_STEEL

/obj/machinery/organ_printer/robot/mapped/Initialize()
	. = ..()
	stored_matter = max_stored_matter

/obj/machinery/organ_printer/robot/dismantle()
	if(stored_matter >= matter_amount_per_sheet)
		new /obj/item/stack/material/steel(get_turf(src), Floor(stored_matter/matter_amount_per_sheet))
	return ..()

/obj/machinery/organ_printer/robot/Initialize()
	. = ..()
	products.Add(BP_CELL)
	products[BP_CELL] = list("Microbattery", /obj/item/organ/internal/cell, 25)
	component_parts += new /obj/item/circuitboard/roboprinter

/obj/machinery/organ_printer/robot/print_organ(choice)
	var/obj/item/organ/O = ..()
	var/obj/item/organ/external/externalOrgan = O
	if(istype(externalOrgan))
		externalOrgan.robotize("NanoTrasen", just_printed = TRUE)
		// TODO [V] Add other companies and ability to choose from input
	else
		O.robotize()
		O.status |= ORGAN_CUT_AWAY // Default robotize() resets status to ORGAN_ROBOTIC only

	visible_message("<span class='info'>\The [src] churns for a moment, then spits out \a [O].</span>")
	return O

/obj/machinery/organ_printer/robot/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/stack/material) && W.get_material_name() == matter_type)
		if((max_stored_matter-stored_matter) < matter_amount_per_sheet)
			to_chat(user, "<span class='warning'>\The [src] is too full.</span>")
			return
		var/obj/item/stack/S = W
		var/space_left = max_stored_matter - stored_matter
		var/sheets_to_take = min(S.amount, Floor(space_left/matter_amount_per_sheet))
		if(sheets_to_take <= 0)
			to_chat(user, "<span class='warning'>\The [src] is too full.</span>")
			return
		stored_matter = min(max_stored_matter, stored_matter + (sheets_to_take*matter_amount_per_sheet))
		to_chat(user, "<span class='info'>\The [src] processes \the [W]. Levels of stored matter now: [stored_matter]</span>")
		S.use(sheets_to_take)
		return
	return ..()
// END ROBOT ORGAN PRINTER

// FLESH ORGAN PRINTER
/obj/machinery/organ_printer/flesh
	name = "bioprinter"
	desc = "It's a machine that prints replacement organs."
	icon_state = "bioprinter"
	var/list/amount_list = list(
		/obj/item/reagent_containers/food/meat = 50,
		/obj/item/reagent_containers/food/rawcutlet = 15
		)
	var/loaded_dna //Blood sample for DNA hashing.

/obj/machinery/organ_printer/flesh/can_print(choice)
	. = ..()
	if(!loaded_dna || !loaded_dna["donor"])
		visible_message("<span class='info'>\The [src] displays a warning: 'No DNA saved. Insert a blood sample.'</span>")
		return 0

/obj/machinery/organ_printer/flesh/mapped/Initialize()
	. = ..()
	stored_matter = max_stored_matter

/obj/machinery/organ_printer/flesh/dismantle()
	var/turf/T = get_turf(src)
	if(T)
		while(stored_matter >= amount_list[/obj/item/reagent_containers/food/meat])
			stored_matter -= amount_list[/obj/item/reagent_containers/food/meat]
			new /obj/item/reagent_containers/food/meat(T)
	return ..()

/obj/machinery/organ_printer/flesh/New()
	..()
	component_parts += new /obj/item/device/healthanalyzer
	component_parts += new /obj/item/circuitboard/bioprinter

/obj/machinery/organ_printer/flesh/print_organ(choice)
	var/obj/item/organ/O
	var/weakref/W = loaded_dna["donor"]
	var/mob/living/carbon/human/H = W.resolve()
	if(H && istype(H))
		if(H.species && H.species.has_organ[choice])
			var/new_organ = H.species.has_organ[choice]
			O = new new_organ(get_turf(src))
			O.status |= ORGAN_CUT_AWAY
		else
			O = ..()
		O.set_dna(H.dna)
		if(O.species)
			// This is a very hacky way of doing of what organ/New() does if it has an owner
			O.w_class = max(O.w_class + mob_size_difference(O.species.mob_size, MOB_MEDIUM), 1)

	visible_message("<span class='info'>\The [src] churns for a moment, injects its stored DNA into the biomass, then spits out \a [O].</span>")
	return O

/obj/machinery/organ_printer/flesh/attackby(obj/item/W, mob/user)
	// Load with matter for printing.
	for(var/path in amount_list)
		if(istype(W, path))
			if(max_stored_matter == stored_matter)
				to_chat(user, "<span class='warning'>\The [src] is too full.</span>")
				return
			stored_matter += min(amount_list[path], max_stored_matter - stored_matter)
			user.drop_item()
			to_chat(user, "<span class='info'>\The [src] processes \the [W]. Levels of stored biomass now: [stored_matter]</span>")
			qdel(W)
			return

	// DNA sample from syringe or dna sampler.
	if(istype(W,/obj/item/reagent_containers/syringe) || istype(W,/obj/item/reagent_containers/dna_sampler))
		var/obj/item/reagent_containers/S = W
		var/datum/reagent/blood/injected = locate() in S.reagents.reagent_list //Grab some blood
		if(injected && injected.data)
			loaded_dna = injected.data
			to_chat(user, "<span class='info'>You inject the blood sample into the bioprinter.</span>")
		return
	return ..()
// END FLESH ORGAN PRINTER
