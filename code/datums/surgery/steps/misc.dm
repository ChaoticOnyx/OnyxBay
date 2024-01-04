/**
 * Cutting powersuit step.
 */
/datum/surgery_step/powersuit
	needs_uncovered_organ = FALSE
	priority = 3
	duration = SAW_DURATION * 2

	allowed_tools = list(
		/obj/item/weldingtool = 80,
		/obj/item/circular_saw = 60,
		/obj/item/gun/energy/plasmacutter = 30
		)

	preop_sound = list(
		/obj/item/weldingtool = 'sound/items/Welder.ogg',
		/obj/item/circular_saw = 'sound/surgery/saw.ogg',
		/obj/item/gun/energy/plasmacutter = 'sound/items/Welder2.ogg',
	)
	success_sound = 'sound/surgery/organ2.ogg'
	failure_sound = 'sound/surgery/organ1.ogg'

/datum/surgery_step/powersuit/check_zone(mob/living/carbon/human/target, target_zone)
	return (..() && target_zone == BP_CHEST)

/datum/surgery_step/powersuit/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	. = ..()
	if(!.)
		return

	if(!istype(target.back, /obj/item/rig))
		return FALSE

	if(isWelder(tool))
		var/obj/item/weldingtool/W = tool
		if(!W.isOn() || !W.remove_fuel(1, user))
			return FALSE

	return !(target.back.canremove)

/datum/surgery_step/powersuit/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_preop(user,
		"[user] starts cutting through the support systems of [target]'s [target.back] with \the [tool].",
		"You start cutting through the support systems of [target]'s [target.back] with \the [tool]."
		)
	return ..()

/datum/surgery_step/powersuit/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	var/obj/item/rig/R = target.back
	if(!istype(R))
		return

	R.reset()
	announce_success(user,
		"[user] has cut through the support systems of [target]'s [R] with \the [tool].",
		"You have cut through the support systems of [target]'s [R] with \the [tool]."
		)

/datum/surgery_step/powersuit/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_failure(user,
		"[user]'s [tool] can't quite seem to get through the metal...",
		"Your [tool] can't quite seem to get through the metal. It's weakening, though - try again."
		)

/**
 * Limb sterialization step.
 */
/datum/surgery_step/sterilize
	priority = 2
	duration = STERILIZATION_DURATION

	allowed_tools = list(
		/obj/item/reagent_containers/spray = 100,
		/obj/item/reagent_containers/dropper = 100,
		/obj/item/reagent_containers/vessel/bottle/chemical = 90,
		/obj/item/reagent_containers/vessel/flask = 90,
		/obj/item/reagent_containers/vessel/beaker = 75,
		/obj/item/reagent_containers/vessel/bottle = 75,
		/obj/item/reagent_containers/vessel/glass = 75,
		/obj/item/reagent_containers/vessel/bucket = 50
		)

	success_sound = 'sound/effects/spray2.ogg'
	failure_sound = 'sound/effects/spray3.ogg'

/datum/surgery_step/sterilize/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	. = ..()
	if(!.)
		return

	if(parent_organ.is_disinfected())
		return FALSE

	var/obj/item/reagent_containers/C = tool
	if(!istype(C) || !C.is_open_container())
		return FALSE

	var/datum/reagent/ethanol/E = locate() in C.reagents.reagent_list
	if(istype(E) && E.strength >= 40)
		return FALSE

	if(!istype(E) && !C.reagents.has_reagent(/datum/reagent/sterilizine))
		return FALSE

	return TRUE

/datum/surgery_step/sterilize/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_preop(user,
		"[user] starts pouring [tool]'s contents on \the [target]'s [parent_organ]." , \
		"You start pouring [tool]'s contents on \the [target]'s [parent_organ]."
		)
	target.custom_pain(
		"Your [parent_organ] is on fire!",
		50,
		affecting = parent_organ
		)
	return ..()

/datum/surgery_step/sterilize/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	var/obj/item/reagent_containers/C = tool
	var/transfered = C.reagents.trans_to_mob(target, C.amount_per_transfer_from_this, CHEM_BLOOD)
	if(!transfered)
		return

	announce_success(user,
		"[user] rubs [target]'s [parent_organ] down with \the [tool]'s contents.",
		"You rub [target]'s [parent_organ] down with \the [tool]'s contents."
		)

/datum/surgery_step/sterilize/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	var/obj/item/reagent_containers/C = tool
	if(!istype(C))
		return

	var/transfered = C.reagents.trans_to_mob(target, C.amount_per_transfer_from_this, CHEM_BLOOD)
	if(!transfered)
		return

	announce_failure(user,
		"[user]'s hand slips, spilling \the [tool]'s contents over the [target]'s [parent_organ]!",
		"Your hand slips, spilling \the [tool]'s contents over the [target]'s [parent_organ]!"
		)
	parent_organ.disinfect()

/**
 * Fix tendon step.
 */
/datum/surgery_step/fix_tendon
	can_infect = TRUE
	delicate = TRUE
	blood_level = BLOODY_HANDS
	shock_level = 40
	priority = 2
	duration = CONNECT_DURATION
	allowed_tools = list(
		/obj/item/FixOVein = 100,
		/obj/item/stack/cable_coil = 75,
		/obj/item/tape_roll = 50
		)

	success_sound = 'sound/surgery/fixovein.ogg'
	failure_sound = 'sound/surgery/organ2.ogg'

/datum/surgery_step/fix_tendon/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	. = ..()
	if(!.)
		return

	if(parent_organ.open() < SURGERY_RETRACTED)
		return FALSE

	return (parent_organ.status & ORGAN_TENDON_CUT)

/datum/surgery_step/fix_tendon/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_preop(user,
		"[user] starts reattaching the damaged [parent_organ.tendon_name] in [target]'s [parent_organ] with \the [tool].",
		"You start reattaching the damaged [parent_organ.tendon_name] in [target]'s [parent_organ] with \the [tool]."
		)
	target.custom_pain(
		"The pain in your [parent_organ] is unbearable!",
		100,
		affecting = parent_organ
		)
	return ..()

/datum/surgery_step/fix_tendon/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_success(user,
		"[user] has reattached the [parent_organ.tendon_name] in [target]'s [parent_organ] with \the [tool].",
		"You have reattached the [parent_organ.tendon_name] in [target]'s [parent_organ] with \the [tool]."
		)
	parent_organ.status &= ~ORGAN_TENDON_CUT
	parent_organ.update_damages()

/datum/surgery_step/fix_tendon/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_failure(user,
		"[user]'s hand slips, smearing [tool] in the incision in [target]'s [parent_organ]!",
		"Your hand slips, smearing [tool] in the incision in [target]'s [parent_organ]!"
		)
	parent_organ.take_external_damage(5, used_weapon = tool)

/**
 * Fix vein inside a limb step.
 */
/datum/surgery_step/fix_vein
	can_infect = TRUE
	delicate = TRUE
	blood_level = BLOODY_HANDS
	shock_level = 40
	priority = 3
	duration = CONNECT_DURATION

	allowed_tools = list(
		/obj/item/FixOVein = 100,
		/obj/item/stack/cable_coil = 75,
		/obj/item/tape_roll = 50
		)

	success_sound = 'sound/surgery/fixovein.ogg'
	failure_sound = 'sound/surgery/organ2.ogg'

/datum/surgery_step/fix_vein/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	. = ..()
	if(!.)
		return

	if(parent_organ.open() < SURGERY_RETRACTED)
		return FALSE

	return (parent_organ.status & ORGAN_ARTERY_CUT)

/datum/surgery_step/fix_vein/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_preop(user,
		"[user] starts patching the damaged [parent_organ.artery_name] in [target]'s [parent_organ] with \the [tool].",
		"You start patching the damaged [parent_organ.artery_name] in [target]'s [parent_organ] with \the [tool]."
		)
	target.custom_pain(
		"The pain in your [parent_organ] is unbearable!",
		100,
		affecting = parent_organ
		)
	return ..()

/datum/surgery_step/fix_vein/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_success(user,
		"[user] has patched the [parent_organ.artery_name] in [target]'s [parent_organ] with \the [tool].",
		"You have patched the [parent_organ.artery_name] in [target]'s [parent_organ] with \the [tool]."
		)
	parent_organ.status &= ~ORGAN_ARTERY_CUT
	parent_organ.update_damages()

/datum/surgery_step/fix_vein/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_failure(user,
		"[user]'s hand slips, smearing [tool] in the incision in [target]'s [parent_organ]!",
		"Your hand slips, smearing [tool] in the incision in [target]'s [parent_organ]!"
		)
	parent_organ.take_external_damage(5, used_weapon = tool)
