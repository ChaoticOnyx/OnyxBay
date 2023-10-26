/**
 * Default generic step, does nothing.
 */
/datum/surgery_step/generic
	can_infect = TRUE
	shock_level = 10
	/// Whether parent organ is required not to be a stump.
	var/check_stump = TRUE

/datum/surgery_step/generic/check_zone(target_zone)
	return ..() && target_zone != BP_EYES

/datum/surgery_step/generic/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	. = ..()
	if(!.)
		return .

	if(check_stump && parent_organ.is_stump())
		return FALSE

	return !BP_IS_ROBOTIC(parent_organ)

/datum/surgery_step/generic/check_target_organ(obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	return TRUE

/**
 * Cauterizes incision.
 */
/datum/surgery_step/generic/cauterize
	allowed_tools = list(
		/obj/item/cautery = 100,
		/obj/item/clothing/mask/smokable/cigarette = 75,
		/obj/item/flame/lighter = 50,
		/obj/item/weldingtool = 25,
		/obj/item/hothands = 20
		)

	duration = CAUTERIZE_DURATION
	check_stump = FALSE

/datum/surgery_step/generic/cauterize/check_zone(target_zone)
	return (..() && target_zone != BP_MOUTH)

/datum/surgery_step/generic/cauterize/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	. = ..()
	if(!.)
		return .

	if(!parent_organ.get_incision(TRUE))
		target.show_splash_text(user, "no incisions that can be closed cleanly!")
		return SURGERY_FAILURE

	if(parent_organ.is_stump())
		return parent_organ.status & ORGAN_ARTERY_CUT

	return parent_organ.open()

/datum/surgery_step/generic/cauterize/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	var/datum/wound/cut/W = parent_organ.get_incision()
	announce_preop(user,
		"[user] is beginning to cauterize[W ? " \a [W.desc] on" : ""] \the [target]'s [parent_organ] with \the [tool].",
		"You are beginning to cauterize[W ? " \a [W.desc] on" : ""] \the [target]'s [parent_organ] with \the [tool]."
		)
	target.custom_pain(
		"Your [parent_organ] is being burned!",
		40,
		affecting = parent_organ
		)
	return ..()

/datum/surgery_step/generic/cauterize/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	var/datum/wound/cut/W = parent_organ.get_incision()
	announce_success(user,
		"[user] cauterizes[W ? " \a [W.desc] on" : ""] \the [target]'s [parent_organ] with \the [tool].",
		"You cauterize[W ? " \a [W.desc] on" : ""] \the [target]'s [parent_organ] with \the [tool]."
		)
	if(parent_organ.clamped())
		parent_organ.remove_clamps()
	if(parent_organ.is_stump())
		parent_organ.status &= ~ORGAN_ARTERY_CUT
	W?.close()

/datum/surgery_step/generic/cauterize/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_failure(user,
		"[user]'s hand slips, leaving a small burn on [target]'s [parent_organ] with \the [tool]!",
		"Your hand slips, leaving a small burn on [target]'s [parent_organ] with \the [tool]!"
		)
	parent_organ.take_external_damage(0, 3, used_weapon = tool)

/**
 * Default incision creation step, does nothing.
 */
/datum/surgery_step/generic/cut
	duration = CUT_DURATION

/datum/surgery_step/generic/cut/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	return (..() && !parent_organ.open())

/**
 * Default icision with scalpel, nothing extra.
 */
/datum/surgery_step/generic/cut/default
	allowed_tools = list(
		/obj/item/scalpel = 100,
		/obj/item/material/knife = 75,
		/obj/item/material/kitchen/utensil/knife = 75,
		/obj/item/broken_bottle = 50,
		/obj/item/material/shard = 50
		)

/datum/surgery_step/generic/cut/default/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_preop(user,
		"[user] starts the incision on [target]'s [parent_organ] with \the [tool].",
		"You start the incision on [target]'s [parent_organ] with \the [tool]."
		)
	target.custom_pain(
		"You feel a horrible pain as if from a sharp knife in your [parent_organ]!",
		40,
		affecting = parent_organ
		)
	return ..()

/datum/surgery_step/generic/cut/default/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_success(user,
		"[user] has made an incision on [target]'s [parent_organ] with \the [tool].",
		"You have made an incision on [target]'s [parent_organ] with \the [tool]."
		)
	parent_organ.createwound(CUT, parent_organ.min_broken_damage / 2, 1)
	playsound(target.loc, 'sound/weapons/bladeslice.ogg', 15, 1)

/datum/surgery_step/generic/cut/default/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_failure(user,
		"[user]'s hand slips, slicing open [target]'s [parent_organ] in the wrong place with \the [tool]!",
		"Your hand slips, slicing open [target]'s [parent_organ] in the wrong place with \the [tool]!"
		)
	parent_organ.take_external_damage(
		10,
		0,
		(DAM_SHARP|DAM_EDGE),
		used_weapon = tool
		)

/**
 * Incision made with laser scalpel, clamps bleeders.
 */
/datum/surgery_step/generic/cut/laser
	priority = 2

	allowed_tools = list(
		/obj/item/scalpel/laser3 = 100,
		/obj/item/scalpel/laser2 = 100,
		/obj/item/scalpel/laser1 = 100,
		/obj/item/melee/energy/sword/one_hand = 50
		)

/datum/surgery_step/generic/cut/laser/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_preop(user,
		"[user] starts the bloodless incision on [target]'s [parent_organ] with \the [tool].",
		"You start the bloodless incision on [target]'s [parent_organ] with \the [tool]."
		)
	target.custom_pain(
		"You feel a horrible, searing pain in your [parent_organ]!",
		50,
		affecting = parent_organ
		)
	return ..()

/datum/surgery_step/generic/cut/laser/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_success(user,
		"[user] has made a bloodless incision on [target]'s [parent_organ] with \the [tool].",
		"You have made a bloodless incision on [target]'s [parent_organ] with \the [tool].",
		)
	parent_organ.createwound(CUT, parent_organ.min_broken_damage / 2, 1)
	parent_organ.clamp_organ()
	spread_germs_to_organ(user, parent_organ)

/datum/surgery_step/generic/cut/laser/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_failure(user,
		"[user]'s hand slips as the blade sputters, searing a long gash in [target]'s [parent_organ] with \the [tool]!",
		"Your hand slips as the blade sputters, searing a long gash in [target]'s [parent_organ] with \the [tool]!"
		)
	parent_organ.take_external_damage(
		15,
		5,
		(DAM_SHARP|DAM_EDGE),
		used_weapon = tool
		)

/**
 * Incision made using incision manager, clamps bleeders and retracts skin.
 */
/datum/surgery_step/generic/incision_manager
	priority = 2
	duration = CUT_DURATION

	allowed_tools = list(
		/obj/item/scalpel/manager = 100
		)

/datum/surgery_step/generic/incision_manager/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	return (..() && (parent_organ.open() == SURGERY_CLOSED || parent_organ.open() == SURGERY_OPEN))

/datum/surgery_step/generic/incision_manager/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	if(parent_organ.open() == SURGERY_CLOSED)
		announce_preop(user,
		"[user] starts to construct a prepared incision on [target]'s [parent_organ] with \the [tool].",
		"You carefully start incision on [target]'s [parent_organ], while \the [tool] makes all the side work for you."
		)
	else
		announce_preop(user,
		"[user] starts sliding \the [tool] above the cut on [target]'s [parent_organ].",
		"You carefully start sliding \the [tool] above the cut on [target]'s [parent_organ], while it makes all the side work for you."
		)
	target.custom_pain(
		"You feel a horrible, searing pain in your [parent_organ] as it is pushed apart!",
		50,
		affecting = parent_organ
		)
	return ..()

/datum/surgery_step/generic/incision_manager/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_success(user,
		"[user] has constructed a prepared incision on [target]'s [parent_organ] with \the [tool].",
		"You have constructed a prepared incision on [target]'s [parent_organ] with \the [tool]."
		)
	if(parent_organ.open() == SURGERY_CLOSED)
		parent_organ.createwound(CUT, parent_organ.min_broken_damage / 2, 1)
	parent_organ.clamp_organ()
	parent_organ.open_incision()

/datum/surgery_step/generic/incision_manager/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_failure(user,
		"[user]'s hand jolts as the system sparks, ripping a gruesome hole in [target]'s [parent_organ] with \the [tool]!",
		"Your hand jolts as the system sparks, ripping a gruesome hole in [target]'s [parent_organ] with \the [tool]!"
		)
	parent_organ.take_external_damage(
		20,
		15,
		(DAM_SHARP|DAM_EDGE),
		used_weapon = tool
		)

/**
 * Clamps bleeders.
 */
/datum/surgery_step/generic/clamp_bleeders
	duration = CLAMP_DURATION

	allowed_tools = list(
		/obj/item/hemostat = 100,
		/obj/item/stack/cable_coil = 75,
		/obj/item/device/assembly/mousetrap = 20
		)

/datum/surgery_step/generic/clamp_bleeders/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	return (..() && parent_organ.open() && !parent_organ.clamped())

/datum/surgery_step/generic/clamp_bleeders/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_preop(user,
		"[user] starts clamping bleeders in [target]'s [parent_organ] with \the [tool].",
		"You start clamping bleeders in [target]'s [parent_organ] with \the [tool]."
		)
	target.custom_pain(
		"The pain in your [parent_organ] is maddening!",
		40,
		affecting = parent_organ
		)
	return ..()

/datum/surgery_step/generic/clamp_bleeders/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_success(user,
		"[user] clamps bleeders in [target]'s [parent_organ] with \the [tool].",
		"You clamp bleeders in [target]'s [parent_organ] with \the [tool]."
		)
	parent_organ.clamp_organ()
	spread_germs_to_organ(user, parent_organ)

/datum/surgery_step/generic/clamp_bleeders/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_failure(user,
		"[user]'s hand slips, tearing blood vessals and causing massive bleeding in [target]'s [parent_organ] with \the [tool]!",
		"Your hand slips, tearing blood vessels and causing massive bleeding in [target]'s [parent_organ] with \the [tool]!"
		)
	parent_organ.take_external_damage(
		10,
		0,
		(DAM_SHARP|DAM_EDGE),
		used_weapon = tool
		)

/**
 * Retracts skin around incision.
 */
/datum/surgery_step/generic/retract_skin
	allowed_tools = list(
		/obj/item/retractor = 100,
		/obj/item/crowbar = 75,
		/obj/item/material/knife = 50,
		/obj/item/material/kitchen/utensil/fork = 50
		)

	priority = 1
	duration = RETRACT_DURATION

/datum/surgery_step/generic/retract_skin/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	return (..() && parent_organ.open() == SURGERY_OPEN)

/datum/surgery_step/generic/retract_skin/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_preop(user,
		"[user] starts to pry open the incision on [target]'s [parent_organ] with \the [tool].",
		"You start to pry open the incision on [target]'s [parent_organ] with \the [tool]."
		)
	target.custom_pain(
		"It feels like the skin on your [parent_organ] is on fire!",
		40,
		affecting = parent_organ
		)
	return ..()

/datum/surgery_step/generic/retract_skin/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_success(user,
		"[user] keeps the incision open on [target]'s [parent_organ] with \the [tool].",
		"You keep the incision open on [target]'s [parent_organ] with \the [tool]."
		)
	parent_organ.open_incision()

/datum/surgery_step/generic/retract_skin/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_failure(user,
		"[user]'s hand slips, tearing the edges of the incision on [target]'s [parent_organ] with \the [tool]!",
		"Your hand slips, tearing the edges of the incision on [target]'s [parent_organ] with \the [tool]!"
		)
	parent_organ.take_external_damage(
		12,
		0,
		(DAM_SHARP|DAM_EDGE),
		used_weapon = tool
		)

/**
 * Saws off bones, covering interal organs.
 */
/datum/surgery_step/generic/saw
	delicate = TRUE
	blood_level = BLOODY_HANDS
	shock_level = 40
	priority = 2
	duration = SAW_DURATION

	allowed_tools = list(
		/obj/item/circular_saw = 100,
		/obj/item/material/knife = 50,
		/obj/item/material/hatchet = 75
		)

/datum/surgery_step/generic/saw/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	return (..() && parent_organ.open() == SURGERY_RETRACTED)

/datum/surgery_step/generic/saw/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_preop(user,
		"[user] begins to cut through [target]'s [parent_organ.encased] with \the [tool].",
		"You begin to cut through [target]'s [parent_organ.encased] with \the [tool]."
		)
	target.custom_pain(
		"Something hurts horribly in your [parent_organ]!",
		60,
		affecting = parent_organ
		)
	return ..()

/datum/surgery_step/generic/saw/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_success(user,
		"[user] has cut [target]'s [parent_organ.encased] open with \the [tool].",
		"You have cut [target]'s [parent_organ.encased] open with \the [tool]."
		)
	parent_organ.fracture()

/datum/surgery_step/generic/saw/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_failure(user,
		"[user]'s hand slips, cracking [target]'s [parent_organ.encased] with \the [tool]!" ,
		"Your hand slips, cracking [target]'s [parent_organ.encased] with \the [tool]!"
		)
	parent_organ.take_external_damage(
		15,
		0,
		(DAM_SHARP|DAM_EDGE),
		used_weapon = tool
		)
	parent_organ.fracture()

/**
 * Amputates limb.
 */
/datum/surgery_step/generic/amputate
	duration = AMPUTATION_DURATION
	check_stump = FALSE

	allowed_tools = list(
		/obj/item/circular_saw = 100,
		/obj/item/material/hatchet = 75,
		/obj/item/material/twohanded/fireaxe = 85,
		/obj/item/gun/energy/plasmacutter = 90
		)

/datum/surgery_step/generic/amputate/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	. = ..()
	if(!.)
		return

	if(parent_organ.open())
		target.show_splash_text(user, "can't get a clean cut due to present incisions!")
		return SURGERY_FAILURE

	return parent_organ.limb_flags & ORGAN_FLAG_CAN_AMPUTATE

/datum/surgery_step/generic/amputate/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
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

/datum/surgery_step/generic/amputate/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_success(user,
		"[user] amputates [target]'s [parent_organ] at the [parent_organ.amputation_point] with \the [tool].",
		"You amputate [target]'s [parent_organ] with \the [tool]."
		)
	parent_organ.droplimb(TRUE, DROPLIMB_EDGE)

/datum/surgery_step/generic/amputate/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_failure(user,
		"[user]'s hand slips, sawing through the bone in [target]'s [parent_organ] with \the [tool]!",
		"Your hand slips, sawwing through the bone in [target]'s [parent_organ] with \the [tool]!"
		)
	parent_organ.take_external_damage(30, 0, (DAM_SHARP|DAM_EDGE), used_weapon = tool)
	parent_organ.fracture()

/datum/surgery_step/generic/amputate/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
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
