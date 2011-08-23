
/obj/constructing
	var/list/states = list()
	var/initial_state = ""
	var/current_state = ""



/obj/constructing/proc/use_tool(mob/user, obj/item/weapon/tool, tool_type)
	var/list/state = states[current_state]

	if(tool_type in state)
		var/list/result = state[tool_type]

		if(result["use_amount"] > 0)
			if(!has_amount(user, tool, result["use_amount"]))
				return 1

		if(result["start_message"])
			user << result["start_message"]

		if(result["wait"])
			if(!do_after(user, result["wait"]))
				return 1

		if(result["use_amount"] > 0)
			if(!use_amount(user, tool, result["use_amount"]))
				return 1

		if(result["drop"])
			create_drops(result["drop"])

		if(result["create"])
			create_drops(result["create"])

		if(result["done_message"])
			user << result["done_message"]

		if(result["state"])
			set_state(result["state"])
			apply_properties(result)

		else
			del src

		return 1

	return 0



/obj/constructing/proc/set_state(new_state)
	if(!(new_state in states))
		return

	current_state = new_state
	icon_state = new_state //Unless otherwise specified, use the new state as the icon state.

	apply_properties(states[new_state])



/obj/constructing/proc/apply_properties(list/node)

	for(var/property in list("icon", "icon_state", "name", "desc", "anchored", "density", "opacity"))
		if(property in node)
			vars[property] = node[property]



/obj/constructing/New(location, state = initial_state)
	..()
	set_state(state)



/obj/constructing/attackby(obj/C, mob/user)
	var/list/tools = list(
		/obj/item/weapon/crowbar = "crowbar",
		/obj/item/weapon/screwdriver = "screwdriver",
		/obj/item/weapon/sheet/metal = "metal",
		/obj/item/weapon/sheet/glass = "glass",
		/obj/item/weapon/sheet/r_metal = "rmetal",
		/obj/item/weapon/sheet/rglass = "rglass",
		/obj/item/weapon/wirecutters = "wirecutters",
		/obj/item/weapon/weldingtool = "weldingtool",
		/obj/item/weapon/wrench = "wrench",
	)

	if(C.type in tools)
		if(use_tool(user, C, tools[C.type]))
			return

	else
		if(use_tool(user, C, C.type))
			return

	..(C, user)



/obj/constructing/attack_hand(mob/user as mob)
	..(user)

	use_tool(user, null, "hand")



/obj/constructing/proc/create_drops(list/drops)
	for(var/type in drops)
		new type(loc)



/obj/constructing/proc/use_sheet(mob/user, obj/item/weapon/sheet/tool, amount_needed)
	if(tool.amount < amount_needed)
		return 0

	if(amount_needed > 0)
		tool.amount -= amount_needed

		if(tool.amount == 0)
			del tool

	return 1



/obj/constructing/proc/has_amount(mob/user, obj/item/weapon/tool, amount_required)

	if(istype(tool, /obj/item/weapon/sheet))
		if(tool:amount < amount_required)
			user << "There are't enough sheets of material left to continue construction."
			return 0

	else if(istype(tool, /obj/item/weapon/weldingtool))
		if(tool:get_fuel() < amount_required)
			user << "There isn't enough fuel to continue."
			return 0

		else if(!tool:welding)
			user << "You may want to light that first."
			return 0

	return 1



/obj/constructing/proc/use_amount(mob/user, obj/item/weapon/tool, amount_used)

	if(istype(tool, /obj/item/weapon/sheet))
		if(!use_sheet(user, tool, amount_used))
			user << "There are't enough sheets of material left to continue construction."
			return 0

	else if(istype(tool, /obj/item/weapon/weldingtool))
		if(tool:get_fuel() < amount_used)
			user << "There isn't enough fuel to continue."
			return 0

		else if(!tool:welding)
			user << "How can you weld something, if you turn off your welder mid-job?"
			return 0

		else
			tool:use_fuel(amount_used)

	else
		del tool	//If a tool doesn't support using an amount, just use it entirely

	return 1