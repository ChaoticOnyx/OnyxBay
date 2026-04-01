#define HUMAN_EATING_NO_ISSUE      0
#define HUMAN_EATING_NBP_MOUTH     1
#define HUMAN_EATING_BLOCKED_MOUTH 2
#define HUMAN_EATING_RESIST        3

#define add_clothing_protection(A)	\
	var/obj/item/clothing/C = A; \
	flash_protection += C.flash_protection; \
	equipment_tint_total += C.tint;

/mob/living/carbon/human/can_eat(food, feedback = 1)
	var/list/status = can_eat_status()

	switch(status[1])
		if(HUMAN_EATING_NO_ISSUE, HUMAN_EATING_RESIST)
			return TRUE
		if(HUMAN_EATING_NBP_MOUTH)
			if(feedback)
				to_chat(src, "Where do you intend to put \the [food]? You don't have a mouth!")
		if(HUMAN_EATING_BLOCKED_MOUTH)
			if(feedback)
				to_chat(src, SPAN("warning", "\The [status[2]] is in the way!"))

	return FALSE

/mob/living/carbon/human/can_force_feed(feeder, food, feedback = 1, check_resist = FALSE)
	var/list/status = can_eat_status()

	switch(status[1])
		if(HUMAN_EATING_NO_ISSUE)
			return TRUE
		if(HUMAN_EATING_NBP_MOUTH)
			if(feedback)
				to_chat(feeder, "Where do you intend to put \the [food]? \The [src] doesn't have a mouth!")
		if(HUMAN_EATING_BLOCKED_MOUTH)
			if(feedback)
				to_chat(feeder, SPAN("warning", "\The [status[2]] is in the way!"))
		if(HUMAN_EATING_RESIST)
			if(!check_resist)
				return TRUE
			if(feedback)
				visible_message(SPAN("warning", "[feeder] tries to feed \the [src] \the [food], but they resist!"))

	return FALSE

/mob/living/carbon/human/proc/can_eat_status()
	if(!check_has_mouth())
		return list(HUMAN_EATING_NBP_MOUTH)
	var/obj/item/blocked = check_mouth_coverage()
	if(blocked)
		return list(HUMAN_EATING_BLOCKED_MOUTH, blocked)
	if(a_intent != I_HELP)
		if(stat || !client || paralysis || sleeping || (handcuffed && (buckled || lying)) || istype(wear_suit, /obj/item/clothing/suit/straight_jacket))
			return list(HUMAN_EATING_NO_ISSUE)
		for(var/obj/item/grab/G in grabbed_by)
			if(G.restrains())
				return list(HUMAN_EATING_NO_ISSUE)
		return list(HUMAN_EATING_RESIST)
	return list(HUMAN_EATING_NO_ISSUE)

#undef HUMAN_EATING_NO_ISSUE
#undef HUMAN_EATING_NBP_MOUTH
#undef HUMAN_EATING_BLOCKED_MOUTH

/// Check whether mob is lying down on something we can operate him on.
/mob/living/carbon/human/proc/can_operate(mob/user)
	var/turf/T = get_turf(src)
	if(lying && locate(/obj/structure/table, T))
		. = TRUE
	if(lying && locate(/obj/machinery/optable, T))
		. = TRUE
	if(lying && locate(/obj/effect/rune/, T))
		. = TRUE
	if(buckled && istype(buckled, /obj/structure/bed))
		. = TRUE

	if(src == user)
		var/mob/living/carbon/human/H = user // No way it can't be human at this point.
		var/hitzone = check_zone(H.zone_sel.selecting)
		var/list/badzones = list(BP_HEAD)
		if(H.active_hand == ACTIVE_HAND_LEFT)
			badzones += BP_L_ARM
			badzones += BP_L_HAND
		else
			badzones += BP_R_ARM
			badzones += BP_R_HAND

		if(hitzone in badzones)
			return FALSE

/mob/living/carbon/human/proc/update_equipment_vision()
	flash_protection = 0
	equipment_tint_total = 0
	equipment_see_invis	= 0
	equipment_vision_flags = 0
	equipment_prescription = 0
	equipment_light_protection = 0
	equipment_darkness_modifier = 0
	equipment_overlays.Cut()

	if(istype(src.head, /obj/item/clothing/head))
		add_clothing_protection(head)
	if(istype(src.glasses, /obj/item/clothing/glasses))
		process_glasses(glasses)
	if(istype(src.wear_mask, /obj/item/clothing/mask))
		add_clothing_protection(wear_mask)
		if(wear_mask.overlay)
			equipment_overlays |= wear_mask.overlay
	if(istype(back,/obj/item/rig))
		process_rig(back)

	process_eye_modules()

	// Removes zoom effect
	if (client && machine_visual)
		if (client.pixel_x != 0 || client.pixel_y != 0)
			shift_view(0, 0)

/mob/living/carbon/human/proc/process_glasses(obj/item/clothing/glasses/G)
	if(machine_visual && !istype(G, /obj/item/clothing/glasses/regular)) //Doesn't allow the use of night vision devices and other funny devices except glasses for vision correction
		return
	if(!G)
		return
	equipment_darkness_modifier += G.darkness_view
	equipment_vision_flags |= G.vision_flags
	equipment_prescription += G.prescription
	equipment_light_protection += G.light_protection
	if(G.overlay)
		equipment_overlays |= G.overlay
	if(G.see_invisible >= 0)
		if(equipment_see_invis)
			equipment_see_invis = min(equipment_see_invis, G.see_invisible)
		else
			equipment_see_invis = G.see_invisible

	add_clothing_protection(G)
	G.process_hud(src)

/mob/living/carbon/human/proc/process_rig(obj/item/rig/O)
	if(O.visor && O.visor.active && O.visor.vision && O.visor.vision.glasses && (!O.helmet || (head && O.helmet == head)))
		process_glasses(O.visor.vision.glasses)

/mob/living/carbon/human/proc/process_eye_modules()
	var/obj/item/organ/internal/eyes/eyes = internal_organs_by_name[BP_EYES]
	if(!istype(eyes))
		return

	for(var/obj/item/organ_module/active/lenses/lens in eyes.organ_modules)
		if(!lens.toggled && lens.toggleable)
			continue

		equipment_darkness_modifier += lens.darkness_view
		equipment_vision_flags |= lens.vision_flags
		equipment_prescription += lens.prescription
		equipment_light_protection += lens.light_protection
		flash_protection += lens.flash_protection
		equipment_tint_total += lens.tint

		if(lens.see_invisible >= 0)
			if(equipment_see_invis)
				equipment_see_invis = min(equipment_see_invis, lens.see_invisible)
			else
				equipment_see_invis = lens.see_invisible

		if(lens.overlay)
			equipment_overlays |= lens.overlay

		lens.process_hud(src)

	return

/mob/living/carbon/human/proc/get_head_organ()
	var/obj/item/organ/external/head/head = external_organs_by_name[BP_HEAD]
	return istype(head) ? head : null

/mob/living/carbon/human/proc/get_all_organs()
	var/list/all_organs = list()
	if(islist(external_organs))
		all_organs += external_organs
	if(islist(internal_organs))
		all_organs += internal_organs
	return all_organs

/mob/living/carbon/human/proc/get_cpu_name()
	var/obj/item/organ/external/head/head = get_head_organ()
	if(!head)
		return "CPU"
	for(var/obj/item/organ_module/module in head.organ_modules)
		if(initial(module.module_type) == OM_TYPE_PROCESSOR)
			return module.name
	return "CPU"

/mob/living/carbon/human/proc/get_cpu_power()
	var/total_cpu_power = 0
	var/obj/item/organ/external/head/head = get_head_organ()
	if(!head)
		return total_cpu_power
	for(var/obj/item/organ_module/module in head.organ_modules)
		if(initial(module.module_type) == OM_TYPE_PROCESSOR)
			total_cpu_power += (isnull(initial(module.cpu_power)) ? 0 : initial(module.cpu_power))
	return total_cpu_power

/mob/living/carbon/human/proc/get_active_cpu_load()
	var/loaded_cpu_power = 0
	for(var/obj/item/organ/O in get_all_organs())
		for(var/obj/item/organ_module/module in O.organ_modules)
			var/load = isnull(initial(module.cpu_load)) ? 0 : initial(module.cpu_load)
			if(load <= 0)
				continue
			if(istype(module, /obj/item/organ_module/active))
				var/obj/item/organ_module/active/A = module
				if(!A.is_cpu_active(src))
					continue
			loaded_cpu_power += load
	return loaded_cpu_power

/mob/living/carbon/human/proc/deactivate_active_augmentations()
	for(var/obj/item/organ/O in get_all_organs())
		for(var/obj/item/organ_module/active/A in O.organ_modules)
			if(A.is_cpu_active(src))
				A.deactivate(O, src)

/mob/living/carbon/human/proc/handle_cpu_overload()
	var/total_cpu_power = get_cpu_power()
	var/loaded_cpu_power = get_active_cpu_load()
	if(loaded_cpu_power <= total_cpu_power)
		cpu_overload_since = 0
		cpu_overload_warned_at = 0
		return

	if(!cpu_overload_since)
		cpu_overload_since = world.time

	if(!cpu_overload_warned_at && (world.time - cpu_overload_since) >= 10 SECONDS)
		to_chat(src, SPAN_WARNING("Your body feels like a thousand needles crawling under your skin."))
		cpu_overload_warned_at = world.time
		return

	if(cpu_overload_warned_at && (world.time - cpu_overload_warned_at) >= 10 SECONDS)
		to_chat(src, SPAN_DANGER("Emergency [get_cpu_name()] reset, deactivating active augmentations."))
		adjustBrainLoss(rand(10, 35))
		deactivate_active_augmentations()
		Paralyse(rand(5, 20))
		cpu_overload_since = 0
		cpu_overload_warned_at = 0

/mob/living/carbon/human/get_gender()
	return gender

/mob/living/carbon/human/fully_replace_character_name(new_name, in_depth = TRUE)
	var/old_name = real_name
	. = ..()
	if(!. || !in_depth)
		return

	var/datum/computer_file/crew_record/R = get_crewmember_record(old_name)
	if(R)
		R.set_name(new_name)

	//update our pda and id if we have them on our person
	var/list/searching = GetAllContents(searchDepth = 3)
	var/search_id = 1
	var/search_pda = 1

	for(var/A in searching)
		if(search_id && istype(A,/obj/item/card/id))
			var/obj/item/card/id/ID = A
			if(ID.registered_name == old_name)
				ID.registered_name = new_name
				ID.update_name()
				search_id = 0
		else if(search_pda && istype(A,/obj/item/device/pda))
			var/obj/item/device/pda/PDA = A
			if(PDA.owner == old_name)
				PDA.set_owner(new_name)
				search_pda = 0


//Get species or synthetic temp if the mob is a FBP. Used when a synthetic type human mob is exposed to a temp check.
//Essentially, used when a synthetic human mob should act diffferently than a normal type mob.
/mob/living/carbon/human/proc/getSpeciesOrSynthTemp(temptype)
	switch(temptype)
		if(COLD_LEVEL_1)
			return isSynthetic()? SYNTH_COLD_LEVEL_1 : species.cold_level_1
		if(COLD_LEVEL_2)
			return isSynthetic()? SYNTH_COLD_LEVEL_2 : species.cold_level_2
		if(COLD_LEVEL_3)
			return isSynthetic()? SYNTH_COLD_LEVEL_3 : species.cold_level_3
		if(HEAT_LEVEL_1)
			return isSynthetic()? SYNTH_HEAT_LEVEL_1 : species.heat_level_1
		if(HEAT_LEVEL_2)
			return isSynthetic()? SYNTH_HEAT_LEVEL_2 : species.heat_level_2
		if(HEAT_LEVEL_3)
			return isSynthetic()? SYNTH_HEAT_LEVEL_3 : species.heat_level_3

/mob/living/carbon/human/proc/getCryogenicFactor(bodytemperature)
	if(isSynthetic())
		return 0
	if(!species)
		return 0

	if(bodytemperature > species.cold_level_1)
		return 0
	else if(bodytemperature > species.cold_level_2)
		. = 5 * (1 - (bodytemperature - species.cold_level_2) / (species.cold_level_1 - species.cold_level_2))
		. = max(2, .)
	else if(bodytemperature > species.cold_level_3)
		. = 20 * (1 - (bodytemperature - species.cold_level_3) / (species.cold_level_2 - species.cold_level_3))
		. = max(5, .)
	else
		. = 80 * (1 - bodytemperature / species.cold_level_3)
		. = max(20, .)
	return round(.)

/mob/living/carbon/human
	var/next_sonar_ping = 0

/mob/living/carbon/human/proc/sonar_ping()
	set name = "Listen In"
	set desc = "Allows you to listen in to movement and noises around you."
	set category = "IC"

	if(incapacitated())
		to_chat(src, "<span class='warning'>You need to recover before you can use this ability.</span>")
		return
	if(world.time < next_sonar_ping)
		to_chat(src, "<span class='warning'>You need another moment to focus.</span>")
		return
	if(is_deaf() || is_below_sound_pressure(get_turf(src)))
		to_chat(src, "<span class='warning'>You are for all intents and purposes currently deaf!</span>")
		return
	next_sonar_ping += 10 SECONDS
	var/heard_something = FALSE
	to_chat(src, "<span class='notice'>You take a moment to listen in to your environment...</span>")
	var/list/view_sizes = get_view_size(client.view)
	for(var/mob/living/L in range(max(view_sizes[1], view_sizes[2]), src))
		var/turf/T = get_turf(L)
		if(!T || L == src || L.is_ic_dead() || is_below_sound_pressure(T))
			continue
		heard_something = TRUE
		var/image/ping_image = image(icon = 'icons/effects/effects.dmi', icon_state = "sonar_ping", loc = src)
		ping_image.plane = EFFECTS_ABOVE_LIGHTING_PLANE
		ping_image.layer = BEAM_PROJECTILE_LAYER
		ping_image.pixel_x = (T.x - src.x) * WORLD_ICON_SIZE
		ping_image.pixel_y = (T.y - src.y) * WORLD_ICON_SIZE
		image_to(src, ping_image)
		spawn(8)
			qdel(ping_image)
		var/feedback = list("<span class='notice'>There are noises of movement ")
		var/direction = get_dir(src, L)
		if(direction)
			feedback += "towards the [dir2text(direction)], "
			switch(get_dist(src, L) / client.view)
				if(0 to 0.2)
					feedback += "very close by."
				if(0.2 to 0.4)
					feedback += "close by."
				if(0.4 to 0.6)
					feedback += "some distance away."
				if(0.6 to 0.8)
					feedback += "further away."
				else
					feedback += "far away."
		else // No need to check distance if they're standing right on-top of us
			feedback += "right on top of you."
		feedback += "</span>"
		to_chat(src, jointext(feedback,null))
	if(!heard_something)
		to_chat(src, "<span class='notice'>You hear no movement but your own.</span>")

/mob/living/carbon/human/reset_layer()
	if(hiding)
		layer = HIDING_MOB_LAYER
	else if(lying)
		layer = LYING_HUMAN_LAYER
	else
		..()

/mob/living/carbon/human/proc/has_headset_in_ears()
	return istype(get_equipped_item(slot_l_ear), /obj/item/device/radio/headset) || istype(get_equipped_item(slot_r_ear), /obj/item/device/radio/headset)

/mob/living/carbon/human/proc/make_grab(mob/living/carbon/human/attacker, mob/living/carbon/human/victim, grab_tag)
	var/obj/item/grab/G

	if(!victim.get_organ(attacker.zone_sel.selecting))
		to_chat(attacker, SPAN("warning", "[victim] is missing the body part you tried to grab!"))
		return FALSE

	if(!prob(attacker.client?.get_luck_for_type(LUCK_CHECK_COMBAT)))
		visible_message(SPAN_DANGER("[attacker] attempted to swing at \the [victim], but failed miserably!"))
		return

	if(!grab_tag)
		G = new attacker.current_grab_type(attacker, victim)
	else
		var/obj/item/grab/given_grab_type = all_grabobjects[grab_tag]
		G = new given_grab_type(attacker, victim)

	if(!G.pre_check())
		qdel(G)
		return FALSE

	if(G.can_grab())
		G.init()
		return TRUE
	else
		qdel(G)
		return FALSE

/mob/living/carbon/human
	var/list/cloaking_sources

// Returns true if, and only if, the human has gone from uncloaked to cloaked
/mob/living/carbon/human/proc/add_cloaking_source(datum/cloaking_source)
	var/has_uncloaked = clean_cloaking_sources()
	LAZYDISTINCTADD(cloaking_sources, weakref(cloaking_source))

	// We don't present the cloaking message if the human was already cloaked just before cleanup.
	if(!has_uncloaked && LAZYLEN(cloaking_sources) == 1)
		update_icons()
		src.visible_message("<span class='warning'>\The [src] seems to disappear before your eyes!</span>", "<span class='notice'>You feel completely invisible.</span>")
		return TRUE
	return FALSE

#define CLOAK_APPEAR_OTHER "<span class='warning'>\The [src] appears from thin air!</span>"
#define CLOAK_APPEAR_SELF "<span class='notice'>You have re-appeared.</span>"

// Returns true if, and only if, the human has gone from cloaked to uncloaked
/mob/living/carbon/human/proc/remove_cloaking_source(datum/cloaking_source)
	var/was_cloaked = LAZYLEN(cloaking_sources)
	clean_cloaking_sources()
	LAZYREMOVE(cloaking_sources, weakref(cloaking_source))

	if(was_cloaked && !LAZYLEN(cloaking_sources))
		update_icons()
		visible_message(CLOAK_APPEAR_OTHER, CLOAK_APPEAR_SELF)
		return TRUE
	return FALSE

// Returns true if the human is cloaked, otherwise false (technically returns the number of cloaking sources)
/mob/living/carbon/human/proc/is_cloaked()
	if(clean_cloaking_sources())
		update_icons()
		visible_message(CLOAK_APPEAR_OTHER, CLOAK_APPEAR_SELF)
	return LAZYLEN(cloaking_sources)

#undef CLOAK_APPEAR_OTHER
#undef CLOAK_APPEAR_SELF

// Returns true if the human is cloaked by the given source
/mob/living/carbon/human/proc/is_cloaked_by(cloaking_source)
	return LAZYISIN(cloaking_sources, weakref(cloaking_source))

// Returns true if this operation caused the mob to go from cloaked to uncloaked
/mob/living/carbon/human/proc/clean_cloaking_sources()
	if(!cloaking_sources)
		return FALSE

	var/list/rogue_entries = list()
	for(var/entry in cloaking_sources)
		var/weakref/W = entry
		if(!W.resolve())
			cloaking_sources -= W
			rogue_entries += W

	if(rogue_entries.len) // These entries did not cleanup after themselves before being destroyed
		var/rogue_entries_as_string = jointext(map(rogue_entries, /proc/log_info_line), ", ")
		util_crash_with("[log_info_line(src)] - Following cloaking entries were removed during cleanup: [rogue_entries_as_string]")

	UNSETEMPTY(cloaking_sources)
	return !cloaking_sources // If cloaking_sources wasn't initially null but is now, we've uncloaked

/mob/living/carbon/human/get_ear_protection()
	for(var/obj/item/C in list(l_ear, r_ear, head))
		if(istype(C))
			. += C.ear_protection
	if(has_cochlear_implant())
		. = max(., 2)
	return .

/mob/living/carbon/human/proc/has_cochlear_implant()
	var/obj/item/organ/external/head/head = external_organs_by_name[BP_HEAD]
	if(!istype(head))
		return FALSE
	if(locate(/obj/item/organ_module/cochlear) in head.organ_modules)
		return TRUE
	return FALSE

/mob/living/carbon/human/is_eligible_for_antag_spawn(antag_id)
	return species ? species.is_eligible_for_antag_spawn(antag_id) : TRUE // No species = no problems, assuming ourselves to be a baseline human being

/mob/living/carbon/human/get_climb_speed()
	. = 1.0

	if(body_build?.climb_speed)
		. = body_build.climb_speed
	else
		. = ..()

	var/area/area = get_area(src)
	if(shoes && (shoes.item_flags & ITEM_FLAG_NOSLIP) && istype(shoes, /obj/item/clothing/shoes/magboots))
		. *= 2.0 // Magboots are pain in the ass
	else if(!area || !area.has_gravity())
		. *= 0.25 // Zero G is fun
		return

	if(isSynthetic())
		. *= 1.5 // Fullsteel fucks are heavy

	// Check hands for additional difficulties
	if(l_hand?.w_class >= ITEM_SIZE_NORMAL && r_hand?.w_class >= ITEM_SIZE_NORMAL)
		. *= 2.5 // Pure pain
	else if(l_hand?.w_class >= ITEM_SIZE_NORMAL || r_hand?.w_class >= ITEM_SIZE_NORMAL)
		. *= 1.5 // Less pain

	return

/// used for hud lights and eye glow effects
/mob/living/carbon/human
	var/hud_eye_glow_active = FALSE
	var/hud_eye_glow_color = null
	var/hud_eye_glow_range = 2
	var/list/hud_eye_glow_saved = null

/mob/living/carbon/human/proc/update_hud_eye_glow()
	var/obj/item/organ/internal/eyes/eyes = internal_organs_by_name[BP_EYES]
	if(!istype(eyes))
		eyes = internal_organs_by_name[BP_OPTICS]
	if(!istype(eyes))
		return
	var/sightlights_active = FALSE
	for(var/obj/item/organ_module/active/sightlights/S in eyes.organ_modules)
		if(S.lights_on)
			sightlights_active = TRUE
			break

	var/list/glow = eyes.get_active_glow()
	if(glow && glow["rgb"])
		if(!hud_eye_glow_saved)
			hud_eye_glow_saved = list(r_eyes, g_eyes, b_eyes)
		var/r = glow["rgb"][1]
		var/g = glow["rgb"][2]
		var/b = glow["rgb"][3]
		change_eye_color(r, g, b)
		if(!sightlights_active)
			set_light(0.2, 0.1, hud_eye_glow_range, l_color = rgb(r, g, b))
		hud_eye_glow_active = TRUE
		hud_eye_glow_color = light_color
		return

	var/obj/item/clothing/glasses/hud/goggles = glasses
	if(istype(goggles) && goggles.active && goggles.matrix?.eye_glow_rgb)
		if(!hud_eye_glow_saved)
			hud_eye_glow_saved = list(r_eyes, g_eyes, b_eyes)
		var/list/g = goggles.matrix.eye_glow_rgb
		if(!sightlights_active)
			set_light(0.2, 0.1, hud_eye_glow_range, l_color = rgb(g[1], g[2], g[3]))
		hud_eye_glow_active = TRUE
		hud_eye_glow_color = light_color
		return

	if(hud_eye_glow_saved)
		change_eye_color(hud_eye_glow_saved[1], hud_eye_glow_saved[2], hud_eye_glow_saved[3])
		hud_eye_glow_saved = null
	else if(eyes.eye_colour)
		change_eye_color(eyes.eye_colour[1], eyes.eye_colour[2], eyes.eye_colour[3])
	if(hud_eye_glow_active && !sightlights_active)
		set_light(0)
	hud_eye_glow_active = FALSE
	hud_eye_glow_color = null

/mob/living/carbon/human/proc/get_hand_organ(certain_hand = -1)
	switch(certain_hand)
		if(-1)
			if(rightclicked)
				return (active_hand == ACTIVE_HAND_LEFT) ? external_organs_by_name[BP_R_HAND] : external_organs_by_name[BP_L_HAND]
			return (active_hand == ACTIVE_HAND_LEFT) ? external_organs_by_name[BP_L_HAND] : external_organs_by_name[BP_R_HAND]
		if(ACTIVE_HAND_LEFT)
			return external_organs_by_name[BP_L_HAND]
		if(ACTIVE_HAND_RIGHT)
			return external_organs_by_name[BP_R_HAND]
	return null

/mob/living/carbon/human/proc/is_hand_usable(silent = FALSE, certain_hand = -1)
	var/_active_hand = certain_hand
	if(_active_hand == -1)
		_active_hand = rightclicked ? !active_hand : active_hand

	var/obj/item/organ/external/temp = get_hand_organ(_active_hand)
	if(istype(temp) && temp.is_usable())
		return TRUE
	if(!silent)
		to_chat(src, SPAN("notice", "You try to move your [(_active_hand == ACTIVE_HAND_LEFT) ? "left" : "right"] hand, but cannot!"))
	return FALSE
