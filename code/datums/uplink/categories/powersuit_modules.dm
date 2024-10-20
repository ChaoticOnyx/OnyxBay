/********************
* Powersuit Modules *
********************/
/datum/uplink_item/item/powersuit_modules
	category = /datum/uplink_category/powersuit_modules

/datum/uplink_item/item/powersuit_modules/thermal
	name = "Thermal Scanner"
	item_cost = 4
	path = /obj/item/rig_module/vision/thermal

/datum/uplink_item/item/powersuit_modules/energy_net
	name = "Net Projector"
	item_cost = 6
	path = /obj/item/rig_module/fabricator/energy_net

/datum/uplink_item/item/powersuit_modules/ewar_voice
	name = "Electrowarfare Suite and Voice Synthesiser"
	item_cost = 3
	path = /obj/item/storage/backpack/satchel/syndie_kit/ewar_voice

/datum/uplink_item/item/powersuit_modules/maneuvering_jets
	name = "Maneuvering Jets"
	item_cost = 2
	path = /obj/item/rig_module/maneuvering_jets

/datum/uplink_item/item/powersuit_modules/egun
	name = "Mounted Energy Gun"
	item_cost = 5
	path = /obj/item/rig_module/mounted/egun

/datum/uplink_item/item/powersuit_modules/power_sink
	name = "Power Sink"
	item_cost = 6
	path = /obj/item/rig_module/power_sink

/datum/uplink_item/item/powersuit_modules/laser_canon
	name = "Mounted Laser Cannon"
	item_cost = 11 // This thing mounted on a RIG turns you into a walking siege machine
	path = /obj/item/rig_module/mounted
