/obj/item/organ_module/active/cyber_hair
	name = "synthetic hair extensions"
	desc = "Synthetical hair augmentations, that allows you to change your hairstyle and haicolor. Facial hair included! Remember, style comes first"
	icon_state = "cranial_aug"
	action_button_name = "Synthetic hair extensions"
	cooldown = 20
	allowed_organs = list(BP_HEAD)
	module_flags = OM_FLAG_DEFAULT | OM_FLAG_BIOLOGICAL
	available_in_charsetup = TRUE
	loadout_cost = 1
	augment_cost = 0
	w_class = 1
	cpu_load = 0
	origin_tech = list(TECH_POWER = 2, TECH_BIO = 2)
	matter = list(
		MATERIAL_PLASTIC = 2000,
		MATERIAL_GLASS = 2000
	)

/obj/item/organ_module/active/cyber_hair/activate(obj/item/organ/E, mob/living/carbon/human/H)
	H.visible_message(SPAN_NOTICE("\The [H]'s hair begins to rapidly shift in shape and length."))
	H.change_appearance(APPEARANCE_ALL_HAIR, H)
