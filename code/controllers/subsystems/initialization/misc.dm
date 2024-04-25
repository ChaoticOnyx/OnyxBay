SUBSYSTEM_DEF(misc)
	name = "Early Initialization"
	init_order = SS_INIT_MISC
	flags = SS_NO_FIRE

/datum/controller/subsystem/misc/Initialize()
	BakeBitmaskOverlays()

	if(config.game.generate_asteroid)
		GLOB.using_map.perform_map_generation()

	// Create robolimbs for chargen.
	populate_robolimb_list()

	job_master = new /datum/controller/occupations()
	job_master.SetupOccupations(setup_titles=1)
	job_master.LoadJobs("config/jobs.toml")

	GLOB.syndicate_code_phrase = generate_code_phrase()
	GLOB.code_phrase_highlight_rule = generate_code_regex(GLOB.syndicate_code_phrase, @"\u0430-\u0451") // Russian chars only
	GLOB.syndicate_code_response = generate_code_phrase()
	GLOB.code_response_highlight_rule = generate_code_regex(GLOB.syndicate_code_response, @"\u0430-\u0451") // Russian chars only

	//Create colors for different poisonous lizards
	var/list/toxin_color = list()
	toxin_color["notoxin"] = hex2rgb(rand_hex_color())
	var/list/toxin_list = POSSIBLE_LIZARD_TOXINS
	for(var/T in toxin_list)
		toxin_color[T] = hex2rgb(rand_hex_color())
	GLOB.lizard_colors = toxin_color

	transfer_controller = new
	. = ..()

// I have no other ideas how to do this. Moreover, it won't work for anything but walls and windows, since things like tables would need 256 baked states instead of 16, due to diagonals. Fuck my life. ~ToTh
/datum/controller/subsystem/misc/proc/BakeBitmaskOverlays()
	var/icon/masks_icon = GLOB.using_map.legacy_mode ? 'icons/turf/wall_masks_legacy.dmi' : 'icons/turf/wall_masks.dmi'
	GLOB.bitmask_icon_sheets["wall_solid"] = _bake_overlays(masks_icon, "solid")
	GLOB.bitmask_icon_sheets["wall_stone"] = _bake_overlays(masks_icon, "stone")
	GLOB.bitmask_icon_sheets["wall_metal"] = _bake_overlays(masks_icon, "metal")
	GLOB.bitmask_icon_sheets["wall_cult"]  = _bake_overlays(masks_icon, "cult")
	GLOB.bitmask_icon_sheets["wall_curvy"] = _bake_overlays(masks_icon, "curvy")
	GLOB.bitmask_icon_sheets["wall_brick"] = _bake_overlays(masks_icon, "brick")
	GLOB.bitmask_icon_sheets["wall_jaggy"] = _bake_overlays(masks_icon, "jaggy")
	GLOB.bitmask_icon_sheets["wall_thalamus"] = _bake_overlays(masks_icon, "thalamus")

	GLOB.bitmask_icon_sheets["wall_reinf_over"]  = _bake_overlays(masks_icon, "reinf_over")
	GLOB.bitmask_icon_sheets["wall_reinf_stone"] = _bake_overlays(masks_icon, "reinf_stone")

	masks_icon = 'icons/obj/structures.dmi'
	GLOB.bitmask_icon_sheets["winborder"]   = _bake_overlays(masks_icon, "winborder")
	GLOB.bitmask_icon_sheets["winborder_r"] = _bake_overlays(masks_icon, "winborder_r")

	GLOB.bitmask_icon_sheets["window"]        = _bake_overlays(masks_icon, "window")
	GLOB.bitmask_icon_sheets["rwindow"]       = _bake_overlays(masks_icon, "rwindow")
	GLOB.bitmask_icon_sheets["twindow"]       = _bake_overlays(masks_icon, "twindow")
	GLOB.bitmask_icon_sheets["plasmawindow"]  = _bake_overlays(masks_icon, "plasmawindow")
	GLOB.bitmask_icon_sheets["plasmarwindow"] = _bake_overlays(masks_icon, "plasmarwindow")
	GLOB.bitmask_icon_sheets["blackwindow"]   = _bake_overlays(masks_icon, "blackwindow")
	GLOB.bitmask_icon_sheets["rblackwindow"]  = _bake_overlays(masks_icon, "rblackwindow")
	return

/datum/controller/subsystem/misc/proc/_bake_overlays(icon_base, icon_state_base = "")
	if(!icon_base)
		util_crash_with("Error during bitmask overlays baking! Check SS_INIT!")
		return

	var/list/possible_dirs = list()
	possible_dirs.len = 16
	var/list/cardinals = list(SOUTH, NORTH, EAST, WEST)
	for(var/i = 0, i < 16, i++)
		possible_dirs[i + 1] = list()
		var/output = ""
		for(var/j = 0, j < 4, j++)
			if((i & (1 << j)) != 0)
				output += "[cardinals[j + 1]]" + " "
				possible_dirs[i + 1].Add(cardinals[j + 1])

	var/overlay_state = 0
	var/icon/baked_sprite_sheet = icon('icons/effects/blank.dmi')
	for(var/D in possible_dirs)
		var/list/connections = D
		var/list/corners = dirs_to_corner_states(connections)

		var/icon/baked_overlay = icon('icons/effects/blank.dmi')
		for(var/i = 1 to 4)
			var/icon/corner = icon(icon_base, "[icon_state_base][corners[i]]", dir = 1<<(i-1))
			baked_overlay.Blend(corner, ICON_OVERLAY)

		overlay_state = 0
		for(var/num in connections)
			overlay_state += num

		baked_sprite_sheet.Insert(baked_overlay, "[overlay_state]")

	return baked_sprite_sheet
