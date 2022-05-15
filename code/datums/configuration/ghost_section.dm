/datum/configuration_section/ghost
	name = "ghost"

	var/allow_antag_hud = TRUE
	var/antag_hud_restricted = TRUE
	var/ghost_interaction = FALSE
	var/ghosts_can_possess_animals = FALSE
	var/allow_cult_ghostwriter = FALSE
	var/req_cult_ghostwriter = 6

/datum/configuration_section/ghost/load_data(list/data)
	CONFIG_LOAD_BOOL(allow_antag_hud, data["allow_antag_hud"])
	CONFIG_LOAD_BOOL(antag_hud_restricted, data["antag_hud_restricted"])
	CONFIG_LOAD_BOOL(ghost_interaction, data["ghost_interaction"])
	CONFIG_LOAD_BOOL(ghosts_can_possess_animals, data["ghosts_can_possess_animals"])
	CONFIG_LOAD_BOOL(allow_cult_ghostwriter, data["allow_cult_ghostwriter"])
	CONFIG_LOAD_NUM(req_cult_ghostwriter, data["req_cult_ghostwriter"])
