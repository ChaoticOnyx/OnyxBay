// ========== BOMB DEFUSAL - ARENA MAP TEMPLATE ==========

/datum/map_template/bombdefusal_arena
	name = "Bomb Defusal Arena"
	returns_created_atoms = TRUE
	// mappaths is set dynamically from the selected map

// ===== MAP REGISTRY =====

/datum/bombdefusal_map
	var/name = "Unknown"
	var/map_path = ""
	var/description = ""
	var/t_extra_freeze = 0  // Extra freeze time (in ticks) for T side after round start
	var/ct_extra_freeze = 0 // Extra freeze time (in ticks) for CT side after round start

/datum/bombdefusal_map/de_pervayaoperacionnaya
	name = "de_pervayaoperacionnaya"
	map_path = "maps/csgo/de_pervayaoperacionnaya.dmm"
	description = "NSS Exodus but cool."
	t_extra_freeze = 70 // 7 seconds extra freeze for T

/datum/bombdefusal_map/de_dust2
	name = "de_dust2"
	map_path = "maps/csgo/de_dust2.dmm"
	description = "Dust 2. You know the one."

/datum/bombdefusal_map/de_inferno
	name = "de_inferno"
	map_path = "maps/csgo/de_inferno.dmm"
	description = "A tight, smoky italian village."

// ===== MAP SELECTION =====

/datum/game_mode/bombdefusal/var/datum/bombdefusal_map/selected_map
/datum/game_mode/bombdefusal/var/list/datum/bombdefusal_map/available_maps

/datum/game_mode/bombdefusal/proc/init_map_registry()
	available_maps = list()
	for(var/map_type in subtypesof(/datum/bombdefusal_map))
		var/datum/bombdefusal_map/M = new map_type()
		if(M.map_path && fexists(M.map_path))
			available_maps += M
		else
			qdel(M)

/datum/game_mode/bombdefusal/proc/get_random_map()
	if(!available_maps || !available_maps.len)
		init_map_registry()
	if(!available_maps.len)
		return null
	return pick(available_maps)

/datum/game_mode/bombdefusal/proc/select_map(datum/bombdefusal_map/map)
	selected_map = map

/datum/game_mode/bombdefusal/proc/get_selected_map_path()
	if(!selected_map)
		selected_map = get_random_map()
	if(!selected_map)
		return "maps/csgo/de_pervayaoperacionnaya.dmm" // fallback
	return selected_map.map_path
