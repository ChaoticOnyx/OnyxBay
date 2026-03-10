/datum/event/space_dust_base
	id = "space_dust_base"
	name = "Space Dust Storm"
	description = "A dense cloud of space dust envelops the station, reducing visibility in space and abrading anything caught outside."

	mtth = 1 HOURS
	difficulty = 35

	options = newlist(
		/datum/event_option/space_dust_option {
			id = "option_mundane";
			name = "Mundane Level";
			weight = 80;
			weight_ratio = EVENT_OPTION_AI_AGGRESSION_R;
			event_id = "space_dust";
			description = "A light dust cloud reduces visibility outside the station.";
			severity = EVENT_LEVEL_MUNDANE;
		},
		/datum/event_option/space_dust_option {
			id = "option_moderate";
			name = "Moderate Level";
			weight = 20;
			weight_ratio = EVENT_OPTION_AI_AGGRESSION;
			event_id = "space_dust";
			description = "A thick dust storm blankets the station exterior, severely limiting visibility and wearing down suits.";
			severity = EVENT_LEVEL_MODERATE;
		}
	)

/datum/event/space_dust_base/get_mtth()
	. = ..()
	. -= (SSevents.triggers.roles_count["Engineer"] * (5 MINUTE))
	. = max(1 HOUR, .)

/datum/event/space_dust_base/get_conditions_description()
	. = "<em>Space Dust</em> should not be <em>running</em>.<br>"

/datum/event/space_dust_base/check_conditions()
	. = SSevents.evars["space_dust_running"] != TRUE

/datum/event_option/space_dust_option
	var/severity = EVENT_LEVEL_MUNDANE

/datum/event_option/space_dust_option/on_choose()
	SSevents.evars["space_dust_severity"] = severity

/datum/event/space_dust
	id = "space_dust"

	hide = TRUE
	triggered_only = TRUE

	var/list/affecting_z = list()
	var/severity = EVENT_LEVEL_MUNDANE
	/// Mobs currently affected by dust visibility reduction.
	var/list/affected_mobs = list()
	/// Areas currently showing the dust overlay. Assoc: area -> list(icon, icon_state, layer)
	var/list/overlayed_areas = list()
	/// World.time of next breach check.
	var/next_breach_check = 0

/datum/event/space_dust/New()
	. = ..()

	add_think_ctx("end", CALLBACK(src, nameof(.proc/end)), 0)

/datum/event/space_dust/on_fire()
	severity = SSevents.evars["space_dust_severity"]
	SSevents.evars["space_dust_running"] = TRUE
	affecting_z = GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION)

	SSannounce.play_station_announce(/datum/announce/space_dust_start)

	// Apply dust overlay to all space areas on station z-levels.
	apply_area_overlays()

	set_next_think_ctx("end", world.time + (rand(2, 5) MINUTES))
	set_next_think(world.time)

/datum/event/space_dust/proc/end()
	set_next_think(0)
	SSevents.evars["space_dust_running"] = FALSE
	SSannounce.play_station_announce(/datum/announce/space_dust_end)

	// Clear visibility effects from all affected mobs.
	for(var/mob/living/L in affected_mobs)
		clear_dust_effect(L)
	affected_mobs.Cut()

	// Remove dust overlays from all areas.
	clear_area_overlays()

/datum/event/space_dust/think()
	// Update breached area overlays every 10 seconds to avoid iterating ZAS zones too often.
	if(world.time >= next_breach_check)
		update_breached_overlays()
		next_breach_check = world.time + (10 SECONDS)

	// Apply visibility and abrasion effects to mobs in space or breached areas.
	process_mobs()

	set_next_think(world.time + (2 SECONDS))

/// Applies dust overlay to all space areas on station z-levels.
/datum/event/space_dust/proc/apply_area_overlays()
	for(var/area/space/A in world)
		var/turf/T = locate(/turf) in A
		if(!T || !(T.z in affecting_z))
			continue
		set_area_dust_overlay(A)

/// Finds station areas directly connected to space via ZAS and applies/removes dust overlays.
/datum/event/space_dust/proc/update_breached_overlays()
	// Collect areas that currently have a direct zone-to-space connection.
	var/list/breached_areas = list()
	for(var/zone/Z in SSair.zones)
		if(Z.invalid || !length(Z.contents))
			continue
		// Quick z-level check using the first turf before iterating edges.
		var/turf/first = Z.contents[1]
		if(!(first.z in affecting_z))
			continue
		var/has_space_edge = FALSE
		for(var/connection_edge/unsimulated/E in Z.edges)
			has_space_edge = TRUE
			break
		if(!has_space_edge)
			continue
		// This zone is directly touching space — find which station areas its turfs belong to.
		for(var/turf/T in Z.contents)
			var/area/A = get_area(T)
			if(!A || istype(A, /area/space))
				continue
			breached_areas |= A

	// Remove overlay from station areas that are no longer breached.
	for(var/area/A in overlayed_areas)
		if(istype(A, /area/space))
			continue
		if(!(A in breached_areas))
			clear_area_dust_overlay(A)

	// Add overlay to newly breached station areas.
	for(var/area/A in breached_areas)
		set_area_dust_overlay(A)

/// Sets the dust overlay on an area, saving original visuals for restoration.
/datum/event/space_dust/proc/set_area_dust_overlay(area/A)
	if(overlayed_areas[A])
		return
	overlayed_areas[A] = list(A.icon, A.icon_state, A.layer, A.opacity)
	A.icon = 'icons/effects/weather_effects.dmi'
	A.layer = ABOVE_PROJECTILE_LAYER
	A.icon_state = "dust_high"
	if(severity >= EVENT_LEVEL_MODERATE)
		A.set_opacity(TRUE)

/// Clears the dust overlay from an area, restoring original visuals.
/datum/event/space_dust/proc/clear_area_dust_overlay(area/A)
	var/list/original = overlayed_areas[A]
	if(!original)
		return
	A.icon = original[1]
	A.icon_state = original[2]
	A.layer = original[3]
	A.set_opacity(original[4])
	overlayed_areas -= A

/// Clears dust overlays from all affected areas.
/datum/event/space_dust/proc/clear_area_overlays()
	for(var/area/A in overlayed_areas)
		clear_area_dust_overlay(A)
	overlayed_areas.Cut()

/// Applies dust effects to all living mobs currently in space or breached areas on station z-levels.
/datum/event/space_dust/proc/process_mobs()
	for(var/mob/living/L in GLOB.living_mob_list_)
		var/turf/T = get_turf(L)
		var/area/A = T ? get_area(T) : null
		var/exposed = T && (T.z in affecting_z) && (A in overlayed_areas)

		if(exposed)
			apply_dust_effect(L)
			// Abrasion damage — dust wears on anything exposed.
			var/in_space = istype(T, /turf/space) || istype(A, /area/space)
			if(in_space)
				// Full abrasion in open space.
				if(severity >= EVENT_LEVEL_MODERATE)
					L.adjustBruteLoss(rand(1, 3))
				else if(prob(30))
					L.adjustBruteLoss(1)
			else
				// Reduced abrasion in breached rooms — dust seeps in but isn't as dense.
				if(severity >= EVENT_LEVEL_MODERATE && prob(30))
					L.adjustBruteLoss(1)
		else if(L in affected_mobs)
			clear_dust_effect(L)
			affected_mobs -= L

/// Applies blurry vision to a mob caught in the dust.
/datum/event/space_dust/proc/apply_dust_effect(mob/living/L)
	if(!(L in affected_mobs))
		affected_mobs += L
		to_chat(L, SPAN_WARNING("Dense clouds of space dust swirl around you!"))

	// Only blur vision if eyes are not covered.
	if(eyes_exposed(L))
		var/blur_amount = severity >= EVENT_LEVEL_MODERATE ? 8 : 4
		L.eye_blurry = max(L.eye_blurry, blur_amount)

/// Returns TRUE if the mob's eyes are not protected by headgear or a mask.
/datum/event/space_dust/proc/eyes_exposed(mob/living/L)
	if(!ishuman(L))
		return TRUE
	var/mob/living/carbon/human/H = L
	if(H.head && (H.head.body_parts_covered & EYES))
		return FALSE
	if(H.wear_mask && (H.wear_mask.body_parts_covered & EYES))
		return FALSE
	return TRUE

/// Clears dust visual effects from a mob.
/datum/event/space_dust/proc/clear_dust_effect(mob/living/L)
	to_chat(L, SPAN_NOTICE("The dust clears from around you."))
