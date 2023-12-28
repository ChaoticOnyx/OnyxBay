/**
 * Default limb attachment step, does nothing.
 */
/datum/surgery_step/limb
	delicate = TRUE
	shock_level = 40
	priority = 3 // Must be higher than /datum/surgery_step/internal.
	preop_sound = 'sound/surgery/scalpel1.ogg'
	success_sound = 'sound/surgery/organ2.ogg'

/datum/surgery_step/limb/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	return TRUE

/datum/surgery_step/limb/check_target_organ(obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	return TRUE

/**
 * Attaches external limb.
 */
/datum/surgery_step/limb/attach_organic
	duration = ATTACH_DURATION

	allowed_tools = list(
		/obj/item/organ/external = 100
		)

/datum/surgery_step/limb/attach_organic/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	var/obj/item/organ/external/E = tool
	if(!istype(E))
		return FALSE

	var/obj/item/organ/external/L = target.get_organ(E.organ_tag)
	if(!isnull(L))
		return FALSE

	var/obj/item/organ/external/P = target.get_organ(E.parent_organ)
	if(isnull(P) || P.is_stump())
		target.show_splash_text(user, "limb is already present!")
		return SURGERY_FAILURE

	if(BP_IS_ROBOTIC(P) && !BP_IS_ROBOTIC(E))
		target.show_splash_text(user, "organic limb can't be connected to a robotic body!")
		return SURGERY_FAILURE

	return !isnull(target.species.has_limbs["[E.organ_tag]"])

/datum/surgery_step/limb/attach_organic/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	var/obj/item/organ/external/E = tool
	user.visible_message(
		"[user] starts attaching [E] to [target]'s [E.amputation_point].",
		"You start attaching [E] to [target]'s [E.amputation_point]."
		)
	return ..()

/datum/surgery_step/limb/attach_organic/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	if(!user.drop(tool))
		return

	var/obj/item/organ/external/E = tool
	announce_success(user,
		"[user] has attached [target]'s [E] to the [E.amputation_point].",
		"You have attached [target]'s [E] to the [E.amputation_point]."
		)
	E.replaced(target)
	target.update_body()
	target.updatehealth()
	target.UpdateDamageIcon()

/datum/surgery_step/limb/attach_organic/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	var/obj/item/organ/external/E = tool
	var/obj/item/organ/external/P = target.organs_by_name[E.parent_organ]
	announce_failure(user,
		"[user]'s hand slips, damaging [target]'s [E.amputation_point]!",
		"Your hand slips, damaging [target]'s [E.amputation_point]!"
		)
	target.apply_damage(
		10,
		BRUTE,
		P,
		damage_flags = DAM_SHARP
		)

/**
 * Connects attached limbs to targets body.
 */
/datum/surgery_step/limb/connect
	can_infect = TRUE
	duration = CLAMP_DURATION

	allowed_tools = list(
		/obj/item/hemostat = 100,
		/obj/item/stack/cable_coil = 75,
		/obj/item/device/assembly/mousetrap = 20
		)

/datum/surgery_step/limb/connect/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	. = ..()
	if(!.)
		return

	if(parent_organ.is_stump())
		return FALSE

	return parent_organ.status & ORGAN_CUT_AWAY

/datum/surgery_step/limb/connect/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_success(user,
		"[user] starts connecting tendons and muscles in [target]'s [parent_organ.amputation_point] with [tool].",
		"You start connecting tendons and muscle in [target]'s [parent_organ.amputation_point]."
		)
	return ..()

/datum/surgery_step/limb/connect/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_failure(user,
		"[user] has connected tendons and muscles in [target]'s [parent_organ.amputation_point] with [tool].",
		"You have connected tendons and muscles in [target]'s [parent_organ.amputation_point] with [tool]."
		)
	parent_organ.status &= ~ORGAN_CUT_AWAY
	if(parent_organ.children)
		for(var/obj/item/organ/external/C in parent_organ.children)
			C.status &= ~ORGAN_CUT_AWAY
			C.update_tally()
	parent_organ.update_tally()
	target.update_body()
	target.updatehealth()
	target.UpdateDamageIcon()

/datum/surgery_step/limb/connect/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_failure(
		"[user]'s hand slips, damaging [target]'s [parent_organ.amputation_point]!",
		"Your hand slips, damaging [target]'s [parent_organ.amputation_point]!"
		)
	target.apply_damage(
		10,
		BRUTE,
		target.organs_by_name[parent_organ.parent_organ],
		damage_flags = DAM_SHARP
		)

/**
 * Attaches robot part as a limb.
 */
/datum/surgery_step/limb/mechanize
	duration = ATTACH_DURATION

	allowed_tools = list(
		/obj/item/robot_parts = 100
		)

/datum/surgery_step/limb/mechanize/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	var/obj/item/robot_parts/P = tool
	return isnull(target.get_organ(P.bp_tag))

/datum/surgery_step/limb/mechanize/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_preop(user,
		"[user] starts attaching \the [tool] to [target].",
		"You start attaching \the [tool] to [target]."
		)
	return ..()

/datum/surgery_step/limb/mechanize/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	var/obj/item/robot_parts/L = tool
	if(!L.part)
		return

	for(var/oragn_tag in L.part)
		if(!isnull(target.get_organ(oragn_tag)))
			continue

		var/list/organ_data = target.species.has_limbs["[oragn_tag]"]
		if(!organ_data)
			continue

		var/limb_path = organ_data["path"]
		var/obj/item/organ/external/new_limb = new limb_path(target)
		new_limb.robotize(L.model_info)
		if(L.sabotaged)
			new_limb.status |= ORGAN_SABOTAGED

	announce_success(user,
		"[user] has attached \the [tool] to [target].",
		"You have attached \the [tool] to [target]."
		)

	target.update_body()
	target.updatehealth()
	target.UpdateDamageIcon()

	qdel(tool)

/datum/surgery_step/limb/mechanize/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_failure(user,
		"[user]'s hand slips, damaging [target]'s flesh!",
		"Your hand slips, damaging [target]'s flesh!"
		)
	target.apply_damage(10, BRUTE, null, damage_flags = DAM_SHARP)

/**
 * Amputates limb.
 */
/datum/surgery_step/amputate
	can_infect = TRUE
	shock_level = 10
	duration = AMPUTATION_DURATION

	allowed_tools = list(
		/obj/item/circular_saw = 100,
		/obj/item/material/hatchet = 75,
		/obj/item/material/twohanded/fireaxe = 85,
		/obj/item/gun/energy/plasmacutter = 90
		)

/datum/surgery_step/amputate/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	. = ..()
	if(!.)
		return

	if(parent_organ.open())
		target.show_splash_text(user, "can't get a clean cut due to present incisions!")
		return SURGERY_FAILURE

	return parent_organ.limb_flags & ORGAN_FLAG_CAN_AMPUTATE

/datum/surgery_step/amputate/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_preop(user,
		"[user] is beginning to amputate [target]'s [parent_organ] with \the [tool].",
		"You are beginning to cut through [target]'s [parent_organ.amputation_point] with \the [tool]."
		)
	target.custom_pain(
		"Your [parent_organ.amputation_point] is being ripped apart!",
		100,
		affecting = parent_organ
		)
	return ..()

/datum/surgery_step/amputate/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_success(user,
		"[user] amputates [target]'s [parent_organ] at the [parent_organ.amputation_point] with \the [tool].",
		"You amputate [target]'s [parent_organ] with \the [tool]."
		)
	parent_organ.droplimb(TRUE, DROPLIMB_EDGE)

/datum/surgery_step/amputate/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_failure(user,
		"[user]'s hand slips, sawing through the bone in [target]'s [parent_organ] with \the [tool]!",
		"Your hand slips, sawwing through the bone in [target]'s [parent_organ] with \the [tool]!"
		)
	parent_organ.take_external_damage(30, 0, (DAM_SHARP|DAM_EDGE), used_weapon = tool)
	parent_organ.fracture()

/datum/surgery_step/amputate/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_failure(user,
		"[user]'s hand slips, sawing through the bone in [target]'s [parent_organ] with \the [tool]!",
		"Your hand slips, sawwing through the bone in [target]'s [parent_organ] with \the [tool]!"
		)
	parent_organ.take_external_damage(
		30,
		0,
		(DAM_SHARP|DAM_EDGE),
		used_weapon = tool
		)
	parent_organ.fracture()
