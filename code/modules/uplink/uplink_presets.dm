// A collection of pre-set uplinks
/obj/item/uplink_debug
	name = "Debug Uplink"
	icon = 'icons/obj/radio.dmi'
	icon_state = "radio"
	item_state = "walkietalkie"

/obj/item/uplink_debug/Initialize(mapload, owner, tc_amount = 20)
	. = ..()
	AddComponent(/datum/component/uplink, owner, FALSE, TRUE, null, tc_amount)

/obj/item/device/radio/uplink
	icon_state = "radio"

// Radio-like uplink; not an actual radio though
/obj/item/device/radio/uplink/Initialize(mapload, owner, amount)
	. = ..()
	AddComponent(/datum/component/uplink, owner, FALSE, FALSE, null, amount)

/obj/item/device/radio/uplink/interact(mob/user)
	if(!user)
		return FALSE

	var/datum/component/uplink/uplink = get_component(/datum/component/uplink)
	if(!istype(uplink))
		return

	uplink.interact(user)
