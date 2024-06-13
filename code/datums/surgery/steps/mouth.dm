#define MOUTH_SPEED_MODIFIER 2

/**
 * Generic mouth surgry step, does nothing.
 */
/datum/surgery_step/mouth
	priority = 2

/datum/surgery_step/mouth/check_zone(mob/living/carbon/human/target, target_zone)
	return (..() && target_zone == BP_MOUTH)

/datum/surgery_step/face/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	. = ..()
	if(!.)
		return

	if(BP_IS_ROBOTIC(parent_organ))
		return FALSE

	return !parent_organ.is_stump()

/**
 * Remove tooth (or teeth).
 */
/datum/surgery_step/mouth/remove_tooth
	duration = RETRACT_DURATION * MOUTH_SPEED_MODIFIER

	allowed_tools = list(
		/obj/item/retractor = 100,
		/obj/item/crowbar = 100,
		/obj/item/material/kitchen/utensil = 50,
		/obj/item/screwdriver = 50,
		)

	preop_sound = 'sound/surgery/scalpel1.ogg'
	success_sound = 'sound/surgery/scalpel2.ogg'
	failure_sound = 'sound/weapons/bladeslice.ogg'

/datum/surgery_step/mouth/remove_tooth/check_parent_organ(obj/item/organ/external/head/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	var/obj/item/organ/internal/jaw/jaw = target.internal_organs_by_name[BP_JAW]
	return jaw?.get_teeth_count() >= 0

/datum/surgery_step/mouth/remove_tooth/initiate(obj/item/organ/external/head/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user, additional_args)
	additional_args = list()
	var/obj/item/organ/internal/jaw/jaw = target.internal_organs_by_name[BP_JAW]
	additional_args["type"] = null
	if(jaw.teeth_types.len > 1)
		additional_args["type"] = tgui_input_list(user, "Which teeth you want to remove?", "Remove Teeth", jaw.teeth_types)
		additional_args["teeth"] = tgui_input_number(user, "How many teeth you want to remove?", "Remove teeth.", 1, jaw.teeth_types[additional_args["type"]], 1)
	else
		additional_args["teeth"] = tgui_input_number(user, "How many teeth you want to remove?", "Remove teeth.", 1, jaw.get_teeth_count(), 1)

	var/tooth_or_teeth = additional_args["teeth"] > 1 ? "teeth" : "tooth"
	announce_preop(user,
		"[user] starts to cut remove [target]'s [tooth_or_teeth] with \the [tool].",
		"You start to remove [target]'s [tooth_or_teeth] with \the [tool]."
		)
	return ..()

/datum/surgery_step/mouth/remove_tooth/calc_duration(mob/living/user, mob/living/carbon/human/target, obj/item/tool, additional_args)
	var/teeth_additional_cd = (1 - (additional_args["teeth"] / 32)) * 100
	return SURGERY_DURATION_DELTA * duration * tool.surgery_speed + teeth_additional_cd

/datum/surgery_step/mouth/remove_tooth/success(obj/item/organ/external/head/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user, additional_args)
	var/obj/item/organ/internal/jaw/jaw = target.internal_organs_by_name[BP_JAW]
	additional_args["teeth"] = Clamp(additional_args["teeth"], 0, jaw?.get_teeth_count())
	if(jaw?.get_teeth_count() <= 0)
		return // This check is here because during do_mob() teeth can magically disapper through other means.

	var/tooth_or_teeth = additional_args["teeth"] > 1 ? "teeth" : "tooth"
	announce_success(user,
		"[user] has removed [target]'s [tooth_or_teeth] with \the [tool].",
		"You have removed [target]'s [tooth_or_teeth] with \the [tool]."
		)

	playsound(get_turf(target), SFX_GORE, 75, FALSE, -1)

	for(var/i = 1 to additional_args["teeth"])
		var/tooth_type = safepick(jaw.teeth_types)
		if(!isnull(additional_args["type"]))
			tooth_type = additional_args["type"]

		if(jaw.teeth_types[tooth_type] <= 0)
			continue

		var/obj/item/tooth/tooth = new tooth_type(get_turf(target))
		tooth.death_time = world.time + 5 MINUTES
		jaw.teeth_types[tooth_type]--
		tooth.add_blood(target)
		if(jaw.teeth_types[tooth_type] <= 0)
			return

/datum/surgery_step/mouth/remove_tooth/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user, additional_args)
	announce_failure(user,
		"[user]'s hand slips, slicing [target]'s mouth wth \the [tool]!",
		"Your hand slips, slicing [target]'s mouth wth \the [tool]!"
		)
	parent_organ.take_external_damage(
		40,
		0,
		(DAM_SHARP|DAM_EDGE),
		used_weapon = tool
		)
	target.losebreath += 10

/**
 * Install tooth.
 */
/datum/surgery_step/mouth/install_tooth
	duration = RETRACT_DURATION * MOUTH_SPEED_MODIFIER

	allowed_tools = list(
		/obj/item/tooth = 100,
		)

	preop_sound = 'sound/surgery/scalpel1.ogg'
	success_sound = 'sound/surgery/scalpel2.ogg'
	failure_sound = 'sound/weapons/bladeslice.ogg'

/datum/surgery_step/mouth/install_tooth/check_parent_organ(obj/item/organ/external/head/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	var/obj/item/organ/internal/jaw/jaw = target.internal_organs_by_name[BP_JAW]
	var/obj/item/tooth/tooth = tool
	return jaw?.get_teeth_count() < jaw?.max_teeth_count && tooth?.death_time <= world.time

/datum/surgery_step/mouth/install_tooth/initiate(obj/item/organ/external/head/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user, additional_args)
	announce_preop(user,
		"[user] starts installing \the [tool].",
		"You start installing \the [tool]."
		)
	return ..()

/datum/surgery_step/mouth/install_tooth/success(obj/item/organ/external/head/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user, additional_args)
	var/obj/item/organ/internal/jaw/jaw = target.internal_organs_by_name[BP_JAW]
	additional_args["teeth"] = Clamp(additional_args["teeth"], 0, jaw?.get_teeth_count())
	if(jaw?.get_teeth_count() >= jaw.max_teeth_count)
		return

	announce_success(user,
		"[user] has installed \the [tool].",
		"You have installed \the [tool]."
		)

	jaw.teeth_types[tool.type]++

/datum/surgery_step/mouth/remove_tooth/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user, additional_args)
	announce_failure(user,
		"[user]'s hand slips!",
		"Your hand slips!"
		)
	parent_organ.take_external_damage(
		40,
		0,
		(DAM_SHARP|DAM_EDGE),
		used_weapon = tool
		)
