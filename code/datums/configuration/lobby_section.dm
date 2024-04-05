/datum/configuration_section/lobby
	name = "lobby"

	var/list/splashes = list("icons/splashes/onyx_old.png", "icons/splashes/onyx_new.png")

/datum/configuration_section/lobby/load_data(list/data)
	CONFIG_LOAD_LIST(splashes, data["splashes"])

	if(splashes)
		var/lobbyscreen_file = file(pick(splashes))

		if(isfile(lobbyscreen_file))
			GLOB.current_lobbyscreen = lobbyscreen_file
