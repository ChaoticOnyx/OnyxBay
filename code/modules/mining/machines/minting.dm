#define POWERUSE_PER_MINT 100

/obj/machinery/mineral/mint
	name = "Coin press"

	icon_state = "coinpress-map"
	base_icon_state = "coinpress"

	ea_color = "#ffc400"

	var/list/stored_material = list(MATERIAL_GOLD = 0, MATERIAL_SILVER = 0, MATERIAL_DIAMOND = 0, MATERIAL_PLASMA = 0, MATERIAL_URANIUM = 0, MATERIAL_IRON = 0)
	/// How many coins the machine made in it's last cycle
	var/produced_coins = 0
 	/// Which material will be used to make coins
	var/chosen_material

	component_types = list(
		/obj/item/circuitboard/minting_machine,
		/obj/item/stock_parts/capacitor = 2,
		/obj/item/stock_parts/scanning_module
	)

/obj/machinery/mineral/mint/pickup_item(datum/source, atom/movable/target, atom/old_loc)
	if(!..())
		return

	var/obj/item/stack/material/incoming_material = target
	if(!istype(incoming_material))
		return

	for(var/material in stored_material)
		if(material != incoming_material.default_type)
			continue

		stored_material[material] += incoming_material.amount
		qdel(incoming_material)

/obj/machinery/mineral/mint/Process()
	if(stat & (NOPOWER | BROKEN | POWEROFF))
		STOP_PROCESSING(SSmachines, src)
		return

	if(!chosen_material || stored_material[chosen_material] <= 0)
		return

	for(var/coin_path in subtypesof(/obj/item/material/coin))
		if(initial(coin_path["default_material"]) != chosen_material)
			continue

		stored_material[chosen_material]--
		produced_coins++
		use_power_oneoff(POWERUSE_PER_MINT)
		unload_item(new coin_path)

/obj/machinery/mineral/mint/attack_hand(mob/user)
	if(stat & (NOPOWER | BROKEN)) // Unfortunately we can't simply call parent here as parent checks include POWEROFF flag.
		return

	if(user.lying || user.is_ic_dead())
		return

	if(!ishuman(user) && !issilicon(user))
		to_chat(usr, FEEDBACK_YOU_LACK_DEXTERITY)
		return

	add_fingerprint(user)
	tgui_interact(user)

/obj/machinery/mineral/mint/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CoinPress", name)
		ui.open()

/obj/machinery/mineral/mint/tgui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("toggle_machine")
			toggle()
			return TRUE

		if("change_material")
			produced_coins = 0
			chosen_material = params["material_name"]
			return TRUE

		if("eject_material")
			if(stored_material[params["material_name"]] <= 0)
				return

			var/material/M = get_material_by_name(params["material_name"])
			var/obj/item/stack/material/output_material = new M.stack_type(src)
			output_material.amount = stored_material[params["material_name"]]
			unload_item(output_material)

/obj/machinery/mineral/mint/tgui_data(mob/user)
	var/list/data = list()

	data["chosen_material"] = chosen_material
	data["produced_coins"] = produced_coins
	data["active"] = !(stat & POWEROFF)

	for(var/material in stored_material)
		data["inserted_materials"] += list(list(
			"name" = material,
			"amount" = stored_material[material]
		))

	return data;

#undef POWERUSE_PER_MINT
