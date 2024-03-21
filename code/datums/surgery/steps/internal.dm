/**
 * Default internal surgery step, does nothing.
 */
/datum/surgery_step/internal
	can_infect = FALSE
	blood_level = BLOODY_HANDS
	delicate = TRUE
	shock_level = 40
	priority = 2
	preop_sound = 'sound/surgery/hemostat1.ogg'
	success_sound = 'sound/surgery/hemostat1.ogg'
	failure_sound = 'sound/surgery/organ2.ogg'

/datum/surgery_step/internal/pick_target_organ(atom/user, mob/living/carbon/human/target, target_zone)
	return target.surgery_status.operated_organs[get_parent_zone(target_zone)]

/datum/surgery_step/internal/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	. = ..()
	if(!.)
		return

	if(BP_IS_ROBOTIC(parent_organ))
		return parent_organ.hatch_state == HATCH_OPENED

	return parent_organ.open() == (parent_organ.encased ? SURGERY_ENCASED : SURGERY_RETRACTED)

/**
 * Organ attachment operation via Fix'o Vein, doesn't work on synths.
 */
/datum/surgery_step/internal/attach_organ
	duration = CONNECT_DURATION

	allowed_tools = list(
		/obj/item/FixOVein = 100,
		/obj/item/stack/cable_coil = 75,
		/obj/item/tape_roll = 50
		)

/datum/surgery_step/internal/attach_organ/pick_target_organ(atom/user, mob/living/carbon/human/target, target_zone)
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

/datum/surgery_step/internal/attach_organ/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	return (..() && !BP_IS_ROBOTIC(parent_organ))

/datum/surgery_step/internal/attach_organ/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_preop(user,
		"[user] begins reattaching [target]'s [target_organ] with \the [tool].",
		"You start reattaching [target]'s [target_organ] with \the [tool]."
		)
	target.custom_pain(
		"Someone's digging needles into your [target_organ]!",
		100
		)
	return ..()

/datum/surgery_step/internal/attach_organ/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_success(user,
		"[user] has reattached [target]'s [target_organ] with \the [tool].",
		"You have reattached [target]'s [target_organ] with \the [tool]."
		)
	target_organ.status &= ~ORGAN_CUT_AWAY
	parent_organ.implants -= target_organ
	target_organ.replaced(target, parent_organ)
	target.update_deformities()

/datum/surgery_step/internal/attach_organ/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_failure(user,
		"[user]'s hand slips, damaging the flesh in [target]'s [parent_organ] with \the [tool]!",
		"Your hand slips, damaging the flesh in [target]'s [parent_organ] with \the [tool]!"
		)
	parent_organ.take_external_damage(20, used_weapon = tool)

/**
 * Organ detachment step using any sharp object, doesn't work on sinths.
 */
/datum/surgery_step/internal/detach_organ
	duration = DETACH_DURATION

	allowed_tools = list(
		/obj/item/scalpel = 100,
		/obj/item/material/knife = 75,
		/obj/item/material/kitchen/utensil/knife = 75,
		/obj/item/material/shard = 50
		)

/datum/surgery_step/internal/detach_organ/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	return (..() && !BP_IS_ROBOTIC(parent_organ))

/datum/surgery_step/internal/detach_organ/pick_target_organ(atom/user, mob/living/carbon/human/target, target_zone)
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

/datum/surgery_step/internal/detach_organ/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_preop(user,
		"[user] starts to separate [target]'s [target_organ] with \the [tool].",
		"You start to separate [target]'s [target_organ] with \the [tool]."
		)
	target.custom_pain("Someone's ripping out your [target_organ]!", 100)
	return ..()

/datum/surgery_step/internal/detach_organ/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_success(user,
		"[user] has separated [target]'s [target_organ] with \the [tool].",
		"You have separated [target]'s [target_organ] with \the [tool]."
		)
	target_organ.cut_away(target_organ.owner)

/datum/surgery_step/internal/detach_organ/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_failure(user,
		"[user]'s hand slips, slicing an artery inside [target]'s [parent_organ] with \the [tool]!",
		"Your hand slips, slicing an artery inside [target]'s [parent_organ] with \the [tool]!"
		)
	parent_organ.take_external_damage(
		rand(30, 50),
		0,
		(DAM_SHARP|DAM_EDGE),
		used_weapon = tool
		)

/**
 * Removes organ from parent using any poking tool.
 */
/datum/surgery_step/internal/remove_organ
	duration = CLAMP_DURATION

	allowed_tools = list(
		/obj/item/hemostat = 100,
		/obj/item/wirecutters = 75,
		/obj/item/material/knife = 75,
		/obj/item/material/kitchen/utensil/fork = 20
		)

/datum/surgery_step/internal/remove_organ/pick_target_organ(atom/user, mob/living/carbon/human/target, target_zone)
	var/list/removable_organs = list()
	var/obj/item/organ/external/parent_organ = target.get_organ(target_zone)
	for(var/obj/item/organ/internal/O in parent_organ.implants)
		if(O.status & ORGAN_CUT_AWAY)
			removable_organs[O] = adjust_organ_image(O)

	var/obj/item/organ/preselected_organ = ..()
	if(istype(preselected_organ))
		if(preselected_organ in removable_organs)
			return preselected_organ

		return null

	var/obj/item/organ/selected_organ = show_radial_menu(user, target, removable_organs, require_near = TRUE)
	if(!istype(selected_organ))
		return null

	return selected_organ

/datum/surgery_step/internal/remove_organ/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_preop(user,
		"[user] starts removing [target]'s [target_organ] with \the [tool].",
		"You start removing [target]'s [target_organ] with \the [tool]."
		)
	target.custom_pain("The pain in your [parent_organ] is living hell!", 100)
	return ..()

/datum/surgery_step/internal/remove_organ/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_success(user,
		"[user] has removed [target]'s [target_organ] with \the [tool].",
		"You have removed [target]'s [target_organ] with \the [tool]."
		)

	parent_organ.implants -= target_organ
	target_organ.dropInto(target.loc)
	if(!BP_IS_ROBOTIC(parent_organ))
		playsound(target.loc, 'sound/effects/squelch1.ogg', 15, 1)
	else
		playsound(target.loc, 'sound/items/Ratchet.ogg', 50, 1)

/datum/surgery_step/internal/remove_organ/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_failure(user,
		"[user]'s hand slips, damaging [target]'s [parent_organ] with \the [tool]!",
		"Your hand slips, damaging [target]'s [parent_organ] with \the [tool]!"
		)
	parent_organ.take_external_damage(20, used_weapon = tool)

/**
 * Puts organ inside its parent.
 */
/datum/surgery_step/internal/replace_organ
	duration = ATTACH_DURATION

	allowed_tools = list(
		/obj/item/organ/internal = 100
		)

	preop_sound = 'sound/effects/squelch1.ogg'
	success_sound = 'sound/effects/squelch2.ogg'

/datum/surgery_step/internal/replace_organ/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	. = ..()
	if(!.)
		return

	var/obj/item/organ/target_organ = tool
	if(!istype(target_organ))
		return FALSE

	if(BP_IS_ROBOTIC(parent_organ) && !BP_IS_ROBOTIC(target_organ))
		target.show_splash_text(user, "organic organ can't be connected to a robotic body!")
		return SURGERY_FAILURE

	if(!target.species)
		CRASH("Target ([target]) of surgery [type] has no species!")

	if(target_organ.organ_tag == BP_POSIBRAIN && !target.species.has_organ[BP_POSIBRAIN])
		target.show_splash_text(user, "this type of body isn't supported!")
		return SURGERY_FAILURE

	if(target_organ.damage > (target_organ.max_damage * 0.75))
		target.show_splash_text(user, "organ is too damaged!")
		return SURGERY_FAILURE

	if(target_organ.w_class > parent_organ.cavity_max_w_class)
		target.show_splash_text(user, "organ won't fit inside!")
		return SURGERY_FAILURE

	var/obj/item/organ/internal/O = target.internal_organs_by_name[target_organ.organ_tag]
	if(O && (O.parent_organ == parent_organ.organ_tag || istype(target_organ, /obj/item/organ/internal/stack)))
		target.show_splash_text(user, "stack is already present!")
		return SURGERY_FAILURE

	var/used_volume = 0
	for(var/obj/item/I in parent_organ.implants)
		if(istype(I, /obj/item/implant))
			continue

		used_volume += I.get_storage_cost()
	for(var/obj/item/I in parent_organ.internal_organs)
		used_volume += I.get_storage_cost()
	if((base_storage_capacity(parent_organ.cavity_max_w_class) + parent_organ.internal_organs_size) < used_volume + target_organ.get_storage_cost())
		target.show_splash_text(user, "not enough space!")
		return SURGERY_FAILURE

	return TRUE

/datum/surgery_step/internal/replace_organ/pick_target_organ(atom/user, mob/living/carbon/human/target, target_zone)
	return target.get_organ(target_zone)

/datum/surgery_step/internal/replace_organ/check_target_organ(obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	return TRUE

/datum/surgery_step/internal/replace_organ/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_preop(user,
		"[user] starts transplanting \the [tool] into [target]'s [parent_organ].",
		"You start transplanting \the [tool] into [target]'s [parent_organ]."
		)
	target.custom_pain("Someone's rooting around in your [parent_organ]!", 100)
	return ..()

/datum/surgery_step/internal/replace_organ/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_success(user,
		"[user] has transplanted \the [tool] into [target]'s [parent_organ].",
		"You have transplanted \the [tool] into [target]'s [parent_organ]."
		)
	var/obj/item/organ/O = tool
	if(!istype(O))
		return

	user.drop(O, target)
	target.update_deformities()
	parent_organ.implants |= O
	if(!(O.status & ORGAN_CUT_AWAY))
		log_debug("[user] ([user.ckey]) replaced organ [O], which didn't have ORGAN_CUT_AWAY set, in [target] ([target.ckey])")
		O.status |= ORGAN_CUT_AWAY

/datum/surgery_step/internal/replace_organ/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_failure(user,
		"[user]'s hand slips, damaging \the [tool]!",
		"Your hand slips, damaging \the [tool]!"
		)
	var/obj/item/organ/internal/I = tool
	if(!istype(tool))
		return

	I.take_internal_damage(rand(3, 5), FALSE)

/**
 * Drefault organ fixing step, does nothing, has overrides.
 */
/datum/surgery_step/internal/fix_organ
	duration = ORGAN_FIX_DURATION

/datum/surgery_step/internal/fix_organ/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	return (istype(parent_organ) && !BP_IS_ROBOTIC(parent_organ))

/datum/surgery_step/internal/fix_organ/pick_target_organ(atom/user, mob/living/carbon/human/target, target_zone)
	var/list/damaged_organs = list()
	var/obj/item/organ/external/parent_organ = target.get_organ(target_zone)
	for(var/obj/item/organ/internal/I in target.internal_organs)
		if(BP_IS_ROBOTIC(I))
			continue

		if(I.damage <= 0)
			continue

		if(I.status & ORGAN_CUT_AWAY)
			continue

		if(I.parent_organ != parent_organ.organ_tag)
			continue

		if(!I.surface_accessible && parent_organ.open() < (parent_organ.encased ? SURGERY_ENCASED : SURGERY_RETRACTED))
			continue

		damaged_organs[I] = adjust_organ_image(I)

	var/obj/item/organ/internal/preselected_organ = ..()
	if(istype(preselected_organ))
		if(preselected_organ in damaged_organs)
			return preselected_organ

		return null

	var/obj/item/organ/internal/selected_organ = show_radial_menu(user, target, damaged_organs, require_near = TRUE)
	if(!istype(selected_organ))
		return null

	return selected_organ

/datum/surgery_step/internal/fix_organ/check_target_organ(obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	. = ..()
	if(!.)
		return

	if(!istype(target_organ, /obj/item/organ/internal))
		return FALSE

	if(!target_organ.can_recover())
		target.show_splash_text(user, "organ is damaged beyond recover!")
		return SURGERY_FAILURE

	return !!target_organ.damage

/**
 * Fixes chosen organ using organ fixer.
 */
/datum/surgery_step/internal/fix_organ/default
	duration = ORGAN_FIX_DURATION

	allowed_tools = list(
		/obj/item/organfixer/standard = 100
		)

/datum/surgery_step/internal/fix_organ/default/check_target_organ(obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	. = ..()
	if(!.)
		return

	var/obj/item/organfixer/organ_fixer = tool
	if(!istype(organ_fixer))
		return FALSE

	if(!. && !organ_fixer.emagged)
		target.show_splash_text(user, "organ doesn't require any healing!")
		return SURGERY_FAILURE

	if(organ_fixer.gel_amt == 0)
		target.show_splash_text(user, "not enough gel!")
		return SURGERY_FAILURE

	return TRUE

/datum/surgery_step/internal/fix_organ/default/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_preop(user,
		"[user] starts repairing [target]'s [target_organ] with \the [tool].",
		"You start repairing [target]'s [target_organ] with \the [tool]."
		)
	target.custom_pain(
		"Something in your [target_organ] is causing you a lot of pain!",
		50
		)
	return ..()

/datum/surgery_step/internal/fix_organ/default/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	var/obj/item/organ/internal/internal_organ = target_organ
	if(!istype(internal_organ))
		return

	var/obj/item/organfixer/organ_fixer = tool
	if(organ_fixer.gel_amt == 0)
		return

	if(organ_fixer.gel_amt > 0)
		organ_fixer.gel_amt--

	if(organ_fixer.emagged)
		announce_success(user,
			"[user]'s hand slips, getting mess and tearing the inside of [target]'s [internal_organ] with \the [organ_fixer]!",
			"Something goes wrong and \the [organ_fixer] shreds [target]'s [internal_organ] before you have a chance to react!"
			)
		target.custom_pain(
			"Your [internal_organ] feels like it's getting torn apart!",
			150
			)
		target.adjustToxLoss(30)
		parent_organ.take_external_damage(10, 0, (DAM_SHARP|DAM_EDGE), used_weapon = organ_fixer)
		internal_organ.take_internal_damage((parent_organ.max_damage - parent_organ.damage), 0)
		return

	announce_success(user,
		"[user] repairs [target]'s [internal_organ] with [organ_fixer].",
		"You repair [target]'s [internal_organ] with [organ_fixer]."
		)

	if((internal_organ.status & ORGAN_DEAD) && internal_organ.can_recover())
		internal_organ.status &= ~ORGAN_DEAD

	internal_organ.damage = 0
	target.update_body(TRUE)

/datum/surgery_step/internal/fix_organ/default/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	var/obj/item/organ/internal/internal_organ = target_organ
	if(!istype(internal_organ))
		return

	announce_failure(user,
		"[user]'s hand slips, getting mess and tearing the inside of [target]'s [internal_organ] with \the [tool]!",
		"Your hand slips, getting mess and tearing the inside of [target]'s [internal_organ] with \the [tool]!"
		)

	target.adjustToxLoss(10)
	parent_organ.take_external_damage(5, 0, (DAM_SHARP|DAM_EDGE), used_weapon = tool)

	if(internal_organ.damage > 0)
		internal_organ.take_internal_damage(5, 0)

/**
 * Ghetto way to fix one chosen organ inside targeted zone.
 */
/datum/surgery_step/internal/fix_organ/ghetto
	duration = ORGAN_FIX_DURATION * 1.75

	allowed_tools = list(
		/obj/item/stack/medical/advanced/bruise_pack= 67,
		/obj/item/stack/medical/bruise_pack = 34
		)

/datum/surgery_step/internal/fix_organ/ghetto/check_target_organ(obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	. = ..()
	if(!.)
		return

	if(!istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
		return FALSE

	if(!istype(tool, /obj/item/stack/medical/bruise_pack))
		return FALSE

	var/obj/item/stack/medical/M = tool
	if(M.amount < 1)
		target.show_splash_text(user, "not enough medicine to complete this step!")
		return SURGERY_FAILURE

	return TRUE

/datum/surgery_step/internal/fix_organ/ghetto/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	var/tool_name = "\the [tool]"
	if(istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
		tool_name = "regenerative membrane"
	else if(istype(tool, /obj/item/stack/medical/bruise_pack))
		tool_name = "the bandaid"

	announce_preop(user,
		"[user] starts treating damage to [target]'s [target_organ] with \the [tool_name].",
		"You start treating damage to [target]'s [target_organ] with \the [tool_name]."
		)
	target.custom_pain("The pain in your [parent_organ] is living hell!", 100)
	return ..()

/datum/surgery_step/internal/fix_organ/ghetto/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	var/obj/item/organ/internal/internal_organ = target_organ
	if(!istype(internal_organ))
		return

	var/tool_name = "\the [tool]"
	if(istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
		tool_name = "regenerative membrane"
	else if(istype(tool, /obj/item/stack/medical/bruise_pack))
		tool_name = "the bandaid"

	if((internal_organ.status & ORGAN_DEAD) && internal_organ.can_recover())
		announce_success(user,
			"[user] treats damage to [target]'s [internal_organ] with [tool_name], though it needs to be recovered further.",
			"You treat damage to [target]'s [internal_organ] with [tool_name], though it needs to be recovered further."
			)
	else
		announce_success(user,
			"[user] treats damage to [target]'s [internal_organ] with [tool_name].",
			"You treat damage to [target]'s [internal_organ] with [tool_name]."
			)

	var/obj/item/stack/medical/M = tool
	M.use(1)

	internal_organ.damage = 0
	target.update_body(TRUE)

/datum/surgery_step/internal/fix_organ/ghetto/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_failure(user,
		"[user]'s hand slips, getting mess and tearing the inside of [target]'s [parent_organ] with \the [tool]!",
		"Your hand slips, getting mess and tearing the inside of [target]'s [parent_organ] with \the [tool]!"
		)

	var/dam_amt = 2
	if(istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
		target.adjustToxLoss(5)
	else
		dam_amt = 5
		target.adjustToxLoss(10)
		parent_organ.take_external_damage(dam_amt, 0, (DAM_SHARP|DAM_EDGE), used_weapon = tool)

	for(var/obj/item/organ/internal/I in parent_organ.internal_organs)
		if(I.damage > 0 && !BP_IS_ROBOTIC(I))
			I.take_internal_damage(dam_amt, 0)

/**
 * Fixes all damaged organs inside targeted zone.
 */
/datum/surgery_step/internal/fix_organ/multiple
	allowed_tools = list(
		/obj/item/organfixer/advanced = 100
		)

/datum/surgery_step/internal/fix_organ/multiple/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	. = ..()
	if(!.)
		return

	var/obj/item/organfixer/organ_fixer = tool
	if(!istype(organ_fixer))
		return FALSE

	if(organ_fixer.gel_amt == 0)
		target.show_splash_text(user, "not enough gel!")
		return SURGERY_FAILURE

	for(var/obj/item/organ/internal/I in parent_organ.internal_organs)
		if(BP_IS_ROBOTIC(I))
			continue

		if(I.damage <= 0)
			continue

		if(I.status & ORGAN_CUT_AWAY)
			continue

		if(I.parent_organ != parent_organ.organ_tag)
			continue

		if(!I.surface_accessible && parent_organ.open() < (parent_organ.encased ? SURGERY_ENCASED : SURGERY_RETRACTED))
			continue

		return TRUE

	return FALSE

/datum/surgery_step/internal/fix_organ/multiple/pick_target_organ(atom/user, mob/living/carbon/human/target, target_zone)
	return target.get_organ(target_zone)

/datum/surgery_step/internal/fix_organ/multiple/check_target_organ(obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	return istype(target_organ)

/datum/surgery_step/internal/fix_organ/multiple/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_preop(user,
		"[user] starts treating damage to [target]'s [parent_organ] with \the [tool].",
		"You start treating damage to [target]'s [parent_organ] with \the [tool]."
		)
	target.custom_pain("The pain in your [parent_organ] is living hell!", 100)
	return ..()

/datum/surgery_step/internal/fix_organ/multiple/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	var/obj/item/organfixer/organ_fixer = tool
	if(!istype(organ_fixer))
		return

	if(organ_fixer.emagged)
		announce_success(user,
			"[user]'s hand slips, getting mess and tearing the inside of [target]'s [parent_organ] with \the [organ_fixer]!",
			"Something goes wrong and \the [organ_fixer] shreds everything inside [target]'s [parent_organ] before you have a chance to react!"
			)
		target.custom_pain(
			"Your whole [parent_organ] feels like it's getting torn apart!",
			150
			)
		target.adjustToxLoss(30)
		parent_organ.take_external_damage(15, 0, (DAM_SHARP|DAM_EDGE), used_weapon = organ_fixer)
		for(var/obj/item/organ/internal/I in parent_organ.internal_organs)
			if(I && (I.surface_accessible || parent_organ.open() >= (parent_organ.encased ? SURGERY_ENCASED : SURGERY_RETRACTED)))
				I.take_internal_damage((parent_organ.max_damage - parent_organ.damage), 0)
		return

	for(var/obj/item/organ/internal/I in parent_organ.internal_organs)
		if(I.damage > 0 && !BP_IS_ROBOTIC(I) && (I.surface_accessible || parent_organ.open() >= (parent_organ.encased ? SURGERY_ENCASED : SURGERY_RETRACTED)))
			if(organ_fixer.gel_amt == 0)
				return

			if((I.status & ORGAN_DEAD) && !I.can_recover())
				continue

			if(I.status & ORGAN_DEAD)
				I.status &= ~ORGAN_DEAD

			if(organ_fixer.gel_amt > 0)
				organ_fixer.gel_amt--

			I.owner.update_body(TRUE)
			I.damage = 0

	announce_success(user,
		"[user] repairs organs in [target]'s [parent_organ] with \the [organ_fixer].",
		"You repair organs in [target]'s [parent_organ] with \the [organ_fixer]."
		)

/datum/surgery_step/internal/fix_organ/multiple/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_failure(user,
		"[user]'s hand slips, getting mess and tearing the inside of [target]'s [parent_organ] with \the [tool]!",
		"Your hand slips, getting mess and tearing the inside of [target]'s [parent_organ] with \the [tool]!"
		)
	target.adjustToxLoss(10)
	parent_organ.take_external_damage(5, 0, (DAM_SHARP|DAM_EDGE), used_weapon = tool)
	for(var/obj/item/organ/internal/I in parent_organ.internal_organs)
		if(I.damage > 0 && !BP_IS_ROBOTIC(I) && (I.surface_accessible || parent_organ.open() >= (parent_organ.encased ? SURGERY_ENCASED : SURGERY_RETRACTED)))
			I.take_internal_damage(5, 0)

/**
 * Treats dead organs.
 */
/datum/surgery_step/internal/treat_necrosis
	blood_level = 0
	priority = 2
	duration = TREAT_NECROSIS_DURATION

	allowed_tools = list(
		/obj/item/reagent_containers/dropper = 100, 	\
		/obj/item/reagent_containers/vessel/bottle/chemical = 75,	\
		/obj/item/reagent_containers/vessel/beaker = 75,	\
		/obj/item/reagent_containers/spray = 50,	\
		/obj/item/reagent_containers/vessel/bucket = 50
	)

/datum/surgery_step/internal/treat_necrosis/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	return (..() && !BP_IS_ROBOTIC(parent_organ))

/datum/surgery_step/internal/treat_necrosis/pick_target_organ(atom/user, mob/living/carbon/human/target, target_zone)
	var/list/dead_organs = list()
	var/obj/item/organ/external/parent_organ = target.get_organ(target_zone)
	for(var/obj/item/organ/internal/O in target.internal_organs)
		if(BP_IS_ROBOTIC(O))
			continue

		if(!(O.status & ORGAN_CUT_AWAY) && (O.status & ORGAN_DEAD) && O.parent_organ == parent_organ.organ_tag)
			dead_organs[O] = adjust_organ_image(O)

	var/obj/item/organ/internal/preselected_organ = ..()
	if(istype(preselected_organ))
		if(preselected_organ in dead_organs)
			return preselected_organ

		return null

	var/obj/item/organ/internal/selected_organ = show_radial_menu(user, target, dead_organs, require_near = TRUE)
	if(!istype(selected_organ))
		return null

	return selected_organ

/datum/surgery_step/internal/treat_necrosis/check_target_organ(obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	. = ..()
	if(!.)
		return

	var/obj/item/reagent_containers/container = tool
	if(!istype(container))
		return FALSE

	if(!container.reagents.has_reagent(/datum/reagent/peridaxon))
		return FALSE

	if(!target_organ.can_recover() && istype(target_organ, /obj/item/organ/internal/cerebrum/brain))
		target.show_splash_text(user, "organ is damaged beyond recover!")
		return SURGERY_FAILURE

	return TRUE

/datum/surgery_step/internal/treat_necrosis/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_preop(user,
		"[user] starts applying medication to the affected tissue in [target]'s [parent_organ] with \the [tool].",
		"You start applying medication to the affected tissue in [target]'s [parent_organ] with \the [tool]."
		)

	target.custom_pain(
		"Something in your [parent_organ] is causing you a lot of pain!",
		50
		)
	return ..()

/datum/surgery_step/internal/treat_necrosis/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	var/obj/item/reagent_containers/container = tool
	if(!istype(container))
		return

	var/amount = container.amount_per_transfer_from_this
	var/datum/reagents/temp_reagents = new(amount, GLOB.temp_reagents_holder)
	container.reagents.trans_to_holder(temp_reagents, amount)

	var/rejuvenate = temp_reagents.has_reagent(/datum/reagent/peridaxon)

	var/trans = temp_reagents.trans_to_mob(target, temp_reagents.total_volume, CHEM_BLOOD)
	qdel(temp_reagents)
	if(trans <= 0)
		return

	if(rejuvenate)
		if(target_organ.can_recover())
			target_organ.damage = 0
			target_organ.status &= ~ORGAN_DEAD
		else
			target_organ.damage = target_organ.min_broken_damage
			target_organ.death_time = 0
		target.update_body(TRUE)

	announce_success(user,
		"[user] applies [trans] unit\s of the solution to affected tissue in [target]'s [parent_organ]",
		"You apply [trans] unit\s of the solution to affected tissue in [target]'s [parent_organ] with \the [tool]."
		)


/datum/surgery_step/internal/treat_necrosis/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	var/obj/item/reagent_containers/container = tool
	if(!istype(container))
		return

	announce_failure(user,
		"[user]'s hand slips, applying solution to the wrong place in [target]'s [parent_organ] with the [tool]!",
		"Your hand slips, applying solution to the wrong place in [target]'s [parent_organ] with the [tool]!"
		)
	container.reagents.trans_to_mob(target, container.amount_per_transfer_from_this, CHEM_BLOOD)
