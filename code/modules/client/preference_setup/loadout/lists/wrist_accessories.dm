/datum/gear/wrist_accessory
	sort_category = "Wrist Accessories"

/datum/gear/wrist_accessory/watch
	display_name = "watch selection"
	path = /obj/item/underwear/wrist/watch

/datum/gear/wrist_accessory/watch/New()
	..()
	var/watchtypes = list()
	watchtypes["Silver watch"] = /obj/item/underwear/wrist/watch/silver
	watchtypes["Golden watch"] = /obj/item/underwear/wrist/watch/gold
	watchtypes["Leather watch"] = /obj/item/underwear/wrist/watch/leather
	watchtypes["Spy watch"] = /obj/item/underwear/wrist/watch/spy
	gear_tweaks += new /datum/gear_tweak/path(watchtypes)

/datum/gear/wrist_accessory/watch_elite
	display_name = "elite watch selection"
	path = /obj/item/underwear/wrist/watch/elite

/datum/gear/wrist_accessory/watch_elite/New()
	..()
	var/watchtypes = list()
	watchtypes["Silver watch"] = /obj/item/underwear/wrist/watch/elite
	watchtypes["Classic watch"] = /obj/item/underwear/wrist/watch/elite/true
	watchtypes["Golden watch"] = /obj/item/underwear/wrist/watch/elite/gold
	gear_tweaks += new /datum/gear_tweak/path(watchtypes)

/datum/gear/wrist_accessory/watch_freak
	display_name = "unusual timepiece selection"
	path = /obj/item/underwear/wrist/watch/nerdy

/datum/gear/wrist_accessory/watch_freak/New()
	..()
	var/watchtypes = list()
	watchtypes["Holo watch"] = /obj/item/underwear/wrist/watch/holo
	watchtypes["Magnitka watch"] = /obj/item/underwear/wrist/watch/magnitka
	watchtypes["Nerdy watch"] = /obj/item/underwear/wrist/watch/nerdy
	watchtypes["Normal watch"] = /obj/item/underwear/wrist/watch/normal
	gear_tweaks += new /datum/gear_tweak/path(watchtypes)

/datum/gear/wrist_accessory/bracelet
	display_name = "bracelet selection"
	path = /obj/item/underwear/wrist/bracelet

/datum/gear/wrist_accessory/bracelet/New()
	..()
	var/bracelettypes = list()
	bracelettypes["beaded bracelet"] = /obj/item/underwear/wrist/beaded
	bracelettypes["slap bracelet"] = /obj/item/underwear/wrist/slap
	gear_tweaks += new /datum/gear_tweak/path(bracelettypes)

/datum/gear/wrist_accessory/armchains
	display_name = "armchains selection"
	path = /obj/item/underwear/wrist/armchain

/datum/gear/wrist_accessory/armchains/New()
	..()
	var/chaintypes = list()
	chaintypes["emerald arm chains"] = /obj/item/underwear/wrist/armchain/emerald
	chaintypes["ruby arm chains"] = /obj/item/underwear/wrist/armchain/ruby
	gear_tweaks += new /datum/gear_tweak/path(chaintypes)

/datum/gear/wrist_accessory/bracers
	display_name = "bracers selection"
	path = /obj/item/underwear/wrist/goldbracer

/datum/gear/wrist_accessory/bracers/New()
	..()
	var/chaintypes = list()
	chaintypes["emerald bracers"] = /obj/item/underwear/wrist/goldbracer/emerald
	chaintypes["ruby bracers"] = /obj/item/underwear/wrist/goldbracer/ruby
	gear_tweaks += new /datum/gear_tweak/path(chaintypes)
