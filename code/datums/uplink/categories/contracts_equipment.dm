
/datum/uplink_item/item/contracts_equipment
	category = /datum/uplink_category/contracts_equipment

/datum/uplink_item/item/contracts_equipment/std
	name = "Syndicate Teleportation Device (STD)"
	desc = "It utilizes a local wormhole generator to teleport the stored items to our base. Upon successful teleportation, the device self-destructs for safety reasons. To use it, briefly put your uplink device inside for authorization, place the items you need to transport inside, and follow the instructions indicated on the STD."
	item_cost = 1
	path = /obj/item/storage/briefcase/std

/datum/uplink_item/item/contracts_equipment/std/buy(datum/component/uplink/U)
	. = ..()
	if(!.)
		return
	if(istype(U.parent, /obj/item/implant/uplink))
		var/obj/item/storage/briefcase/std/STD = .
		if(istype(STD))
			STD.uplink = U
			STD.authentication_complete = TRUE
			STD.visible_message("\The [STD] blinks green!")
	U.complimentary_std = FALSE

/datum/uplink_item/item/contracts_equipment/std/cost(telecrystals, datum/component/uplink/U)
	return (U?.complimentary_std ? 0 : ..())

/datum/uplink_item/item/contracts_equipment/spy
	name = "Bug Kit"
	desc = "Six small cameras and a totaly-not-suspicious PDA. This kit is required to complete the recon-type contracts."
	item_cost = 2
	path = /obj/item/storage/box/syndie_kit/spy

/datum/uplink_item/item/contracts_equipment/spy/buy(datum/component/uplink/U)
	. = ..()
	if(.)
		var/obj/item/storage/box/syndie_kit/spy/B = .
		var/obj/item/device/spy_monitor/SM = locate() in B
		if(SM)
			SM.uplink = U
