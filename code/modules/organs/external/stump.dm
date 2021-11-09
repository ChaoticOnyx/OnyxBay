/obj/item/organ/external/stump
	name = "limb stump"
	icon_name = ""
	dislocated = -1
	disable_food_organ = TRUE

/obj/item/organ/external/stump/New(mob/living/carbon/holder, internal, obj/item/organ/external/limb)
	if(istype(limb))
		organ_tag = limb.organ_tag
		icon_name = limb.icon_name
		body_part = limb.body_part
		amputation_point = limb.amputation_point
		joint = limb.joint
		parent_organ = limb.parent_organ
	..(holder, internal)
	if(istype(limb))
		max_damage = limb.max_damage
		if(BP_IS_ROBOTIC(limb) && (!parent || BP_IS_ROBOTIC(parent)))
			robotize() //if both limb and the parent are robotic, the stump is robotic too

/obj/item/organ/external/stump/is_stump()
	return 1
