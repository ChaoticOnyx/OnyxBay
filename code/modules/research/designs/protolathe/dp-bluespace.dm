/datum/design/item/bluespace
	category_items = list("Bluespace")


/datum/design/item/bluespace/beacon
	name = "tracking beacon"
	id = "beacon"

	materials = list (MATERIAL_STEEL = 20, MATERIAL_GLASS = 10)
	build_path = /obj/item/device/radio/beacon
	sort_string = "VADAA"

/datum/design/item/bluespace/gps
	name = "triangulating device"
	desc = "Triangulates approximate co-ordinates using a nearby satellite network."
	id = "gps"

	materials = list(MATERIAL_STEEL = 500)
	build_path = /obj/item/device/gps
	sort_string = "VADAB"

/datum/design/item/bluespace/beacon_locator
	name = "beacon tracking pinpointer"
	desc = "Used to scan and locate signals on a particular frequency."
	id = "beacon_locator"

	materials = list(MATERIAL_STEEL = 1000, MATERIAL_GLASS = 500)
	build_path = /obj/item/pinpointer/radio
	sort_string = "VADAC"

/datum/design/item/bluespace/bag_holding
	name = "Bag of Holding"
	desc = "Using localized pockets of bluespace this bag prototype offers incredible storage capacity with the contents weighting nothing. It's a shame the bag itself is pretty heavy."
	id = "bag_holding"

	materials = list(MATERIAL_GOLD = 3000, MATERIAL_DIAMOND = 1500, MATERIAL_URANIUM = 250)
	build_path = /obj/item/storage/backpack/holding
	sort_string = "VAFAA"

/datum/design/item/weapon/vortex_manipulator
	id = "timelord_vortex"
	name = "Vortex Manipulator"
	desc = "Ancient reverse-engineered technology of some old species designed to travel through space and time. Time-shifting is DNA-locked, sadly."

	materials = list(MATERIAL_STEEL = 10000, MATERIAL_GLASS = 5000, MATERIAL_SILVER = 1000, MATERIAL_GOLD = 1000, MATERIAL_DIAMOND = 2000)
	build_path = /obj/item/vortex_manipulator
	sort_string = "VAGVV"
