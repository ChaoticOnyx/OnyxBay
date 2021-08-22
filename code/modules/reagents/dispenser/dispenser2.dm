/obj/machinery/chemical_dispenser
	name = "chemical dispenser"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "dispenser"
	layer = BELOW_OBJ_LAYER
	clicksound = "button"
	clickvol = 20

	var/list/spawn_cartridges = null // Set to a list of types to spawn one of each on New()

	var/list/cartridges = list() // Associative, label -> cartridge
	var/obj/item/weapon/reagent_containers/beaker = null

	var/ui_title = "Chemical Dispenser"

	var/accept_drinking = 0
	var/amount = 5

	component_types = list(
		/obj/item/weapon/circuitboard/chemical_dispenser,
		/obj/item/device/healthanalyzer,
		/obj/item/weapon/stock_parts/scanning_module = 2,
		/obj/item/weapon/stock_parts/manipulator = 4,
		/obj/item/weapon/stock_parts/console_screen,
	)

	idle_power_usage = 100
	density = 1
	anchored = 1
	obj_flags = OBJ_FLAG_ANCHORABLE

	var/list/recording_recipe
	var/list/saved_recipes = list()

/obj/machinery/chemical_dispenser/Initialize()
	. = ..()
	if(spawn_cartridges)
		for(var/type in spawn_cartridges)
			add_cartridge(new type(src))

/obj/machinery/chemical_dispenser/examine(mob/user)
	. = ..()
	. += "\nIt has [cartridges.len] cartridges installed, and has space for [DISPENSER_MAX_CARTRIDGES - cartridges.len] more."

/obj/machinery/chemical_dispenser/proc/add_cartridge(obj/item/weapon/reagent_containers/chem_disp_cartridge/C, mob/user)
	if(!istype(C))
		if(user)
			to_chat(user, "<span class='warning'>\The [C] will not fit in \the [src]!</span>")
		return

	if(cartridges.len >= DISPENSER_MAX_CARTRIDGES)
		if(user)
			to_chat(user, "<span class='warning'>\The [src] does not have any slots open for \the [C] to fit into!</span>")
		return

	if(!C.label)
		if(user)
			to_chat(user, "<span class='warning'>\The [C] does not have a label!</span>")
		return

	if(cartridges[C.label])
		if(user)
			to_chat(user, "<span class='warning'>\The [src] already contains a cartridge with that label!</span>")
		return

	if(user)
		user.drop_from_inventory(C)
		to_chat(user, "<span class='notice'>You add \the [C] to \the [src].</span>")

	C.loc = src
	cartridges[C.label] = C
	cartridges = sortAssoc(cartridges)

/obj/machinery/chemical_dispenser/proc/remove_cartridge(label)
	. = cartridges[label]
	cartridges -= label

/obj/machinery/chemical_dispenser/attackby(obj/item/weapon/W, mob/user)
	if(default_deconstruction_crowbar(user, W))
		return
	if(default_part_replacement(user, W))
		return

	if(istype(W, /obj/item/weapon/reagent_containers/chem_disp_cartridge))
		add_cartridge(W, user)

	else if(isScrewdriver(W))
		if(!length(cartridges) && default_deconstruction_screwdriver(user, W))
			return
		var/label = input(user, "Which cartridge would you like to remove?", "Chemical Dispenser") as null|anything in cartridges
		if(!label) return
		var/obj/item/weapon/reagent_containers/chem_disp_cartridge/C = remove_cartridge(label)
		if(C)
			to_chat(user, "<span class='notice'>You remove \the [C] from \the [src].</span>")
			C.loc = loc

	else if(istype(W, /obj/item/weapon/reagent_containers/glass) || istype(W, /obj/item/weapon/reagent_containers/food))
		if(beaker)
			to_chat(user, SPAN_WARNING("There is already \a [beaker] on \the [src]!"))
			return

		var/obj/item/weapon/reagent_containers/RC = W

		if(!accept_drinking && istype(RC,/obj/item/weapon/reagent_containers/food))
			to_chat(user, "<span class='warning'>This machine only accepts beakers!</span>")
			return

		if(istype(RC,/obj/item/weapon/reagent_containers/glass/bucket))
			to_chat(user, "<span class='warning'>This machine only accepts beakers!</span>")
			return

		if(!RC.is_open_container())
			to_chat(user, "<span class='warning'>You don't see how \the [src] could dispense reagents into \the [RC].</span>")
			return

		beaker =  RC
		user.drop_from_inventory(RC)
		RC.loc = src
		update_icon()
		to_chat(user, "<span class='notice'>You set \the [RC] on \the [src].</span>")
		SStgui.update_uis(src)

	else
		..()
	return

/obj/machinery/chemical_dispenser/tgui_data(mob/user)
	var/list/data = list()
	data["amount"] = amount
	data["isBeakerLoaded"] = !!beaker

	var/list/beakerContents = list()
	var/beakerCurrentVolume = 0
	if(beaker && beaker.reagents && beaker.reagents.reagent_list.len)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents.Add(list(list("name" = R.name, "volume" = round(R.volume, MINIMUM_CHEMICAL_VOLUME)))) // list in a list because Byond merges the first list...
			beakerCurrentVolume += R.volume
	data["beakerContents"] = beakerContents

	if (beaker)
		data["beakerCurrentVolume"] = round(beakerCurrentVolume, 0.01)
		data["beakerMaxVolume"] = beaker.volume
		data["beakerTransferAmounts"] = splittext(beaker.possible_transfer_amounts, ";")
	else
		data["beakerCurrentVolume"] = null
		data["beakerMaxVolume"] = null
		data["beakerTransferAmounts"] = null

	var/list/chemicals = list()
	for(var/label in cartridges)
		chemicals += label
	data["chemicals"] = chemicals

	return data

/obj/machinery/chemical_dispenser/tgui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("amount")
			var/target = text2num(params["target"])
			amount = between(0, target, 120)
			. = TRUE
		if("dispense")
			var/reagent_name = params["reagent"]
			var/obj/item/weapon/reagent_containers/chem_disp_cartridge/cartridge = cartridges[reagent_name]
			if(!(beaker && cartridge))
				return
			var/datum/reagents/holder = beaker.reagents
			var/to_dispense = between(0, holder.maximum_volume - holder.total_volume, amount)
			playsound(loc, 'sound/effects/using/sink/fast_filling1.ogg', 75)
			cartridge.reagents.trans_to_holder(holder, to_dispense)
			. = TRUE
		if("eject")
			var/obj/item/weapon/reagent_containers/B = beaker
			if(!B)
				return
			B.dropInto(loc)
			beaker = null
			update_icon()
			. = TRUE



/obj/machinery/chemical_dispenser/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Dispenser")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/chemical_dispenser/attack_ai(mob/user as mob)
	tgui_interact(user)

/obj/machinery/chemical_dispenser/attack_hand(mob/user as mob)
	tgui_interact(user)

/obj/machinery/chemical_dispenser/update_icon()
	overlays.Cut()
	if(beaker)
		var/mutable_appearance/beaker_overlay
		beaker_overlay = image('icons/obj/chemical.dmi', src, "lil_beaker")
		beaker_overlay.pixel_x = rand(-10, 5)
		overlays += beaker_overlay
