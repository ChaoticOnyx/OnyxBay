/obj/item/rig/light/internalaffairs
	name = "augmented tie"
	suit_type = "augmented suit"
	desc = "Prepare for paperwork."
	icon_state = "internalaffairs_rig"
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0)
	siemens_coefficient = 0.9
	online_slowdown = 0
	offline_slowdown = 0
	offline_vision_restriction = 0

	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/storage/briefcase, /obj/item/storage/secure/briefcase)

	req_access = list()
	req_one_access = list()

	glove_type = null
	helm_type = null
	boot_type = null

	hides_uniform = 0

/obj/item/rig/light/internalaffairs/equipped

	req_access = list(access_iaa)

	initial_modules = list(
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/device/flash,
		/obj/item/rig_module/device/paperdispenser,
		/obj/item/rig_module/device/pen,
		/obj/item/rig_module/device/stamp,
		/obj/item/rig_module/cooling_unit
		)

	glove_type = null
	helm_type = null
	boot_type = null

/obj/item/rig/industrial
	name = "industrial suit control module"
	suit_type = "industrial powersuit"
	desc = "A heavy, powerful rig used by construction crews and mining corporations."
	icon_state = "engineering_rig"
	armor = list(melee = 75, bullet = 35, laser = 35, energy = 15, bomb = 50, bio = 100)
	online_slowdown = 2
	offline_slowdown = 10
	offline_vision_restriction = TINT_HEAVY

	chest_type = /obj/item/clothing/suit/space/rig/industrial
	helm_type = /obj/item/clothing/head/helmet/space/rig/industrial
	boot_type = /obj/item/clothing/shoes/magboots/rig/industrial
	glove_type = /obj/item/clothing/gloves/rig/industrial

	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/stack/flag,/obj/item/storage/ore,/obj/item/device/t_scanner,/obj/item/pickaxe, /obj/item/construction/rcd, /obj/item/gun/energy/kinetic_accelerator, /obj/item/shovel, /obj/item/ore_radar, /obj/item/resonator)

	req_access = list()
	req_one_access = list()

/obj/item/clothing/head/helmet/space/rig/industrial
	brightness_on = 6
	camera = /obj/machinery/camera/network/mining
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_TAJARA,SPECIES_UNATHI)

/obj/item/clothing/suit/space/rig/industrial
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_TAJARA,SPECIES_UNATHI)

/obj/item/clothing/shoes/magboots/rig/industrial
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_TAJARA,SPECIES_UNATHI)

/obj/item/clothing/gloves/rig/industrial
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_TAJARA,SPECIES_UNATHI)
	siemens_coefficient = 0

/obj/item/rig/industrial/equipped

	initial_modules = list(
		/obj/item/rig_module/device/drill,
		/obj/item/rig_module/device/orescanner,
		/obj/item/rig_module/device/rcd,
		/obj/item/rig_module/vision/meson,
		/obj/item/rig_module/cooling_unit
		)

/obj/item/rig/eva
	name = "EVA powersuit control module"
	suit_type = "EVA powersuit"
	desc = "A light rig for repairs and maintenance to the outside of habitats and vessels."
	icon_state = "eva_rig"
	armor = list(melee = 30, bullet = 10, laser = 20, energy = 25, bomb = 20, bio = 100)
	online_slowdown = 0
	offline_slowdown = 1
	offline_vision_restriction = TINT_HEAVY

	chest_type = /obj/item/clothing/suit/space/rig/eva
	helm_type = /obj/item/clothing/head/helmet/space/rig/eva
	boot_type = /obj/item/clothing/shoes/magboots/rig/eva
	glove_type = /obj/item/clothing/gloves/rig/eva

	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/storage/toolbox,/obj/item/storage/briefcase/inflatable,/obj/item/inflatable_dispenser,/obj/item/device/t_scanner,/obj/item/construction/rcd)

	req_access = list()
	req_one_access = list()

/obj/item/clothing/head/helmet/space/rig/eva
	light_overlay = "helmet_light_dual"
	camera = /obj/machinery/camera/network/engineering
	species_restricted = list(SPECIES_HUMAN)

/obj/item/clothing/suit/space/rig/eva
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI)

/obj/item/clothing/shoes/magboots/rig/eva
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI)

/obj/item/clothing/gloves/rig/eva
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI)
	siemens_coefficient = 0

/obj/item/rig/eva/equipped

	req_access = list(access_engine_equip)

	initial_modules = list(
		/obj/item/rig_module/maneuvering_jets,
		/obj/item/rig_module/device/rcd,
		/obj/item/rig_module/vision/meson,
		/obj/item/rig_module/cooling_unit
		)

/obj/item/rig/ce

	name = "advanced engineering powersuit control module"
	suit_type = "engineering powersuit"
	desc = "An advanced powersuit that protects against hazardous, low pressure environments. Shines with a high polish. Appears compatible with the physiology of most species."
	icon_state = "ce_rig"
	armor = list(melee = 80, bullet = 70, laser = 60, energy = 65, bomb = 45, bio = 100)
	online_slowdown = 0
	offline_slowdown = 0
	offline_vision_restriction = TINT_HEAVY

	chest_type = /obj/item/clothing/suit/space/rig/ce
	helm_type = /obj/item/clothing/head/helmet/space/rig/ce
	boot_type =  /obj/item/clothing/shoes/magboots/rig/ce
	glove_type = /obj/item/clothing/gloves/rig/ce

	allowed = list(/obj/item/gun,/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/storage/ore,/obj/item/storage/toolbox,/obj/item/storage/briefcase/inflatable,/obj/item/inflatable_dispenser,/obj/item/device/t_scanner,/obj/item/pickaxe,/obj/item/construction/rcd)

	req_access = list()
	req_one_access = list()

/obj/item/rig/ce/equipped

	req_access = list(access_ce)

	initial_modules = list(
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/maneuvering_jets,
		/obj/item/rig_module/device/rcd,
		/obj/item/rig_module/device/flash,
		/obj/item/rig_module/vision/meson,
		/obj/item/rig_module/grenade_launcher/mfoam,
		/obj/item/rig_module/cooling_unit
		)

/obj/item/clothing/suit/space/rig/ce
	rad_resist_type = /datum/rad_resist/rig_ce

/obj/item/clothing/head/helmet/space/rig/ce
	rad_resist_type = /datum/rad_resist/rig_ce
	camera = /obj/machinery/camera/network/engineering

/obj/item/clothing/gloves/rig/ce
	rad_resist_type = /datum/rad_resist/rig_ce
	siemens_coefficient = 0

/obj/item/clothing/shoes/magboots/rig/ce
	rad_resist_type = /datum/rad_resist/rig_ce

/datum/rad_resist/rig_ce
	alpha_particle_resist = 533 MEGA ELECTRONVOLT
	beta_particle_resist = 400 MEGA ELECTRONVOLT
	hawking_resist = 1 ELECTRONVOLT


/obj/item/rig/hazmat
	name = "AMI control module"
	suit_type = "hazmat powersuit"
	desc = "An Anomalous Material Interaction powersuit, a prototype NanoTrasen design, protects the wearer against the strangest energies the universe can throw at it."
	icon_state = "science_rig"
	armor = list(melee = 70, bullet = 90, laser = 70, energy = 80, bomb = 90, bio = 100) // Basically a bombsuit but space-adapted
	online_slowdown = 1
	offline_vision_restriction = TINT_HEAVY

	chest_type = /obj/item/clothing/suit/space/rig/hazmat
	helm_type = /obj/item/clothing/head/helmet/space/rig/hazmat
	boot_type = /obj/item/clothing/shoes/magboots/rig/hazmat
	glove_type = /obj/item/clothing/gloves/rig/hazmat

	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/stack/flag,/obj/item/storage/excavation,/obj/item/pickaxe,/obj/item/device/healthanalyzer,/obj/item/device/measuring_tape,/obj/item/device/ano_scanner,/obj/item/device/depth_scanner,/obj/item/device/core_sampler,/obj/item/device/gps,/obj/item/pinpointer/radio,/obj/item/device/bluespace_beacon,/obj/item/pickaxe/archaeologist/hand,/obj/item/storage/bag/fossils)

	req_access = list()
	req_one_access = list()

/obj/item/clothing/head/helmet/space/rig/hazmat
	light_overlay = "helmet_light_dual"
	camera = /obj/machinery/camera/network/research
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_TAJARA,SPECIES_UNATHI)

/obj/item/clothing/suit/space/rig/hazmat
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_TAJARA,SPECIES_UNATHI)

/obj/item/clothing/shoes/magboots/rig/hazmat
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_TAJARA,SPECIES_UNATHI)

/obj/item/clothing/gloves/rig/hazmat
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_TAJARA,SPECIES_UNATHI)

/obj/item/rig/hazmat/equipped

	req_access = list(access_rd)

	initial_modules = list(
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/maneuvering_jets,
		/obj/item/rig_module/device/anomaly_scanner,
		/obj/item/rig_module/cooling_unit,
		)

/obj/item/rig/medical
	name = "medical powersuit control module"
	suit_type = "medical powersuit"
	desc = "A durable suit designed for medical rescue in high-risk areas. Although its armor plating is not that tough, it provides exceptional protection against radiation."
	icon_state = "medical_rig"
	armor = list(melee = 40, bullet = 30, laser = 40, energy = 40, bomb = 45, bio = 100)
	online_slowdown = 1
	offline_vision_restriction = TINT_HEAVY

	chest_type = /obj/item/clothing/suit/space/rig/medical
	helm_type = /obj/item/clothing/head/helmet/space/rig/medical
	boot_type = /obj/item/clothing/shoes/magboots/rig/medical
	glove_type = /obj/item/clothing/gloves/rig/medical

	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/storage/firstaid,/obj/item/device/healthanalyzer,/obj/item/stack/medical,/obj/item/roller )

	req_access = list(access_medical_equip)

/obj/item/clothing/head/helmet/space/rig/medical
	camera = /obj/machinery/camera/network/medbay
	species_restricted = list(SPECIES_HUMAN, SPECIES_TAJARA, SPECIES_UNATHI)

/obj/item/clothing/suit/space/rig/medical
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL, SPECIES_TAJARA, SPECIES_UNATHI)

/obj/item/clothing/shoes/magboots/rig/medical
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL, SPECIES_TAJARA, SPECIES_UNATHI)

/obj/item/clothing/gloves/rig/medical
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL, SPECIES_TAJARA, SPECIES_UNATHI)

/obj/item/rig/medical/equipped

	initial_modules = list(
		/obj/item/rig_module/chem_dispenser/injector,
		/obj/item/rig_module/maneuvering_jets,
		/obj/item/rig_module/device/healthscanner,
		/obj/item/rig_module/vision/medhud,
		/obj/item/rig_module/cooling_unit
		)

/obj/item/rig/security
	name = "security powersuit control module"
	suit_type = "security powersuit"
	desc = "A NanoTrasen security powersuit designed for prolonged EVA in dangerous environments."
	// TODO[V] Make icon_state resembling new naming
	icon_state = "hazard_rig"
	armor = list(melee = 90, bullet = 100, laser = 80, energy = 15, bomb = 70, bio = 100)
	online_slowdown = 1
	offline_slowdown = 3
	offline_vision_restriction = TINT_BLIND

	chest_type = /obj/item/clothing/suit/space/rig/hazard
	helm_type = /obj/item/clothing/head/helmet/space/rig/hazard
	boot_type = /obj/item/clothing/shoes/magboots/rig/hazard
	glove_type = /obj/item/clothing/gloves/rig/hazard

	allowed = list(/obj/item/gun,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/handcuffs,/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/melee/baton)

	req_access = list()
	req_one_access = list()

/obj/item/clothing/head/helmet/space/rig/hazard
	light_overlay = "helmet_light_dual"
	camera = /obj/machinery/camera/network/security
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_TAJARA,SPECIES_UNATHI)

/obj/item/clothing/suit/space/rig/hazard
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_TAJARA,SPECIES_UNATHI)

/obj/item/clothing/shoes/magboots/rig/hazard
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_TAJARA,SPECIES_UNATHI)

/obj/item/clothing/gloves/rig/hazard
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_TAJARA,SPECIES_UNATHI)

/obj/item/rig/security/equipped

	initial_modules = list(
		/obj/item/rig_module/maneuvering_jets,
		/obj/item/rig_module/vision/nvg,
		/obj/item/rig_module/mounted/taser,
		/obj/item/rig_module/chem_dispenser/combat/security,
		/obj/item/rig_module/grenade_launcher/flashbang,
		/obj/item/rig_module/cooling_unit
		)

/obj/item/rig/mining
	name = "mining powersuit control module"
	suit_type = "mining powersuit"
	desc = "An heavy, durable powersuit used for excavation in extremely hazardous environments."
	icon_state = "mining_rig"
	armor = list(melee = 145, bullet = 100, laser = 95, energy = 35, bomb = 85, bio = 100)
	online_slowdown = 2
	offline_slowdown = 10
	offline_vision_restriction = TINT_HEAVY

	chest_type = /obj/item/clothing/suit/space/rig/mining
	helm_type = /obj/item/clothing/head/helmet/space/rig/mining
	boot_type = /obj/item/clothing/shoes/magboots/rig/mining
	glove_type = /obj/item/clothing/gloves/rig/mining

	allowed = list(/obj/item/device/flashlight,
				   /obj/item/tank,
				   /obj/item/device/suit_cooling_unit,
				   /obj/item/stack/flag,
				   /obj/item/storage/ore,
				   /obj/item/device/t_scanner,
				   /obj/item/pickaxe,
				   /obj/item/construction/rcd,
				   /obj/item/gun/energy/kinetic_accelerator,
				   /obj/item/shovel,
				   /obj/item/ore_radar,
				   /obj/item/resonator)

	req_access = list()
	req_one_access = list()

/obj/item/clothing/head/helmet/space/rig/mining
	brightness_on = 6
	light_overlay = "helmet_light_dual_low"
	camera = /obj/machinery/camera/network/mining
	species_restricted = list(SPECIES_HUMAN, SPECIES_SKRELL, SPECIES_TAJARA, SPECIES_UNATHI)

/obj/item/clothing/suit/space/rig/mining
	species_restricted = list(SPECIES_HUMAN, SPECIES_SKRELL, SPECIES_TAJARA, SPECIES_UNATHI)

/obj/item/clothing/shoes/magboots/rig/mining
	species_restricted = list(SPECIES_HUMAN, SPECIES_SKRELL, SPECIES_TAJARA, SPECIES_UNATHI)

/obj/item/clothing/gloves/rig/mining
	species_restricted = list(SPECIES_HUMAN, SPECIES_SKRELL, SPECIES_TAJARA, SPECIES_UNATHI)
	siemens_coefficient = 0

/obj/item/rig/mining/equipped

	initial_modules = list(
		/obj/item/rig_module/device/drill,
		/obj/item/rig_module/device/orescanner,
		/obj/item/rig_module/device/rcd,
		/obj/item/rig_module/vision/meson,
		/obj/item/rig_module/cooling_unit
		)
