/obj/item/organ_module/armor
	name = "subdermal armor"
	desc = "A set of subdermal steel plates, designed to provide additional impact protection to the torso while remaining lightweight."
	allowed_organs = list(BP_CHEST)
	icon_state = "armor-chest"
	loadout_cost = 15
	available_in_charsetup = TRUE
	origin_tech = list(TECH_COMBAT = 3, TECH_ENGINEERING = 3)
	module_flags = OM_FLAG_DEFAULT | OM_FLAG_BIOLOGICAL

/obj/item/organ_module/armor/post_install(obj/item/organ/external/E)
	E?.brute_mod -= 0.3

/obj/item/organ_module/armor/post_removed(obj/item/organ/external/E)
	E?.brute_mod += 0.3
