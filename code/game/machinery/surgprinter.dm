/obj/machinery/surg_printer
	name = "Surgical Printer"
	desc = "It's a machine that prints prosthetic organs."

	icon = 'icons/obj/surgery.dmi'
	icon_state = "roboprinter"
	layer = BELOW_OBJ_LAYER

	density = 1
	anchored = 1

	// Power
	use_power = POWER_USE_IDLE
	idle_power_usage = 20
	active_power_usage = 5000

	var/matter_type = MATERIAL_STEEL
	var/matter_amount_per_sheet = 20
	var/stored_matter = 0
	var/max_stored_matter = 100

	// Printing stuff
	var/print_delay = 100
	var/busy = 	FALSE

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

/obj/machinery/surg_printer/Initialize()
	..()

	component_parts = list()
	component_parts += new /obj/machinery/surg_printer(src)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(src)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(src)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(src)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(src)

	RefreshParts()

/obj/machinery/surg_printer/Destroy()
	if(stored_matter >= matter_amount_per_sheet)
		new /obj/item/stack/material/steel(get_turf(src), Floor(stored_matter/matter_amount_per_sheet))
	return ..()

/obj/machinery/surg_printer/update_icon()
	overlays.Cut()
	if(panel_open)
		overlays.Add(image(icon, "_panel"))
	if(busy)
		overlays.Add(image(icon, "_work"))

/obj/machinery/surg_printer/attack_hand(mob/user)
	if(busy || (stat & (BROKEN|NOPOWER)))
		return

	show_printer_menu(user)
	printer_menu.open()

/obj/machinery/surg_printer/attackby(obj/item/O, mob/user)
	if(default_deconstruction_screwdriver(user, O))
		updateUsrDialog()
		return

	if(default_deconstruction_crowbar(user, O))
		return

	if(istype(O, /obj/item/stack/material) && O.get_material_name() == matter_type)
		if((max_stored_matter-stored_matter) < matter_amount_per_sheet)
			to_chat(user, SPAN("warning", "\The [src] is too full."))
			return

		var/obj/item/stack/S = O
		var/space_left = max_stored_matter - stored_matter
		var/sheets_to_take = min(S.amount, Floor(space_left/matter_amount_per_sheet))
		if(sheets_to_take <= 0)
			to_chat(user, SPAN("warning", "\The [src] is too full."))
			return

		stored_matter = min(max_stored_matter, stored_matter + (sheets_to_take*matter_amount_per_sheet))
		to_chat(user, SPAN("info", "\The [src] processes \the [O]. Levels of stored matter now: [stored_matter]"))
		S.use(sheets_to_take)
		return

	return ..()

// Menu stuff.
/obj/machinery/surg_printer/proc/show_printer_menu(mob/user)
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

/obj/machinery/surg_printer/OnTopic(user, href_list)
	// Receives list(name, type, cost)
	if(href_list["item"])
		var/choice = href_list["item"]
		if(!choice || busy || (stat & (BROKEN|NOPOWER)))
			return
		if(!can_print(choice))
			return

		update_use_power(POWER_USE_ACTIVE)
		busy = TRUE
		update_icon()

		sleep(print_delay)

		update_use_power(POWER_USE_IDLE)
		busy = FALSE
		update_icon()

		if(!choice || !src || (stat & (BROKEN|NOPOWER)))
			return

		stored_matter -= products[choice][3]
		print_organ(choice)
		for(var/mob/M in viewers(1, src.loc))
			if((M.client && M.machine == src))
				show_printer_menu(M)
		return

// Printing checks.
/obj/machinery/surg_printer/proc/can_print(choice)
	if(stored_matter < products[choice][3])
		visible_message(SPAN("notice", "\The [src] displays a warning: 'Not enough matter. [stored_matter] stored and [products[choice][3]] needed.'"))
		return 0
	return 1

/obj/machinery/surg_printer/proc/print_organ(choice)
	var/build_path = products[choice][2]
	var/obj/item/organ/O = new build_path(get_turf(src))

	O.species = all_species[SPECIES_HUMAN]

	O.robotize("Unbranded")

	O.dna = new/datum/dna()
	O.dna.ResetUI()
	O.dna.ResetSE()

	O.status |= ORGAN_CUT_AWAY
	O.dir = SOUTH

	visible_message(SPAN("notice", "\The [src] churns for a moment, then spits out \a [O]."))
	return O
