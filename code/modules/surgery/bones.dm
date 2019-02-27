//Procedures in this file: Fracture repair surgery
//////////////////////////////////////////////////////////////////
//						BONE SURGERY							//
//////////////////////////////////////////////////////////////////





//////////////////////////////////////////////////////////////////
//	bone gelling surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/glue_bone
	allowed_tools = list(
	/obj/item/weapon/bonegel = 100,	\
	/obj/item/weapon/tape_roll = 75
	)
	can_infect = 1
	blood_level = 1

	min_duration = 50
	max_duration = 60
	shock_level = 20

/datum/surgery_step/glue_bone/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!hasorgans(target))
		return 0
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	return affected && (affected.robotic < ORGAN_ROBOT) && affected.open() >= 2 && affected.stage == 0

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
	user.visible_message("<span class='notice'>[user] applies some [tool.name] to [bone]</span>", \
		"<span class='notice'>You apply some [tool.name] to [bone].</span>")
	affected.stage = 1

/datum/surgery_step/glue_bone/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, smearing [tool] in the incision in [target]'s [affected.name]!</span>" , \
	"<span class='warning'>Your hand slips, smearing [tool] in the incision in [target]'s [affected.name]!</span>")


//////////////////////////////////////////////////////////////////
//	bone setting surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/set_bone
	allowed_tools = list(
	/obj/item/weapon/bonesetter = 100,	\
	/obj/item/weapon/wrench = 75		\
	)

	min_duration = 60
	max_duration = 70
	shock_level = 40
	delicate = 1

/datum/surgery_step/set_bone/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!hasorgans(target))
		return 0
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	return affected && affected.organ_tag != BP_HEAD && !(affected.robotic >= ORGAN_ROBOT) && affected.open() >= SURGERY_RETRACTED && affected.stage == 1

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
		user.visible_message("<span class='notice'>[user] sets the [bone] n place with \the [tool].</span>", \
			"<span class='notice'>You set the [bone] in place with \the [tool].</span>")
		affected.stage = 2
	else
		user.visible_message("<span class='notice'>[user] sets the [bone]</span> <span class='warning'>in the WRONG place with \the [tool].</span>", \
			"<span class='notice'>You set the [bone]</span> <span class='warning'>in the WRONG place with \the [tool].</span>")
		affected.fracture()

/datum/surgery_step/set_bone/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging the [affected.encased ? affected.encased : "bones"] in [target]'s [affected.name] with \the [tool]!</span>" , \
		"<span class='warning'>Your hand slips, damaging the [affected.encased ? affected.encased : "bones"] in [target]'s [affected.name] with \the [tool]!</span>")
	affected.fracture()
	affected.take_damage(5, used_weapon = tool)


//////////////////////////////////////////////////////////////////
//	skull mending surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/mend_skull
	allowed_tools = list(
	/obj/item/weapon/bonesetter = 100,	\
	/obj/item/weapon/wrench = 75		\
	)

	min_duration = 60
	max_duration = 70
	shock_level = 40
	delicate = 1

/datum/surgery_step/mend_skull/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!hasorgans(target))
		return 0
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	return affected && affected.organ_tag == BP_HEAD && (affected.robotic < ORGAN_ROBOT) && affected.open() >= SURGERY_RETRACTED && affected.stage == 1

/datum/surgery_step/mend_skull/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] is beginning to piece together [target]'s skull with \the [tool]."  , \
		"You are beginning to piece together [target]'s skull with \the [tool].")
	..()

/datum/surgery_step/mend_skull/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] sets [target]'s skull with \the [tool].</span>" , \
		"<span class='notice'>You set [target]'s skull with \the [tool].</span>")
	affected.stage = 2

/datum/surgery_step/mend_skull/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging [target]'s face with \the [tool]!</span>"  , \
		"<span class='warning'>Your hand slips, damaging [target]'s face with \the [tool]!</span>")
	var/obj/item/organ/external/head/h = affected
	affected.take_damage(10, used_weapon = tool)
	h.disfigured = 1

//////////////////////////////////////////////////////////////////
//	post setting bone-gelling surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/finish_bone
	allowed_tools = list(
	/obj/item/weapon/bonegel = 100,	\
	/obj/item/weapon/tape_roll = 75
	)
	can_infect = 1
	blood_level = 1

	min_duration = 50
	max_duration = 60
	shock_level = 20

/datum/surgery_step/finish_bone/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!hasorgans(target))
		return 0
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	return affected && affected.open() >= SURGERY_RETRACTED && !(affected.robotic >= ORGAN_ROBOT) && affected.stage == 2

/datum/surgery_step/finish_bone/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/bone = affected.encased ? "[target]'s [affected.encased]" : "bones in [target]'s [affected.name]"
	user.visible_message("[user] starts to finish mending the damaged [bone] with \the [tool].", \
	"You start to finish mending the damaged [bone] with \the [tool].")
	..()

/datum/surgery_step/finish_bone/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/bone = affected.encased ? "[target]'s [affected.encased]" : "bones in [target]'s [affected.name]"
	user.visible_message("<span class='notice'>[user] has mended the damaged [bone] with \the [tool].</span>"  , \
		"<span class='notice'>You have mended the damaged [bone] with \the [tool].</span>" )
	affected.status &= ~ORGAN_BROKEN
	affected.stage = 0

/datum/surgery_step/finish_bone/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, smearing [tool] in the incision in [target]'s [affected.name]!</span>" , \
	"<span class='warning'>Your hand slips, smearing [tool] in the incision in [target]'s [affected.name]!</span>")

//////BONE MENDER/////////
/datum/surgery_step/bone_mender
	allowed_tools = list(
		/obj/item/weapon/bonesetter/bone_mender = 100,
		)

	can_infect = 1
	blood_level = 1

	min_duration = 80
	max_duration = 90
	shock_level = 20

/datum/surgery_step/bone_mender/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!hasorgans(target))
		return 0
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	return affected && (affected.robotic < ORGAN_ROBOT) && affected.open() >= 2 && affected.stage == 0

/datum/surgery_step/bone_mender/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if (affected.stage <= 5)
		user.visible_message("[user] starts grasping the damaged bone edges in [target]'s [affected.name] with \the [tool]." , \
		"You start grasping the bone edges and fusing them in [target]'s [affected.name] with \the [tool].")
	target.custom_pain("Something in your [affected.name] is causing you a lot of pain!", 50, affecting = affected)
	..()

/datum/surgery_step/bone_mender/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	affected.status &= ~ORGAN_BROKEN
	affected.stage = 0

/datum/surgery_step/bone_mender/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>\The [tool] in [user]'s hand skips, jabbing the bone edges into the sides of [target]'s [affected.name]!</span>" , \
	"<span class='warning'>Your hand jolts and \the [tool] skips, jabbing the bone edges into [target]'s [affected.name] with \the [tool]!</span>")
	affected.take_damage(10, used_weapon = tool)