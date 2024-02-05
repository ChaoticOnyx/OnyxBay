/datum/surgery_step
	/// Whether performing this step can cause infection.
	var/can_infect = FALSE
	/// Whether this step require not covered organ.
	var/needs_uncovered_organ = TRUE
	/// Whether this step can be successfully performed on any surface.
	var/delicate = FALSE
	/**
	 * Bitflag, whther this step would make user covered in blood.
	 * * 0 - nothing.
	 * * BLOODY_BODY - makes body covered in blood.
	 * * BLOODY_HANDS - makes hands covered in blood.
	 */
	var/blood_level = 0
	/// Level of shock to be apllied on target when performing this step.
	var/shock_level = 0
	/// Priority, steps with higher priority would be called first during step macthing.
	var/priority = 0
	/// Duration of step in deciseconds.
	var/duration = 0
	/// Associative list of typepath -> value, where typepath is surgery tool and value is chance to succeed from 0 to 100.
	var/list/allowed_tools = null
	/// Played when the step is started
	var/preop_sound
	/// Played on step succsess
	var/success_sound
	// Played if the step fails
	var/failure_sound

/**
 * Performs preop checks and fires step if succeeded.
 *
 * Returns `FALSE` if step requirements weren't met or `SURGERY_FAILURE`
 * if any organ checks were failed.
 *
 * Vars:
 * * user - atom that fired this step.
 * * target - human mob over which this step would be fired.
 * * tool - tool used on target.
 * * target_zone - zone selected by user when using tool on target mob.
 *
 * Checks tool.
 *
 * Checks whether zone is used by another step.
 *
 * Checks clothing.
 *
 * Checks parent organ.
 *
 * Picks target organ.
 *
 * Runs check to ensure that tool was not changed.
 *
 * Checks target organ.
 *
 * Adds operated organ to target's operated_organs associative list.
 *
 * Initiates step.
 *
 * Removes operated organ from operated_organs.
 *
 * Updates target's icon.
 *
 */
/datum/surgery_step/proc/do_step(atom/user, mob/living/carbon/human/target, obj/item/tool, target_zone)
	if(!hasorgans(target))
		return FALSE

	if(!get_tool_quality(tool))
		return FALSE

	var/parent_zone = get_parent_zone(target_zone)
	if(!check_zone(target, parent_zone))
		return FALSE

	var/obj/item/organ/parent_organ = target.get_organ(parent_zone)
	var/parent_status = check_parent_organ(parent_organ, target, tool, user)
	if(!parent_status || parent_status == SURGERY_FAILURE)
		return parent_status

	if(needs_uncovered_organ && !check_clothing(target, target_zone))
		to_chat(user, SPAN_DANGER("Clothing on [target]'s [organ_name_by_zone(target, target_zone)] blocks surgery!"))
		return SURGERY_FAILURE

	var/obj/item/organ/target_organ = pick_target_organ(user, target, target_zone)

	// Integrated circuits can't change tool during organ picking step, but spessmen can.
	var/mob/possible_mob = user
	if(istype(possible_mob))
		var/obj/item/active_item = possible_mob.get_active_item()
		if(active_item != tool)
			return SURGERY_FAILURE

	var/target_status = check_target_organ(target_organ, target, tool, user)
	if(!target_status || target_status == SURGERY_FAILURE)
		return target_status

	// At this point we can access selected organ via `surgery_status`.
	target.surgery_status.start_surgery(target_organ || parent_organ, parent_zone)
	initiate(parent_organ, target_organ, target, tool, user)
	target.surgery_status.stop_surgery(parent_zone)

	target.update_surgery()

	return TRUE

/**
 * Checks if type of tool is present in allowed_tools and returns value
 * associated with it, FALSE otherwise.
 */
/datum/surgery_step/proc/get_tool_quality(obj/item/tool)
	for(var/typepath as anything in allowed_tools)
		if(!istype(tool, typepath))
			continue
		return allowed_tools[typepath]

	return FALSE

/// Checks if zone is valid and is not used by other steps.
/datum/surgery_step/proc/check_zone(mob/living/carbon/human/target, target_zone)
	if(target_zone in target.surgery_status.ongoing_steps)
		return FALSE

	return TRUE

/// Checks if zone is covered by clothing.
/datum/surgery_step/proc/check_clothing(mob/living/carbon/human/target, target_zone)
	var/list/clothes = get_target_clothes(target, target_zone)
	for(var/obj/item/clothing/C in clothes)
		if(C.body_parts_covered & body_part_flags[target_zone])
			return FALSE

	return TRUE

/// Returns parent organ's tag depending on zone, currently used by eyes only.
/datum/surgery_step/proc/get_parent_zone(target_zone)
	if(target_zone == BP_EYES)
		return BP_HEAD

	return target_zone

/**
 * Returns organ from 'organs_by_name' associative list based on tag, override
 * to rerturn something else.
 *
 * Vars:
 * * user - atom that fired this step.
 * * target - human mob this step is fired upon.
 * * target_zone - zone selected by user.
 */
/datum/surgery_step/proc/pick_target_organ(atom/user, mob/living/carbon/human/target, target_zone)
	return target.get_organ(target_zone)

/**
 * Performs checks on parent a.e external organ, override to add extra ones.
 *
 * Vars:
 * * parent_organ - external organ, where target organ is located.
 * * target - human mob this step is fired upon.
 * * tool - tool used to fire this step.
 * * user - atom that fired this step.
 *
 * Checks if parent organ is present.
 */
/datum/surgery_step/proc/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	if(!istype(parent_organ))
		return FALSE

	return TRUE

/**
 * Performs checks on target organ, override to add extra ones.
 *
 * Vars:
 * * target_organ - target organ, can be equal to parent.
 * * target - human mob this step is fired upon.
 * * tool - tool used to fire this step.
 * * user - atom that fired this step.
 *
 * Checks if target organ is present.
 */
/datum/surgery_step/proc/check_target_organ(obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	if(!istype(target_organ))
		return FALSE

	return TRUE

/**
 * Initiates surgery step, override to add extra messages and injuries.
 *
 * Vars:
 * * parent_organ - external organ, where target organ is located.
 * * target_organ - target organ, can be equal to parent.
 * * target - human mob this step is fired upon.
 * * tool - tool used to fire this step.
 * * user - atom that fired this step.
 *
 * Infects organ if `can_infect` set to TRUE.
 *
 * Applies blood on users body and hands if corresponding flags are present.
 *
 * Applies shock effect if value is present.
 *
 * Calls `success` or `failure` proc based on success chance.
 *
 */
/datum/surgery_step/proc/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	if(can_infect)
		spread_germs_to_organ(user, target_organ)

	if(ishuman(user) && prob(60))
		var/mob/living/carbon/human/H = user
		if(blood_level & BLOODY_HANDS)
			H.bloody_hands(target, 0)
		if(blood_level & BLOODY_BODY)
			H.bloody_body(target, 0)

	if(shock_level)
		target.shock_stage = max(target.shock_stage, shock_level)

	play_preop_sound(user, target, target_organ, tool)

	var/success_chance = calc_success_chance(user, target, tool)
	var/surgery_duration = SURGERY_DURATION_DELTA * duration * tool.surgery_speed
	if(prob(success_chance) && do_mob(user, target, surgery_duration, can_multitask = TRUE))
		play_success_sound(user, target, target_organ, tool)
		success(parent_organ, target_organ, target, tool, user)
	else
		play_failure_sound(user, target, target_organ, tool)
		failure(parent_organ, target_organ, target, tool, user)

/// Spreads germs to organ if no gloves is present.
/datum/surgery_step/proc/spread_germs_to_organ(mob/living/carbon/human/user, obj/item/organ/external/target_organ)
	if(!istype(user) || !istype(target_organ))
		return

	var/germ_level = user.germ_level
	var/obj/item/clothing/gloves/G = user.gloves
	if(istype(G) && !(G.clipped && prob(75)))
		germ_level = G.germ_level

	target_organ.germ_level = max(germ_level, target_organ.germ_level)

/// Calculates success chance based on users health conditions, surface and target.
/datum/surgery_step/proc/calc_success_chance(mob/living/user, mob/living/carbon/human/target, obj/item/tool, target_zone)
	. = get_tool_quality(tool)
	if(user == target)
		. -= 10

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		. -= round(H.shock_stage * 0.5)
		if(H.eye_blurry)
			. -= 20
		if(H.eye_blind)
			. -= 60

	if(delicate)
		if(ishuman(user) && user?.slurring)
			. -= 10
		if(!target.lying)
			. -= 30

		var/turf/T = get_turf(target)
		if(locate(/obj/machinery/optable, T))
			. -= 0
		else if(locate(/obj/structure/bed, T))
			. -= 5
		else if(locate(/obj/structure/table, T))
			. -= 10
		else if(locate(/obj/effect/rune/, T))
			. -= 10

	. = max(., 0)

/**
 * Called on step success, override to apply effects on target and print out
 * extra fluff.
 *
 * Vars:
 * * parent_organ - external organ, where target organ is located.
 * * target_organ - target organ, can be equal to parent.
 * * target - human mob this step is fired upon.
 * * tool - tool used to fire this step.
 * * user - atom that fired this step.
 */
/datum/surgery_step/proc/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	pass()

/**
 * Called on step failure, override to apply effects on target and print out
 * extra fluff.
 *
 * Vars:
 * * parent_organ - external organ, where target organ is located.
 * * target_organ - target organ, can be equal to parent.
 * * target - human mob this step is fired upon.
 * * tool - tool used to fire this step.
 * * user - atom that fired this step.
 */
/datum/surgery_step/proc/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	pass()

/// Prints out visible message.
/datum/surgery_step/proc/announce_preop(mob/living/user, self_message, blind_message)
	user.visible_message(
		self_message,
		blind_message
	)

/// Prints out visible message with "notice" class.
/datum/surgery_step/proc/announce_success(mob/living/user, self_message, blind_message)
	user.visible_message(
		SPAN("notice", self_message),
		SPAN("notice", blind_message)
	)

/// Prints out visible message with "warning" class.
/datum/surgery_step/proc/announce_failure(mob/living/user, self_message, blind_message)
	user.visible_message(
		SPAN("warning", self_message),
		SPAN("warning", blind_message)
	)

/datum/surgery_step/proc/play_preop_sound(mob/user, mob/living/carbon/target, obj/item/organ/target_organ, obj/item/tool)
	if(!preop_sound)
		return

	var/sound_file_use
	if(islist(preop_sound))
		for(var/typepath in preop_sound)
			if(istype(tool, typepath))
				sound_file_use = preop_sound[typepath]
				break
	else
		sound_file_use = preop_sound

	playsound(get_turf(target), sound_file_use, 75, TRUE)

/datum/surgery_step/proc/play_success_sound(mob/user, mob/living/carbon/target, obj/item/organ/target_organ, obj/item/tool)
	if(!success_sound)
		return

	playsound(get_turf(target), success_sound, 75, TRUE)

/datum/surgery_step/proc/play_failure_sound(mob/user, mob/living/carbon/target, obj/item/organ/target_organ, obj/item/tool)
	if(!failure_sound)
		return

	playsound(get_turf(target), failure_sound, 75, TRUE)
