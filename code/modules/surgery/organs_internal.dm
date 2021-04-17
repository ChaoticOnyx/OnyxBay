//Procedures in this file: internal organ surgery, removal, transplants
//////////////////////////////////////////////////////////////////
//						INTERNAL ORGANS							//
//////////////////////////////////////////////////////////////////
/datum/surgery_step/internal
	priority = 2
	can_infect = 1
	blood_level = 1
	shock_level = 40
	delicate = 1

/datum/surgery_step/internal/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!hasorgans(target))
		return FALSE

	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!affected)
		return FALSE
	if(BP_IS_ROBOTIC(affected))
		return affected.hatch_state == HATCH_OPENED
	else
		return affected.open() == (affected.encased ? SURGERY_ENCASED : SURGERY_RETRACTED)

//////////////////////////////////////////////////////////////////
//	 Single organ mending surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/internal/fix_organ
	allowed_tools = list(
	/obj/item/weapon/organfixer/standard = 100
	)

	duration = ORGAN_FIX_DURATION

/datum/surgery_step/internal/fix_organ/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/weapon/organfixer/O = tool
	if(!istype(O))
		return FALSE
	if(!..())
		return FALSE
	if(O.gel_amt == 0)
		to_chat(user, SPAN("warning", "\The [O] is empty!"))
		return SURGERY_FAILURE
	if(target.op_stage.current_organ)
		to_chat(user, SPAN("warning", "You can't do this right now."))
		return SURGERY_FAILURE

	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	if(BP_IS_ROBOTIC(affected))
		return FALSE

	target.op_stage.current_organ = null

	var/obj/item/organ/internal/list/damaged_organs = list()
	for(var/obj/item/organ/internal/I in target.internal_organs)
		if(I && !(I.status & ORGAN_CUT_AWAY) && I.parent_organ == affected.organ_tag && !BP_IS_ROBOTIC(I))
			var/image/img = image(icon = I.icon, icon_state = I.icon_state)
			img.overlays = I.overlays
			img.transform *= 1.5
			img.pixel_y = -5
			img.pixel_x = 3
			damaged_organs[I] = img

	var/obj/item/organ/internal/organ_to_fix = show_radial_menu(user, target, damaged_organs, require_near = TRUE)

	if(!organ_to_fix || (user.get_active_hand().return_item() != tool))
		return FALSE
	if(!organ_to_fix.can_recover())
		to_chat(user, SPAN("notice", "The [organ_to_fix.name] is destroyed and can't be saved."))
		return SURGERY_FAILURE
	if(!organ_to_fix.damage && !O.emagged)
		to_chat(user, SPAN("notice", "The [organ_to_fix.name] is intact and doesn't require any healing."))
		return SURGERY_FAILURE

	target.op_stage.current_organ = organ_to_fix

	return TRUE

/datum/surgery_step/internal/fix_organ/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!hasorgans(target))
		return
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!affected || affected.open() < 2)
		return
	user.visible_message("[user] starts repairing [target]'s [target.op_stage.current_organ] with \the [tool]." , \
	"You start repairing [target]'s [target.op_stage.current_organ] with \the [tool].")

	target.custom_pain("Something in your [target.op_stage.current_organ] is causing you a lot of pain!",50,affecting = target.op_stage.current_organ)
	..()

/datum/surgery_step/internal/fix_organ/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/internal/affected = target.op_stage.current_organ
	var/obj/item/weapon/organfixer/O = tool
	if(O.gel_amt != 0)
		if(!O.emagged)
			if(affected && affected.damage > 0 && !BP_IS_ROBOTIC(affected) && (affected.surface_accessible || target.get_organ(target_zone).open() >= (target.get_organ(target_zone).encased ? SURGERY_ENCASED : SURGERY_RETRACTED)))
				user.visible_message(SPAN("notice", "[user] repairs [target]'s [affected.name] with [O]."), \
				SPAN("notice", "You repair [target]'s [affected.name] with [O]."))
				affected.damage = 0
				if(affected.status & ORGAN_DEAD && affected.can_recover())
					affected.status &= ~ORGAN_DEAD
				affected.owner.update_body(1)
		else
			user.visible_message(SPAN("warning", "[user]'s hand slips, getting mess and tearing the inside of [target]'s [affected.name] with \the [O]!"), \
			SPAN("warning", "Something goes wrong and \the [O] shreds [target]'s [affected.name] before you have a chance to react!"))

			target.custom_pain("Your [target.op_stage.current_organ] feels like it's getting torn apart!",150,affecting = target.op_stage.current_organ)
			target.adjustToxLoss(30)
			target.get_organ(target_zone).take_external_damage(10, 0, (DAM_SHARP|DAM_EDGE), used_weapon = O)
			affected.take_internal_damage((affected.max_damage - affected.damage), 0)
		if(O.gel_amt_max != -1)
			O.gel_amt--
	else
		to_chat(user, SPAN("warning", "\The [O] is empty!"))
	target.op_stage.current_organ = null

/datum/surgery_step/internal/fix_organ/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!hasorgans(target))
		return
	var/obj/item/organ/internal/affected = target.op_stage.current_organ

	user.visible_message(SPAN("warning", "[user]'s hand slips, getting mess and tearing the inside of [target]'s [affected.name] with \the [tool]!"), \
	SPAN("warning", "Your hand slips, getting mess and tearing the inside of [target]'s [affected.name] with \the [tool]!"))

	target.adjustToxLoss(10)
	target.get_organ(target_zone).take_external_damage(5, 0, (DAM_SHARP|DAM_EDGE), used_weapon = tool)

	if(affected && affected.damage > 0 && !BP_IS_ROBOTIC(affected) && (affected.surface_accessible || target.get_organ(target_zone).open() >= (target.get_organ(target_zone).encased ? 3 : 2)))
		affected.take_internal_damage(5, 0)
	target.op_stage.current_organ = null


//////////////////////////////////////////////////////////////////
//	 Multiple organs mending surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/internal/fix_organ_multiple
	allowed_tools = list(
	/obj/item/weapon/organfixer/advanced = 100
	)

	duration = ORGAN_FIX_DURATION

/datum/surgery_step/internal/fix_organ_multiple/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/weapon/organfixer/O = tool
	if(!istype(O))
		return FALSE
	if(!..())
		return FALSE
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(BP_IS_ROBOTIC(affected))
		return FALSE
	if(O.gel_amt == 0)
		to_chat(user, SPAN("warning", "\The [O] is empty!"))
		return SURGERY_FAILURE
	if(O.emagged == 1) // We can shred 'em even if they have no damaged internals
		return TRUE
	for(var/obj/item/organ/internal/I in affected.internal_organs)
		if(I.damage > 0)
			if(I.surface_accessible)
				return TRUE
			if(affected.open() >= (affected.encased ? SURGERY_ENCASED : SURGERY_RETRACTED))
				return TRUE
	return FALSE

/datum/surgery_step/internal/fix_organ_multiple/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!hasorgans(target))
		return
	var/obj/item/weapon/organfixer/O = tool
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!affected || affected.open() < 2)
		return
	for(var/obj/item/organ/internal/I in affected.internal_organs)
		if(I && (I.damage > 0 || O.emagged == 1) && !BP_IS_ROBOTIC(I) && (!I.status & ORGAN_DEAD || I.can_recover()) && (I.surface_accessible || affected.open() >= (affected.encased ? 3 : 2)))
			user.visible_message("[user] starts treating damage to [target]'s [I.name] with \the [tool].", \
			"You start treating damage to [target]'s [I.name] with \the [tool]." )

	target.custom_pain("The pain in your [affected.name] is living hell!",100,affecting = affected)
	..()

/datum/surgery_step/internal/fix_organ_multiple/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!hasorgans(target))
		return
	var/obj/item/weapon/organfixer/O = tool
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!affected || affected.open() < 2)
		return
	if(!O.emagged)
		for(var/obj/item/organ/internal/I in affected.internal_organs)
			if(I && I.damage > 0 && !BP_IS_ROBOTIC(I) && (I.surface_accessible || affected.open() >= (affected.encased ? SURGERY_ENCASED : SURGERY_RETRACTED)))
				if(O.gel_amt == 0)
					to_chat(user, SPAN("warning", "\The [O] runs out of gel!"))
					return FALSE
				if(I.status & ORGAN_DEAD && !I.can_recover())
					to_chat(user, SPAN("notice", "[target]'s [I.name] is destroyed and can't be fixed with \the [O]."))
					continue
				user.visible_message(SPAN("notice", "[user] repairs [target]'s [I.name] with \the [O]."), \
				SPAN("notice", "You repair [target]'s [I.name] with \the [O]."))
				I.damage = 0
				if(I.status & ORGAN_DEAD && I.can_recover())
					I.status &= ~ORGAN_DEAD
				I.owner.update_body(1)
				if(O.gel_amt_max != -1)
					O.gel_amt--
	else
		user.visible_message(SPAN("warning", "[user]'s hand slips, getting mess and tearing the inside of [target]'s [affected.name] with \the [O]!"), \
		SPAN("warning", "Something goes wrong and \the [O] shreds everything inside [target]'s [affected.name] before you have a chance to react!"))

		target.custom_pain("Your whole [affected] feels like it's getting torn apart!",150,affecting = affected)
		target.adjustToxLoss(30)
		affected.take_external_damage(15, 0, (DAM_SHARP|DAM_EDGE), used_weapon = O)
		for(var/obj/item/organ/internal/I in affected.internal_organs)
			if(I && (I.surface_accessible || affected.open() >= (affected.encased ? SURGERY_ENCASED : SURGERY_RETRACTED)))
				I.take_internal_damage((affected.max_damage - affected.damage), 0)

/datum/surgery_step/internal/fix_organ_multiple/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!hasorgans(target))
		return
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message(SPAN("warning", "[user]'s hand slips, getting mess and tearing the inside of [target]'s [affected.name] with \the [tool]!"), \
	SPAN("warning", "Your hand slips, getting mess and tearing the inside of [target]'s [affected.name] with \the [tool]!"))
	target.adjustToxLoss(10)
	affected.take_external_damage(5, 0, (DAM_SHARP|DAM_EDGE), used_weapon = tool)

	for(var/obj/item/organ/internal/I in affected.internal_organs)
		if(I && I.damage > 0 && !BP_IS_ROBOTIC(I) && (I.surface_accessible || affected.open() >= (affected.encased ? 3 : 2)))
			I.take_internal_damage(5, 0)

//////////////////////////////////////////////////////////////////
//	 Ghetto organs mending surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/internal/fix_organ_ghetto
	allowed_tools = list(
	/obj/item/stack/medical/advanced/bruise_pack= 67,		\
	/obj/item/stack/medical/bruise_pack = 34,	\
	/obj/item/weapon/tape_roll = 20
	)

	duration = ORGAN_FIX_DURATION * 1.75

/datum/surgery_step/internal/fix_organ_ghetto/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return FALSE
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(BP_IS_ROBOTIC(affected))
		return FALSE
	if(target.op_stage.current_organ)
		to_chat(user, SPAN("warning", "You can't do this right now."))
		return SURGERY_FAILURE
	if(istype(tool, /obj/item/stack/medical/advanced/bruise_pack) || istype(tool, /obj/item/stack/medical/bruise_pack))
		var/obj/item/stack/medical/M = tool
		if(M.amount < 1)
			to_chat(user, SPAN("warning", "\The [M] is empty!"))
			return SURGERY_FAILURE

	var/obj/item/organ/internal/list/damaged_organs = list()
	for(var/obj/item/organ/internal/I in target.internal_organs)
		if(I && !(I.status & ORGAN_CUT_AWAY) && I.parent_organ == affected.organ_tag && !BP_IS_ROBOTIC(I))
			var/image/img = image(icon = I.icon, icon_state = I.icon_state)
			img.overlays = I.overlays
			img.transform *= 1.5
			img.pixel_y = -5
			img.pixel_x = 3
			damaged_organs[I] = img

	var/obj/item/organ/internal/organ_to_fix = show_radial_menu(user, target, damaged_organs, require_near = TRUE)

	if(!organ_to_fix || (user.get_active_hand().return_item() != tool))
		return FALSE
	if(target.op_stage.current_organ)
		to_chat(user, SPAN("warning", "You can't do this right now."))
		return SURGERY_FAILURE
	if(!organ_to_fix.can_recover())
		to_chat(user, SPAN("notice", "The [organ_to_fix.name] is destroyed and can't be saved."))
		return SURGERY_FAILURE
	if(!organ_to_fix.damage)
		to_chat(user, SPAN("notice", "The [organ_to_fix.name] is intact and doesn't require any healing."))
		return SURGERY_FAILURE

	target.op_stage.current_organ = organ_to_fix

	return FALSE

/datum/surgery_step/internal/fix_organ_ghetto/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/tool_name = "\the [tool]"
	if (istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
		tool_name = "regenerative membrane"
	else if (istype(tool, /obj/item/stack/medical/bruise_pack))
		tool_name = "the bandaid"

	if (!hasorgans(target))
		return
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!affected || affected.open() < 2)
		return
	user.visible_message("[user] starts treating damage to [target]'s [target.op_stage.current_organ] with \the [tool_name]." , \
			       	         "You start treating damage to [target]'s [target.op_stage.current_organ] with \the [tool_name].")
	target.custom_pain("The pain in your [affected.name] is living hell!",100,affecting = affected)
	..()

/datum/surgery_step/internal/fix_organ_ghetto/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!hasorgans(target))
		return
	var/tool_name = "\the [tool]"
	if (istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
		tool_name = "regenerative membrane"
	if (istype(tool, /obj/item/stack/medical/bruise_pack))
		tool_name = "the bandaid"
	var/obj/item/organ/internal/affected = target.op_stage.current_organ
	if(affected && affected.damage > 0 && !BP_IS_ROBOTIC(affected) && (affected.surface_accessible || target.get_organ(target_zone).open() >= (target.get_organ(target_zone).encased ? SURGERY_ENCASED : SURGERY_RETRACTED)))
		if(affected.status & ORGAN_DEAD && affected.can_recover())
			user.visible_message(SPAN("notice", "[user] treats damage to [target]'s [affected.name] with [tool_name], though it needs to be recovered further."), \
						             SPAN("notice", "You treat damage to [target]'s [affected.name] with [tool_name], though it needs to be recovered further."))
		else
			user.visible_message(SPAN("notice", "[user] treats damage to [target]'s [affected.name] with [tool_name]."), \
						             SPAN("notice", "You treat damage to [target]'s [affected.name] with [tool_name]."))
		if(istype(tool, /obj/item/stack/medical/advanced/bruise_pack) || istype(tool, /obj/item/stack/medical/bruise_pack))
			var/obj/item/stack/medical/M = tool
			M.use(1)
		affected.damage = 0
		affected.owner.update_body(1)
	target.op_stage.current_organ = null

/datum/surgery_step/internal/fix_organ_ghetto/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!hasorgans(target))
		return
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message(SPAN("warning", "[user]'s hand slips, getting mess and tearing the inside of [target]'s [affected.name] with \the [tool]!"), \
			                 SPAN("warning", "Your hand slips, getting mess and tearing the inside of [target]'s [affected.name] with \the [tool]!"))
	var/dam_amt = 2

	if (istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
		target.adjustToxLoss(5)

	else
		dam_amt = 5
		target.adjustToxLoss(10)
		affected.take_external_damage(dam_amt, 0, (DAM_SHARP|DAM_EDGE), used_weapon = tool)

	for(var/obj/item/organ/internal/I in affected.internal_organs)
		if(I && I.damage > 0 && !BP_IS_ROBOTIC(I) && (I.surface_accessible || affected.open() >= (affected.encased ? 3 : 2)))
			I.take_internal_damage(dam_amt, 0)

//////////////////////////////////////////////////////////////////
//	 Organ detatchment surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/internal/detatch_organ

	allowed_tools = list(
	/obj/item/weapon/scalpel = 100,	\
	/obj/item/weapon/material/knife = 75,	\
	/obj/item/weapon/material/kitchen/utensil/knife = 75,	\
	/obj/item/weapon/material/shard = 50
	)

	duration = CUT_DURATION * 1.75

/datum/surgery_step/internal/detatch_organ/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return FALSE

	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	if(BP_IS_ROBOTIC(affected))
		return FALSE

	if(target.op_stage.current_organ)
		to_chat(user, SPAN("warning", "You can't do this right now."))
		return SURGERY_FAILURE

	var/list/attached_organs = list()
	for(var/obj/item/organ/organ in target.internal_organs)
		if(organ && !(organ.status & ORGAN_CUT_AWAY) && organ.parent_organ == target_zone)
			var/image/img = image(icon = organ.icon, icon_state = organ.icon_state)
			img.overlays = organ.overlays
			img.transform *= 1.5
			img.pixel_y = -5
			img.pixel_x = 3
			attached_organs[organ] = img

	var/organ_to_remove = show_radial_menu(user, target, attached_organs, require_near = TRUE)

	if(!organ_to_remove || (user.get_active_hand().return_item() != tool))
		return FALSE
	if(target.op_stage.current_organ)
		to_chat(user, SPAN("warning", "You can't do this right now."))
		return SURGERY_FAILURE

	target.op_stage.current_organ = organ_to_remove

	return ..() && organ_to_remove

/datum/surgery_step/internal/detatch_organ/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts to separate [target]'s [target.op_stage.current_organ] with \the [tool].", \
	"You start to separate [target]'s [target.op_stage.current_organ] with \the [tool]." )
	target.custom_pain("Someone's ripping out your [target.op_stage.current_organ]!",100)
	..()

/datum/surgery_step/internal/detatch_organ/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message(SPAN("notice", "[user] has separated [target]'s [target.op_stage.current_organ] with \the [tool].") , \
	SPAN("notice", "You have separated [target]'s [target.op_stage.current_organ] with \the [tool]."))

	var/obj/item/organ/I = target.op_stage.current_organ
	if(istype(I))
		I.cut_away(I.owner)

/datum/surgery_step/internal/detatch_organ/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(SPAN("warning", "[user]'s hand slips, slicing an artery inside [target]'s [affected.name] with \the [tool]!"), \
	SPAN("warning", "Your hand slips, slicing an artery inside [target]'s [affected.name] with \the [tool]!"))
	affected.take_external_damage(rand(30,50), 0, (DAM_SHARP|DAM_EDGE), used_weapon = tool)

//////////////////////////////////////////////////////////////////
//	 Organ removal surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/internal/remove_organ
	priority = 2
	allowed_tools = list(
	/obj/item/weapon/hemostat = 100,	\
	/obj/item/weapon/wirecutters = 75,	\
	/obj/item/weapon/material/knife = 75,	\
	/obj/item/weapon/material/kitchen/utensil/fork = 20
	)

	duration = CLAMP_DURATION

/datum/surgery_step/internal/remove_organ/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return FALSE

	target.op_stage.current_organ = null

	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	if(target.op_stage.current_organ)
		to_chat(user, SPAN("warning", "You can't do this right now."))
		return SURGERY_FAILURE

	var/list/removable_organs = list()
	for(var/obj/item/organ/internal/I in affected.implants)
		if(I.status & ORGAN_CUT_AWAY)
			var/image/img = image(icon = I.icon, icon_state = I.icon_state)
			img.overlays = I.overlays
			img.transform *= 1.5
			img.pixel_y = -5
			img.pixel_x = 3
			removable_organs[I] = img

	var/organ_to_remove = show_radial_menu(user, target, removable_organs, require_near = TRUE)

	if(!organ_to_remove || (user.get_active_hand().return_item() != tool))
		return FALSE
	if(target.op_stage.current_organ)
		to_chat(user, SPAN("warning", "You can't do this right now."))
		return SURGERY_FAILURE

	target.op_stage.current_organ = organ_to_remove
	return ..()

/datum/surgery_step/internal/remove_organ/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts removing [target]'s [target.op_stage.current_organ] with \the [tool].", \
	"You start removing [target]'s [target.op_stage.current_organ] with \the [tool].")
	target.custom_pain("The pain in your [affected.name] is living hell!",100,affecting = affected)
	..()

/datum/surgery_step/internal/remove_organ/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message(SPAN("notice", "[user] has removed [target]'s [target.op_stage.current_organ] with \the [tool]."), \
	SPAN("notice", "You have removed [target]'s [target.op_stage.current_organ] with \the [tool]."))

	// Extract the organ!
	var/obj/item/organ/O = target.op_stage.current_organ
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(istype(O) && istype(affected))
		affected.implants -= O
		O.dropInto(target.loc)
		target.op_stage.current_organ = null
		if(!BP_IS_ROBOTIC(affected))
			playsound(target.loc, 'sound/effects/squelch1.ogg', 15, 1)
		else
			playsound(target.loc, 'sound/items/Ratchet.ogg', 50, 1)
	if(istype(O, /obj/item/organ/internal/mmi_holder))
		var/obj/item/organ/internal/mmi_holder/brain = O
		brain.transfer_and_delete()

	// Just in case somehow the organ we're extracting from an organic is an MMI
	if(istype(O, /obj/item/organ/internal/mmi_holder))
		var/obj/item/organ/internal/mmi_holder/brain = O
		brain.transfer_and_delete()

/datum/surgery_step/internal/remove_organ/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(SPAN("warning", "[user]'s hand slips, damaging [target]'s [affected.name] with \the [tool]!"), \
	SPAN("warning", "Your hand slips, damaging [target]'s [affected.name] with \the [tool]!"))
	affected.take_external_damage(20, used_weapon = tool)

//////////////////////////////////////////////////////////////////
//	 Organ inserting surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/internal/replace_organ
	allowed_tools = list(
	/obj/item/organ = 100
	)

	duration = ATTACH_DURATION

/datum/surgery_step/internal/replace_organ/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return FALSE

	var/obj/item/organ/internal/O = tool
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!affected)
		return FALSE

	if(!istype(O))
		return FALSE

	if(BP_IS_ROBOTIC(affected) && !BP_IS_ROBOTIC(O))
		to_chat(user, SPAN("danger", "You cannot install a naked organ into a robotic body."))
		return SURGERY_FAILURE

	if(!target.species)
		CRASH("Target ([target]) of surgery [type] has no species!")

	var/o_is = (O.gender == PLURAL) ? "are" : "is"
	var/o_a =  (O.gender == PLURAL) ? "" : "a "

	if(O.organ_tag == BP_POSIBRAIN && !target.species.has_organ[BP_POSIBRAIN])
		to_chat(user, SPAN("warning", "There's no place in [target] to fit \the [O.organ_tag]."))
		return SURGERY_FAILURE

	if(O.damage > (O.max_damage * 0.75))
		to_chat(user, SPAN("warning", "\The [O.name] [o_is] in no state to be transplanted."))
		return SURGERY_FAILURE
	if(O.w_class > affected.cavity_max_w_class)
		to_chat(user, SPAN("warning", "\The [O.name] [o_is] too big for [affected.cavity_name] cavity!"))
		return SURGERY_FAILURE

	var/obj/item/organ/internal/I = target.internal_organs_by_name[O.organ_tag]
	if(I && (I.parent_organ == affected.organ_tag || istype(O, /obj/item/organ/internal/stack)))
		to_chat(user, SPAN("warning", "\The [target] already has [o_a][O.name]."))
		return SURGERY_FAILURE

	var/used_volume = 0
	for(var/obj/item/implant in affected.implants)
		if(istype(implant, /obj/item/weapon/implant))
			continue
		used_volume += implant.get_storage_cost()
	for(var/obj/item/organ in affected.internal_organs)
		used_volume += organ.get_storage_cost()
	if((base_storage_capacity(affected.cavity_max_w_class) + affected.internal_organs_size) < used_volume + O.get_storage_cost())
		to_chat(user, SPAN("warning", "There isn't enough space left in [affected.name]"))
		return SURGERY_FAILURE

	return ..()

/datum/surgery_step/internal/replace_organ/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts transplanting \the [tool] into [target]'s [affected.name].", \
	"You start transplanting \the [tool] into [target]'s [affected.name].")
	target.custom_pain("Someone's rooting around in your [affected.name]!",100,affecting = affected)
	..()

/datum/surgery_step/internal/replace_organ/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(SPAN("notice", "[user] has transplanted \the [tool] into [target]'s [affected.name]."), \
	SPAN("notice", "You have transplanted \the [tool] into [target]'s [affected.name]."))
	var/obj/item/organ/O = tool
	if(istype(O))
		user.remove_from_mob(O)
		O.forceMove(target)
		target.update_deformities()
		affected.implants |= O //move the organ into the patient. The organ is properly reattached in the next step
		if(!(O.status & ORGAN_CUT_AWAY))
			log_debug("[user] ([user.ckey]) replaced organ [O], which didn't have ORGAN_CUT_AWAY set, in [target] ([target.ckey])")
			O.status |= ORGAN_CUT_AWAY

		playsound(target.loc, 'sound/effects/squelch1.ogg', 15, 1)

/datum/surgery_step/internal/replace_organ/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message(SPAN("warning", "[user]'s hand slips, damaging \the [tool]!"), \
	SPAN("warning", "Your hand slips, damaging \the [tool]!"))
	var/obj/item/organ/internal/I = tool
	if(istype(I))
		I.take_internal_damage(rand(3,5), 0)

//////////////////////////////////////////////////////////////////
//	 Organ inserting surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/internal/attach_organ
	allowed_tools = list(
	/obj/item/weapon/FixOVein = 100,	\
	/obj/item/stack/cable_coil = 75,	\
	/obj/item/weapon/tape_roll = 50
	)

	duration = CONNECT_DURATION

/datum/surgery_step/internal/attach_organ/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return FALSE

	if(target.op_stage.current_organ)
		to_chat(user, SPAN("warning", "You can't do this right now."))
		return FALSE

	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(BP_IS_ROBOTIC(affected))
		// robotic attachment handled via screwdriver
		return FALSE

	var/list/attachable_organs = list()
	for(var/obj/item/organ/I in affected.implants)
		if(I && (I.status & ORGAN_CUT_AWAY))
			var/image/img = image(icon = I.icon, icon_state = I.icon_state)
			img.overlays = I.overlays
			img.transform *= 1.5
			img.pixel_y = -5
			img.pixel_x = 3
			attachable_organs[I] = img

	var/obj/item/organ/organ_to_replace = show_radial_menu(user, target, attachable_organs, require_near = TRUE)

	if(!organ_to_replace || (user.get_active_hand().return_item() != tool))
		return FALSE
	if(target.op_stage.current_organ)
		to_chat(user, SPAN("warning", "You can't do this right now."))
		return SURGERY_FAILURE
	if(organ_to_replace.parent_organ != affected.organ_tag)
		to_chat(user, SPAN("warning", "You can't find anywhere to attach [organ_to_replace] to!"))
		return SURGERY_FAILURE

	target.op_stage.current_organ = organ_to_replace
	return ..()

/datum/surgery_step/internal/attach_organ/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] begins reattaching [target]'s [target.op_stage.current_organ] with \the [tool].", \
	"You start reattaching [target]'s [target.op_stage.current_organ] with \the [tool].")
	target.custom_pain("Someone's digging needles into your [target.op_stage.current_organ]!",100)
	..()

/datum/surgery_step/internal/attach_organ/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message(SPAN("notice", "[user] has reattached [target]'s [target.op_stage.current_organ] with \the [tool].") , \
	SPAN("notice", "You have reattached [target]'s [target.op_stage.current_organ] with \the [tool]."))

	var/obj/item/organ/I = target.op_stage.current_organ
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(istype(I) && I.parent_organ == target_zone && affected && (I in affected.implants))
		I.status &= ~ORGAN_CUT_AWAY //apply fixovein
		affected.implants -= I
		I.replaced(target, affected)
		target.update_deformities()

/datum/surgery_step/internal/attach_organ/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(SPAN("warning", "[user]'s hand slips, damaging the flesh in [target]'s [affected.name] with \the [tool]!"), \
	SPAN("warning", "Your hand slips, damaging the flesh in [target]'s [affected.name] with \the [tool]!"))
	affected.take_external_damage(20, used_weapon = tool)

//////////////////////////////////////////////////////////////////
//	 Peridaxon destroyed organ restoration surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/internal/treat_necrosis
	priority = 2
	allowed_tools = list(
		/obj/item/weapon/reagent_containers/dropper = 100, 	\
		/obj/item/weapon/reagent_containers/glass/bottle = 75,	\
		/obj/item/weapon/reagent_containers/glass/beaker = 75,	\
		/obj/item/weapon/reagent_containers/spray = 50,	\
		/obj/item/weapon/reagent_containers/glass/bucket = 50
	)

	can_infect = 0
	blood_level = 0

	duration = ORGAN_FIX_DURATION * 0.75

/datum/surgery_step/internal/treat_necrosis/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/weapon/reagent_containers/container = tool
	if(!istype(container) || !container.reagents.has_reagent(/datum/reagent/peridaxon))
		return 0
	if (!..())
		return 0

	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	if(BP_IS_ROBOTIC(affected))
		return 0

	if(target.op_stage.current_organ)
		to_chat(user, SPAN("warning", "You can't do this right now."))
		return SURGERY_FAILURE

	var/obj/item/organ/internal/list/dead_organs = list()
	for(var/obj/item/organ/internal/I in target.internal_organs)
		if(I && !(I.status & ORGAN_CUT_AWAY) && I.status & ORGAN_DEAD && I.parent_organ == affected.organ_tag && !BP_IS_ROBOTIC(I))
			var/image/img = image(icon = I.icon, icon_state = I.icon_state)
			img.overlays = I.overlays
			img.transform *= 1.5
			img.pixel_y = -5
			img.pixel_x = 3
			dead_organs[I] = img

	var/obj/item/organ/internal/organ_to_fix = show_radial_menu(user, target, dead_organs, require_near = TRUE)

	if(!organ_to_fix || (user.get_active_hand().return_item() != tool))
		return 0
	if(target.op_stage.current_organ)
		to_chat(user, SPAN("warning", "You can't do this right now."))
		return SURGERY_FAILURE
	if(!organ_to_fix.can_recover() && istype(organ_to_fix, /obj/item/organ/internal/brain))
		to_chat(user, SPAN("warning", "The [organ_to_fix.name] is destroyed and can't be saved."))
		return SURGERY_FAILURE

	target.op_stage.current_organ = organ_to_fix

	return 1

/datum/surgery_step/internal/treat_necrosis/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts applying medication to the affected tissue in [target]'s [target.op_stage.current_organ] with \the [tool]." , \
	"You start applying medication to the affected tissue in [target]'s [target.op_stage.current_organ] with \the [tool].")

	target.custom_pain("Something in your [target.op_stage.current_organ] is causing you a lot of pain!",50,affecting = target.op_stage.current_organ)
	..()

/datum/surgery_step/internal/treat_necrosis/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/internal/affected = target.op_stage.current_organ
	var/obj/item/weapon/reagent_containers/container = tool

	var/amount = container.amount_per_transfer_from_this
	var/datum/reagents/temp_reagents = new(amount, GLOB.temp_reagents_holder)
	container.reagents.trans_to_holder(temp_reagents, amount)

	var/rejuvenate = temp_reagents.has_reagent(/datum/reagent/peridaxon)

	var/trans = temp_reagents.trans_to_mob(target, temp_reagents.total_volume, CHEM_BLOOD) //technically it's contact, but the reagents are being applied to internal tissue
	if (trans > 0)
		if(rejuvenate)
			if(affected.can_recover())
				affected.damage = 0
				affected.status &= ~ORGAN_DEAD
				affected.owner.update_body(1)
			else
				affected.damage = affected.min_broken_damage
				affected.death_time = 0
				affected.owner.update_body(1)

		user.visible_message(SPAN("notice", "[user] applies [trans] unit\s of the solution to affected tissue in [target]'s [affected.name]"), \
			SPAN("notice", "You apply [trans] unit\s of the solution to affected tissue in [target]'s [affected.name] with \the [tool]."))
	qdel(temp_reagents)

/datum/surgery_step/internal/treat_necrosis/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	if (!istype(tool, /obj/item/weapon/reagent_containers))
		return

	var/obj/item/weapon/reagent_containers/container = tool

	var/trans = container.reagents.trans_to_mob(target, container.amount_per_transfer_from_this, CHEM_BLOOD)

	user.visible_message(SPAN("warning", "[user]'s hand slips, applying [trans] units of the solution to the wrong place in [target]'s [affected.name] with the [tool]!") , \
	SPAN("warning", "Your hand slips, applying [trans] units of the solution to the wrong place in [target]'s [affected.name] with the [tool]!"))

	//no damage or anything, just wastes medicine
