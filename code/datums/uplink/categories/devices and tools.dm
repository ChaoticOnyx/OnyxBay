/********************
* Devices and Tools *
********************/
/datum/uplink_item/item/tools
	category = /datum/uplink_category/tools

/datum/uplink_item/item/tools/std/buy(obj/item/device/uplink/U)
	. = ..()
	if(. && istype(U.loc, /obj/item/weapon/implant/uplink))
		var/obj/item/weapon/storage/briefcase/std/STD = .
		if(istype(STD))
			STD.uplink = U
			STD.authentication_complete = TRUE
			STD.visible_message("\The [STD] blinks green!")

/datum/uplink_item/item/tools/std
	name = "Syndicate Teleportation Device (STD)"
	desc = "It utilizes a local wormhole generator to teleport the stored items to our base. Upon successful teleportation, the device self-destructs for safety reasons. To use it, briefly put your uplink device inside for authorization, place the items you need to transport inside, and follow the instructions indicated on the STD."
	item_cost = 1
	path = /obj/item/weapon/storage/briefcase/std

/datum/uplink_item/item/tools/portalgen
	name = "Scary Red Portal Generator"
	desc = "It uses bluespace and plasma to create portal to our concentration camp, used for kidnap contract."
	item_cost = 2
	path = /obj/item/device/portalgen

/datum/uplink_item/item/tools/portalgen/buy(obj/item/device/uplink/U)
	. = ..()
	if(.)
		var/obj/item/device/portalgen/pg = .
		if(istype(pg))
			pg.linked_uplink = U

/datum/uplink_item/item/tools/encryptionkey_radio
	name = "Encrypted Radio Channel Key"
	item_cost = 1
	path = /obj/item/device/encryptionkey/syndicate

/datum/uplink_item/item/tools/toolbox
	name = "Fully Loaded Toolbox"
	desc = "An extra robust toolbox filled with all the tools you need."
	item_cost = 1
	path = /obj/item/weapon/storage/toolbox/syndicate

/datum/uplink_item/item/tools/ductape
	name = "Syn-Duct Tape"
	desc = "A roll of an extra sticky duct tape. Quickly changes annoying \"HELP\" into sexy \"mmm\"."
	item_cost = 1
	path = /obj/item/weapon/tape_roll/syndie

/datum/uplink_item/item/tools/clerical
	name = "Morphic Clerical Kit"
	desc = "Contains chameleon pen and stamp, as well as some other clerical items."
	item_cost = 1
	path = /obj/item/weapon/storage/backpack/satchel/syndie_kit/clerical

/datum/uplink_item/item/tools/barrier
	name = "Energy Barrier"
	desc = "A simple yet effective one-use energy barrier generator. Quite effective as a battlefield cover, but explodes upon recieving too much damage."
	item_cost = 1
	path = /obj/item/device/energybarrier

/datum/uplink_item/item/tools/money
	name = "Operations Funding"
	desc = "A briefcase with 5,000 untraceable credits for funding your sneaky activities."
	item_cost = 2
	path = /obj/item/weapon/storage/secure/briefcase/money

/datum/uplink_item/item/tools/cleaning_kit
	name = "Cleaning Kit"
	desc = "A satchel full of stuff you'll need to scrub the crimescene clear."
	item_cost = 2
	path = /obj/item/weapon/storage/backpack/satchel/syndie_kit/cleaning_kit

/datum/uplink_item/item/tools/plastique
	name = "C-4 Explosive"
	desc = "This little thing can detonate and destroy anything it is set on, after any chosen amount of seconds."
	item_cost = 2
	path = /obj/item/weapon/plastique

/datum/uplink_item/item/tools/suit_sensor_mobile
	name = "Suit Sensor Jamming Device"
	desc = "This device will affect suit sensor data using method and radius defined by the user."
	item_cost = 2
	path = /obj/item/device/suit_sensor_jammer

/datum/uplink_item/item/stealth_items/chameleon_hologram
	name = "Chameleon Hologram"
	item_cost = 2
	path = /obj/item/device/chameleonholo
	desc = "This device can scan any item and save its appearance, projecting it onto itself when dropped and becoming almost indistinguishable from the scanned item. It will lose its disguise if it's picked up again. You can also clear the memory buffer when holding it."

/datum/uplink_item/item/tools/space_suit
	name = "Space Suit"
	desc = "A complete, red space suit. This suit's movement penalties are fewer than an EVA space suit and it is decently armored! \
			Useful if you need to hide in a vacuum. They can also hold a wide selection of items in suit storage. \
			Comes packaged with internals. Be careful, Nanotrasen crewmembers are trained to report red space suit sightings."
	item_cost = 3
	path = /obj/item/weapon/storage/backpack/satchel/syndie_kit/space

/datum/uplink_item/item/tools/encryptionkey_binary
	name = "Binary Translator Key"
	item_cost = 3
	path = /obj/item/device/encryptionkey/binary

/datum/uplink_item/item/tools/shield_diffuser
	name = "Handheld Shield Diffuser"
	item_cost = 3
	path = /obj/item/weapon/shield_diffuser

/datum/uplink_item/item/tools/interceptor
	name = "Radio Interceptor"
	desc = "A radio that can intercept secure radio channels. Doesn't fit in pockets."
	item_cost = 3
	path = /obj/item/device/radio/intercept

/datum/uplink_item/item/tools/sindicuffs
	name = "Explosive Handcuffs"
	desc = "A pair of handcuffs that will explode a few seconds after being applied or removed. It's up to you to choose."
	item_cost = 3
	path = /obj/item/weapon/handcuffs/syndicate

/datum/uplink_item/item/tools/c4explosive
	name = "Small Package Bomb"
	item_cost = 3
	path = /obj/item/weapon/syndie/c4explosive

/datum/uplink_item/item/tools/hacking_tool
	name = "Door Hacking Tool"
	item_cost = 3
	path = /obj/item/device/multitool/hacktool
	desc = "Appears and functions as a standard multitool until the mode is toggled by applying a screwdriver appropriately. \
			When in hacking mode this device will grant full access to any standard airlock within 20 to 40 seconds. \
			This device will also be able to immediately access the last 6 to 8 hacked airlocks."

/datum/uplink_item/item/tools/emag
	name = "Cryptographic Sequencer"
	desc = "This sophisticated piece of equipment allows you to quite literally open anything: doors, lockers, crates and other things. \
			However, the affected machinery will be broken permanently and while this can have the desired effect, \
			it also leaves a trail for people to follow (mostly doors). \
			Emagging something is also fairly noticeable, so you should make sure nobody's watching."
	item_cost = 4
	path = /obj/item/weapon/card/emag

/datum/uplink_item/item/tools/powersink
	name = "Powersink"
	desc = "This bad boy is a station engineers and AI's worst enemy. When bought, this thing is useless, \
			but when the power sink comes in contact with exposed wires out in space or on the station it starts to drain the power at a RAPID rate. \
			Once it has enough power, powersink explodes, destroying everything in a HUGE range."
	item_cost = 5
	path = /obj/item/device/powersink

/datum/uplink_item/item/stealth_items/chameleon_bomb
	name = "Chameleon Bomb"
	desc = "A powerful bomb with an integrated chameleon hologram projector. Be careful, once you arm and activate it, any touch will trigger an explosion!"
	item_cost = 6
	path = /obj/item/device/chameleonholo/bomb

/datum/uplink_item/item/tools/c4explosive/heavy
	name = "Large Package Bomb"
	item_cost = 6
	path = /obj/item/weapon/syndie/c4explosive/heavy

/datum/uplink_item/item/tools/supply_beacon
	name = "Hacked Supply Beacon"
	item_cost = 6
	path = /obj/item/supply_beacon

/datum/uplink_item/item/tools/camera_mask
	name = "Camera MIU"
	item_cost = 6
	path = /obj/item/clothing/mask/ai

/datum/uplink_item/item/tools/heavy_armor
	name = "Heavy Armor Vest and Helmet"
	item_cost = 6
	path = /obj/item/weapon/storage/backpack/satchel/syndie_kit/armor

/datum/uplink_item/item/tools/flashdark
	name = "Flashdark"
	item_cost = 7
	antag_costs = list(MODE_NUKE = 14)
	path = /obj/item/device/flashlight/flashdark

/datum/uplink_item/item/tools/ai_module
	name = "Hacked AI Upload Module"
	item_cost = 7
	path = /obj/item/weapon/aiModule/syndicate

/datum/uplink_item/item/tools/teleporter
	name = "Teleporter Circuit Board"
	item_cost = 8
	path = /obj/item/weapon/circuitboard/teleporter
	antag_roles = list(MODE_NUKE)
