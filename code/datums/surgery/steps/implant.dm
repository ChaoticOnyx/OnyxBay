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
		50,
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
		50,
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
		target.show_splash_text(user, "tool is too big!", "\The [tool] is too big to fit inside!")
		return SURGERY_FAILURE

	var/total_volume = tool.get_storage_cost()
	for(var/obj/item/I in parent_organ.implants)
		if(istype(I, /obj/item/implant))
			continue

		total_volume += I.get_storage_cost()

	if(total_volume > max_volume)
		target.show_splash_text(user, "not enough space!", "There's not enough space!")
		return FALSE

	return TRUE

/datum/surgery_step/cavity/place_item/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	announce_preop(user,
		"[user] starts putting \the [tool] inside [target]'s [parent_organ.cavity_name] cavity.",
		"You start putting \the [tool] inside [target]'s [parent_organ.cavity_name] cavity."
		)
	target.custom_pain(
		"The pain in your chest is living hell!",
		50,
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
	var/list/selected_loot_by_user = list()

	allowed_tools = list(
		/obj/item/hemostat = 100,
		/obj/item/wirecutters = 75,
		/obj/item/material/kitchen/utensil/fork = 20
		)

	preop_sound = 'sound/surgery/hemostat1.ogg'
	success_sound = 'sound/effects/squelch1.ogg'
	failure_sound = 'sound/surgery/organ2.ogg'

/datum/surgery_step/cavity/implant_removal/proc/get_selection_key(atom/user, obj/item/organ/external/parent_organ)
	if(!user || !parent_organ)
		return null
	return "\ref[user]:\ref[parent_organ]"

/datum/surgery_step/cavity/implant_removal/proc/clear_selected_loot(atom/user, obj/item/organ/external/parent_organ)
	var/key = get_selection_key(user, parent_organ)
	if(!key)
		return
	selected_loot_by_user -= key

/datum/surgery_step/cavity/implant_removal/proc/build_loot_list(obj/item/organ/external/parent_organ)
	var/exposed = FALSE
	if(BP_IS_ROBOTIC(parent_organ) && parent_organ.hatch_state == HATCH_OPENED)
		exposed = TRUE
	else if(parent_organ.open() >= (parent_organ.encased ? SURGERY_ENCASED : SURGERY_RETRACTED))
		exposed = TRUE

	var/find_prob = 0
	var/list/atom/loot = list()
	if(exposed)
		loot = parent_organ.implants.Copy()
	else
		for(var/datum/wound/W in parent_organ.wounds)
			if(LAZYLEN(W.embedded_objects))
				loot |= W.embedded_objects
			find_prob += 50

	var/attached_augmentations = 0
	for(var/obj/item/organ_module/module in loot.Copy())
		if(module.surgically_attached)
			loot -= module
			attached_augmentations++

	return list(
		"exposed" = exposed,
		"find_prob" = find_prob,
		"loot" = loot,
		"attached_augmentations" = attached_augmentations
	)

/datum/surgery_step/cavity/implant_removal/proc/get_loot_find_prob(obj/item/organ/external/parent_organ, obj/item/implanted_item, base_prob)
	. = base_prob
	if(istype(implanted_item, /obj/item/implant))
		var/obj/item/implant/I = implanted_item
		. += I.islegal() ? 60 : 40
	else if(istype(implanted_item, /obj/item/organ_module))
		var/list/data = build_loot_list(parent_organ)
		. += (data["exposed"] ? 100 : 50)
	else
		. += 50

/datum/surgery_step/cavity/implant_removal/proc/get_selected_loot(atom/user, obj/item/organ/external/parent_organ)
	if(!user || !parent_organ)
		return null
	var/key = get_selection_key(user, parent_organ)
	if(!key)
		return null
	var/obj/item/selected = selected_loot_by_user[key]
	if(!istype(selected) || QDELETED(selected))
		return null

	var/list/data = build_loot_list(parent_organ)
	var/list/loot = data["loot"]
	if(!(selected in loot))
		return null
	return selected

/datum/surgery_step/cavity/implant_removal/pick_target_organ(atom/user, mob/living/carbon/human/target, target_zone)
	var/obj/item/organ/external/parent_organ = target.get_organ(get_parent_zone(target_zone))
	if(!istype(parent_organ))
		return null
	clear_selected_loot(user, parent_organ)

	var/list/data = build_loot_list(parent_organ)
	var/list/loot = data["loot"]
	if(!length(loot))
		return parent_organ

	var/list/radial_loot_choices = list()
	for(var/obj/item/I in loot)
		if(istype(I, /obj/item/organ_module))
			var/obj/item/organ_module/module = I
			radial_loot_choices[I] = adjust_augment_image(module)
		else
			radial_loot_choices[I] = make_item_radial_menu_button(I)

	var/obj/item/selected = null
	if(length(radial_loot_choices) == 1)
		for(var/obj/item/I in radial_loot_choices)
			selected = I
			break
	else
		selected = show_radial_menu(user, target, radial_loot_choices, require_near = TRUE)
		if(!istype(selected))
			return null

	selected_loot_by_user[get_selection_key(user, parent_organ)] = selected
	return parent_organ

/datum/surgery_step/cavity/implant_removal/check_target_organ(obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	. = ..()
	if(!.)
		return

	var/obj/item/organ/external/parent_organ = target_organ
	if(!istype(parent_organ))
		return FALSE

	var/list/data = build_loot_list(parent_organ)
	var/list/loot = data["loot"]
	if(!length(loot))
		return TRUE

	var/obj/item/selected = get_selected_loot(user, parent_organ)
	if(!selected)
		clear_selected_loot(user, parent_organ)
		return FALSE
	return TRUE

/datum/surgery_step/cavity/implant_removal/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	var/obj/item/selected = get_selected_loot(user, parent_organ)
	if(selected)
		announce_preop(user,
			"[user] starts removing [selected] from [target]'s [parent_organ] with \the [tool].",
			"You start removing [selected] from [target]'s [parent_organ] with \the [tool]."
			)
	else
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
	var/list/data = build_loot_list(parent_organ)
	var/find_prob = data["find_prob"]
	var/list/loot = data["loot"]

	if(!length(loot))
		clear_selected_loot(user, parent_organ)
		announce_success(user,
			"[user] could not find anything inside [target]'s [parent_organ], and pulls \the [tool] out.",
			"You could not find anything inside [target]'s [parent_organ]."
			)
		return

	var/obj/item/implanted_item = get_selected_loot(user, parent_organ)
	clear_selected_loot(user, parent_organ)
	if(!implanted_item)
		if(length(loot) == 1)
			implanted_item = loot[1]
		else
			announce_success(user,
				"[user] removes \the [tool] from [target]'s [parent_organ].",
				"There's something inside [target]'s [parent_organ], but you just missed it this time."
				)
			return

	find_prob = get_loot_find_prob(parent_organ, implanted_item, find_prob)

	if(prob(find_prob))
		announce_success(user,
			"[user] takes something out of incision on [target]'s [parent_organ] with \the [tool].",
			"You take [implanted_item] out of incision on [target]'s [parent_organ]s with \the [tool]."
			)
		for(var/datum/wound/wound in parent_organ.wounds)
			if(implanted_item in wound.embedded_objects)
				wound.embedded_objects -= implanted_item
				break

		BITSET(target.hud_updateflag, IMPLOYAL_HUD)

		if(istype(implanted_item, /obj/item/organ_module))
			var/obj/item/organ_module/module = implanted_item
			module.remove(parent_organ)
			module.add_blood(target)
			module.update_icon()
		else
			parent_organ.implants -= implanted_item
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
	clear_selected_loot(user, parent_organ)
	. = ..()
	for(var/obj/item/implant/I in parent_organ.implants)
		if(prob(10 + 100 - get_tool_quality(tool)))
			user.visible_message("Something beeps inside [target]'s [parent_organ]!")
			spawn(25)
				I.activate()

/**
 * Installing organ modules
 */
/datum/surgery_step/cavity/place_organ_module
	duration = ATTACH_DURATION

	allowed_tools = list(
		/obj/item/organ_module = 100
		)

	preop_sound = 'sound/surgery/organ1.ogg'
	success_sound = 'sound/surgery/organ2.ogg'
	failure_sound = 'sound/effects/fighting/crunch1.ogg'

/datum/surgery_step/cavity/place_organ_module/check_parent_organ(obj/item/organ/parent_organ, mob/living/carbon/human/target, obj/item/organ_module/tool, atom/user)
	. = ..()
	if(!.)
		return

	if(issilicon(user))
		return FALSE

	if(!tool.can_install_in(parent_organ, user))
		return SURGERY_FAILURE

	return TRUE

/datum/surgery_step/cavity/place_organ_module/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/organ_module/tool, mob/user)
	announce_preop(user,
		"[user] starts putting \the [tool] inside [target]'s [parent_organ.cavity_name] cavity.",
		"You start putting \the [tool] inside [target]'s [parent_organ.cavity_name] cavity."
		)
	target.custom_pain(
		"The pain in your chest is living hell!",
		50,
		affecting = parent_organ
		)
	playsound(target.loc, 'sound/effects/squelch1.ogg', 25, 1)
	return ..()

/datum/surgery_step/cavity/place_organ_module/success(obj/item/organ/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/organ_module/tool, mob/user)
	if(!user.drop(tool, parent_organ))
		return

	announce_success(user,
		"[user] puts \the [tool] inside [target]'s [parent_organ], leaving it disconnected.",
		"You put \the [tool] inside [target]'s [parent_organ], but it still needs to be connected."
		)
	tool.surgical_insert(parent_organ)

/**
 * Attaches previously inserted organ module with FixOVein.
 */
/datum/surgery_step/cavity/attach_organ_module
	duration = CONNECT_DURATION
	priority = 3
	var/list/selected_module_by_user = list()

	allowed_tools = list(
		/obj/item/FixOVein = 100
	)

	preop_sound = 'sound/surgery/hemostat1.ogg'
	success_sound = 'sound/surgery/hemostat.ogg'
	failure_sound = 'sound/surgery/organ2.ogg'

/datum/surgery_step/cavity/attach_organ_module/proc/get_selection_key(atom/user, obj/item/organ/external/parent_organ)
	if(!user || !parent_organ)
		return null
	return "\ref[user]:\ref[parent_organ]"

/datum/surgery_step/cavity/attach_organ_module/proc/clear_selected_module(atom/user, obj/item/organ/external/parent_organ)
	var/key = get_selection_key(user, parent_organ)
	if(!key)
		return
	selected_module_by_user -= key

/datum/surgery_step/cavity/attach_organ_module/proc/get_attachable_modules(obj/item/organ/external/parent_organ)
	. = list()
	for(var/obj/item/organ_module/module in parent_organ.implants)
		if(!module.surgically_attached)
			. += module

/datum/surgery_step/cavity/attach_organ_module/proc/get_selected_module(atom/user, obj/item/organ/external/parent_organ)
	if(!user || !parent_organ)
		return null
	var/key = get_selection_key(user, parent_organ)
	if(!key)
		return null
	var/obj/item/organ_module/selected = selected_module_by_user[key]
	if(!istype(selected) || QDELETED(selected) || !(selected in parent_organ.implants) || selected.surgically_attached)
		return null
	return selected

/datum/surgery_step/cavity/attach_organ_module/pick_target_organ(atom/user, mob/living/carbon/human/target, target_zone)
	var/obj/item/organ/external/parent_organ = target.get_organ(get_parent_zone(target_zone))
	if(!istype(parent_organ))
		return null
	clear_selected_module(user, parent_organ)

	var/list/attachable_modules = list()
	for(var/obj/item/organ_module/module in parent_organ.implants)
		if(!module.surgically_attached)
			attachable_modules[module] = adjust_augment_image(module)

	for(var/obj/item/organ/O in parent_organ.implants)
		if(O.parent_organ != get_parent_zone(target_zone))
			continue
		if(O.status & ORGAN_CUT_AWAY)
			attachable_modules[O] = adjust_organ_image(O)

	if(!length(attachable_modules))
		return null

	var/selected = null
	if(length(attachable_modules) == 1)
		for(var/obj/item/I in attachable_modules)
			selected = I
			break
	else
		selected = show_radial_menu(user, target, attachable_modules, require_near = TRUE)
		if(istype(selected, /obj/item/organ))
			return null
		if(!istype(selected, /obj/item/organ_module))
			return null

	if(istype(selected, /obj/item/organ))
		return null

	selected_module_by_user[get_selection_key(user, parent_organ)] = selected
	return parent_organ

/datum/surgery_step/cavity/attach_organ_module/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	. = ..()
	if(!.)
		return

	return length(get_attachable_modules(parent_organ))

/datum/surgery_step/cavity/attach_organ_module/check_target_organ(obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	. = ..()
	if(!.)
		return

	var/obj/item/organ/external/parent_organ = target_organ
	if(!istype(parent_organ))
		return FALSE

	var/obj/item/organ_module/selected = get_selected_module(user, parent_organ)
	if(!selected)
		clear_selected_module(user, parent_organ)
		return FALSE
	return TRUE

/datum/surgery_step/cavity/attach_organ_module/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	var/obj/item/organ_module/selected = get_selected_module(user, parent_organ)
	if(!selected)
		clear_selected_module(user, parent_organ)
		return SURGERY_FAILURE

	announce_preop(user,
		"[user] starts connecting [selected.name] inside [target]'s [parent_organ.name] with \the [tool].",
		"You start connecting [selected.name] inside [target]'s [parent_organ.name] with \the [tool]."
		)
	return ..()

/datum/surgery_step/cavity/attach_organ_module/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	var/obj/item/organ_module/selected = get_selected_module(user, parent_organ)
	clear_selected_module(user, parent_organ)
	if(!selected)
		return

	selected.surgical_attach(parent_organ)
	announce_success(user,
		"[user] connects [selected.name] inside [target]'s [parent_organ.name] with \the [tool].",
		"You connect [selected.name] inside [target]'s [parent_organ.name] with \the [tool]."
		)

/datum/surgery_step/cavity/attach_organ_module/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	var/obj/item/organ_module/selected = get_selected_module(user, parent_organ)
	var/module_name = selected ? selected.name : "augmentation"
	clear_selected_module(user, parent_organ)

	announce_failure(user,
		"[user]'s hand slips, damaging tissue while connecting [module_name] in [target]'s [parent_organ.name] with \the [tool]!",
		"Your hand slips, damaging tissue while connecting [module_name] in [target]'s [parent_organ.name] with \the [tool]!"
		)
	parent_organ.take_external_damage(10, used_weapon = tool)

/**
 * Detaches installed augmentation before extraction.
 */
/datum/surgery_step/cavity/detach_organ_module
	duration = DETACH_DURATION
	priority = 3
	var/list/selected_module_by_user = list()

	allowed_tools = list(
		/obj/item/scalpel = 100,
		/obj/item/material/knife = 75,
		/obj/item/material/kitchen/utensil/knife = 75,
		/obj/item/material/shard = 50
	)

	preop_sound = 'sound/surgery/scalpel1.ogg'
	success_sound = 'sound/surgery/scalpel2.ogg'
	failure_sound = 'sound/surgery/organ1.ogg'

/datum/surgery_step/cavity/detach_organ_module/proc/get_selection_key(atom/user, obj/item/organ/external/parent_organ)
	if(!user || !parent_organ)
		return null
	return "\ref[user]:\ref[parent_organ]"

/datum/surgery_step/cavity/detach_organ_module/proc/clear_selected_module(atom/user, obj/item/organ/external/parent_organ)
	var/key = get_selection_key(user, parent_organ)
	if(!key)
		return
	selected_module_by_user -= key

/datum/surgery_step/cavity/detach_organ_module/proc/get_detachable_modules(obj/item/organ/external/parent_organ)
	. = list()
	for(var/obj/item/organ_module/module in parent_organ.organ_modules)
		if(module.surgically_attached)
			. += module

/datum/surgery_step/cavity/detach_organ_module/proc/get_selected_module(atom/user, obj/item/organ/external/parent_organ)
	if(!user || !parent_organ)
		return null
	var/key = get_selection_key(user, parent_organ)
	if(!key)
		return null
	var/obj/item/organ_module/selected = selected_module_by_user[key]
	if(!istype(selected) || QDELETED(selected) || !(selected in parent_organ.organ_modules) || !selected.surgically_attached)
		return null
	return selected

/datum/surgery_step/cavity/detach_organ_module/pick_target_organ(atom/user, mob/living/carbon/human/target, target_zone)
	var/obj/item/organ/external/parent_organ = target.get_organ(get_parent_zone(target_zone))
	if(!istype(parent_organ))
		return null
	clear_selected_module(user, parent_organ)

	var/list/detachable_modules = list()
	for(var/obj/item/organ_module/module in parent_organ.organ_modules)
		if(module.surgically_attached)
			detachable_modules[module] = adjust_augment_image(module)

	for(var/obj/item/organ/O in target.internal_organs)
		if(O.parent_organ != get_parent_zone(target_zone))
			continue
		if(!(O.status & ORGAN_CUT_AWAY))
			detachable_modules[O] = adjust_organ_image(O)

	if(!length(detachable_modules))
		return null

	var/selected = null
	if(length(detachable_modules) == 1)
		for(var/obj/item/I in detachable_modules)
			selected = I
			break
	else
		selected = show_radial_menu(user, target, detachable_modules, require_near = TRUE)
		if(istype(selected, /obj/item/organ))
			return null
		if(!istype(selected, /obj/item/organ_module))
			return null

	if(istype(selected, /obj/item/organ))
		return null

	selected_module_by_user[get_selection_key(user, parent_organ)] = selected
	return parent_organ

/datum/surgery_step/cavity/detach_organ_module/check_parent_organ(obj/item/organ/external/parent_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	. = ..()
	if(!.)
		return

	return length(get_detachable_modules(parent_organ))

/datum/surgery_step/cavity/detach_organ_module/check_target_organ(obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, atom/user)
	. = ..()
	if(!.)
		return

	var/obj/item/organ/external/parent_organ = target_organ
	if(!istype(parent_organ))
		return FALSE

	var/obj/item/organ_module/selected = get_selected_module(user, parent_organ)
	if(!selected)
		clear_selected_module(user, parent_organ)
		return FALSE
	return TRUE

/datum/surgery_step/cavity/detach_organ_module/initiate(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	var/obj/item/organ_module/selected = get_selected_module(user, parent_organ)
	if(!selected)
		clear_selected_module(user, parent_organ)
		return SURGERY_FAILURE

	announce_preop(user,
		"[user] starts detaching [selected.name] inside [target]'s [parent_organ.name] with \the [tool].",
		"You start detaching [selected.name] inside [target]'s [parent_organ.name] with \the [tool]."
		)
	return ..()

/datum/surgery_step/cavity/detach_organ_module/success(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	var/obj/item/organ_module/selected = get_selected_module(user, parent_organ)
	clear_selected_module(user, parent_organ)
	if(!selected)
		return

	selected.surgical_detach(parent_organ)
	announce_success(user,
		"[user] detaches [selected.name] inside [target]'s [parent_organ.name] with \the [tool].",
		"You detach [selected.name] inside [target]'s [parent_organ.name] with \the [tool]."
		)

/datum/surgery_step/cavity/detach_organ_module/failure(obj/item/organ/external/parent_organ, obj/item/organ/target_organ, mob/living/carbon/human/target, obj/item/tool, mob/user)
	var/obj/item/organ_module/selected = get_selected_module(user, parent_organ)
	var/module_name = selected ? selected.name : "augmentation"
	clear_selected_module(user, parent_organ)

	announce_failure(user,
		"[user]'s hand slips, tearing tissue while detaching [module_name] in [target]'s [parent_organ.name] with \the [tool]!",
		"Your hand slips, tearing tissue while detaching [module_name] in [target]'s [parent_organ.name] with \the [tool]!"
		)
	parent_organ.take_external_damage(20, 0, (DAM_SHARP|DAM_EDGE), used_weapon = tool)
