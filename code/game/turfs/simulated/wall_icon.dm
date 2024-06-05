/// How many variations of bullethole patterns there are
#define BULLETHOLE_STATES 10
/// Maximum possible bullet holes in a closed turf
#define BULLETHOLE_MAX 24

/turf/simulated/wall/proc/update_material()
	if(!material)
		return

	if(reinf_material)
		construction_stage = 6
	else
		construction_stage = null
	if(!material)
		material = get_material_by_name(DEFAULT_WALL_MATERIAL)
	if(material)
		explosion_resistance = material.explosion_resistance
	if(reinf_material && reinf_material.explosion_resistance > explosion_resistance)
		explosion_resistance = reinf_material.explosion_resistance

	if(reinf_material)
		SetName("reinforced [material.display_name] [initial(name)]")
		desc = "It seems to be a section of hull reinforced with [reinf_material.display_name] and plated with [material.display_name]."
	else
		SetName("[material.display_name] [initial(name)]")
		desc = "It seems to be a section of hull plated with [material.display_name]."

	set_opacity(material.opacity >= 0.5)

	update_connections(1)
	update_icon()

	if(material.reagent_path)
		create_reagents(2 * REAGENTS_PER_MATERIAL_SHEET)
		reagents.add_reagent(material.reagent_path, 2 * REAGENTS_PER_MATERIAL_SHEET)

/turf/simulated/wall/proc/set_material(material/newmaterial, material/newrmaterial)
	material = newmaterial
	reinf_material = newrmaterial
	update_material()

/turf/simulated/wall/on_update_icon()
	if(!material)
		return

	if(!damage_overlays[1]) //list hasn't been populated
		generate_overlays()

	ClearOverlays()
	var/image/I

	if(!density)
		icon = masks_icon
		icon_state = "[material.icon_base]fwall_open"
		color = material.icon_colour
		return

	icon = GLOB.bitmask_icon_sheets["wall_[material.icon_base]"]
	icon_state = "[wall_connections]"
	color = material.icon_colour

	if(reinf_material)
		if(construction_stage != null && construction_stage < 6)
			I = OVERLAY(masks_icon, "reinf_construct-[construction_stage]", appearance_flags = RESET_COLOR)
			I.color = reinf_material.icon_colour
			AddOverlays(I)
		else
			if(!mask_overlay_states[masks_icon]) // Lets just cache them instead of calling icon_states() every damn time.
				mask_overlay_states[masks_icon] = icon_states(masks_icon)
			if("[reinf_material.icon_reinf]0" in mask_overlay_states[masks_icon])
				I = image(GLOB.bitmask_icon_sheets["wall_[reinf_material.icon_reinf]"], "[wall_connections]")
				I.color = reinf_material.icon_colour
				I.appearance_flags = DEFAULT_APPEARANCE_FLAGS | RESET_COLOR
				AddOverlays(I)
			else
				I = OVERLAY(masks_icon, reinf_material.icon_reinf)
				I.color = reinf_material.icon_colour
				I.appearance_flags = DEFAULT_APPEARANCE_FLAGS | RESET_COLOR
				AddOverlays(I)

	CutOverlays(bullethole_overlay)
	if(damage != 0)
		var/integrity = material.integrity
		if(reinf_material)
			integrity += reinf_material.integrity

		var/overlay = round(damage / integrity * damage_overlays.len) + 1
		if(overlay > damage_overlays.len)
			overlay = damage_overlays.len

		AddOverlays(damage_overlays[overlay])
		if(current_bulletholes && current_bulletholes <= BULLETHOLE_MAX)
			if(!bullethole_variation)
				bullethole_variation = rand(1, BULLETHOLE_STATES)
			bullethole_overlay = image('icons/effects/bulletholes.dmi', src, "bhole_[bullethole_variation]_[current_bulletholes]")
			AddOverlays(bullethole_overlay)

	else
		QDEL_NULL(bullethole_overlay)

	return

/turf/simulated/wall/proc/generate_overlays()
	var/alpha_inc = 256 / damage_overlays.len

	for(var/i = 1; i <= damage_overlays.len; i++)
		var/image/img = image('icons/turf/walls.dmi', "overlay_damage") // Don't use OVERLAY here, we don't need all this garbage in the global cache
		img.blend_mode = BLEND_MULTIPLY
		img.alpha = (i * alpha_inc) - 1
		damage_overlays[i] = img


/turf/simulated/wall/proc/update_connections(propagate = 0)
	if(!material)
		return
	wall_connections = 0

	for(var/I in GLOB.cardinal)
		var/turf/simulated/wall/W = get_step(src, I)
		if(!istype(W))
			continue
		if(!W.material)
			continue
		if(propagate)
			W.update_connections()
			W.update_icon()
		if(can_join_with(W))
			wall_connections += get_dir(src, W)

/turf/simulated/wall/proc/can_join_with(turf/simulated/wall/W)
	if(material && W.material && material.icon_base == W.material.icon_base)
		return 1
	return 0

#undef BULLETHOLE_STATES
#undef BULLETHOLE_MAX
