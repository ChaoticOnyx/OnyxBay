/obj/item/rig/ert
	name = "ERT commander powersuit control module"
	desc = "A powersuit used by NanoTrasen's elite Emergency Response Teams. Has blue highlights. Armored and space ready."
	suit_type = "ERT commander"
	icon_state = "ert_commander_rig"

	chest_type = /obj/item/clothing/suit/space/rig/ert
	helm_type = /obj/item/clothing/head/helmet/space/rig/ert
	boot_type = /obj/item/clothing/shoes/magboots/rig/ert
	glove_type = /obj/item/clothing/gloves/rig/ert

	req_access = list(access_cent_specops)

	armor = list(melee = 100, bullet = 110, laser = 120, energy = 15, bomb = 30, bio = 100)

	allowed = list(/obj/item/device/flashlight, /obj/item/tank,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/handcuffs, /obj/item/device/t_scanner, /obj/item/construction/rcd, /obj/item/crowbar, \
	/obj/item/screwdriver, /obj/item/weldingtool, /obj/item/wirecutters, /obj/item/wrench, /obj/item/device/multitool, \
	/obj/item/device/radio, /obj/item/device/analyzer,/obj/item/storage/briefcase/inflatable, /obj/item/melee/baton, /obj/item/gun, \
	/obj/item/storage/firstaid, /obj/item/reagent_containers/hypospray, /obj/item/roller)

	initial_modules = list(
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/maneuvering_jets,
		/obj/item/rig_module/datajack,
		/obj/item/rig_module/cooling_unit
		)

/obj/item/rig/ert/empty
	initial_modules = list(
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/cooling_unit,
		)

/obj/item/clothing/head/helmet/space/rig/ert
	light_overlay = "helmet_light_dual"
	camera = /obj/machinery/camera/network/ert
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI)

/obj/item/clothing/suit/space/rig/ert
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI)

/obj/item/clothing/shoes/magboots/rig/ert
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI)

/obj/item/clothing/gloves/rig/ert
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI)


/obj/item/rig/ert/engineer
	name = "ERT engineering powersuit control module"
	desc = "A powersuit used by NanoTrasen's elite Emergency Response Teams. Has orange highlights. Armored and space ready."
	suit_type = "ERT engineer"
	icon_state = "ert_engineer_rig"
	armor = list(melee = 100, bullet = 110, laser = 120, energy = 40, bomb = 60, bio = 100)

	glove_type = /obj/item/clothing/gloves/rig/ert/engineer

	initial_modules = list(
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/maneuvering_jets,
		/obj/item/rig_module/device/rcd,
		/obj/item/rig_module/cooling_unit
		)

/obj/item/rig/ert/engineer/empty
	initial_modules = list(
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/cooling_unit,
		)

/obj/item/clothing/gloves/rig/ert/engineer
	siemens_coefficient = 0

/obj/item/rig/ert/janitor
	name = "ERT sanitation powersuit control module"
	desc = "A powersuit used by NanoTrasen's elite Emergency Response Teams. Has purple highlights. Armored and space ready."
	suit_type = "ERT sanitation"
	icon_state = "ert_janitor_rig"
	armor = list(melee = 100, bullet = 110, laser = 120, energy = 15, bomb = 30, bio = 100)

	initial_modules = list(
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/maneuvering_jets,
		/obj/item/rig_module/fabricator/wf_sign,
		/obj/item/rig_module/grenade_launcher/cleaner,
		/obj/item/rig_module/device/decompiler,
		/obj/item/rig_module/cooling_unit
		)

/obj/item/rig/ert/janitor/empty
	initial_modules = list(
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/cooling_unit,
		)

/obj/item/rig/ert/medical
	name = "ERT medical powersuit control module"
	desc = "A powersuit used by NanoTrasen's elite Emergency Response Teams. Has white highlights. Armored and space ready."
	suit_type = "ERT medic"
	icon_state = "ert_medical_rig"

	initial_modules = list(
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/maneuvering_jets,
		/obj/item/rig_module/device/healthscanner,
		/obj/item/rig_module/chem_dispenser/injector,
		/obj/item/rig_module/cooling_unit
		)

/obj/item/rig/ert/medical/empty
	initial_modules = list(
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/cooling_unit,
		)

/obj/item/rig/ert/security
	name = "ERT security powersuit control module"
	desc = "A powersuit used by NanoTrasen's elite Emergency Response Teams. Has red highlights. Armored and space ready."
	suit_type = "ERT security"
	icon_state = "ert_security_rig"

	initial_modules = list(
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/maneuvering_jets,
		/obj/item/rig_module/grenade_launcher,
		/obj/item/rig_module/mounted/egun,
		/obj/item/rig_module/cooling_unit
		)

/obj/item/rig/ert/security/empty
	initial_modules = list(
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/cooling_unit,
		)

/obj/item/rig/ert/assetprotection
	name = "Death Squad suit control module"
	desc = "That's not red paint. That's real blood."
	suit_type = "Death Squad"
	icon_state = "asset_protection_rig"
	armor = list(melee = 130, bullet = 150, laser = 150, energy = 65, bomb = 80, bio = 100)

	glove_type = /obj/item/clothing/gloves/rig/ert/assetprotection

	initial_modules = list(
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/maneuvering_jets,
		/obj/item/rig_module/grenade_launcher,
		/obj/item/rig_module/vision/multi,
		/obj/item/rig_module/mounted/egun,
		/obj/item/rig_module/chem_dispenser/injector,
		/obj/item/rig_module/device/rcd,
		/obj/item/rig_module/datajack,
		/obj/item/rig_module/cooling_unit
		)

/obj/item/rig/ert/assetprotection/empty
	initial_modules = list(
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/cooling_unit,
		)

/obj/item/clothing/gloves/rig/ert/assetprotection
	siemens_coefficient = 0
