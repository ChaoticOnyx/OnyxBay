/obj/item/organ_module/armor
	name = "armor plating mark 1"
	desc = "A set of lightweight armor plates designed to provide additional impact protection."
	allowed_organs = BP_ALL_LIMBS
	icon_state = "mk1armor"
	loadout_cost = 0
	available_in_charsetup = TRUE
	augment_cost = 5
	cpu_load = 0
	origin_tech = list(TECH_MATERIAL = 2, TECH_BIO = 3, TECH_COMBAT = 2)
	matter = list(
		MATERIAL_STEEL = 4000,
		MATERIAL_PLASTIC = 6000
	)
	module_flags = OM_FLAG_DEFAULT | OM_FLAG_BIOLOGICAL | OM_FLAG_MECHANICAL
	var/armor_protection = 0.12

/obj/item/organ_module/armor/post_install(obj/item/organ/external/E)
	E?.brute_mod -= armor_protection

/obj/item/organ_module/armor/post_removed(obj/item/organ/external/E)
	E?.brute_mod += armor_protection

/obj/item/organ_module/armor/has_duplicate_in(obj/item/organ/E)
	for(var/obj/item/organ_module/module in E.organ_modules)
		if(module == src)
			continue
		if(istype(module, /obj/item/organ_module/armor))
			return TRUE
	return FALSE

/obj/item/organ_module/armor/mk2
	name = "armor plating mark 2"
	icon_state = "mk2armor"
	available_in_charsetup = FALSE
	origin_tech = list(TECH_MATERIAL = 3, TECH_BIO = 4, TECH_COMBAT = 4)
	matter = list(
		MATERIAL_STEEL = 4000,
		MATERIAL_SILVER = 4000,
		MATERIAL_PLASTIC = 2000
	)
	armor_protection = 0.20

/obj/item/organ_module/armor/mk3
	name = "armor plating mark 3"
	icon_state = "mk3armor"
	available_in_charsetup = FALSE
	origin_tech = list(TECH_MATERIAL = 5, TECH_BIO = 6, TECH_COMBAT = 5)
	matter = list(
		MATERIAL_PLASTEEL = 4000,
		MATERIAL_GOLD = 2500,
		MATERIAL_PLASTIC = 1500,
		MATERIAL_SILVER = 1000
	)
	armor_protection = 0.35

/obj/item/organ_module/armor/mk4
	name = "armor plating mark 4"
	icon_state = "mk4armor"
	available_in_charsetup = FALSE
	origin_tech = list(TECH_MATERIAL = 7, TECH_BIO = 8, TECH_COMBAT = 7)
	matter = list(
		MATERIAL_DURANIUM = 2000,
		MATERIAL_PLASTEEL = 2500,
		MATERIAL_DIAMOND = 2000,
		MATERIAL_PLASTIC = 1000,
		MATERIAL_SILVER = 500,
		MATERIAL_GOLD = 500
	)
	armor_protection = 0.50
