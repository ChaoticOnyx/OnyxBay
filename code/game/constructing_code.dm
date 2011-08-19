
/obj/constructing
	var/list/states = list()
	var/initial_state = ""
	var/current_state = ""

/obj/constructing/proc/use_tool(mob/user, obj/item/weapon/tool, tool_type)
	var/list/state = states[current_state]

	if(tool_type in state)
		var/list/result = state[tool_type]

		if("use_amount" in result)
			if(istype(tool, /obj/item/weapon/sheet))
				if(tool:amount < result["use_amount"])
					user << "There are't enough sheets of material left to continue construction."
					return 1

			else if(istype(tool, /obj/item/weapon/weldingtool))
				if(tool:get_fuel() < result["use_amount"])
					user << "There isn't enough fuel to continue."
					return 1

				else if(!tool:welding)
					user << "You may want to light that first."
					return 1

		if("start_message" in result)
			user << result["start_message"]

		if("wait" in result)
			if(!do_after(user, result["wait"]))
				return 1

		if("use_amount" in result)
			if(istype(tool, /obj/item/weapon/sheet))
				if(!use_sheet(user, tool, result["use_amount"]))
					user << "There are't enough sheets of material left to continue construction."
					return 1

			else if(istype(tool, /obj/item/weapon/weldingtool))
				if(tool:get_fuel() < result["use_amount"])
					user << "There isn't enough fuel to continue."
					return 1

				else if(!tool:welding)
					user << "How can you weld something, if you turn off your welder mid-job?"
					return 1

				else
					tool:use_fuel(result["use_amount"])

			else
				if(state["use_amount"] > 0)
					del tool	//If a tool doesn't support using an amount, just use it entirely

		if("drop" in result)
			create_drops(result["drop"])

		if("create" in result)
			create_drops(result["create"])

		if("done_message" in result)
			user << result["done_message"]

		if("name" in result)
			name = result["name"]

		if("desc" in result)
			desc = result["desc"]

		if(("state" in result) && result["state"])
			set_state(result["state"])

		else
			del src

		return 1

	return 0

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

/obj/constructing/proc/set_state(new_state)
	if(!(new_state in states))
		return

	current_state = new_state
	var/list/state = states[current_state]

	if("icon" in state)
		icon = state["icon"]

	if("icon_state" in state)
		icon = state["icon_state"]

	else
		icon_state = current_state

