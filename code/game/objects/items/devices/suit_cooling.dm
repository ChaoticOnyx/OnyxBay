/obj/item/device/suit_cooling_unit
	name = "portable cooling unit"
	desc = "A large portable heat sink with liquid cooled radiator packaged into a modified backpack."
	description_info = "You may wear this instead of your packpack to cool yourself down. \
	It allows them to go into low pressure environments for more than few seconds without overheating. It runs off energy provided by an internal power cell. \
	Remember to turn it on by clicking it when it's your in your hand before you put it on."
	description_fluff = "Before the advent of ultra-heat-resistant fibers and flexible alloyed shielding, portable coolers were most commonly used to keep technicians from roasting alive in their suits. Nowadays they have been repurposed to keep IPCs from overheating in vacuum environments."

	w_class = ITEM_SIZE_LARGE
	icon = 'icons/obj/suitcooler.dmi'
	icon_state = "suitcooler0"
	item_state = "coolingpack"			// beautiful codersprites until someone makes a prettier one.
	slot_flags = SLOT_BACK

	//copied from tank.dm
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	force = 5.0
	throwforce = 10.0
	throw_range = 4
	throw_speed = 2
	action_button_name = "Toggle Heatsink"

	matter = list(MATERIAL_STEEL = 15000, MATERIAL_GLASS = 3500)
	origin_tech = list(TECH_MAGNET = 2, TECH_MATERIAL = 2)

	var/on = 0								//is it turned on?
	var/cover_open = 0						//is the cover open?
	var/obj/item/cell/cell
	var/max_cooling = 12					// in degrees per second - probably don't need to mess with heat capacity here
	var/charge_consumption = 2 KILO WATTS	// energy usage at full power
	var/thermostat = 20 CELSIUS

/obj/item/device/suit_cooling_unit/ui_action_click()
	toggle(usr)

/obj/item/device/suit_cooling_unit/Initialize()
	. = ..()
	cell = new /obj/item/cell/high(src)
	if(on)
		set_next_think(world.time)

/obj/item/device/suit_cooling_unit/Destroy()
	QDEL_NULL(cell)
	return ..()

/obj/item/device/suit_cooling_unit/think()
	if (!on || !cell)
		turn_off(1)
		return

	if (!is_in_slot())
		turn_off(1)
		return

	var/mob/living/carbon/human/H = loc

	var/temp_adj = min(H.bodytemperature - thermostat, max_cooling)

	if (temp_adj < 0.5)	//only cools, doesn't heat, also we don't need extreme precision
		set_next_think(world.time + 1 SECOND)
		return

	var/charge_usage = (temp_adj/max_cooling)*charge_consumption

	H.bodytemperature -= temp_adj

	cell.use(charge_usage * CELLRATE)
	update_icon()

	if(cell.charge <= 0)
		turn_off(1)
		return

	set_next_think(world.time + 1 SECOND)

// Checks whether the cooling unit is being worn on the back/suit slot.
// That way you can't carry it in your hands while it's running to cool yourself down.
/obj/item/device/suit_cooling_unit/proc/is_in_slot()
	var/mob/living/carbon/human/H = loc
	if(!istype(H))
		return 0

	return (H.back == src) || (H.s_store == src)

/obj/item/device/suit_cooling_unit/proc/turn_on()
	if(!cell)
		return
	if(cell.charge <= 0)
		return

	on = 1
	update_icon()
	set_next_think(world.time)

/obj/item/device/suit_cooling_unit/proc/turn_off(failed)
	if(failed) visible_message("\The [src] clicks and whines as it powers down.")
	on = 0
	update_icon()
	set_next_think(0)

/obj/item/device/suit_cooling_unit/attack_self(mob/user)
	if(cover_open && cell)
		if(ishuman(user))
			user.pick_or_drop(cell)
		else
			cell.forceMove(get_turf(src))

		cell.add_fingerprint(user)
		cell.update_icon()

		to_chat(user, "You remove \the [src.cell].")
		src.cell = null
		update_icon()
		return

	toggle(user)

/obj/item/device/suit_cooling_unit/proc/toggle(mob/user)
	if(on)
		turn_off()
	else
		turn_on()
	to_chat(user, "<span class='notice'>You switch \the [src] [on ? "on" : "off"].</span>")

/obj/item/device/suit_cooling_unit/attackby(obj/item/W as obj, mob/user as mob)
	if(isScrewdriver(W))
		if(cover_open)
			cover_open = 0
			to_chat(user, "You screw the panel into place.")
		else
			cover_open = 1
			to_chat(user, "You unscrew the panel.")
		update_icon()
		return

	if (istype(W, /obj/item/cell))
		if(cover_open)
			if(cell)
				to_chat(user, "There is a [cell] already installed here.")
			else if(user.drop(W, src))
				cell = W
				to_chat(user, "You insert the [cell].")
		update_icon()
		return

	return ..()

/obj/item/device/suit_cooling_unit/on_update_icon()
	ClearOverlays()
	if (cover_open)
		if (cell)
			icon_state = "suitcooler1"
		else
			icon_state = "suitcooler2"
		return

	icon_state = "suitcooler0"

	if(!cell || !on)
		return

	switch(round(CELL_PERCENT(cell)))
		if(86 to INFINITY)
			AddOverlays("battery-0")
		if(69 to 85)
			AddOverlays("battery-1")
		if(52 to 68)
			AddOverlays("battery-2")
		if(35 to 51)
			AddOverlays("battery-3")
		if(18 to 34)
			AddOverlays("battery-4")
		if(-INFINITY to 17)
			AddOverlays("battery-5")


/obj/item/device/suit_cooling_unit/_examine_text(mob/user)
	. = ..()
	if(get_dist(src, user) > 1)
		return

	if (on)
		. += "\nIt's switched on and running."
	else
		. += "\nIt is switched off."

	if (cover_open)
		. += "\nThe panel is open."

	if (cell)
		. += "\nThe charge meter reads [round(CELL_PERCENT(cell))]%."
