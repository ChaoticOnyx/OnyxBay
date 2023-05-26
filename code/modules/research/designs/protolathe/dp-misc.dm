/datum/design/item/hud/security
	name = "HUD security records"
	id = "security_hud"

	build_path = /obj/item/clothing/glasses/hud/aviators/security
	sort_string = "GAAAB"

/datum/design/item/optical
	materials = list(MATERIAL_STEEL = 50, MATERIAL_GLASS = 50)
	category_items = list("Misc")

/datum/design/item/optical/mesons
	name = "optical mesons scanner"
	desc = "Using the meson-scanning technology those glasses allow you to see through walls, floor or anything else."
	id = "mesons"

	build_path = /obj/item/clothing/glasses/hud/standard/meson
	sort_string = "GBAAA"

/datum/design/item/optical/material
	name = "optical material scanner"
	id = "mesons_material"

	materials = list(MATERIAL_STEEL = 50, MATERIAL_GLASS = 50, MATERIAL_PLASMA = 100)
	build_path = /obj/item/clothing/glasses/hud/standard/material
	sort_string = "GBAAB"

/datum/design/item/optical/tactical
	name = "tactical goggles"
	id = "tactical_goggles"

	materials = list(MATERIAL_STEEL = 50, MATERIAL_GLASS = 50, MATERIAL_SILVER = 50, MATERIAL_GOLD = 50)
	build_path = /obj/item/clothing/glasses/tacgoggles
	sort_string = "GBAAC"

/datum/design/item/synthstorage/paicard
	name = "pAI"
	desc = "Personal Artificial Intelligence device."
	id = "paicard"

	materials = list(MATERIAL_GLASS = 500, MATERIAL_STEEL = 500)
	build_path = /obj/item/device/paicard
	sort_string = "VABAI"
	category_items = list("Misc")

/datum/design/item/tool/light_replacer
	name = "light replacer"
	desc = "A device to automatically replace lights. Refill with working lightbulbs."
	id = "light_replacer"

	materials = list(MATERIAL_STEEL = 1500, MATERIAL_SILVER = 150, MATERIAL_GLASS = 3000)
	build_path = /obj/item/device/lightreplacer
	sort_string = "VAGAB"

/datum/design/item/advanced_light_replacer
	name = "advanced light replacer"
	desc = "A specialised light replacer which stores more lights and refills faster from boxes."
	id = "advanced_light_replacer"

	materials = list(MATERIAL_STEEL = 1500, MATERIAL_SILVER = 300, MATERIAL_GLASS = 3000, MATERIAL_GOLD = 100, MATERIAL_URANIUM = 250)
	build_path =/obj/item/device/lightreplacer/advanced
	sort_string = "VAGAC"

/datum/design/item/tool/price_scanner
	name = "price scanner"
	desc = "Using an up-to-date database of various costs and prices, this device estimates the market price of an item up to 0.001% accuracy."
	id = "price_scanner"

	materials = list(MATERIAL_STEEL = 3000, MATERIAL_GLASS = 3000, MATERIAL_SILVER = 250)
	build_path = /obj/item/device/price_scanner
	sort_string = "VAGAG"

/datum/design/item/encryptionkey/AssembleDesignName()
	..()
	name = "Encryption [item_name] key"

/datum/design/item/encryptionkey/binary
	name = "binary"
	desc = "Allows for deciphering the binary channel on-the-fly."
	id = "binaryencrypt"

	materials = list(MATERIAL_STEEL = 300, MATERIAL_GLASS = 300)
	build_path = /obj/item/device/encryptionkey/binary
	sort_string = "VASAA"
	category_items = list("Misc")

/datum/design/item/camouflage/chameleon
	name = "holographic equipment kit"
	desc = "A kit of dangerous, high-tech equipment with changeable looks."
	id = "chameleon"

	materials = list(MATERIAL_STEEL = 500)
	build_path = /obj/item/storage/backpack/chameleon/sydie_kit
	sort_string = "VASBA"
	category_items = list("Misc")
