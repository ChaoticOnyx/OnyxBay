/obj/item/organ_module/active/cyber_hair
	name = "synthetic hair extensions"
	icon_state = "cranial_aug"
	cooldown = 20
	allowed_organs = list(BP_HEAD)
	module_flags = OM_FLAG_DEFAULT | OM_FLAG_BIOLOGICAL

/obj/item/organ_module/active/cyber_hair/activate(obj/item/organ/E, mob/living/carbon/human/H)
	H.visible_message(SPAN_NOTICE("\The [H]'s hair begins to rapidly shift in shape and length."))
	H.change_appearance(APPEARANCE_ALL_HAIR, H)
