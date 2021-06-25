/obj/item/device/portalgen
	name = "scary generator"
	desc = "A strange device with twin antennas."
	icon_state = "batterer"
	throwforce = 5
	w_class = ITEM_SIZE_SMALL
	throw_speed = 4
	throw_range = 10
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	item_state = "electronic"
	origin_tech = list(TECH_MAGNET = 3, TECH_COMBAT = 3, TECH_ILLEGAL = 3)
	var/used = FALSE
	var/obj/item/device/uplink/linked_uplink

/obj/item/device/portalgen/attack_self(mob/user)
	if(!user || used || !linked_uplink)
		return

	var/turf/rift_location = get_turf(user)

	playsound(rift_location, 'sound/misc/interference.ogg', 50, 1)
	to_chat(user, SPAN("notice", "You trigger [src]."))

	var/obj/effect/red_portal/RP = new(rift_location, 4.5 MINUTES, linked_uplink) // EOS moment
	RP.linked_uplink = linked_uplink

	icon_state = "battererburnt"
	used = TRUE
