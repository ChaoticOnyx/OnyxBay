
//Deathsquad suit
/obj/item/clothing/suit/space/void/swat
	name = "\improper SWAT suit"
	desc = "A heavily armored suit that protects against moderate damage. Used in special operations."
	icon_state = "deathsquad"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS
	allowed = list(/obj/item/gun, /obj/item/ammo_magazine, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/handcuffs, /obj/item/tank)
	armor_type = /datum/armor/suit_space_void_swat
	flags_inv = HIDESHOES|HIDEJUMPSUIT
	siemens_coefficient = 0.6
	rad_resist = list(
		RADIATION_ALPHA_PARTICLE = 59.4 MEGA ELECTRONVOLT,
		RADIATION_BETA_PARTICLE = 13.2 MEGA ELECTRONVOLT,
		RADIATION_HAWKING = 1 ELECTRONVOLT
	)

/datum/armor/suit_space_void_swat
	bio = 100
	bomb = 65
	bullet = 70
	energy = 45
	laser = 70
	melee = 80

/obj/item/clothing/suit/space/void/swat/New()
	..()
	slowdown_per_slot[slot_wear_suit] = 1

/obj/item/clothing/head/helmet/space/deathsquad
	name = "deathsquad helmet"
	desc = "That's not red paint. That's real blood."
	icon_state = "deathsquad"
	item_state_slots = list(
		slot_l_hand_str = "syndicate-helm-black-red",
		slot_r_hand_str = "syndicate-helm-black-red",
		)
	armor_type = /datum/armor/head_helmet_space_deathsquad
	item_flags = ITEM_FLAG_STOPPRESSUREDAMAGE | ITEM_FLAG_THICKMATERIAL
	flags_inv = BLOCKHAIR
	siemens_coefficient = 0.6
	rad_resist = list(
		RADIATION_ALPHA_PARTICLE = 59.4 MEGA ELECTRONVOLT,
		RADIATION_BETA_PARTICLE = 13.2 MEGA ELECTRONVOLT,
		RADIATION_HAWKING = 1 ELECTRONVOLT
	)

/datum/armor/head_helmet_space_deathsquad
	bio = 100
	bomb = 65
	bullet = 70
	energy = 45
	laser = 70
	melee = 80

// Captain
/obj/item/clothing/head/helmet/space/void/captain
	name = "captain's space helmet"
	desc = "A special heavily armored helmet designed for work in a hazardous, low-pressure environment. Only for the most fashionable of military figureheads."
	icon_state = "capspace"
	item_state_slots = list(
		slot_l_hand_str = "caphelmet",
		slot_r_hand_str = "caphelmet",
	)
	armor_type = /datum/armor/head_helmet_space_void_captain
	siemens_coefficient = 0.5
	light_overlay = "helmet_light_dual"

/datum/armor/head_helmet_space_void_captain
	bio = 100
	bomb = 55
	bullet = 60
	energy = 35
	laser = 60
	melee = 75

/obj/item/clothing/suit/space/void/captain
	name = "captain's space armor"
	desc = "A bulky, heavy-duty piece of exclusive corporate hardsuit. YOU are in charge!"
	icon_state = "caparmor"
	item_state_slots = list(
		slot_l_hand_str = "capspacesuit",
		slot_r_hand_str = "capspacesuit",
	)
	armor_type = /datum/armor/suit_space_void_captain
	allowed = list(/obj/item/gun,/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit, /obj/item/ammo_magazine, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/handcuffs, /obj/item/disk/nuclear)
	siemens_coefficient = 0.5

/datum/armor/suit_space_void_captain
	bio = `00
	bomb = 55
	bullet = 60
	energy = 35
	laser = 60
	melee = 75

/obj/item/clothing/suit/space/void/captain/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/captain
	boots = /obj/item/clothing/shoes/magboots


// Exploration
/obj/item/clothing/head/helmet/space/void/exploration
	name = "exploration voidhelmet"
	desc = "A radiation-resistant helmet made especially for exploring unknown planetary environments."
	icon_state = "helm_explorer"
	item_state = "helm_explorer"
	armor_type = /datum/armor/head_helmet_space_void_exploration
	light_overlay = "explorer_light"

/datum/armor/head_helmet_space_void_exploration
	bio = 100
	bomb = 30
	bullet = 10
	energy = 45
	laser = 15
	melee = 20

/obj/item/clothing/suit/space/void/exploration
	name = "exploration voidsuit"
	desc = "A lightweight, radiation-resistant voidsuit, featuring the Expeditionary Corps emblem on its chest plate. Designed for exploring unknown planetary environments."
	icon_state = "void_explorer"
	armor_type = /datum/armor/suit_space_void_exploration
	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/stack/flag,/obj/item/device/healthanalyzer,/obj/item/device/gps,/obj/item/pinpointer/radio,/obj/item/device/radio/beacon,/obj/item/material/hatchet/machete,/obj/item/shovel)

/datum/armor/suit_space_void_exploration
	bio = 100
	bomb = 30
	bullet = 10
	energy = 45
	laser = 15
	melee = 20

/obj/item/clothing/suit/space/void/exploration/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/exploration
	boots = /obj/item/clothing/shoes/magboots


// Salvage
/obj/item/clothing/head/helmet/space/void/engineering/salvage
	name = "salvage voidhelmet"
	desc = "A heavily modified salvage voidsuit helmet. It has been fitted with radiation-resistant plating."
	icon_state = "rig0-salvage"
	item_state = "salvage_helm"
	item_state_slots = list(
		slot_l_hand_str = "eng_helm",
		slot_r_hand_str = "eng_helm",
		)
	armor_type = /datum/armor/head_helmet_space_void_engineering_salvage

/datum/armor/head_helmet_space_void_engineering_salvage
	bio = 100
	bomb = 35
	bullet = 10
	energy = 15
	laser = 30
	melee = 50

/obj/item/clothing/suit/space/void/engineering/salvage
	name = "salvage voidsuit"
	desc = "A hand-me-down salvage voidsuit. It has obviously had a lot of repair work done to its radiation shielding."
	icon_state = "rig-salvage"
	item_state_slots = list(
		slot_l_hand_str = "eng_voidsuit",
		slot_r_hand_str = "eng_voidsuit",
	)
	armor_type = /datum/armor/suit_space_void_engineering_salvage
	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/storage/toolbox,/obj/item/storage/briefcase/inflatable,/obj/item/device/t_scanner,/obj/item/rcd)

/datum/armor/suit_space_void_engineering_salvage
	bio = 100
	bomb = 35
	bullet = 10
	energy = 15
	laser = 30
	melee = 50

/obj/item/clothing/suit/space/void/engineering/salvage/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/engineering/salvage
	boots = /obj/item/clothing/shoes/magboots


// Pilot
/obj/item/clothing/head/helmet/space/void/pilot
	name = "pilot voidhelmet"
	desc = "An atmos resistant helmet for space and planet exploration."
	icon_state = "rig0_pilot"
	item_state = "pilot_helm"
	armor_type = /datum/armor/head_helmet_space_void_pilot
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	light_overlay = "helmet_light_dual"

/datum/armor/head_helmet_space_void_pilot
	bio = 100
	bomb = 5
	bullet = 5
	energy = 5
	laser = 15
	melee = 40

/obj/item/clothing/suit/space/void/pilot
	name = "pilot voidsuit"
	desc = "An atmos resistant voidsuit for space and planet exploration."
	icon_state = "rig-pilot"
	item_state = "rig-pilot"
	armor_type = /datum/armor/suit_space_void_pilot
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/storage/toolbox,/obj/item/storage/briefcase/inflatable,/obj/item/device/t_scanner,/obj/item/rcd)

/datum/armor/suit_space_void_pilot
	bio = 100
	bomb = 5
	bullet = 5
	energy = 5
	laser = 15
	melee = 40

/obj/item/clothing/suit/space/void/pilot/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/pilot
	boots = /obj/item/clothing/shoes/magboots


// Knight
/obj/item/clothing/head/helmet/space/void/knight
	name = "strange voidhelmet"
	desc = "A bulky helmet with some heavy armor plating."
	icon_state = "hardsuit-helm-knight"
	item_state = "hardsuit-helm-knight"
	armor_type = /datum/armor/head_helmet_space_void_knight
	siemens_coefficient = 0.7
	light_overlay = "helmet_light_dual"

/datum/armor/head_helmet_space_void_knight
	bio = 100
	bomb = 55
	bullet = 35
	energy = 25
	laser = 35
	melee = 70

/obj/item/clothing/suit/space/void/knight
	icon_state = "hardsuit-knight"
	item_state = "hardsuit-knight"
	name = "strange voidsuit"
	desc = "A bulky set of space-proof armor, that looks kinda ancient. 'Lancelot X-40' is written on the front plate."
	armor_type = /datum/armor/suit_space_void_knight
	allowed = list(/obj/item/gun,/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/melee/baton)
	siemens_coefficient = 0.7

/datum/armor/suit_space_void_knight
	bio = 100
	bomb = 55
	bullet = 35
	energy = 25
	laser = 35
	melee = 70


// Optical
/obj/item/clothing/head/helmet/space/void/optical
	name = "experimental voidhelmet"
	icon_state = "hardsuit-optical"
	desc = "Strange looking, smoothly contoured helmet. It looks a bit blurry."
	siemens_coefficient = 0
	armor_type = /datum/armor/head_helmet_space_void_optical

/datum/armor/head_helmet_space_void_optical
	bio = 100
	bomb = 20
	bullet = 40
	energy = 40
	laser = 45
	melee = 35

/obj/item/clothing/suit/space/void/optical
	name = "experimental voidsuit"
	icon_state = "hardsuit-optical"
	desc = "Strange black voidsuit, with some devices attached to it. It looks a bit blurry."
	action_button_name = "Toggle Optical Disruptor"
	siemens_coefficient = 0
	armor_type = /datum/armor/suit_space_void_optical
	var/cloak = FALSE

/datum/armor/suit_space_void_optical
	bio = 100
	bomb = 20
	bullet = 40
	energy = 40
	laser = 45
	melee = 35

/obj/item/clothing/suit/space/void/optical/New()
	..()
	slowdown_per_slot[slot_wear_suit] = 0

/obj/item/clothing/suit/space/void/optical/attack_self(mob/user)
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		return
	if(!istype(H.head, /obj/item/clothing/head/helmet/space/void/optical))
		return
	cloak(H)

/obj/item/clothing/suit/space/void/optical/proc/cloak(mob/living/carbon/human/H)
	if(cloak)
		cloak = FALSE
		return 1

	to_chat(H, "<span class='notice'>Optical disruptor activated.</span>")
	cloak = TRUE
	animate(H,alpha = 255, alpha = 85, time = 10)

	var/remain_cloaked = TRUE
	while(remain_cloaked)
		sleep(1 SECOND)
		if(!cloak)
			remain_cloaked = 0
		if(H.stat)
			remain_cloaked = 0
		if(!istype(H.head, /obj/item/clothing/head/helmet/space/void/optical))
			remain_cloaked = 0
	H.invisibility = initial(H.invisibility)
	H.visible_message("<span class='warning'>[H] suddenly fades in.</span>",
	"<span class='notice'>Optical disruptor deactivated.</span>")
	cloak = FALSE

	animate(H,alpha = 85, alpha = 255, time = 10)


// Rmc(Only)
/obj/item/clothing/head/helmet/space/void/rmc_red
	name = "rmc red helmet"
	desc = "An atmos resistant helmet for space and planet exploration."
	icon_state = "rig0_rmc_red"
	item_state = "rmc_red_helm"
	armor_type = /datum/armor/head_helmet_space_void_rmc
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	light_overlay = "helmet_light_dual"

/datum/armor/head_helmet_space_void_rmc
	bio = 100
	bomb = 5
	bullet = 5
	energy = 5
	laser = 15
	melee = 40

/obj/item/clothing/suit/space/void/rmc_red
	name = "rmc red voidsuit"
	desc = "An atmos resistant voidsuit for space and planet exploration."
	icon_state = "rmc_red"
	item_state = "rmc_red"
	armor_type = /datum/armor/suit_space_void_rmc
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/storage/toolbox,/obj/item/storage/briefcase/inflatable,/obj/item/device/t_scanner,/obj/item/rcd)

/datum/armor/suit_space_void_rmc
	bio = 100
	bomb = 5
	bullet = 5
	energy = 5
	laser = 15
	melee = 40

/obj/item/clothing/suit/space/void/rmc_red/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/rmc_red
	boots = /obj/item/clothing/shoes/magboots

/obj/item/clothing/head/helmet/space/void/rmc_green
	name = "rmc red helmet"
	desc = "An atmos resistant helmet for space and planet exploration."
	icon_state = "rig0_rmc_green"
	item_state = "rmc_green_helm"
	armor_type = /datum/armor/head_helmet_space_void_rmc
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	light_overlay = "helmet_light_dual"

/obj/item/clothing/suit/space/void/rmc_green
	name = "rmc green voidsuit"
	desc = "An atmos resistant voidsuit for space and planet exploration."
	icon_state = "rmc_green"
	item_state = "rmc_green"
	armor_type = /datum/armor/suit_space_void_rmc
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/storage/toolbox,/obj/item/storage/briefcase/inflatable,/obj/item/device/t_scanner,/obj/item/rcd)

/obj/item/clothing/suit/space/void/rmc_green/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/rmc_green
	boots = /obj/item/clothing/shoes/magboots

/obj/item/clothing/head/helmet/space/void/rmc_royal
	name = "rmc royal helmet"
	desc = "An atmos resistant helmet for space and planet exploration."
	icon_state = "rig0_rmc_royal"
	item_state = "rmc_royal_helm"
	armor_type = /datum/armor/head_helmet_space_void_rmc
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	light_overlay = "helmet_light_dual"

/obj/item/clothing/suit/space/void/rmc_royal
	name = "rmc royal voidsuit"
	desc = "An atmos resistant voidsuit for space and planet exploration."
	icon_state = "rmc_royal"
	item_state = "rmc_royal"
	armor_type = /datum/armor/suit_space_void_rmc
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/storage/toolbox,/obj/item/storage/briefcase/inflatable,/obj/item/device/t_scanner,/obj/item/rcd)

/obj/item/clothing/suit/space/void/rmc_royal/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/rmc_royal
	boots = /obj/item/clothing/shoes/magboots

/obj/item/clothing/suit/space/void/engsuit_spc
	name = "engineer spc voidsuit"
	desc = "An atmos resistant voidsuit for space and planet exploration."
	icon_state = "engsuit_spc"
	item_state = "engsuit_spc"
	armor_type = /datum/armor/suit_space_void_spc
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/storage/toolbox,/obj/item/storage/briefcase/inflatable,/obj/item/device/t_scanner,/obj/item/rcd)

/datum/armor/suit_space_void_spc
	bio = 100
	bomb = 5
	bullet = 5
	energy = 5
	laser = 15
	melee = 40

/obj/item/clothing/suit/space/void/secsuit_spc
	name = "security spc voidsuit"
	desc = "An atmos resistant voidsuit for space and planet exploration."
	icon_state = "secsuit_spc"
	item_state = "secsuit_spc"
	armor_type = /datum/armor/suit_space_void_spc
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/storage/toolbox,/obj/item/storage/briefcase/inflatable,/obj/item/device/t_scanner,/obj/item/rcd)

/obj/item/clothing/head/helmet/space/void/pilot_spc
	name = "pilot spc helmet"
	desc = "An atmos resistant helmet for space and planet exploration."
	icon_state = "pilot_spc"
	item_state = "pilot_spc"
	armor_type = /datum/armor/head_helmet_space_void_spc
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	light_overlay = "helmet_light_dual"

/datum/armor/head_helmet_space_void_spc
	bio = 100
	bomb = 5
	bullet = 5
	energy = 5
	laser = 15
	melee = 40

/obj/item/clothing/head/helmet/space/void/templar
	name = "templar helmet"
	desc = "An atmos resistant helmet for space and planet exploration."
	icon_state = "templar"
	item_state = "templar"
	armor_type = /datum/armor/head_helmet_space_void_templar
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	light_overlay = "helmet_light_dual"

/datum/armor/head_helmet_space_void_templar
	bio = 100
	bomb = 5
	bullet = 5
	energy = 5
	laser = 15
	melee = 40

/obj/item/clothing/head/helmet/space/void/scuba
	name = "scuba helmet"
	desc = "An atmos resistant helmet for space and planet exploration."
	icon_state = "scuba"
	item_state = "scuba"
	armor_type = /datum/armor/suit_space_void_scuba
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	light_overlay = "helmet_light_dual"

/datum/armor/suit_space_void_scuba
	bio = 100
	bomb = 5
	bullet = 5
	energy = 5
	laser = 15
	melee = 40
