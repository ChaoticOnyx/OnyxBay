/obj/item/device/bluespace_beacon
	name = "tracking beacon"
	desc = "A device that draws power from bluespace and creates a permanent bluespace anchor."

	icon_state = "beacon"
	item_state = "signaler"

	matter = list(MATERIAL_STEEL = 20, MATERIAL_GLASS = 10)

	origin_tech = list(TECH_BLUESPACE = 1)

/obj/item/device/bluespace_beacon/Initialize()
	. = ..()
	GLOB.bluespace_beacons += src

/obj/item/device/bluespace_beacon/Destroy()
	GLOB.bluespace_beacons -= src
	return ..()

/obj/item/device/bluespace_beacon/hidden
	name = "stealth tracking beacon"
	desc = parent_type::desc + " This one is a bit shy..."

	icon = 'icons/obj/objects.dmi'
	icon_state = "floor_beacon"

	level = 1

	anchored = TRUE
	randpixel = FALSE

/obj/item/device/bluespace_beacon/hidden/attackby(obj/item/W, mob/user)
	if(isWrench(W) && loc == get_turf(src))
		wrench_floor_bolts(user)
		return

	return ..()

/obj/item/device/bluespace_beacon/hidden/Initialize()
	. = ..()

	if(isturf(loc))
		var/turf/loc_turf = loc
		hide(!loc_turf.is_plating())

/obj/item/device/bluespace_beacon/hidden/hide(hide)
	if(!anchored)
		return

	..()
	update_icon()
