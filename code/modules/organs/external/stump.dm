/obj/item/organ/external/stump
	name = "limb stump"
	icon_name = ""
	dislocated = -1
	disable_food_organ = TRUE

/obj/item/organ/external/stump/New(mob/living/carbon/holder, internal, obj/item/organ/external/limb)
	if(istype(limb))
		organ_tag = limb.organ_tag
		if(!BP_IS_ROBOTIC(limb)) // These nasty fucks are broken, fuck robolimbs, their dumb icons and whomever the fuck created them in their current fucking state
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

/obj/item/organ/external/stump/rejuvenate(ignore_prosthetic_prefs)
	. = ..()
	var/mob/living/carbon/human/H = owner
	removed(drop_organ = FALSE)
	H.restore_limb(organ_tag)
	if(organ_tag == BP_L_ARM||organ_tag == BP_R_ARM)
		H.restore_limb(organ_tag==BP_L_ARM?BP_L_HAND:BP_R_HAND)

	if(organ_tag == BP_L_LEG||organ_tag == BP_R_LEG)
		H.restore_limb(organ_tag==BP_L_LEG?BP_L_FOOT:BP_R_FOOT)

	H.regenerate_icons()

/obj/item/organ/external/stump/update_damstate()
	damage_state = "00"
	return
