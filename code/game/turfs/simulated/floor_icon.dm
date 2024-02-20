var/list/flooring_cache = list()

/turf/simulated/floor/on_update_icon(update_neighbors)

	if(lava)
		return

	if(flooring)
		// Set initial icon and strings.
		SetName(flooring.name)
		desc = flooring.desc
		icon = flooring.icon
		if (flooring.color)
			color = flooring.color

		if(flooring_override)
			icon_state = flooring_override
		else
			icon_state = flooring.icon_base
			if(flooring.has_base_range)
				icon_state = "[icon_state][rand(0,flooring.has_base_range)]"
				flooring_override = icon_state

		// Apply edges, corners, and inner corners.
		ClearOverlays()
		var/has_border = 0
		if(flooring.flags & TURF_HAS_EDGES)
			for(var/step_dir in GLOB.cardinal)
				var/turf/simulated/floor/T = get_step(src, step_dir)
				if(!istype(T) || !T.flooring || T.flooring.name != flooring.name)
					has_border |= step_dir
					AddOverlays(get_flooring_overlay("[flooring.icon_base]-edge-[step_dir]", "[flooring.icon_base]_edges", step_dir))

			for(var/diagonal in list(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))
				if((has_border & diagonal) == diagonal)
					AddOverlays(get_flooring_overlay("[flooring.icon_base]-edge-[diagonal]", "[flooring.icon_base]_edges", diagonal))
				if((has_border & diagonal) == 0 && (flooring.flags & TURF_HAS_CORNERS))
					var/turf/simulated/floor/T = get_step(src, diagonal)
					if(!(istype(T) && T.flooring && T.flooring.name == flooring.name))
						AddOverlays(get_flooring_overlay("[flooring.icon_base]-corner-[diagonal]", "[flooring.icon_base]_corners", diagonal))

		if(flooring.can_paint && decals && decals.len)
			AddOverlays(decals)

	else if(decals && decals.len)
		for(var/image/I in decals)
			if(I.layer < layer)
				continue
			AddOverlays(I)

	if(is_plating() && !(isnull(broken) && isnull(burnt))) //temp, todo
		icon = 'icons/turf/flooring/plating.dmi'
		icon_state = "[base_icon_state]_dmg[rand(1,4)]"
	else if(flooring)
		if(!isnull(broken) && (flooring.flags & TURF_CAN_BREAK))
			AddOverlays(get_damage_overlay("broken[broken]", BLEND_MULTIPLY))
		if(!isnull(burnt) && (flooring.flags & TURF_CAN_BURN))
			AddOverlays(get_damage_overlay("burned[burnt]"))

	if(update_neighbors)
		for(var/turf/simulated/floor/F in orange(src, 1))
			F.update_icon()

/turf/simulated/floor/proc/get_flooring_overlay(cache_key, icon_base, icon_dir = 0)
	if(!flooring_cache[cache_key])
		var/image/I = image(icon = flooring.icon, icon_state = icon_base, dir = icon_dir)
		I.layer = DECAL_LAYER
		flooring_cache[cache_key] = I
	return flooring_cache[cache_key]

/turf/simulated/floor/proc/get_damage_overlay(cache_key, blend)
	if(!flooring_cache[cache_key])
		var/image/I = image(icon = 'icons/turf/flooring/damage.dmi', icon_state = cache_key)
		if(blend)
			I.blend_mode = blend
		I.plane = plane
		I.layer = DECAL_LAYER
		flooring_cache[cache_key] = I
	return flooring_cache[cache_key]
