/obj/item/shield_diffuser
	name = "portable shield diffuser"
	desc = "A small handheld device designed to disrupt energy barriers."
	description_info = "This device disrupts shields on directly adjacent tiles (in a + shaped pattern), in a similar way the floor mounted variant does. It is, however, portable and run by an internal battery. Can be recharged with a regular recharger."
	icon = 'icons/obj/machines/shielding.dmi'
	icon_state = "hdiffuser_off"
	origin_tech = list(TECH_MAGNET = 5, TECH_POWER = 5, TECH_ILLEGAL = 2)
	var/obj/item/cell/device/cell
	var/enabled = 0

/obj/item/shield_diffuser/on_update_icon()
	if(enabled)
		icon_state = "hdiffuser_on"
	else
		icon_state = "hdiffuser_off"

/obj/item/shield_diffuser/Initialize()
	. = ..()
	cell = new(src)

/obj/item/shield_diffuser/Destroy()
	QDEL_NULL(cell)
	. = ..()

/obj/item/shield_diffuser/think()
	if(!enabled)
		return

	for(var/direction in GLOB.cardinal)
		var/turf/shielded_tile = get_step(get_turf(src), direction)
		for(var/obj/effect/shield/S in shielded_tile)
			// 10kJ per pulse, but gap in the shield lasts for longer than regular diffusers.
			if(istype(S) && cell.checked_use(10 KILO WATTS * CELLRATE))
				qdel(S)

	set_next_think(world.time + 1 SECOND)

/obj/item/shield_diffuser/attack_self()
	enabled = !enabled
	update_icon()
	if(enabled)
		set_next_think(world.time)
	else
		set_next_think(0)
	to_chat(usr, "You turn \the [src] [enabled ? "on" : "off"].")

/obj/item/shield_diffuser/examine(mob/user, infix)
	. = ..()

	. += "The charge meter reads [cell ? CELL_PERCENT(cell) : 0]%"
	. += "It is [enabled ? "enabled" : "disabled"]."
