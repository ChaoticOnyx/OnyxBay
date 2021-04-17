// Station voidsuits

//Engineering
/obj/item/clothing/head/helmet/space/void/engineering
	name = "engineering voidsuit helmet"
	desc = "A sturdy looking voidsuit helmet rated to protect against radiation."
	icon_state = "rig0-engineering"
	item_state = "eng_helm"
	item_state_slots = list(
		slot_l_hand_str = "eng_helm",
		slot_r_hand_str = "eng_helm",
		)
	armor = list(melee = 40, bullet = 5, laser = 20,energy = 5, bomb = 35, bio = 100, rad = 80)

/obj/item/clothing/suit/space/void/engineering
	name = "engineering voidsuit"
	desc = "A run-of-the-mill service voidsuit with all the plating and radiation protection required for industrial work in vacuum."
	icon_state = "rig-engineering"
	item_state_slots = list(
		slot_l_hand_str = "eng_voidsuit",
		slot_r_hand_str = "eng_voidsuit",
	)
	armor = list(melee = 40, bullet = 5, laser = 20,energy = 5, bomb = 35, bio = 100, rad = 80)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/device/suit_cooling_unit,/obj/item/weapon/storage/toolbox,/obj/item/weapon/storage/briefcase/inflatable,/obj/item/device/t_scanner,/obj/item/weapon/rcd)

/obj/item/clothing/suit/space/void/engineering/New()
	..()
	slowdown_per_slot[slot_wear_suit] = 1

/obj/item/clothing/suit/space/void/engineering/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/engineering
	boots = /obj/item/clothing/shoes/magboots

//Mining
/obj/item/clothing/head/helmet/space/void/mining
	name = "mining voidsuit helmet"
	desc = "A scuffed voidsuit helmet with a boosted communication system and reinforced armor plating."
	icon_state = "rig0-mining"
	item_state = "mining_helm"
	item_state_slots = list(
		slot_l_hand_str = "mining_helm",
		slot_r_hand_str = "mining_helm",
		)
	armor = list(melee = 50, bullet = 5, laser = 20,energy = 5, bomb = 55, bio = 100, rad = 20)
	light_overlay = "helmet_light_dual"

/obj/item/clothing/suit/space/void/mining
	icon_state = "rig-mining"
	name = "mining voidsuit"
	desc = "A grimy, decently armored voidsuit with purple blazes and extra insulation."
	item_state_slots = list(
		slot_l_hand_str = "mining_voidsuit",
		slot_r_hand_str = "mining_voidsuit",
	)
	armor = list(melee = 50, bullet = 5, laser = 20,energy = 5, bomb = 55, bio = 100, rad = 20)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/stack/flag,/obj/item/device/suit_cooling_unit,/obj/item/weapon/storage/ore,/obj/item/device/t_scanner,/obj/item/weapon/pickaxe, /obj/item/weapon/rcd)

/obj/item/clothing/suit/space/void/mining/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/mining

//Medical
/obj/item/clothing/head/helmet/space/void/medical
	name = "medical voidsuit helmet"
	desc = "A bulbous voidsuit helmet with minor radiation shielding and a massive visor."
	icon_state = "rig0-medical"
	item_state = "medical_helm"
	item_state_slots = list(
		slot_l_hand_str = "medical_helm",
		slot_r_hand_str = "medical_helm",
		)
	armor = list(melee = 30, bullet = 5, laser = 20,energy = 5, bomb = 25, bio = 100, rad = 50)

/obj/item/clothing/suit/space/void/medical
	icon_state = "rig-medical"
	name = "medical voidsuit"
	desc = "A sterile voidsuit with minor radiation shielding and a suite of self-cleaning technology. Standard issue in NanoTrasen medical facilities."
	item_state_slots = list(
		slot_l_hand_str = "medical_voidsuit",
		slot_r_hand_str = "medical_voidsuit",
	)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/device/suit_cooling_unit,/obj/item/weapon/storage/firstaid,/obj/item/device/healthanalyzer,/obj/item/stack/medical)
	armor = list(melee = 30, bullet = 5, laser = 20,energy = 5, bomb = 25, bio = 100, rad = 50)

/obj/item/clothing/suit/space/void/medical/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/medical
	boots = /obj/item/clothing/shoes/magboots

//Security
/obj/item/clothing/head/helmet/space/void/security
	name = "security voidsuit helmet"
	desc = "A somewhat tacky voidsuit helmet, a fact mitigated by heavy armor plating."
	icon_state = "rig0-sec"
	item_state = "sec_helm"
	item_state_slots = list(
		slot_l_hand_str = "sec_helm",
		slot_r_hand_str = "sec_helm",
		)
	armor = list(melee = 60, bullet = 40, laser = 40, energy = 5, bomb = 45, bio = 100, rad = 10)
	siemens_coefficient = 0.7
	light_overlay = "helmet_light_dual"

/obj/item/clothing/suit/space/void/security
	icon_state = "rig-sec"
	name = "security voidsuit"
	desc = "A heavily armored voidsuit, designed to intimidate people who find black intimidating. Surprisingly slimming."
	item_state_slots = list(
		slot_l_hand_str = "sec_voidsuit",
		slot_r_hand_str = "sec_voidsuit",
	)
	armor = list(melee = 60, bullet = 40, laser = 40, energy = 5, bomb = 45, bio = 100, rad = 10)
	allowed = list(/obj/item/weapon/gun,/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/device/suit_cooling_unit,/obj/item/weapon/melee/baton)
	siemens_coefficient = 0.7

/obj/item/clothing/suit/space/void/security/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/security
	boots = /obj/item/clothing/shoes/magboots

// Alt
/obj/item/clothing/head/helmet/space/void/security/alt
	name = "riot security voidsuit helmet"
	desc = "A comfortable voidsuit helmet with cranial armor and eight-channel surround sound."
	icon_state = "rig0-secalt"
	item_state = "secalt_helm"
	armor = list(melee = 70, bullet = 50, laser = 50, energy = 5, bomb = 35, bio = 100, rad = 10)

/obj/item/clothing/suit/space/void/security/alt
	icon_state = "rig-secalt"
	name = "riot security voidsuit"
	desc = "A somewhat clumsy voidsuit layered with impact and laser-resistant armor plating. Specially designed to dissipate minor electrical charges."
	armor = list(melee = 70, bullet = 50, laser = 50, energy = 5, bomb = 35, bio = 100, rad = 10)
	allowed = list(/obj/item/weapon/gun,/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/device/suit_cooling_unit,/obj/item/weapon/melee/baton)

/obj/item/clothing/suit/space/void/security/alt/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/security/alt
	boots = /obj/item/clothing/shoes/magboots

// HoS
/obj/item/clothing/head/helmet/space/void/security/hos
	name = "security commander voidsuit helmet"
	desc = "A heavily armored voidsuit helmet. Gold trimming radiates its owner's eliteness."
	icon_state = "rig0-sechos"
	item_state = "sechos_helm"
	armor = list(melee = 70, bullet = 55, laser = 55, energy = 25, bomb = 45, bio = 100, rad = 40)

/obj/item/clothing/suit/space/void/security/hos
	icon_state = "rig-sechos"
	name = "security commander voidsuit"
	desc = "A heavily armored voidsuit. Gold trimming shows who's the boss here, while heavy pauldrons and kama make it extra durable."
	armor = list(melee = 70, bullet = 55, laser = 55, energy = 25, bomb = 45, bio = 100, rad = 40)
	allowed = list(/obj/item/weapon/gun,/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/device/suit_cooling_unit,/obj/item/weapon/melee/baton)

/obj/item/clothing/suit/space/void/security/hos/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/security/hos
	boots = /obj/item/clothing/shoes/magboots

//Captain
/obj/item/clothing/head/helmet/space/void/captain
	name = "captain's space helmet"
	desc = "A special heavily armored helmet designed for work in a hazardous, low-pressure environment. Only for the most fashionable of military figureheads."
	icon_state = "capspace"
	item_state_slots = list(
		slot_l_hand_str = "caphelmet",
		slot_r_hand_str = "caphelmet",
	)
	armor = list(melee = 75, bullet = 60, laser = 60, energy = 35, bomb = 55, bio = 100, rad = 50)
	siemens_coefficient = 0.5
	light_overlay = "helmet_light_dual"

/obj/item/clothing/suit/space/void/captain
	name = "captain's space armor"
	desc = "A bulky, heavy-duty piece of exclusive corporate hardsuit. YOU are in charge!"
	icon_state = "caparmor"
	item_state_slots = list(
		slot_l_hand_str = "capspacesuit",
		slot_r_hand_str = "capspacesuit",
	)
	armor = list(melee = 75, bullet = 60, laser = 60, energy = 35, bomb = 55, bio = 100, rad = 50)
	allowed = list(/obj/item/weapon/gun,/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/device/suit_cooling_unit, /obj/item/ammo_magazine, /obj/item/ammo_casing, /obj/item/weapon/melee/baton, /obj/item/weapon/handcuffs, /obj/item/weapon/disk/nuclear)
	siemens_coefficient = 0.5

/obj/item/clothing/suit/space/void/captain/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/captain
	boots = /obj/item/clothing/shoes/magboots

//Atmospherics
/obj/item/clothing/head/helmet/space/void/atmos
	desc = "A flame-retardant voidsuit helmet with a self-repairing visor and light anti-radiation shielding."
	name = "atmospherics voidsuit helmet"
	icon_state = "rig0-atmos"
	item_state = "atmos_helm"
	item_state_slots = list(
		slot_l_hand_str = "atmos_helm",
		slot_r_hand_str = "atmos_helm",
		)
	armor = list(melee = 40, bullet = 5, laser = 20,energy = 5, bomb = 35, bio = 100, rad = 50)
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	light_overlay = "helmet_light_dual"

/obj/item/clothing/suit/space/void/atmos
	desc = "A durable voidsuit with advanced temperature-regulation systems as well as minor radiation protection. Well worth the price."
	icon_state = "rig-atmos"
	name = "atmos voidsuit"
	item_state_slots = list(
		slot_l_hand_str = "atmos_voidsuit",
		slot_r_hand_str = "atmos_voidsuit",
	)
	armor = list(melee = 40, bullet = 5, laser = 20,energy = 5, bomb = 35, bio = 100, rad = 50)
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/device/suit_cooling_unit,/obj/item/weapon/storage/toolbox,/obj/item/weapon/storage/briefcase/inflatable,/obj/item/device/t_scanner,/obj/item/weapon/rcd)

/obj/item/clothing/suit/space/void/atmos/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/atmos
	boots = /obj/item/clothing/shoes/magboots

//Surplus Voidsuits

//Engineering
/obj/item/clothing/head/helmet/space/void/engineering/alt
	name = "reinforced engineering voidsuit helmet"
	desc = "A heavy, radiation-shielded voidsuit helmet with a surprisingly comfortable interior."
	icon_state = "rig0-engineeringalt"
	item_state = "engalt_helm"
	armor = list(melee = 40, bullet = 5, laser = 20,energy = 5, bomb = 45, bio = 100, rad = 100)
	light_overlay = "helmet_light_dual"

/obj/item/clothing/suit/space/void/engineering/alt
	name = "reinforced engineering voidsuit"
	desc = "A bulky industrial voidsuit. It's a few generations old, but a reliable design and radiation shielding make up for the lack of climate control."
	icon_state = "rig-engineeringalt"
	armor = list(melee = 40, bullet = 5, laser = 20,energy = 5, bomb = 45, bio = 100, rad = 100)

/obj/item/clothing/suit/space/void/engineering/alt/New()
	..()
	slowdown_per_slot[slot_wear_suit] = 2

/obj/item/clothing/suit/space/void/engineering/alt/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/engineering/alt
	boots = /obj/item/clothing/shoes/magboots

//Mining
/obj/item/clothing/head/helmet/space/void/mining/alt
	name = "frontier mining voidsuit helmet"
	desc = "An armored voidsuit helmet. Someone must have through they were pretty cool when they painted a mohawk on it."
	icon_state = "rig0-miningalt"
	item_state = "miningalt_helm"
	armor = list(melee = 50, bullet = 15, laser = 20,energy = 5, bomb = 55, bio = 100, rad = 0)

/obj/item/clothing/suit/space/void/mining/alt
	icon_state = "rig-miningalt"
	name = "frontier mining voidsuit"
	desc = "A cheap prospecting voidsuit. What it lacks in comfort it makes up for in armor plating and street cred."
	armor = list(melee = 50, bullet = 15, laser = 20,energy = 5, bomb = 55, bio = 100, rad = 0)

/obj/item/clothing/suit/space/void/mining/alt/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/mining/alt

/obj/item/clothing/head/helmet/space/void/mining/reinforced
	name = "reinforced mining voidsuit helmet"
	desc = "An armored voidsuit helmet. Someone must have through they were pretty cool when they painted a mohawk on it."
	icon_state = "rig0-miningref"
	item_state = "miningref_helm"
	armor = list(melee = 70, bullet = 5, laser = 30,energy = 5, bomb = 55, bio = 100, rad = 80)

/obj/item/clothing/suit/space/void/mining/reinforced
	icon_state = "rig-miningref"
	name = "reinforced mining voidsuit"
	desc = "A heavy-duty prospecting voidsuit. What it lacks in comfort it makes up for in armor plating and street cred."
	armor = list(melee = 70, bullet = 5, laser = 30,energy = 5, bomb = 55, bio = 100, rad = 80)

/obj/item/clothing/suit/space/void/mining/reinforced/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/mining/reinforced

//Medical
/obj/item/clothing/head/helmet/space/void/medical/alt
	name = "streamlined medical voidsuit helmet"
	desc = "A trendy, lightly radiation-shielded voidsuit helmet trimmed in a fetching blue."
	icon_state = "rig0-medicalalt"
	item_state = "medicalalt_helm"
	armor = list(melee = 30, bullet = 5, laser = 10,energy = 5, bomb = 5, bio = 100, rad = 60)
	light_overlay = "helmet_light_dual_green"

/obj/item/clothing/suit/space/void/medical/alt
	icon_state = "rig-medicalalt"
	name = "streamlined medical voidsuit"
	desc = "A more recent model of Vey-Med voidsuit, featuring the latest in radiation shielding technology, without sacrificing comfort or style."
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/device/suit_cooling_unit,/obj/item/weapon/storage/firstaid,/obj/item/device/healthanalyzer,/obj/item/stack/medical)
	armor = list(melee = 30, bullet = 5, laser = 10,energy = 5, bomb = 5, bio = 100, rad = 60)

/obj/item/clothing/suit/space/void/medical/alt/New()
	..()
	slowdown_per_slot[slot_wear_suit] = 0

/obj/item/clothing/suit/space/void/medical/alt/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/medical/alt
	boots = /obj/item/clothing/shoes/magboots

//Atmospherics
/obj/item/clothing/head/helmet/space/void/atmos/alt
	desc = "A voidsuit helmet plated with an expensive heat and radiation resistant ceramic."
	name = "heavy duty atmospherics voidsuit helmet"
	icon_state = "rig0-atmosalt"
	item_state = "atmosalt_helm"
	armor = list(melee = 20, bullet = 5, laser = 20,energy = 15, bomb = 45, bio = 100, rad = 50)
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	light_overlay = "hardhat_light"

/obj/item/clothing/suit/space/void/atmos/alt
	desc = "An expensive NanoTrasen voidsuit, rated to withstand extreme heat and even minor radiation without exceeding room temperature within."
	icon_state = "rig-atmosalt"
	name = "heavy duty atmos voidsuit"
	armor = list(melee = 20, bullet = 5, laser = 20,energy = 15, bomb = 45, bio = 100, rad = 50)
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/suit/space/void/atmos/alt/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/atmos/alt
	boots = /obj/item/clothing/shoes/magboots

//Exploration
/obj/item/clothing/head/helmet/space/void/exploration
	name = "exploration voidsuit helmet"
	desc = "A radiation-resistant helmet made especially for exploring unknown planetary environments."
	icon_state = "helm_explorer"
	item_state = "helm_explorer"
	armor = list(melee = 20, bullet = 10, laser = 15,energy = 45, bomb = 30, bio = 100, rad = 90)
	light_overlay = "explorer_light"

/obj/item/clothing/suit/space/void/exploration
	name = "exploration voidsuit"
	desc = "A lightweight, radiation-resistant voidsuit, featuring the Expeditionary Corps emblem on its chest plate. Designed for exploring unknown planetary environments."
	icon_state = "void_explorer"
	armor = list(melee = 20, bullet = 10, laser = 15,energy = 45, bomb = 30, bio = 100, rad = 90)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/device/suit_cooling_unit,/obj/item/stack/flag,/obj/item/device/healthanalyzer,/obj/item/device/gps,/obj/item/weapon/pinpointer/radio,/obj/item/device/radio/beacon,/obj/item/weapon/material/hatchet/machete,/obj/item/weapon/shovel)

/obj/item/clothing/suit/space/void/exploration/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/exploration
	boots = /obj/item/clothing/shoes/magboots

//Misc
/obj/item/clothing/head/helmet/space/void/engineering/salvage
	name = "salvage voidsuit helmet"
	desc = "A heavily modified salvage voidsuit helmet. It has been fitted with radiation-resistant plating."
	icon_state = "rig0-salvage"
	item_state = "salvage_helm"
	item_state_slots = list(
		slot_l_hand_str = "eng_helm",
		slot_r_hand_str = "eng_helm",
		)
	armor = list(melee = 50, bullet = 10, laser = 30,energy = 15, bomb = 35, bio = 100, rad = 80)

/obj/item/clothing/suit/space/void/engineering/salvage
	name = "salvage voidsuit"
	desc = "A hand-me-down salvage voidsuit. It has obviously had a lot of repair work done to its radiation shielding."
	icon_state = "rig-salvage"
	item_state_slots = list(
		slot_l_hand_str = "eng_voidsuit",
		slot_r_hand_str = "eng_voidsuit",
	)
	armor = list(melee = 50, bullet = 10, laser = 30,energy = 15, bomb = 35, bio = 100, rad = 80)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/device/suit_cooling_unit,/obj/item/weapon/storage/toolbox,/obj/item/weapon/storage/briefcase/inflatable,/obj/item/device/t_scanner,/obj/item/weapon/rcd)

/obj/item/clothing/suit/space/void/engineering/salvage/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/engineering/salvage
	boots = /obj/item/clothing/shoes/magboots

//Pilot
/obj/item/clothing/head/helmet/space/void/pilot
	desc = "An atmos resistant helmet for space and planet exploration."
	name = "pilot voidsuit helmet"
	icon_state = "rig0_pilot"
	item_state = "pilot_helm"
	armor = list(melee = 40, bullet = 5, laser = 15,energy = 5, bomb = 5, bio = 100, rad = 50)
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	light_overlay = "helmet_light_dual"

/obj/item/clothing/suit/space/void/pilot
	desc = "An atmos resistant voidsuit for space and planet exploration."
	icon_state = "rig-pilot"
	item_state = "rig-pilot"
	name = "pilot voidsuit"
	armor = list(melee = 40, bullet = 5, laser = 15,energy = 5, bomb = 5, bio = 100, rad = 50)
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/device/suit_cooling_unit,/obj/item/weapon/storage/toolbox,/obj/item/weapon/storage/briefcase/inflatable,/obj/item/device/t_scanner,/obj/item/weapon/rcd)

/obj/item/clothing/suit/space/void/pilot/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/pilot
	boots = /obj/item/clothing/shoes/magboots

//Non-standard
/obj/item/clothing/head/helmet/space/void/knight
	name = "strange voidsuit helmet"
	desc = "A bulky helmet with some heavy armor plating."
	icon_state = "hardsuit-helm-knight"
	item_state = "hardsuit-helm-knight"
	armor = list(melee = 70, bullet = 35, laser = 35, energy = 25, bomb = 55, bio = 100, rad = 10)
	siemens_coefficient = 0.7
	light_overlay = "helmet_light_dual"

/obj/item/clothing/suit/space/void/knight
	icon_state = "hardsuit-knight"
	item_state = "hardsuit-knight"
	name = "strange voidsuit"
	desc = "A bulky set of space-proof armor, that looks kinda ancient. 'Lancelot X-40' is written on the front plate."
	armor = list(melee = 70, bullet = 35, laser = 35, energy = 25, bomb = 55, bio = 100, rad = 10)
	allowed = list(/obj/item/weapon/gun,/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/device/suit_cooling_unit,/obj/item/weapon/melee/baton)
	siemens_coefficient = 0.7

/obj/item/clothing/head/helmet/space/void/optical
	name = "experimental helmet"
	icon_state = "hardsuit-optical"
	desc = "Strange looking, smoothly contoured helmet. It looks a bit blurry."
	siemens_coefficient = 0
	armor = list(melee = 35, bullet = 40, laser = 45, energy = 40, bomb = 20, bio = 100, rad = 60)

/obj/item/clothing/suit/space/void/optical
	name = "experimental voidsuit"
	icon_state = "hardsuit-optical"
	desc = "Strange black voidsuit, with some devices attached to it. It looks a bit blurry."
	action_button_name = "Toggle Optical Disruptor"
	siemens_coefficient = 0
	armor = list(melee = 35, bullet = 40, laser = 45, energy = 40, bomb = 20, bio = 100, rad = 60)
	var/cloak = FALSE

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
