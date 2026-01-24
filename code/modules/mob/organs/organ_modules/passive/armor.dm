/obj/item/organ_module/armor
	name = "armor plating"
	desc = "A set of lightweight armor plates designed to provide additional impact protection."
	allowed_organs = BP_ALL_LIMBS
	icon_state = "armor"
	loadout_cost = 0
	available_in_charsetup = TRUE
	augment_cost = 5
	cpu_load = 0
	origin_tech = list(TECH_COMBAT = 4, TECH_MATERIAL = 7)
	matter = list(
		MATERIAL_DURANIUM = 1000,
		MATERIAL_PLASTEEL = 2000
	)
	module_flags = OM_FLAG_DEFAULT | OM_FLAG_BIOLOGICAL | OM_FLAG_MECHANICAL

/obj/item/organ_module/armor/post_install(obj/item/organ/external/E)
	E?.brute_mod -= 0.3

/obj/item/organ_module/armor/post_removed(obj/item/organ/external/E)
	E?.brute_mod += 0.3
