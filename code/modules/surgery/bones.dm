//Procedures in this file: Fracture repair surgery
//////////////////////////////////////////////////////////////////
//						BONE SURGERY							//
//////////////////////////////////////////////////////////////////





//////////////////////////////////////////////////////////////////
//	bone gelling surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/glue_bone
	allowed_tools = list(
		/obj/item/bonegel = 100,
		/obj/item/tape_roll = 75
	)
	can_infect = 1
	blood_level = 1

	duration = GLUE_BONE_DURATION
	shock_level = 20

/datum/surgery_step/glue_bone/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!hasorgans(target))
		return 0
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	return affected && !BP_IS_ROBOTIC(affected) && affected.open() >= 2 && affected.stage == 0

/datum/surgery_step/glue_bone/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/bone = affected.encased ? "[target]'s [affected.encased]" : "bones in [target]'s [affected.name]"
	if (affected.stage == 0)
		user.visible_message("[user] starts applying \the [tool] to the [bone]." , \
		"You start applying \the [tool] to the [bone].")
	target.custom_pain("Something in your [affected.name] is causing you a lot of pain!",50, affecting = affected)
	..()

/datum/surgery_step/glue_bone/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/bone = affected.encased ? "[target]'s [affected.encased]" : "bones in [target]'s [affected.name]"
	user.visible_message(SPAN_NOTICE("[user] applies some [tool.name] to [bone]"), \
		SPAN_NOTICE("You apply some [tool.name] to [bone]."))
	affected.stage = 1

/datum/surgery_step/glue_bone/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(SPAN_WARNING("[user]'s hand slips, smearing [tool] in the incision in [target]'s [affected.name]!") , \
	SPAN_WARNING("Your hand slips, smearing [tool] in the incision in [target]'s [affected.name]!"))


//////////////////////////////////////////////////////////////////
//	bone setting surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/set_bone
	allowed_tools = list(
	/obj/item/bonesetter = 100,	\
	/obj/item/wrench = 75		\
	)

	duration = BONE_MEND_DURATION
	shock_level = 40
	delicate = 1

/datum/surgery_step/set_bone/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!hasorgans(target))
		return 0
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	return affected && affected.organ_tag != BP_HEAD && !BP_IS_ROBOTIC(affected) && affected.open() >= SURGERY_RETRACTED && affected.stage == 1

/datum/surgery_step/set_bone/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/bone = affected.encased ? "[target]'s [affected.encased]" : "bones in [target]'s [affected.name]"
	user.visible_message("[user] is beginning to set the [bone] in place with \the [tool]." , \
		"You are beginning to set the [bone] in place with \the [tool].")
	target.custom_pain("The pain in your [affected.name] is going to make you pass out!", 50, affecting = affected)
	..()

/datum/surgery_step/set_bone/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/bone = affected.encased ? "[target]'s [affected.encased]" : "bones in [target]'s [affected.name]"
	if (affected.status & ORGAN_BROKEN)
		user.visible_message(SPAN_NOTICE("[user] sets the [bone] in place with \the [tool]."), \
			SPAN_NOTICE("You set the [bone] in place with \the [tool]."))
		affected.stage = 2
	else
		user.visible_message(SPAN_NOTICE("[user] sets the [bone]") + SPAN_WARNING(" in the WRONG place with \the [tool]."), \
			SPAN_NOTICE("You set the [bone]") + SPAN_WARNING(" in the WRONG place with \the [tool]."))
		affected.fracture()

/datum/surgery_step/set_bone/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(SPAN_WARNING("[user]'s hand slips, damaging the [affected.encased ? affected.encased : "bones"] in [target]'s [affected.name] with \the [tool]!") , \
		SPAN_WARNING("Your hand slips, damaging the [affected.encased ? affected.encased : "bones"] in [target]'s [affected.name] with \the [tool]!"))
	affected.fracture()
	affected.take_external_damage(5, used_weapon = tool)


//////////////////////////////////////////////////////////////////
//	skull mending surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/mend_skull
	allowed_tools = list(
	/obj/item/bonesetter = 100,	\
	/obj/item/wrench = 75		\
	)

	duration = BONE_MEND_DURATION
	shock_level = 40
	delicate = 1

/datum/surgery_step/mend_skull/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!hasorgans(target))
		return 0
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	return affected && affected.organ_tag == BP_HEAD && !BP_IS_ROBOTIC(affected) && affected.open() >= SURGERY_RETRACTED && affected.stage == 1

/datum/surgery_step/mend_skull/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] is beginning to piece together [target]'s skull with \the [tool]."  , \
		"You are beginning to piece together [target]'s skull with \the [tool].")
	..()

/datum/surgery_step/mend_skull/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(SPAN_NOTICE("[user] sets [target]'s skull with \the [tool].") , \
		SPAN_NOTICE("You set [target]'s skull with \the [tool]."))
	affected.stage = 2

/datum/surgery_step/mend_skull/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(SPAN_WARNING("[user]'s hand slips, damaging [target]'s face with \the [tool]!")  , \
		SPAN_WARNING("Your hand slips, damaging [target]'s face with \the [tool]!"))
	var/obj/item/organ/external/head/h = affected
	affected.take_external_damage(10, used_weapon = tool)
	h.status |= ORGAN_DISFIGURED

//////////////////////////////////////////////////////////////////
//	post setting bone-gelling surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/finish_bone
	allowed_tools = list(
	/obj/item/bonegel = 100,	\
	/obj/item/tape_roll = 75
	)
	can_infect = 1
	blood_level = 1

	duration = GLUE_BONE_DURATION
	shock_level = 20

/datum/surgery_step/finish_bone/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!hasorgans(target))
		return 0
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	return affected && affected.open() >= SURGERY_RETRACTED && !BP_IS_ROBOTIC(affected) && affected.stage == 2

/datum/surgery_step/finish_bone/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/bone = affected.encased ? "[target]'s [affected.encased]" : "bones in [target]'s [affected.name]"
	user.visible_message("[user] starts to finish mending the damaged [bone] with \the [tool].", \
	"You start to finish mending the damaged [bone] with \the [tool].")
	..()

/datum/surgery_step/finish_bone/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/bone = affected.encased ? "[target]'s [affected.encased]" : "bones in [target]'s [affected.name]"

	user.visible_message(SPAN("notice", "[user] has mended the damaged [bone] with \the [tool]."), \
						 SPAN("notice", "You have mended the damaged [bone] with \the [tool].") )
	affected.mend_fracture()
	affected.stage = 0

/datum/surgery_step/finish_bone/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(SPAN_WARNING("[user]'s hand slips, smearing [tool] in the incision in [target]'s [affected.name]!") , \
	SPAN_WARNING("Your hand slips, smearing [tool] in the incision in [target]'s [affected.name]!"))

//////BONE MENDER/////////
/datum/surgery_step/bone_mender
	allowed_tools = list(
		/obj/item/bonesetter/bone_mender = 100,
		)

	can_infect = 1
	blood_level = 1

	duration = BONE_MEND_DURATION
	shock_level = 20

/datum/surgery_step/bone_mender/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!hasorgans(target))
		return 0
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	return affected && !BP_IS_ROBOTIC(affected) && affected.open() >= 2 && affected.stage == 0

/datum/surgery_step/bone_mender/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if (affected.stage <= 5)
		user.visible_message("[user] starts grasping the damaged bone edges in [target]'s [affected.name] with \the [tool]." , \
		"You start grasping the bone edges and fusing them in [target]'s [affected.name] with \the [tool].")
	target.custom_pain("Something in your [affected.name] is causing you a lot of pain!", 50, affecting = affected)
	..()

/datum/surgery_step/bone_mender/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(SPAN_NOTICE("[user] has grasped the damaged bone edges in [target]'s [affected.name] with \the [tool].")  , \
	SPAN_NOTICE("You have grasped the damaged bone edges in [target]'s [affected.name] with \the [tool].") )
	affected.mend_fracture()
	affected.stage = 0

/datum/surgery_step/bone_mender/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(SPAN_WARNING("\The [tool] in [user]'s hand skips, jabbing the bone edges into the sides of [target]'s [affected.name]!") , \
	SPAN_WARNING("Your hand jolts and \the [tool] skips, jabbing the bone edges into [target]'s [affected.name] with \the [tool]!"))
	affected.take_external_damage(10, used_weapon = tool)
