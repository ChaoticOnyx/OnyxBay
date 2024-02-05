/**
 * Generic implant step, does nothing.
 */
/datum/surgery_step/cavity
	delicate = TRUE
	shock_level = 40
	priority = 1

/datum/surgery_step/cavity/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	. = ..()
	if(!.)
		return

	if(BP_IS_ROBOTIC(parent_organ))
		return parent_organ.hatch_state == HATCH_OPENED

	return (parent_organ.open() >= (parent_organ.encased ? SURGERY_ENCASED : SURGERY_RETRACTED))

/datum/surgery_step/cavity/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_failure(user,
		"[user]'s hand slips, scraping around inside [target]'s [parent_organ] with \the [tool]!",
		"Your hand slips, scraping around inside [target]'s [parent_organ] with \the [tool]!"
		)
	parent_organ.take_external_damage(
		20,
		0,
		(DAM_SHARP|DAM_EDGE),
		used_weapon = tool
		)

/**
 * Create cavity step.
 */
/datum/surgery_step/cavity/make_space
	duration = DRILL_DURATION

	allowed_tools = list(
		/obj/item/surgicaldrill = 100,
		/obj/item/pen = 75,
		/obj/item/stack/rods = 50
		)

	preop_sound = 'sound/surgery/surgicaldrill.ogg'
	success_sound = 'sound/surgery/organ2.ogg'
	failure_sound = 'sound/surgery/organ1.ogg'

/datum/surgery_step/cavity/make_space/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	return (..() && !parent_organ.cavity)

/datum/surgery_step/cavity/make_space/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_preop(user,
		"[user] starts making some space inside [target]'s [parent_organ.cavity_name] cavity with \the [tool].",
		"You start making some space inside [target]'s [parent_organ.cavity_name] cavity with \the [tool]."
		)
	target.custom_pain(
		"The pain in your chest is living hell!",
		1,
		affecting = target_organ
		)
	parent_organ.cavity = TRUE
	return ..()

/datum/surgery_step/cavity/make_space/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_success(user,
		"[user] makes some space inside [target]'s [parent_organ.cavity_name] cavity with \the [tool].",
		"You make some space inside [target]'s [parent_organ.cavity_name] cavity with \the [tool]."
		)

/**
 * Cavity sealing step.
 */
/datum/surgery_step/cavity/close_space
	priority = 2
	duration = CAUTERIZE_DURATION

	allowed_tools = list(
		/obj/item/cautery = 100,
		/obj/item/clothing/mask/smokable/cigarette = 75,
		/obj/item/flame/lighter = 50,
		/obj/item/weldingtool = 25
		)

	preop_sound = 'sound/surgery/cautery1.ogg'
	success_sound = 'sound/surgery/cautery2.ogg'
	failure_sound = 'sound/surgery/cautery.ogg'

/datum/surgery_step/cavity/close_space/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	return (..() && parent_organ.cavity)

/datum/surgery_step/cavity/close_space/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_preop(user,
		"[user] starts mending [target]'s [parent_organ.cavity_name] cavity wall with \the [tool].",
		"You start mending [target]'s [parent_organ.cavity_name] cavity wall with \the [tool]."
		)
	target.custom_pain(
		"The pain in your chest is living hell!",
		1,
		affecting = parent_organ
		)
	parent_organ.cavity = FALSE
	return ..()

/datum/surgery_step/cavity/close_space/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_success(user,
		"[user] mends [target]'s [parent_organ.cavity_name] cavity walls with \the [tool].",
		"You mend [target]'s [parent_organ.cavity_name] cavity walls with \the [tool]."
		)

/**
 * Implanting surgery step.
 */
/datum/surgery_step/cavity/place_item
	duration = ATTACH_DURATION

	allowed_tools = list(
		/obj/item = 100
		)

	preop_sound = 'sound/surgery/organ1.ogg'
	success_sound = 'sound/surgery/organ2.ogg'
	failure_sound = 'sound/effects/fighting/crunch1.ogg'

/datum/surgery_step/cavity/place_item/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	. = ..()
	if(!.)
		return

	if(issilicon(user))
		return FALSE

	if(!parent_organ.cavity)
		return FALSE

	var/max_volume = base_storage_capacity(parent_organ.cavity_max_w_class) + parent_organ.internal_organs_size
	for(var/obj/item/organ/internal/O in parent_organ.internal_organs)
		max_volume -= O.get_storage_cost()

	if(tool.get_storage_cost() > max_volume || parent_organ.cavity_max_w_class < tool.w_class)
		target.show_splash_text(user, "tool is too big!")
		return SURGERY_FAILURE

	var/total_volume = tool.get_storage_cost()
	for(var/obj/item/I in parent_organ.implants)
		if(istype(I, /obj/item/implant))
			continue

		total_volume += I.get_storage_cost()

	if(total_volume > max_volume)
		target.show_splash_text(user, "not enough space!")
		return FALSE

	return TRUE

/datum/surgery_step/cavity/place_item/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_preop(user,
		"[user] starts putting \the [tool] inside [target]'s [parent_organ.cavity_name] cavity.",
		"You start putting \the [tool] inside [target]'s [parent_organ.cavity_name] cavity."
		)
	target.custom_pain(
		"The pain in your chest is living hell!",
		1,
		affecting = parent_organ
		)
	playsound(target.loc, 'sound/effects/squelch1.ogg', 25, 1)
	return ..()

/datum/surgery_step/cavity/place_item/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	if(!user.drop(tool, parent_organ))
		return

	announce_success(user,
		"[user] puts \the [tool] inside [target]'s [parent_organ.cavity_name] cavity.",
		"You put \the [tool] inside [target]'s [parent_organ.cavity_name] cavity."
		)
	if(tool.w_class > parent_organ.cavity_max_w_class / 2 && prob(50) && !BP_IS_ROBOTIC(parent_organ) && parent_organ.sever_artery())
		to_chat(user, SPAN("warning", "You tear some blood vessels trying to fit such a big object in this cavity."))
		target.custom_pain(
			"You feel something rip in your [parent_organ]!",
			1,
			affecting = parent_organ
			)
	parent_organ.implants += tool
	parent_organ.cavity = FALSE

/**
 * Implant removal step.
 */
/datum/surgery_step/cavity/implant_removal
	duration = CLAMP_DURATION

	allowed_tools = list(
		/obj/item/hemostat = 100,
		/obj/item/wirecutters = 75,
		/obj/item/material/kitchen/utensil/fork = 20
		)

	preop_sound = 'sound/surgery/hemostat1.ogg'
	success_sound = 'sound/effects/squelch1.ogg'
	failure_sound = 'sound/surgery/organ2.ogg'

/datum/surgery_step/cavity/implant_removal/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_preop(user,
		"[user] starts poking around inside [target]'s [parent_organ] with \the [tool].",
		"You start poking around inside [target]'s [parent_organ] with \the [tool]"
		)
	target.custom_pain(
		"The pain in your [parent_organ] is living hell!",
		1,
		affecting = parent_organ
		)
	return ..()

/datum/surgery_step/cavity/implant_removal/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	var/exposed = FALSE
	if(BP_IS_ROBOTIC(parent_organ) && parent_organ.hatch_state == HATCH_OPENED)
		exposed = TRUE
	else if(parent_organ.open() >= (parent_organ.encased ? SURGERY_ENCASED : SURGERY_RETRACTED))
		exposed = TRUE

	var/find_prob = 0
	var/list/atom/loot = list()
	if(exposed)
		loot = parent_organ.implants
	else
		for(var/datum/wound/W in parent_organ.wounds)
			if(LAZYLEN(W.embedded_objects))
				loot |= W.embedded_objects
			find_prob += 50

	if(!length(loot))
		announce_success(user,
			"[user] could not find anything inside [target]'s [parent_organ], and pulls \the [tool] out.",
			"You could not find anything inside [target]'s [parent_organ]."
			)
		return

	var/obj/item/implanted_item = pick(loot)
	if(istype(implanted_item, /obj/item/implant))
		var/obj/item/implant/I = implanted_item
		find_prob += I.islegal() ? 60 : 40
	else
		find_prob += 50

	if(prob(find_prob))
		announce_success(user,
			"[user] takes something out of incision on [target]'s [parent_organ] with \the [tool].",
			"You take [implanted_item] out of incision on [target]'s [parent_organ]s with \the [tool]."
			)
		parent_organ.implants -= implanted_item
		for(var/datum/wound/wound in parent_organ.wounds)
			if(implanted_item in wound.embedded_objects)
				wound.embedded_objects -= implanted_item
				break

		BITSET(target.hud_updateflag, IMPLOYAL_HUD)

		implanted_item.dropInto(target.loc)
		implanted_item.add_blood(target)
		implanted_item.update_icon()
		if(istype(implanted_item, /obj/item/implant))
			var/obj/item/implant/I = implanted_item
			I.removed()
		return

	announce_success(user,
		"[user] removes \the [tool] from [target]'s [parent_organ].",
		"There's something inside [target]'s [parent_organ], but you just missed it this time."
		)

/datum/surgery_step/cavity/implant_removal/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	. = ..()
	for(var/obj/item/implant/I in parent_organ.implants)
		if(prob(10 + 100 - get_tool_quality(tool)))
			user.visible_message("Something beeps inside [target]'s [parent_organ]!")
			spawn(25)
				I.activate()
