/obj/item/organ/external/diona
	name = "tendril"
	amputation_point = "branch"
	joint = "structural ligament"
	dislocated = -1
	limb_flags = ORGAN_FLAG_CAN_AMPUTATE

/obj/item/organ/external/diona/chest
	name = "core trunk"
	organ_tag = BP_CHEST
	icon_name = "torso"
	max_damage = 200
	min_broken_damage = 50
	w_class = ITEM_SIZE_HUGE
	body_part = UPPER_TORSO
	vital = 1
	parent_organ = null
	limb_flags = ORGAN_FLAG_HEALS_OVERKILL

/obj/item/organ/external/diona/groin
	name = "fork"
	organ_tag = BP_GROIN
	icon_name = "groin"
	max_damage = 100
	min_broken_damage = 50
	w_class = ITEM_SIZE_LARGE
	body_part = LOWER_TORSO
	parent_organ = BP_CHEST

/obj/item/organ/external/diona/arm
	name = "left upper tendril"
	organ_tag = BP_L_ARM
	icon_name = "l_arm"
	max_damage = 35
	min_broken_damage = 20
	w_class = ITEM_SIZE_NORMAL
	body_part = ARM_LEFT
	parent_organ = BP_CHEST
	limb_flags = ORGAN_FLAG_CAN_AMPUTATE | ORGAN_FLAG_CAN_GRASP

/obj/item/organ/external/diona/arm/right
	name = "right upper tendril"
	organ_tag = BP_R_ARM
	icon_name = "r_arm"
	body_part = ARM_RIGHT

/obj/item/organ/external/diona/leg
	name = "left lower tendril"
	organ_tag = BP_L_LEG
	icon_name = "l_leg"
	max_damage = 35
	min_broken_damage = 20
	w_class = ITEM_SIZE_NORMAL
	body_part = LEG_LEFT
	icon_position = LEFT
	parent_organ = BP_GROIN
	limb_flags = ORGAN_FLAG_CAN_AMPUTATE | ORGAN_FLAG_CAN_STAND

/obj/item/organ/external/diona/leg/right
	name = "right lower tendril"
	organ_tag = BP_R_LEG
	icon_name = "r_leg"
	body_part = LEG_RIGHT
	icon_position = RIGHT

/obj/item/organ/external/diona/foot
	name = "left foot"
	organ_tag = BP_L_FOOT
	icon_name = "l_foot"
	max_damage = 20
	min_broken_damage = 10
	w_class = ITEM_SIZE_SMALL
	body_part = FOOT_LEFT
	icon_position = LEFT
	parent_organ = BP_L_LEG
	limb_flags = ORGAN_FLAG_CAN_AMPUTATE | ORGAN_FLAG_CAN_STAND

/obj/item/organ/external/diona/foot/right
	name = "right foot"
	organ_tag = BP_R_FOOT
	icon_name = "r_foot"
	body_part = FOOT_RIGHT
	icon_position = RIGHT
	parent_organ = BP_R_LEG
	joint = "right ankle"
	amputation_point = "right ankle"

/obj/item/organ/external/diona/hand
	name = "left grasper"
	organ_tag = BP_L_HAND
	icon_name = "l_hand"
	max_damage = 30
	min_broken_damage = 15
	w_class = ITEM_SIZE_SMALL
	body_part = HAND_LEFT
	parent_organ = BP_L_ARM
	limb_flags = ORGAN_FLAG_CAN_AMPUTATE | ORGAN_FLAG_CAN_GRASP

/obj/item/organ/external/diona/hand/right
	name = "right grasper"
	organ_tag = BP_R_HAND
	icon_name = "r_hand"
	body_part = HAND_RIGHT
	parent_organ = BP_R_ARM

//DIONA ORGANS.
/obj/item/organ/external/diona/removed()
	if(BP_IS_ROBOTIC(src))
		return ..()
	var/mob/living/carbon/human/H = owner
	..()
	if(!istype(H) || !H.organs || !H.organs.len)
		H.death()
	if(prob(50))
		spawn_diona_nymph(get_turf(src))
		qdel(src)

// Copypaste due to eye code, RIP.
/obj/item/organ/external/head/no_eyes/diona
	can_intake_reagents = 0
	max_damage = 50
	min_broken_damage = 25
	limb_flags = ORGAN_FLAG_CAN_AMPUTATE | ORGAN_FLAG_CAN_BREAK
	skull_path = null

/obj/item/organ/external/head/no_eyes/diona/removed()
	if(BP_IS_ROBOTIC(src))
		return ..()
	var/mob/living/carbon/human/H = owner
	..()
	if(!istype(H) || !H.organs || !H.organs.len)
		H.death()
	if(prob(50))
		spawn_diona_nymph(get_turf(src))
		qdel(src)

/obj/item/organ/internal/diona
	name = "diona nymph"
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"
	organ_tag = "special" // Turns into a nymph instantly, no transplanting possible.

/obj/item/organ/internal/diona/removed(mob/living/user, skip_nymph)
	if(BP_IS_ROBOTIC(src))
		return ..()
	var/mob/living/carbon/human/H = owner
	..()
	if(!istype(H) || !H.organs || !H.organs.len)
		H.death()
	if(prob(50) && !skip_nymph)
		spawn_diona_nymph(get_turf(src))
		qdel(src)

/obj/item/organ/internal/diona/Process()
	return PROCESS_KILL

/obj/item/organ/internal/diona/strata
	name = "neural strata"
	parent_organ = BP_CHEST
	organ_tag = "neural strata"


/obj/item/organ/internal/diona/bladder
	name = "gas bladder"
	parent_organ = BP_HEAD
	organ_tag = "gas bladder"

/obj/item/organ/internal/diona/polyp
	name = "polyp segment"
	parent_organ = BP_GROIN
	organ_tag = "polyp segment"

/obj/item/organ/internal/diona/ligament
	name = "anchoring ligament"
	parent_organ = BP_GROIN
	organ_tag = "anchoring ligament"

/obj/item/organ/internal/diona/node
	name = "receptor node"
	parent_organ = BP_HEAD

/obj/item/organ/internal/diona/nutrients
	name = BP_NUTRIENT
	parent_organ = BP_CHEST

// These are different to the standard diona organs as they have a purpose in other
// species (absorbing radiation and light respectively)
/obj/item/organ/internal/diona/nutrients
	name = BP_NUTRIENT
	parent_organ = BP_CHEST
	organ_tag = BP_NUTRIENT
	icon = 'icons/mob/alien.dmi'
	icon_state = "claw"

/obj/item/organ/internal/diona/nutrients/removed(mob/user)
	return ..(user, 1)

/obj/item/organ/internal/diona/node
	name = "response node"
	parent_organ = BP_HEAD
	organ_tag = "response node"
	icon = 'icons/mob/alien.dmi'
	icon_state = "claw"

/obj/item/organ/internal/diona/node/Process()
	..()
	if(is_broken() || !owner)
		return
	var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
	if(isturf(owner.loc)) //else, there's considered to be no light
		var/turf/T = owner.loc
		light_amount = T.get_lumcount() * 10
	owner.nutrition   += light_amount
	owner.shock_stage -= light_amount
	owner.nutrition    = Clamp(owner.nutrition, 0, 450)

/obj/item/organ/internal/diona/node/removed(mob/user)
	return ..(user, 1)
