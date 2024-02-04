/**
 * Generic robotic surgery step, does nothing.
 */
/datum/surgery_step/robotic/check_zone(mob/living/carbon/human/target, target_zone)
	return (..() && target_zone != BP_MOUTH)

/datum/surgery_step/robotic/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	. = ..()
	if(!.)
		return

	if(parent_organ.status & ORGAN_CUT_AWAY)
		return FALSE

	return BP_IS_ROBOTIC(parent_organ)

//////////////////////////////////////////////////////////////////
//	 unscrew robotic limb hatch surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/robotic/unscrew_hatch
	duration = CUT_DURATION

	allowed_tools = list(
		/obj/item/screwdriver = 100,
		/obj/item/material/coin = 50,
		/obj/item/material/kitchen/utensil/knife = 50
		)

/datum/surgery_step/robotic/unscrew_hatch/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	return ..() && parent_organ.hatch_state == HATCH_CLOSED

/datum/surgery_step/robotic/unscrew_hatch/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_preop(user,
		"[user] starts to unscrew the maintenance hatch on [target]'s [parent_organ] with \the [tool].",
		"You start to unscrew the maintenance hatch on [target]'s [parent_organ] with \the [tool]."
		)
	return ..()

/datum/surgery_step/robotic/unscrew_hatch/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_success(user,
		"[user] has opened the maintenance hatch on [target]'s [parent_organ] with \the [tool].",
		"You have opened the maintenance hatch on [target]'s [parent_organ] with \the [tool]."
		)
	parent_organ.hatch_state = HATCH_UNSCREWED

/datum/surgery_step/robotic/unscrew_hatch/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_failure(user,
		"[user]'s [tool] slips, failing to unscrew [target]'s [parent_organ].",
		"Your [tool] slips, failing to unscrew [target]'s [parent_organ]."
		)

/**
 * Hatch screwing step.
 */
/datum/surgery_step/robotic/screw_hatch
	duration = CUT_DURATION

	allowed_tools = list(
		/obj/item/screwdriver = 100,
		/obj/item/material/coin = 50,
		/obj/item/material/kitchen/utensil/knife = 50
		)

/datum/surgery_step/robotic/screw_hatch/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	return (..() && parent_organ.hatch_state == HATCH_UNSCREWED)

/datum/surgery_step/robotic/screw_hatch/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_preop(user,
		"[user] starts to screw down the maintenance hatch on [target]'s [parent_organ] with \the [tool].",
		"You start to screw down the maintenance hatch on [target]'s [parent_organ] with \the [tool]."
		)
	return..()

/datum/surgery_step/robotic/screw_hatch/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_success(user,
		"[user] has screwed down the maintenance hatch on [target]'s [parent_organ] with \the [tool].",
		"You have screwed down the maintenance hatch on [target]'s [parent_organ] with \the [tool]."
		)
	parent_organ.hatch_state = HATCH_CLOSED

/datum/surgery_step/robotic/screw_hatch/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_failure(user,
		"[user]'s [tool.name] slips, failing to screw down [target]'s [parent_organ].",
		"Your [tool] slips, failing to screw down [target]'s [parent_organ]."
		)

/**
 * Open robotic limb step.
 */
/datum/surgery_step/robotic/open_hatch
	duration = RETRACT_DURATION

	allowed_tools = list(
		/obj/item/retractor = 100,
		/obj/item/crowbar = 100,
		/obj/item/material/kitchen/utensil = 50
		)

/datum/surgery_step/robotic/open_hatch/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	return (..() && parent_organ.hatch_state == HATCH_UNSCREWED)

/datum/surgery_step/robotic/open_hatch/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_preop(user,
		"[user] starts to pry open the maintenance hatch on [target]'s [parent_organ] with \the [tool].",
		"You start to pry open the maintenance hatch on [target]'s [parent_organ] with \the [tool]."
		)
	return ..()

/datum/surgery_step/robotic/open_hatch/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_success(user,
		"[user] opens the maintenance hatch on [target]'s [parent_organ] with \the [tool].",
		"You open the maintenance hatch on [target]'s [parent_organ] with \the [tool]."
		)
	parent_organ.hatch_state = HATCH_OPENED

/datum/surgery_step/robotic/open_hatch/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_failure(user,
		"[user]'s [tool] slips, failing to open the hatch on [target]'s [parent_organ].",
		"Your [tool] slips, failing to open the hatch on [target]'s [parent_organ]."
		)

/**
 * Close robotic limb step.
 */
/datum/surgery_step/robotic/close_hatch
	allowed_tools = list(
		/obj/item/retractor = 100,
		/obj/item/crowbar = 100,
		/obj/item/material/kitchen/utensil = 50
	)

	duration = RETRACT_DURATION

/datum/surgery_step/robotic/close_hatch/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	return (..() && parent_organ.hatch_state == HATCH_OPENED)

/datum/surgery_step/robotic/close_hatch/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_preop(user,
		"[user] begins to close the hatch on [target]'s [parent_organ] with \the [tool].",
		"You begin to close the hatch on [target]'s [parent_organ] with \the [tool]."
		)
	return ..()

/datum/surgery_step/robotic/close_hatch/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_success(user,
		"[user] closes the hatch on [target]'s [parent_organ] with \the [tool].",
		"You close the hatch on [target]'s [parent_organ] with \the [tool]."
		)
	parent_organ.hatch_state = HATCH_UNSCREWED
	parent_organ.germ_level = 0

/datum/surgery_step/robotic/close_hatch/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_failure(user,
		"[user]'s [tool] slips, failing to close the hatch on [target]'s [parent_organ].",
		"Your [tool] slips, failing to close the hatch on [target]'s [parent_organ]."
		)

/**
 * Robotic limb brute repair step.
 */
/datum/surgery_step/robotic/repair_brute
	duration = ORGAN_FIX_DURATION

	allowed_tools = list(
		/obj/item/weldingtool = 100,
		/obj/item/gun/energy/plasmacutter = 50
		)

/datum/surgery_step/robotic/repair_brute/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	. = ..()
	if(!.)
		return

	if(isWelder(tool))
		var/obj/item/weldingtool/W = tool
		if(!W.isOn() || !W.remove_fuel(1, user))
			return FALSE

	if(parent_organ.hatch_state != HATCH_OPENED)
		return FALSE

	return ((parent_organ.status & ORGAN_DISFIGURED) || parent_organ.brute_dam > 0)

/datum/surgery_step/robotic/repair_brute/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_preop(user,
		"[user] begins to patch damage to [target]'s [parent_organ]'s support structure with \the [tool].",
		"You begin to patch damage to [target]'s [parent_organ]'s support structure with \the [tool]."
		)
	return ..()

/datum/surgery_step/robotic/repair_brute/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_success(user,
		"[user] finishes patching damage to [target]'s [parent_organ] with \the [tool].",
		"You finish patching damage to [target]'s [parent_organ] with \the [tool]."
		)
	parent_organ.heal_damage(rand(30, 50), 0, 1, 1)
	parent_organ.status &= ~ORGAN_DISFIGURED

/datum/surgery_step/robotic/repair_brute/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_failure(user,
		"[user]'s [tool] slips, damaging the internal structure of [target]'s [parent_organ].",
		"Your [tool] slips, damaging the internal structure of [target]'s [parent_organ]."
		)
	parent_organ.take_external_damage(0, rand(5, 10), 0, used_weapon = tool)

/**
 * Robotic limb burn damage repair step.
 */
/datum/surgery_step/robotic/repair_burn
	duration = CONNECT_DURATION

	allowed_tools = list(
		/obj/item/stack/cable_coil = 100
		)

/datum/surgery_step/robotic/repair_burn/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	. = ..()
	if(!.)
		return

	if(parent_organ.hatch_state != HATCH_OPENED)
		return FALSE

	if(parent_organ.burn_dam <= 0 && !(parent_organ.status & ORGAN_DISFIGURED))
		return FALSE

	var/obj/item/stack/cable_coil/C = tool
	if(!istype(C))
		return FALSE

	if(!C.use(3))
		target.show_splash_text(user, "not enough coil length!")
		return SURGERY_FAILURE

	return TRUE

/datum/surgery_step/robotic/repair_burn/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_preop(user,
		"[user] begins to splice new cabling into [target]'s [parent_organ].",
		"You begin to splice new cabling into [target]'s [parent_organ]."
		)
	return ..()

/datum/surgery_step/robotic/repair_burn/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_success(user,
		"[user] finishes splicing cable into [target]'s [parent_organ].",
		"You finishes splicing new cable into [target]'s [parent_organ]."
		)
	parent_organ.heal_damage(0, rand(30, 50), 1, 1)
	parent_organ.status &= ~ORGAN_DISFIGURED

/datum/surgery_step/robotic/repair_burn/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_failure(user,
		"[user] causes a short circuit in [target]'s [parent_organ]!",
		"You cause a short circuit in [target]'s [parent_organ]!"
		)
	target.apply_damage(rand(5, 10), BURN, parent_organ)

/**
 * Default robotic internal step, does nothing.
 */
/datum/surgery_step/robotics/internal/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	return (..() && parent_organ.hatch_state == HATCH_OPENED)

/datum/surgery_step/robotics/internal/pick_target_organ(atom/user, mob/living/carbon/human/target, target_zone)
	return target.surgery_status.operated_organs[get_parent_zone(target_zone)]

/**
 * Robotic organ detachment step.
 */
/datum/surgery_step/robotics/internal/detach_organ
	duration = CUT_DURATION * 1.75

	allowed_tools = list(
		/obj/item/device/multitool = 100
		)

/datum/surgery_step/robotics/internal/detach_organ/pick_target_organ(atom/user, mob/living/carbon/human/target, target_zone)
	var/list/attached_organs = list()
	for(var/obj/item/organ/O in target.internal_organs)
		if(O.parent_organ != target_zone)
			continue

		if(!(O.status & ORGAN_CUT_AWAY))
			attached_organs[O] = adjust_organ_image(O)

	var/obj/item/organ/preselected_organ = ..()
	if(istype(preselected_organ))
		if(preselected_organ in attached_organs)
			return preselected_organ

		return null

	var/obj/item/organ/selected_organ = show_radial_menu(user, target, attached_organs, require_near = TRUE)
	if(!istype(selected_organ))
		return null

	return selected_organ

/datum/surgery_step/robotics/internal/detach_organ/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_preop(user,
		"[user] starts to decouple [target]'s [target_organ] with \the [tool].",
		"You start to decouple [target]'s [target_organ] with \the [tool]."
		)
	return ..()

/datum/surgery_step/robotics/internal/detach_organ/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	var/obj/item/organ/internal/I = target_organ
	if(!istype(I))
		return

	announce_success(user,
		"[user] has decoupled [target]'s [I] with \the [tool].",
		"You have decoupled [target]'s [I] with \the [tool]."
		)
	I.cut_away(user)

/datum/surgery_step/robotics/internal/detach_organ/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_failure(user,
		"[user]'s hand slips, disconnecting \the [tool].",
		"Your hand slips, disconnecting \the [tool]."
		)

/**
 * Robotic organ transplant finalization step.
 */
/datum/surgery_step/robotics/internal/attach_organ
	allowed_tools = list(
		/obj/item/screwdriver = 100
		)

	duration = CONNECT_DURATION

/datum/surgery_step/robotics/internal/attach_organ/pick_target_organ(atom/user, mob/living/carbon/human/target, target_zone)
	var/list/attachable_organs = list()
	var/obj/item/organ/external/parent_organ = target.get_organ(target_zone)
	for(var/obj/item/organ/O in parent_organ.implants)
		if(O.parent_organ != target_zone)
			continue

		if(O.status & ORGAN_CUT_AWAY)
			attachable_organs[O] = adjust_organ_image(O)

	var/obj/item/organ/preselected_organ = ..()
	if(istype(preselected_organ))
		if(preselected_organ in attachable_organs)
			return preselected_organ

		return null

	var/obj/item/organ/selected_organ = show_radial_menu(user, target, attachable_organs, require_near = TRUE)
	if(!istype(selected_organ))
		return null

	return selected_organ

/datum/surgery_step/robotics/internal/attach_organ/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_preop(user,
		"[user] begins reattaching [target]'s [target_organ] with \the [tool].",
		"You start reattaching [target]'s [target_organ] with \the [tool]."
		)
	return ..()

/datum/surgery_step/robotics/internal/attach_organ/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_success(user,
		"[user] has reattached [target]'s [target_organ] with \the [tool].",
		"You have reattached [target]'s [target_organ] with \the [tool]."
		)
	target_organ.status &= ~ORGAN_CUT_AWAY
	parent_organ.implants -= target_organ
	target_organ.replaced(target, parent_organ)

/datum/surgery_step/robotics/internal/attach_organ/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_failure(user,
		"[user]'s hand slips, disconnecting \the [tool].",
		"Your hand slips, disconnecting \the [tool]."
		)

/**
 * Artificial organ repair step.
 */
/datum/surgery_step/robotic/fix_organ
	duration = ORGAN_FIX_DURATION

	allowed_tools = list(
		/obj/item/stack/nanopaste = 100,
		/obj/item/bonegel = 30,
		/obj/item/screwdriver = 70
		)

/datum/surgery_step/robotic/fix_organ/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	if(!istype(parent_organ))
		return FALSE

	for(var/obj/item/organ/internal/I in parent_organ.internal_organs)
		if(!BP_IS_ROBOTIC(I) || I.damage <= 0)
			continue

		if(I.surface_accessible)
			return TRUE

		if(parent_organ.open() >= (parent_organ.encased ? SURGERY_ENCASED : SURGERY_RETRACTED) || parent_organ.hatch_state == HATCH_OPENED)
			return TRUE

	return FALSE

/datum/surgery_step/robotic/fix_organ/check_target_organ(obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	return TRUE

/datum/surgery_step/robotic/fix_organ/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_preop(user,
		"[user] starts mending the damage to mechanisms inside [target]'s [parent_organ].",
		"You start mending the damage to mechanisms inside [target]'s [parent_organ]."
		)
	return ..()

/datum/surgery_step/robotic/fix_organ/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	for(var/obj/item/organ/I in parent_organ.internal_organs)
		if(I.damage <= 0)
			continue

		if(!BP_IS_ROBOTIC(I))
			continue

		announce_success(user,
			"[user] repairs [target]'s [I] with \the [tool].",
			"You repair [target]'s [I] with \the [tool]."
			)
		I.damage = 0

/datum/surgery_step/robotic/fix_organ/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_failure(user,
		"[user]'s hand slips, gumming up the mechanisms inside of [target]'s [parent_organ] with \the [tool]!",
		"Your hand slips, gumming up the mechanisms inside of [target]'s [parent_organ] with \the [tool]!"
		)

	target.adjustToxLoss(5)
	parent_organ.createwound(CUT, 5)

	for(var/obj/item/organ/internal/I in parent_organ.internal_organs)
		I.take_internal_damage(rand(3, 5), 0)
