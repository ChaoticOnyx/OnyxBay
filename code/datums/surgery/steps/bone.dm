/**
 * Default bone surgery step, does nothing.
 */
/datum/surgery_step/bone
	can_infect = TRUE
	blood_level = BLOODY_HANDS
	shock_level = 20

	failure_sound = 'sound/effects/bonebreak1.ogg'

/datum/surgery_step/bone/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	return (..() && !BP_IS_ROBOTIC(parent_organ) && parent_organ.open() >= SURGERY_RETRACTED)

/**
 * Bone glueing step.
 */
/datum/surgery_step/bone/glue_bone
	duration = GLUE_BONE_DURATION
	allowed_tools = list(
		/obj/item/bonegel = 100,
		/obj/item/tape_roll = 75
		)

	preop_sound = 'sound/surgery/bonegel.ogg'
	success_sound = 'sound/surgery/organ2.ogg'

/datum/surgery_step/bone/glue_bone/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	return (..() && parent_organ.stage == 0)

/datum/surgery_step/bone/glue_bone/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	var/bone = parent_organ.encased ? "[target]'s [parent_organ.encased]" : "bones in [target]'s [parent_organ]"
	announce_preop(user,
		"[user] starts applying \the [tool] to the [bone].",
		"You start applying \the [tool] to the [bone]."
		)
	target.custom_pain(
		"Something in your [parent_organ] is causing you a lot of pain!",
		50,
		affecting = parent_organ
		)
	return ..()

/datum/surgery_step/bone/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	var/bone = parent_organ.encased ? "[target]'s [parent_organ.encased]" : "bones in [target]'s [parent_organ]"
	announce_success(user,
		"[user] applies some [tool.name] to [bone]",
		"You apply some [tool.name] to [bone]."
		)
	parent_organ.stage = 1

/datum/surgery_step/glue_bone/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_failure(user,
		"[user]'s hand slips, smearing [tool] in the incision in [target]'s [parent_organ]!",
		"Your hand slips, smearing [tool] in the incision in [target]'s [parent_organ]!"
		)

/**
 * Bone mending step, used on all bodypart except head.
 */
/datum/surgery_step/bone/mend_bone
	duration = BONE_MEND_DURATION
	shock_level = 40
	delicate = TRUE

	allowed_tools = list(
		/obj/item/bonesetter = 100,
		/obj/item/wrench = 75
		)

	preop_sound = 'sound/surgery/bonesetter.ogg'
	success_sound = 'sound/surgery/bonesetter.ogg'

/datum/surgery_step/bone/mend_bone/check_zone(mob/living/carbon/human/target, target_zone)
	return (..() && target_zone != BP_HEAD)

/datum/surgery_step/bone/mend_bone/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	return (..() && parent_organ.stage == 1)

/datum/surgery_step/bone/mend_bone/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	var/bone = parent_organ.encased ? "[target]'s [parent_organ.encased]" : "bones in [target]'s [parent_organ]"
	announce_preop(user,
		"[user] is beginning to piece together [bone] with \the [tool].",
		"You are beginning to piece together [bone] with \the [tool]."
		)
	return ..()

/datum/surgery_step/bone/mend_bone/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	var/bone = parent_organ.encased ? "[target]'s [parent_organ.encased]" : "bones in [target]'s [parent_organ]"
	announce_success(user,
		"[user] sets [bone] with \the [tool].",
		"You set [bone] with \the [tool]."
		)
	parent_organ.status &= ~ORGAN_DISFIGURED
	parent_organ.stage = 2

/datum/surgery_step/bone/mend_bone/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_failure(user,
		"[user]'s hand slips, damaging [target]'s [parent_organ.name] with \the [tool]!",
		"Your hand slips, damaging [target]'s [parent_organ.name] with \the [tool]!"
		)
	parent_organ.take_external_damage(10, used_weapon = tool)
	parent_organ.status |= ORGAN_DISFIGURED

/**
 * Skull mending step.
 */
/datum/surgery_step/bone/mend_skull
	delicate = TRUE
	shock_level = 40
	duration = BONE_MEND_DURATION

	allowed_tools = list(
		/obj/item/bonesetter = 100,
		/obj/item/wrench = 75
		)

	preop_sound = 'sound/surgery/bonesetter.ogg'
	success_sound = 'sound/surgery/bonesetter.ogg'

/datum/surgery_step/bone/mend_skull/check_zone(mob/living/carbon/human/target, target_zone)
	return (..() && target_zone == BP_HEAD)

/datum/surgery_step/bone/mend_skull/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	return (..() && parent_organ.stage == 1)

/datum/surgery_step/bone/mend_skull/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_preop(user,
		"[user] is beginning to piece together [target]'s skull with \the [tool].",
		"You are beginning to piece together [target]'s skull with \the [tool]."
		)
	return ..()

/datum/surgery_step/bone/mend_skull/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_success(user,
		"[user] sets [target]'s skull with \the [tool].",
		"You set [target]'s skull with \the [tool]."
		)
	parent_organ.stage = 2

/datum/surgery_step/bone/mend_skull/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_failure(user,
		"[user]'s hand slips, damaging [target]'s face with \the [tool]!",
		"Your hand slips, damaging [target]'s face with \the [tool]!"
		)
	parent_organ.take_external_damage(10, used_weapon = tool)
	parent_organ.status |= ORGAN_DISFIGURED

/**
 * Bone setting step.
 */
/datum/surgery_step/bone/set_bone
	shock_level = 40
	delicate = TRUE
	duration = BONE_MEND_DURATION
	allowed_tools = list(
		/obj/item/bonesetter = 100,
		/obj/item/wrench = 75
		)

	preop_sound = 'sound/surgery/bonesetter.ogg'
	success_sound = 'sound/surgery/bonesetter.ogg'

/datum/surgery_step/bone/set_bone/check_zone(mob/living/carbon/human/target, target_zone)
	return (..() && target_zone != BP_HEAD)

/datum/surgery_step/bone/set_bone/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	return (..() && parent_organ.stage == 1)

/datum/surgery_step/bone/set_bone/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	var/bone = parent_organ.encased ? "[target]'s [parent_organ.encased]" : "bones in [target]'s [parent_organ]"
	announce_preop(user,
		"[user] is beginning to set the [bone] in place with \the [tool].",
		"You are beginning to set the [bone] in place with \the [tool]."
		)
	target.custom_pain(
		"The pain in your [parent_organ] is going to make you pass out!",
		50,
		affecting = parent_organ
		)
	return ..()

/datum/surgery_step/bone/set_bone/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	var/bone = parent_organ.encased ? "[target]'s [parent_organ.encased]" : "bones in [target]'s [parent_organ]"
	if(parent_organ.status & ORGAN_BROKEN)
		announce_success(user,
			"[user] sets the [bone] in place with \the [tool].",
			"You set the [bone] in place with \the [tool]."
			)
		parent_organ.stage = 2
	else
		announce_success(user,
			"[user] sets the [bone]" + SPAN("warning", " in the WRONG place with \the [tool]."),
			"You set the [bone]" + SPAN("warning", " in the WRONG place with \the [tool].")
			)
		parent_organ.fracture()

/datum/surgery_step/bone/set_bone/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_failure(user,
		"[user]'s hand slips, damaging the [parent_organ.encased ? parent_organ.encased : "bones"] in [target]'s [parent_organ] with \the [tool]!",
		"Your hand slips, damaging the [parent_organ.encased ? parent_organ.encased : "bones"] in [target]'s [parent_organ] with \the [tool]!"
		)
	parent_organ.fracture()
	parent_organ.take_external_damage(5, used_weapon = tool)

/**
 * Applies bonegel on set bone.
 */
/datum/surgery_step/bone/postset_bone
	duration = GLUE_BONE_DURATION

	allowed_tools = list(
		/obj/item/bonegel = 100,
		/obj/item/tape_roll = 75
		)

	preop_sound = 'sound/surgery/bonegel.ogg'
	success_sound = 'sound/surgery/organ1.ogg'

/datum/surgery_step/bone/postset_bone/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	return (..() && parent_organ.stage == 2)

/datum/surgery_step/bone/postset_bone/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	var/bone = parent_organ.encased ? "[target]'s [parent_organ.encased]" : "bones in [target]'s [parent_organ]"
	announce_preop(user,
		"[user] starts to finish mending the damaged [bone] with \the [tool].",
		"You start to finish mending the damaged [bone] with \the [tool]."
		)
	return ..()

/datum/surgery_step/bone/postset_bone/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	var/bone = parent_organ.encased ? "[target]'s [parent_organ.encased]" : "bones in [target]'s [parent_organ]"
	announce_success(user,
		"[user] has mended the damaged [bone] with \the [tool].",
		"You have mended the damaged [bone] with \the [tool]."
		)
	parent_organ.mend_fracture()
	parent_organ.stage = 0

/datum/surgery_step/bone/postset_bone/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_failure(user,
		"[user]'s hand slips, smearing [tool] in the incision in [target]'s [parent_organ]!",
		"Your hand slips, smearing [tool] in the incision in [target]'s [parent_organ]!"
		)

/**
 * All-in-one operation using bone mender.
 */
/datum/surgery_step/bone/mender
	duration = BONE_MEND_DURATION

	allowed_tools = list(
		/obj/item/bonesetter/bone_mender = 100
		)

	preop_sound = 'sound/surgery/bonesetter.ogg'
	success_sound = 'sound/surgery/organ1.ogg'

/datum/surgery_step/bone/mender/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	return (..() && parent_organ.stage <= 5)

/datum/surgery_step/bone/mender/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_preop(user,
		"[user] starts grasping the damaged bone edges in [target]'s [parent_organ] with \the [tool].",
		"You start grasping the bone edges and fusing them in [target]'s [parent_organ] with \the [tool]."
		)
	target.custom_pain(
		"Something in your [parent_organ] is causing you a lot of pain!",
		50,
		affecting = parent_organ
		)
	return ..()

/datum/surgery_step/bone/mender/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_success(user,
		"[user] has grasped the damaged bone edges in [target]'s [parent_organ] with \the [tool].",
		"You have grasped the damaged bone edges in [target]'s [parent_organ] with \the [tool]."
		)
	parent_organ.mend_fracture()
	parent_organ.stage = 0

/datum/surgery_step/bone/mender/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_failure(user,
		"\The [tool] in [user]'s hand skips, jabbing the bone edges into the sides of [target]'s [parent_organ]!",
		"Your hand jolts and \the [tool] skips, jabbing the bone edges into [target]'s [parent_organ] with \the [tool]!"
		)
	parent_organ.take_external_damage(10, used_weapon = tool)
