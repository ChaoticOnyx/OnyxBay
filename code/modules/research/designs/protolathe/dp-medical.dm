/datum/design/item/hud/health
	name = "HUD health scanner"
	id = "health_hud"

	build_path = /obj/item/clothing/glasses/hud/standard/medical
	sort_string = "GAAAA"
	category_items = list("Medical")

/datum/design/item/medical
	materials = list(MATERIAL_STEEL = 30, MATERIAL_GLASS = 20)
	category_items = list("Medical")

/datum/design/item/medical/metroid_scanner
	desc = "Multipurpose organic life scanner."
	id = "metroid_scanner"

	materials = list(MATERIAL_STEEL = 200, MATERIAL_GLASS = 100)
	build_path = /obj/item/device/metroid_scanner
	sort_string = "MACFA"

/datum/design/item/medical/mass_spectrometer
	desc = "A device for analyzing chemicals in blood."
	id = "mass_spectrometer"

	build_path = /obj/item/device/mass_spectrometer
	sort_string = "MACAA"

/datum/design/item/medical/adv_mass_spectrometer
	desc = "A device for analyzing chemicals in blood and their quantities."
	id = "adv_mass_spectrometer"

	build_path = /obj/item/device/mass_spectrometer/adv
	sort_string = "MACAB"

/datum/design/item/medical/reagent_scanner
	desc = "A device for identifying chemicals."
	id = "reagent_scanner"

	build_path = /obj/item/device/reagent_scanner
	sort_string = "MACBA"

/datum/design/item/medical/adv_reagent_scanner
	desc = "A device for identifying chemicals and their proportions."
	id = "adv_reagent_scanner"

	build_path = /obj/item/device/reagent_scanner/adv
	sort_string = "MACBB"

/datum/design/item/medical/nanopaste
	desc = "A tube of paste containing swarms of repair nanites. Very effective in repairing robotic machinery."
	id = "nanopaste"

	materials = list(MATERIAL_STEEL = 7000, MATERIAL_GLASS = 7000)
	build_path = /obj/item/stack/nanopaste
	sort_string = "MADAA"

/datum/design/item/medical/hypospray
	desc = "A sterile, air-needle autoinjector for rapid administration of drugs"
	id = "hypospray"

	materials = list(MATERIAL_STEEL = 8000, MATERIAL_GLASS = 8000, MATERIAL_SILVER = 2000)
	build_path = /obj/item/reagent_containers/hypospray/vial
	sort_string = "MAEAA"

/datum/design/item/beaker
	category_items = list("Medical")



/datum/design/item/beaker/plass
	desc = "A beaker made of plasma-based silicate, it doesn't allow radiation to pass through. Can hold up to 60 units."
	id = "plassbeaker"

	materials = list(MATERIAL_GLASS = 2500, MATERIAL_PLASMA = 1500)
	build_path = /obj/item/reagent_containers/vessel/beaker/plass
	sort_string = "MCAAA"

/datum/design/item/beaker/noreact
	desc = "A cryostasis beaker that allows for chemical storage without reactions. Can hold up to 60 units."
	id = "splitbeaker"

	materials = list(MATERIAL_STEEL = 3000)
	build_path = /obj/item/reagent_containers/vessel/beaker/noreact
	sort_string = "MCAAB"

/datum/design/item/beaker/bluespace
	desc = "A bluespace beaker, powered by experimental bluespace technology and Element Cuban combined with the Compound Pete. Can hold up to 300 units."
	id = "bluespacebeaker"

	materials = list(MATERIAL_STEEL = 3000, MATERIAL_PLASMA = 3000, MATERIAL_DIAMOND = 500)
	build_path = /obj/item/reagent_containers/vessel/beaker/bluespace
	sort_string = "MCAAC"

/datum/design/item/implant
	materials = list(MATERIAL_STEEL = 50, MATERIAL_GLASS = 50)
	category_items = list("Medical")

/datum/design/item/implant/chemical
	name = "chemical implant"
	id = "implant_chem"

	build_path = /obj/item/implantcase/chem
	sort_string = "MFAAA"

/datum/design/item/implant/death_alarm
	name = "death alarm implant"
	id = "implant_death"

	build_path = /obj/item/implantcase/death_alarm
	sort_string = "MFAAB"

/datum/design/item/implant/tracking
	name = "tracking implant"
	id = "implant_tracking"

	build_path = /obj/item/implantcase/tracking
	sort_string = "MFAAC"

/datum/design/item/implant/imprinting
	name = "imprinting implant"
	id = "implant_imprinting"

	build_path = /obj/item/implantcase/imprinting
	sort_string = "MFAAD"

/datum/design/item/implant/adrenaline
	name = "adrenaline implant"
	id = "implant_adrenaline"

	build_path = /obj/item/implantcase/adrenalin
	sort_string = "MFAAE"

/datum/design/item/implant/freedom
	name = "freedom implant"
	id = "implant_free"

	build_path = /obj/item/implantcase/freedom
	sort_string = "MFAAF"

/datum/design/item/implant/explosive
	name = "explosive implant"
	id = "implant_explosive"

	build_path = /obj/item/implantcase/explosive
	sort_string = "MFAAG"


/datum/design/item/implant/speech_corrector
	name = "speech corrector implant"
	id = "implant_speech_corrector"

	build_path = /obj/item/implantcase/speech_corrector
	sort_string = "MFAAH"
