// A collection of pre-set uplinks
/obj/item/uplink
	name = "station bounced radio"
	icon = 'icons/obj/radio.dmi'
	icon_state = "radio"
	item_state = "walkietalkie"
	desc = "A basic handheld radio that communicates with local telecommunication networks."

/obj/item/uplink/Initialize(mapload, owner, tc_amount = 20)
	. = ..()
	AddComponent(/datum/component/uplink, owner, FALSE, TRUE, null, tc_amount)

// Radio-like uplink; not an actual radio though
/obj/item/device/radio/uplink/Initialize(mapload, owner, amount)
	. = ..()
	AddComponent(/datum/component/uplink, owner, FALSE, FALSE, null, amount)
	icon_state = "radio"

/obj/item/device/radio/uplink/interact(mob/user)
	if(!user)
		return FALSE

	var/datum/component/uplink/uplink = get_component(/datum/component/uplink)
	if(!istype(uplink))
		return

	uplink.interact(user)
