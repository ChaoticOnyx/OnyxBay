/obj/item/weapon/storage/briefcase
	name = "briefcase"
	desc = "It's made of AUTHENTIC faux-leather and has a price-tag still attached. Its owner must be a real professional."
	icon_state = "briefcase"
	item_state = "briefcase"
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	force = 8.0
	throw_speed = 1
	throw_range = 4
	w_class = ITEM_SIZE_HUGE
	mod_weight = 1.5
	mod_reach = 0.75
	mod_handy = 1.0
	max_w_class = ITEM_SIZE_NORMAL
	max_storage_space = DEFAULT_BACKPACK_STORAGE

/obj/item/weapon/storage/briefcase/iaa
	startswith = list(/obj/item/weapon/paper/trade_lic/trade_guide,\
	/obj/item/weapon/folder/nt,\
	/obj/item/weapon/pen,\
	/obj/item/device/camera)

// Syndicate Teleportation Device

/obj/item/weapon/storage/briefcase/std
	desc = "It's an old-looking briefcase with some high-tech markings. It has a label on it, which reads: \"ONLY WORKS NEAR SPACE\"."
	origin_tech = list(TECH_BLUESPACE = 3, TECH_ILLEGAL = 3)
	var/obj/item/device/uplink/uplink
	var/authentication_complete = FALSE
	var/del_on_send = TRUE

/obj/item/weapon/storage/briefcase/std/attackby(obj/item/I, mob/user)
	if(I.hidden_uplink)
		visible_message("\The [src] blinks green!")
		uplink = I.hidden_uplink
		authentication_complete = TRUE
	..()

/obj/item/weapon/storage/briefcase/std/proc/can_launch()
	return authentication_complete && (locate(/turf/space) in view(get_turf(src)))

/obj/item/weapon/storage/briefcase/std/attack_self(mob/user)
	ui_interact(user)

/obj/item/weapon/storage/briefcase/std/interact(mob/user)
	ui_interact(user)

/obj/item/weapon/storage/briefcase/std/proc/ui_data(mob/user)
	var/list/list/data = list()

	data["can_launch"] = can_launch()
	data["fixer"] = GLOB.traitors.fixer.name
	data["owner"] = uplink.uplink_owner ? uplink.uplink_owner.name : "Unknown"
	data["is_owner"] = uplink.uplink_owner && (uplink.uplink_owner == user.mind)
	data["contracts"] = list()

	for(var/datum/antag_contract/item/C in GLOB.traitors.fixer.return_contracts())
		if(!C.check(src))
			continue
		data["contracts"].Add(list(list(
			"name" = C.name,
			"desc" = C.desc,
			"reward" = C.reward
		)))

	return data

/obj/item/weapon/storage/briefcase/std/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	if(!authentication_complete)
		audible_message("\The [src] blinks red.")
		return
	var/list/data = ui_data(user)

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "std.tmpl", "[name]", 400, 430)
		ui.set_initial_data(data)
		ui.open()

/obj/item/weapon/storage/briefcase/std/Topic(href, href_list)
	if(usr.incapacitated() || !Adjacent(usr) || isobserver(usr))
		return

	if(!authentication_complete)
		return FALSE

	if(href_list["launch"])
		if(!can_launch())
			return FALSE

		for(var/datum/antag_contract/item/C in GLOB.all_contracts)
			if(C.completed)
				continue
			C.on_container(src)
		for(var/obj/item/I in contents)
			if(I.hidden_uplink == uplink)
				remove_from_storage(I, get_turf(src))
				continue
			qdel(I)
		contents = list()
		if(del_on_send)
			if(ishuman(loc))
				var/mob/living/carbon/human/H = loc
				H.drop_from_inventory(src, get_turf(src))
				to_chat(loc, SPAN("notice", "\The [src] fades away in a brief flash of light."))
			qdel(src)

	if(.)
		SSnano.update_uis(src)
