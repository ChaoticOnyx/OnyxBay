/obj/machinery/cell_charger
	name = "heavy-duty cell charger"
	desc = "A much more powerful version of the standard recharger that is specially designed for charging power cells."
	icon = 'icons/obj/power.dmi'
	icon_state = "ccharger0"
	anchored = 1
	idle_power_usage = 5
	active_power_usage = 60 KILOWATTS	//This is the power drawn when charging
	power_channel = STATIC_EQUIP
	var/obj/item/cell/charging = null
	var/chargelevel = -1

	component_types = list(
		/obj/item/circuitboard/cell_charger,
		/obj/item/stock_parts/capacitor
	)

/obj/machinery/cell_charger/update_icon()
	icon_state = "ccharger[charging ? 1 : 0]"
	if(charging)
		overlays.Cut()
		if(charging.icon == icon)
			overlays += charging.icon_state
		else
			overlays += "cell"
		overlays += "ccharger-wires"
		if(!(stat & (BROKEN|NOPOWER)))
			chargelevel = round(charging.percent() * 4.0 / 99)
			overlays += "ccharger-o[chargelevel]"
	else
		overlays.Cut()

/obj/machinery/cell_charger/_examine_text(mob/user)
	. = ..()
	if(get_dist(src, user) > 5)
		return

	. += "\nThere's [charging ? "a" : "no"] cell in the charger."
	if(charging)
		. += "\nCurrent charge: [charging.charge]"

/obj/machinery/cell_charger/attackby(obj/item/W, mob/user)
	if(stat & BROKEN)
		return

	if(istype(W, /obj/item/cell) && anchored)
		if(charging)
			to_chat(user, "<span class='warning'>There is already a cell in the charger.</span>")
			return
		else
			var/area/a = get_area(loc)
			if(a.power_equip == 0) // There's no APC in this area, don't try to cheat power!
				to_chat(user, "<span class='warning'>The [name] blinks red as you try to insert the cell!</span>")
				return
			user.drop_item()
			W.forceMove(src)
			charging = W
			set_power()
			START_PROCESSING(SSmachines, src)
			user.visible_message("[user] inserts a cell into the charger.", "You insert a cell into the charger.")
			chargelevel = -1
		queue_icon_update()

	if(isScrewdriver(W) || isCrowbar(W) || isWrench(W))
		if(charging)
			to_chat(user, "<span class='warning'>Remove the cell first!</span>")
			return
		if(default_deconstruction_screwdriver(user, W))
			return
		if(default_deconstruction_crowbar(user, W))
			return
		if(isWrench(W))
			anchored = !anchored
			set_power()
			to_chat(user, "You [anchored ? "attach" : "detach"] the cell charger [anchored ? "to" : "from"] the ground")
			playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
	if(default_part_replacement(user, W))
		return

/obj/machinery/cell_charger/attack_hand(mob/user)
	if(charging)
		user.put_in_hands(charging)
		charging.add_fingerprint(user)
		charging.update_icon()

		src.charging = null
		user.visible_message("[user] removes the cell from the charger.", "You remove the cell from the charger.")
		chargelevel = -1
		update_icon()

/obj/machinery/cell_charger/attack_ai(mob/user)
	if(istype(user, /mob/living/silicon/robot) && Adjacent(user)) // Borgs can remove the cell if they are near enough
		if(!src.charging)
			return

		charging.loc = src.loc
		charging.update_icon()
		charging = null
		user.visible_message("[user] removes the cell from the charger.", "You remove the cell from the charger.")
		chargelevel = -1
		set_power()
		STOP_PROCESSING(SSmachines, src)

/obj/machinery/cell_charger/attack_robot(mob/user)
	if(Adjacent(user)) // Borgs can remove the cell if they are near enough
		attack_hand(user)

/obj/machinery/cell_charger/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		return
	if(charging)
		charging.emp_act(severity)
	..(severity)

/obj/machinery/cell_charger/power_change()
	if(..())
		set_power()

/obj/machinery/cell_charger/proc/set_power()
	if((stat & (BROKEN|NOPOWER)) || !anchored)
		update_use_power(POWER_USE_OFF)
		return
	if (charging && !charging.fully_charged())
		update_use_power(POWER_USE_ACTIVE)
	else
		update_use_power(POWER_USE_IDLE)
	queue_icon_update()

/obj/machinery/cell_charger/Process()
	if(!charging)
		return PROCESS_KILL
	if(stat & NOPOWER)
		return
	charging.give(active_power_usage*CELLRATE)
	update_icon()
