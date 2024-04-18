
/* SmartFridge.  Much todo
*/
/obj/machinery/smartfridge
	name = "\improper SmartFridge"
	icon = 'icons/obj/machines/vending/smartfridge.dmi'
	icon_state = "smartfridge"
	layer = BELOW_OBJ_LAYER
	density = 1
	anchored = 1
	idle_power_usage = 5 WATTS
	active_power_usage = 100 WATTS
	atom_flags = ATOM_FLAG_NO_REACT
	var/global/max_n_of_items = 999 // Sorry but the BYOND infinite loop detector doesn't look things over 1000.
	var/icon_on = "smartfridge"
	var/icon_off = "smartfridge-off"
	var/icon_panel = "smartfridge-panel"
	var/list/item_records = list()
	var/datum/stored_items/currently_vending = null	//What we're putting out of the machine.
	var/seconds_electrified = 0;
	var/shoot_inventory = 0
	var/locked = 0
	var/scan_id = 1
	var/is_secure = 0
	var/shows_number_of_items = TRUE // Most machines of this type may show an approximate number of items in their storage
	var/datum/wires/smartfridge/wires = null

/obj/machinery/smartfridge/secure
	is_secure = 1

/obj/machinery/smartfridge/New()
	..()
	if(is_secure)
		wires = new /datum/wires/smartfridge/secure(src)
	else
		wires = new /datum/wires/smartfridge(src)

/obj/machinery/smartfridge/Destroy()
	qdel(wires)
	wires = null
	for(var/datum/stored_items/S in item_records)
		qdel(S)
	item_records = null
	return ..()

/obj/machinery/smartfridge/proc/accept_check(obj/item/O as obj)
	if(istype(O,/obj/item/reagent_containers/food/grown/) || istype(O,/obj/item/seeds/))
		return 1
	return 0

/obj/machinery/smartfridge/seeds
	name = "\improper MegaSeed Servitor"
	desc = "When you need seeds fast!"
	icon = 'icons/obj/machines/vending/seeds.dmi'
	icon_state = "seeds"
	icon_on = "seeds"
	icon_off = "seeds-off"
	shows_number_of_items = FALSE

/obj/machinery/smartfridge/seeds/accept_check(obj/item/O as obj)
	if(istype(O,/obj/item/seeds/))
		return 1
	return 0

/obj/machinery/smartfridge/secure/extract
	name = "\improper Metroid Extract Storage"
	desc = "A refrigerated storage unit for metroid extracts."
	req_access = list(access_research)

/obj/machinery/smartfridge/secure/extract/accept_check(obj/item/O as obj)
	if(istype(O,/obj/item/metroid_extract))
		return TRUE

	if(istype(O,/obj/item/metroidcross))
		return TRUE

	return FALSE

/obj/machinery/smartfridge/secure/medbay
	name = "\improper Refrigerated Medicine Storage"
	desc = "A refrigerated storage unit for storing medicine and chemicals."
	icon_state = "smartfridge" //To fix the icon in the map editor.
	icon_on = "smartfridge_chem"
	req_one_access = list(access_medical,access_chemistry)

/obj/machinery/smartfridge/secure/medbay/accept_check(obj/item/O as obj)
	if(istype(O, /obj/item/reagent_containers/vessel))
		return 1
	if(istype(O, /obj/item/storage/pill_bottle))
		return 1
	if(istype(O, /obj/item/reagent_containers/pill))
		return 1
	return 0

/obj/machinery/smartfridge/secure/virology
	name = "\improper Refrigerated Virus Storage"
	desc = "A refrigerated storage unit for storing viral material."
	req_access = list(access_virology)
	icon_state = "smartfridge_virology"
	icon_on = "smartfridge_virology"

/obj/machinery/smartfridge/secure/virology/accept_check(obj/item/O as obj)
	if(istype(O,/obj/item/reagent_containers/vessel/beaker/vial/))
		return 1
	if(istype(O,/obj/item/virusdish/))
		return 1
	return 0

/obj/machinery/smartfridge/chemistry
	name = "\improper Smart Chemical Storage"
	desc = "A refrigerated storage unit for medicine and chemical storage."

/obj/machinery/smartfridge/chemistry/accept_check(obj/item/O as obj)
	if(istype(O,/obj/item/storage/pill_bottle) || istype(O,/obj/item/reagent_containers))
		return 1
	return 0

/obj/machinery/smartfridge/chemistry/virology
	name = "\improper Smart Virus Storage"
	desc = "A refrigerated storage unit for volatile sample storage."

/obj/machinery/smartfridge/secure/blood
	name = "\improper Smart Blood Storage"
	desc = "A refrigerated storage unit for IV bags, usualy with blood."
	icon_state = "smartfridge_blood"
	icon_on = "smartfridge_blood"
	icon_off = "smartfridge_blood-off"
	req_one_access = list(access_medical,access_chemistry)
	shows_number_of_items = FALSE

/obj/machinery/smartfridge/secure/blood/filled/Initialize()
	. = ..()
	for(var/item_path in starts_with)
		var/quantity = starts_with[item_path]
		for(var/i = 1 to quantity)
			stock_item(new item_path(src))

/obj/machinery/smartfridge/secure/blood/filled
	var/list/starts_with = list(
		/obj/item/reagent_containers/ivbag/blood/OPlus = 1,
		/obj/item/reagent_containers/ivbag/blood/OMinus = 1,
		/obj/item/reagent_containers/ivbag/blood/APlus = 2,
		/obj/item/reagent_containers/ivbag/blood/AMinus = 2,
		/obj/item/reagent_containers/ivbag/blood/BPlus = 2,
		/obj/item/reagent_containers/ivbag/blood/BMinus = 2,
		/obj/item/reagent_containers/ivbag = 2
		)

/obj/machinery/smartfridge/secure/blood/accept_check(obj/item/O)
	if(istype(O, /obj/item/reagent_containers/ivbag))
		return TRUE
	return FALSE

/obj/machinery/smartfridge/drinks
	name = "\improper Drink Showcase"
	desc = "A refrigerated storage unit for tasty tasty alcohol."

/obj/machinery/smartfridge/drinks/accept_check(obj/item/O as obj)
	if(istype(O,/obj/item/reagent_containers/vessel))
		return 1

/obj/machinery/smartfridge/secure/food
	name = "\improper Refrigerated Food Showcase"
	desc = "A refrigerated storage unit for tasty tasty food."
	req_access = list(access_kitchen)

/obj/machinery/smartfridge/secure/food/accept_check(obj/item/O as obj)
	if(istype(O,/obj/item/reagent_containers/food))
		return 1
	return 0

/obj/machinery/smartfridge/drying_rack
	name = "\improper Drying Rack"
	desc = "A machine for drying plants."
	icon = 'icons/obj/machines/vending/drying.dmi'
	icon_state = "drying_rack"
	icon_on = "drying_rack_on"
	icon_off = "drying_rack"

/obj/machinery/smartfridge/drying_rack/accept_check(obj/item/O as obj)
	if(istype(O, /obj/item/reagent_containers/food/))
		var/obj/item/reagent_containers/food/S = O
		if (S.dried_type)
			return 1
	return 0

/obj/machinery/smartfridge/drying_rack/Process()
	..()
	if(inoperable())
		return
	if(contents.len)
		dry()
		update_icon()

/obj/machinery/smartfridge/drying_rack/on_update_icon()
	ClearOverlays()
	if(inoperable())
		icon_state = icon_off
	else
		icon_state = icon_on
	if(contents.len)
		AddOverlays("drying_rack_filled")
		if(!inoperable())
			AddOverlays("drying_rack_drying")

/obj/machinery/smartfridge/drying_rack/proc/dry()
	for(var/datum/stored_items/I in item_records)
		for(var/obj/item/reagent_containers/food/S in I.instances)
			if(S.dry || !I.get_specific_product(get_turf(src), S)) continue
			if(S.dried_type == S.type)
				S.dry = 1
				S.SetName("dried [S.name]")
				S.color = "#a38463"
				stock_item(S)
			else
				var/D = S.dried_type
				new D(get_turf(src))
				qdel(S)
			return

/obj/machinery/smartfridge/Process()
	if(stat & (BROKEN|NOPOWER))
		return
	if(src.seconds_electrified > 0)
		src.seconds_electrified--
	if(src.shoot_inventory && prob(2))
		src.throw_item()

/obj/machinery/smartfridge/on_update_icon()
	if(stat & (BROKEN|NOPOWER))
		icon_state = icon_off // Some of them don't have any display cases thus not requiring an overlay
	else
		icon_state = icon_on
	if(shows_number_of_items)
		ClearOverlays()
		if(stat & (BROKEN|NOPOWER))
			AddOverlays(icon_off) // The use of overlays allows us to see how much is stored inside, even if the machine happens to be unpowered
		switch(contents.len)
			if(0)
				icon_state = icon_on
			if(1 to 25)
				icon_state = "[icon_on]1" // 1/4 loaded
			if(26 to 75)
				icon_state = "[icon_on]2" // half-loaded
			if(76 to INFINITY)
				icon_state = "[icon_on]3" // "full"
	else
/*******************
*   Item Adding
********************/

/obj/machinery/smartfridge/attackby(obj/item/O as obj, mob/user as mob)
	if(isScrewdriver(O))
		panel_open = !panel_open
		user.visible_message("[user] [panel_open ? "opens" : "closes"] the maintenance panel of \the [src].", "You [panel_open ? "open" : "close"] the maintenance panel of \the [src].")
		ClearOverlays()
		if(panel_open)
			AddOverlays(image(icon, icon_panel))
		SSnano.update_uis(src)
		return

	if(isMultitool(O) || isWirecutter(O))
		if(panel_open)
			attack_hand(user)
		return

	if(stat & NOPOWER)
		to_chat(user, SPAN_NOTICE("\The [src] is unpowered and useless."))
		return

	if(accept_check(O))
		if(!user.drop(O))
			return
		stock_item(O)
		update_icon()
		user.visible_message(SPAN_NOTICE("\The [user] has added \the [O] to \the [src]."), SPAN_NOTICE("You add \the [O] to \the [src]."))

	else if(istype(O, /obj/item/storage))
		var/obj/item/storage/bag/P = O
		var/plants_loaded = 0
		for(var/obj/G in P.contents)
			if(accept_check(G) && P.remove_from_storage(G, src))
				plants_loaded++
				stock_item(G)
				update_icon()

		if(plants_loaded)
			user.visible_message(SPAN_NOTICE("\The [user] loads \the [src] with the contents of \the [P]."), SPAN_NOTICE("You load \the [src] with the contents of \the [P]."))
			if(P.contents.len > 0)
				to_chat(user, SPAN_NOTICE("Some items were refused."))

	else
		to_chat(user, SPAN_NOTICE("\The [src] smartly refuses [O]."))
	return 1

/obj/machinery/smartfridge/secure/emag_act(remaining_charges, mob/user)
	if(!emagged)
		playsound(src.loc, 'sound/effects/computer_emag.ogg', 25)
		emagged = 1
		locked = -1
		to_chat(user, "You short out the product lock on [src].")
		return 1

/obj/machinery/smartfridge/proc/stock_item(obj/item/O)
	for(var/datum/stored_items/I in item_records)
		if(istype(O, I.item_path) && O.name == I.item_name)
			stock(I, O)
			return

	var/datum/stored_items/I = new /datum/stored_items(src, O.type, O.name)
	dd_insertObjectList(item_records, I)
	stock(I, O)

/obj/machinery/smartfridge/proc/stock(datum/stored_items/I, obj/item/O)
	I.add_product(O)
	SSnano.update_uis(src)

/obj/machinery/smartfridge/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/smartfridge/attack_hand(mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return
	wires.Interact(user)
	ui_interact(user)

/*******************
*   SmartFridge Menu
********************/

/obj/machinery/smartfridge/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	user.set_machine(src)

	var/data[0]
	data["contents"] = null
	data["electrified"] = seconds_electrified > 0
	data["shoot_inventory"] = shoot_inventory
	data["locked"] = locked
	data["secure"] = is_secure

	var/list/items[0]
	for (var/i=1 to length(item_records))
		var/datum/stored_items/I = item_records[i]
		var/count = I.get_amount()
		if(count > 0)
			items.Add(list(list("display_name" = html_encode(capitalize(I.item_name)), "vend" = i, "quantity" = count)))

	if(items.len > 0)
		data["contents"] = items

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "smartfridge.tmpl", src.name, 400, 500)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/smartfridge/Topic(href, href_list)
	if(..()) return 0

	var/mob/user = usr
	var/datum/nanoui/ui = SSnano.get_open_ui(user, src, "main")

	if(href_list["close"])
		user.unset_machine()
		ui.close()
		return 0

	if(href_list["vend"])
		var/index = text2num(href_list["vend"])
		var/amount = text2num(href_list["amount"])
		var/datum/stored_items/I = item_records[index]
		var/count = I.get_amount()

		// Sanity check, there are probably ways to press the button when it shouldn't be possible.
		if(count > 0)
			if((count - amount) < 0)
				amount = count
			for(var/i = 1 to amount)
				I.get_product(get_turf(src), user)
			update_icon()

		return 1
	return 0

/obj/machinery/smartfridge/proc/throw_item()
	var/obj/throw_item = null
	var/mob/living/target = locate() in view(7,src)
	if(!target)
		return 0

	for(var/datum/stored_items/I in src.item_records)
		throw_item = I.get_product(loc)
		if (!throw_item)
			continue
		break

	if(!throw_item)
		return 0
	throw_item.throw_at(target, 16, null, src)
	update_icon()
	visible_message(SPAN_WARNING("[src] launches [throw_item.name] at [target.name]!"))
	return 1

/************************
*   Secure SmartFridges
*************************/

/obj/machinery/smartfridge/secure/Topic(href, href_list)
	if(stat & (NOPOWER|BROKEN)) return 0
	if(usr.contents.Find(src) || (in_range(src, usr) && istype(loc, /turf)))
		if(!allowed(usr) && !emagged && scan_id && href_list["vend"])
			to_chat(usr, SPAN_WARNING("Access denied."))
			return 0
	return ..()
