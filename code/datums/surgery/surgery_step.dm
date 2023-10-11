/datum/surgery_step
	var/can_infect = FALSE
	var/accessible = FALSE
	var/delicate = FALSE
	var/blood_level = 0
	var/shock_level = 0
	var/priority = 0
	var/duration = 0
	var/list/allowed_tools = null

/// tool check -> organ selection -> organ checks -> surgery init -> orher stuff
/datum/surgery_step/proc/do_step(atom/user, mob/living/carbon/human/target, obj/item/tool, target_zone)
	if(!check_tool(tool))
		return FALSE

	if(accessible && !check_clothing(target, target_zone))
		return FALSE

	var/obj/item/organ/target_organ = target.get_organ(pick_organ_tag(user, target, target_zone))
	if(!check_organ(target, target_organ, tool, target_zone))
		return FALSE

	// At this point we can access selected organ via `surgery_status`.
	target.surgery_status.start_surgery(target_organ, target_zone)
	initiate(user, target, tool, target_zone)
	target.surgery_status.stop_surgery(target_zone)

	target.update_surgery()

	return TRUE

/datum/surgery_step/proc/check_tool(obj/item/tool)
	var/bool = (tool.type in allowed_tools)
	return bool

/datum/surgery_step/proc/check_clothing(mob/living/carbon/target, target_zone)
	var/list/clothes = get_target_clothes(target, target_zone)
	for(var/obj/item/clothing/C in clothes)
		if(C.body_parts_covered & body_part_flags[target_zone])
			return FALSE
	return TRUE

/datum/surgery_step/proc/check_organ(mob/living/carbon/human/target, obj/item/organ/target_organ, obj/item/tool, target_zone)
	if(!istype(target_organ))
		return FALSE

	return TRUE

/datum/surgery_step/proc/pick_organ_tag(atom/user, mob/living/carbon/target, target_zone)
	return target_zone

/datum/surgery_step/proc/initiate(mob/user, mob/living/carbon/human/target, obj/item/tool, target_zone)
	var/obj/item/target_organ = target.surgery_status.operated_organs[target_zone]
	if(can_infect && target_organ)
		spread_germs_to_organ(user, target_organ)

	if(ishuman(user) && prob(60))
		var/mob/living/carbon/human/H = user
		if(blood_level & BLOODY_HANDS)
			H.bloody_hands(target, 0)
		if(blood_level & BLOODY_BODY)
			H.bloody_body(target, 0)

	if(shock_level)
		target.shock_stage = max(target.shock_stage, shock_level)

	var/success_chance = calc_success_chance(user, target, tool)
	var/surgery_duration = SURGERY_DURATION_DELTA * duration * tool.surgery_speed
	if(prob(success_chance) && do_mob(user, target, surgery_duration))
		success(user, target, tool, target_zone)
	else
		failure(user, target, tool, target_zone)

/datum/surgery_step/proc/spread_germs_to_organ(mob/living/carbon/human/user, obj/item/organ/external/target_organ)
	if(!istype(user) || !istype(target_organ))
		return

	var/germ_level = user.germ_level
	var/obj/item/clothing/gloves/G = user.gloves
	if(istype(G) && !(G.clipped && prob(75)))
		germ_level = G.germ_level

	target_organ.germ_level = max(germ_level, target_organ.germ_level)

/datum/surgery_step/proc/calc_success_chance(mob/living/user, mob/living/carbon/human/target, obj/item/tool, target_zone)
	. = allowed_tools[tool.type]
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

/datum/surgery_step/proc/success(mob/user, mob/living/carbon/human/target, obj/item/tool, target_zone)
	pass()

/datum/surgery_step/proc/failure(mob/user, mob/living/carbon/human/target, obj/item/tool, target_zone)
	pass()

/datum/surgery_step/proc/announce_preop(mob/living/user, self_message, blind_message)
	user.visible_message(
		self_message,
		blind_message
	)

/datum/surgery_step/proc/announce_success(mob/living/user, self_message, blind_message)
	user.visible_message(
		SPAN("notice", self_message),
		SPAN("notice", blind_message)
	)

/datum/surgery_step/proc/announce_failure(mob/living/user, self_message, blind_message)
	user.visible_message(
		SPAN("warning", self_message),
		SPAN("warning", blind_message)
	)
