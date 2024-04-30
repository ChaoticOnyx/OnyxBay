/datum/component/uplink
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/name = "syndicate uplink"
	var/ui_style = "Uplink"
	var/active = FALSE
	var/lockable = TRUE
	var/locked = TRUE
	var/allow_restricted = TRUE
	var/telecrystals
	var/list/uplink_items
	var/datum/mind/owner = null
	var/datum/game_mode/gamemode
	var/datum/uplink_purchase_log/purchase_log
	var/unlock_code
	var/unlock_emote
	var/traitor_frequency
	var/debug = FALSE
	var/exploit_uid = null
	// Can STD be purchased for free
	var/complimentary_std = TRUE

/datum/component/uplink/Initialize(owner, lockable = TRUE, active = FALSE, datum/game_mode/gamemode, starting_tc = DEFAULT_TELECRYSTAL_AMOUNT)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	GLOB.uplinks += src

	src.owner = owner
	src.lockable = lockable
	src.active = active
	src.gamemode = gamemode
	telecrystals = starting_tc
	if(!lockable)
		active = TRUE
		locked = FALSE

/datum/component/uplink/inherit_component(datum/component/uplink/U)
	lockable |= U.lockable
	active |= U.active
	if(!gamemode)
		gamemode = U.gamemode
	telecrystals += U.telecrystals

/datum/component/uplink/Destroy()
	GLOB.uplinks -= src
	gamemode = null
	return ..()

/datum/component/uplink/proc/LoadTC(mob/user, obj/item/stack/TC, silent = FALSE)
	if(!silent)
		to_chat(user, SPAN_NOTICE("You slot [TC] into [parent] and charge its internal uplink."))
	var/amt = TC.amount
	telecrystals += amt
	TC.use(amt)

/datum/component/uplink/proc/set_gamemode(_gamemode)
	gamemode = _gamemode

/datum/component/uplink/proc/interact(mob/user)
	if(locked)
		return

	active = TRUE
	if(user)
		tgui_interact(user)

/datum/component/uplink/tgui_state(mob/user)
	return GLOB.tgui_inventory_state

/datum/component/uplink/tgui_interact(mob/user, datum/tgui/ui)
	active = TRUE
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, ui_style, name)
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/component/uplink/tgui_data(mob/user)
	if(!user.mind)
		return

	var/list/data = list(
		"telecrystals" = telecrystals,
		"lockable" = lockable,
		"selectedExploitUID" = exploit_uid,
	)

	data["exploitData"] = list()
	if(!isnull(exploit_uid))
		for(var/datum/computer_file/crew_record/L in GLOB.all_crew_records)
			if(L.uid != exploit_uid)
				continue

			var/list/fields = list(
				REC_FIELD(name),
				REC_FIELD(sex),
				REC_FIELD(age),
				REC_FIELD(species),
				REC_FIELD(homeSystem),
				REC_FIELD(background),
				REC_FIELD(religion),
				REC_FIELD(fingerprint),
				REC_FIELD(antagRecord))
			var/list/rec_fields = list()
			for(var/field in fields)
				var/record_field/F = locate(field) in L.fields
				if(!F)
					continue

				rec_fields[html_encode(F.name)] += list(F.get_display_value())

			data["exploitData"] += rec_fields
			break

	return data

/datum/component/uplink/tgui_static_data(mob/user)
	var/list/data = list()

	var/list/all_contracts = list()
	for(var/datum/antag_contract/AC in GLOB.traitors.fixer.return_contracts(user?.mind))
		all_contracts[AC.category] += list(list(
			"name" = AC.name,
			"category" = AC.category,
			"desc" = AC.desc,
			"reward" = AC.reward,
			))

	data["contractCategories"] = list()
	for(var/category in GLOB.contract_categories)
		data["contractCategories"] += list(list(
			"name" = category,
			"contracts" = LAZYCOPY(all_contracts[category]),
		))

	uplink_items = get_uplink_items(src, allow_sales = TRUE)

	data["itemCategories"] = list()
	for(var/category in uplink_items)
		var/list/cat = list(
			"name" = capitalize(replacetext(replacetext("[category]", "/datum/uplink_category/", ""), "_", " "))
		)

		for(var/item in uplink_items[category])
			var/datum/uplink_item/I = uplink_items[category][item]
			if(LAZYLEN(I.job_specific))
				var/is_inaccessible = TRUE
				for(var/R in I.job_specific)
					if(R == user.mind.assigned_role || debug)
						is_inaccessible = FALSE
				if(is_inaccessible)
					continue

			cat["items"] += list(list(
				"name" = I.name,
				"cost" = I.cost(telecrystals, src),
				"desc" = I.desc,
				"path" = replacetext(replacetext("[I.path]", "/obj/item/", ""), "/", "-"),
			))

		data["itemCategories"] += list(cat)

	data["crewRecords"] = list()
	for(var/datum/computer_file/crew_record/L in GLOB.all_crew_records)
		data["crewRecords"] += list(list(
			"name" = L.get_name(),
			"uid" = L.uid,
		))

	return data

/datum/component/uplink/tgui_act(action, params)
	. = ..()
	if(.)
		return

	if(!active)
		return

	switch(action)
		if("buy")
			var/item_name = params["name"]
			var/list/buyable_items = list()
			for(var/category in uplink_items)
				buyable_items += uplink_items[category]
			if(item_name in buyable_items)
				var/datum/uplink_item/I = buyable_items[item_name]
				MakePurchase(usr, I)
				return TRUE

		if("lock")
			active = FALSE
			locked = TRUE
			SStgui.close_uis(src)
			return TRUE

		if("select_exploit")
			var/old_exploit_uid = exploit_uid
			exploit_uid = text2num(params["uid"])
			if(exploit_uid == old_exploit_uid)
				exploit_uid = null
			return TRUE

/datum/component/uplink/proc/MakePurchase(mob/user, datum/uplink_item/U)
	if(!istype(U))
		return

	if(!user || user.incapacitated())
		return

	if(telecrystals < U.cost(telecrystals, src))
		return

	U.buy(src, user)
