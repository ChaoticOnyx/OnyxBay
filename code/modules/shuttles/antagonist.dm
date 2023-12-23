/obj/machinery/computer/shuttle_control/multi/vox
	name = "skipjack control console"
	req_access = list(access_syndicate)
	shuttle_tag = "Skipjack"

/obj/machinery/computer/shuttle_control/multi/syndicate/Initialize()
	. = ..()
	AddComponent(/datum/component/holomarker/toggleable/transmitting/shuttle, "skipjack", HOLOMAP_FILTER_VOX)

/obj/machinery/computer/shuttle_control/multi/syndicate
	name = "syndicate shuttle control console"
	req_access = list(access_syndicate)
	shuttle_tag = "Syndicate"

/obj/machinery/computer/shuttle_control/multi/syndicate/Initialize()
	. = ..()
	AddComponent(/datum/component/holomarker/toggleable/transmitting/shuttle, "syndishuttle", HOLOMAP_FILTER_NUKEOPS)

/obj/machinery/computer/shuttle_control/multi/elite_syndicate
	name = "elite syndicate operative shuttle control console"
	req_access = list(access_syndicate)
	shuttle_tag = "Elite Syndicate Operative"

/obj/machinery/computer/shuttle_control/multi/elite_syndicate/Initialize()
	. = ..()
	AddComponent(/datum/component/holomarker/toggleable/transmitting/shuttle, "skipjack", HOLOMAP_FILTER_ELITESYNDICATE)

/obj/machinery/computer/shuttle_control/multi/rescue
	name = "rescue shuttle control console"
	req_access = list(access_cent_specops)
	shuttle_tag = "Rescue"

/obj/machinery/computer/shuttle_control/multi/rescue/Initialize()
	. = ..()
	AddComponent(/datum/component/holomarker/toggleable/transmitting/shuttle, "skipjack", HOLOMAP_FILTER_ERT)

/obj/machinery/computer/shuttle_control/multi/ninja
	name = "stealth shuttle control console"
	req_access = list(access_syndicate)
	shuttle_tag = "Ninja"

/obj/machinery/computer/shuttle_control/multi/merchant
	name = "merchant shuttle control console"
	req_access = list(access_merchant)
	shuttle_tag = "Merchant"

/obj/machinery/computer/shuttle_control/multi/mining_ship
	name = "Creaker control console"
	req_access = list(access_mining)
	shuttle_tag = "Creaker"
