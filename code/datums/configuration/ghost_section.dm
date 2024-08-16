/datum/configuration_section/ghost
	name = "ghost"

	var/allow_antag_hud
	var/antag_hud_restricted
	var/ghost_interaction
	var/ghosts_can_possess_animals
	var/allow_cult_ghostwriter
	var/req_cult_ghostwriter

/datum/configuration_section/ghost/load_data(list/data)
	CONFIG_LOAD_BOOL(allow_antag_hud, data["allow_antag_hud"])
	CONFIG_LOAD_BOOL(antag_hud_restricted, data["antag_hud_restricted"])
	CONFIG_LOAD_BOOL(ghost_interaction, data["ghost_interaction"])
	CONFIG_LOAD_BOOL(ghosts_can_possess_animals, data["ghosts_can_possess_animals"])
	CONFIG_LOAD_BOOL(allow_cult_ghostwriter, data["allow_cult_ghostwriter"])
	CONFIG_LOAD_NUM(req_cult_ghostwriter, data["req_cult_ghostwriter"])
