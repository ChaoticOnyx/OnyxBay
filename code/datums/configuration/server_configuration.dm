var/list/gamemode_cache = list()

/// Global configuration datum holder for all the config sections.
GLOBAL_REAL(config, /datum/server_configuration) = new

/// Represents a base configuration datum. Has everything else bundled into it
/datum/server_configuration
	var/datum/configuration_section/admin/admin = new
	var/datum/configuration_section/ban/ban = new
	var/datum/configuration_section/character_setup/character_setup = new
	var/datum/configuration_section/custom/custom = new
	var/datum/configuration_section/database/database = new
	var/datum/configuration_section/donations/donations = new
	var/datum/configuration_section/error/error = new
	var/datum/configuration_section/events/events = new
	var/datum/configuration_section/external/external = new
	var/datum/configuration_section/game/game = new
	var/datum/configuration_section/gamemode/gamemode = new
	var/datum/configuration_section/general/general = new
	var/datum/configuration_section/ghost/ghost = new
	var/datum/configuration_section/health/health = new
	var/datum/configuration_section/indigo_bot/indigo_bot = new
	var/datum/configuration_section/jobs/jobs = new
	var/datum/configuration_section/link/link = new
	var/datum/configuration_section/log/log = new
	var/datum/configuration_section/mapping/mapping = new
	var/datum/configuration_section/misc/misc = new
	var/datum/configuration_section/movement/movement = new
	var/datum/configuration_section/multiaccount/multiaccount = new
	var/datum/configuration_section/revival/revival = new
	var/datum/configuration_section/texts/texts = new
	var/datum/configuration_section/vote/vote = new
	var/datum/configuration_section/whitelist/whitelist = new

	/// Raw data. Stored here to avoid passing data between procs constantly
	var/list/raw_data = list()

/datum/server_configuration/proc/create_gamemodes_cache()
	var/list/L = typesof(/datum/game_mode) - /datum/game_mode

	for (var/T in L)
		// I wish I didn't have to instance the game modes in order to look up
		// their information, but it is the only way (at least that I know of).
		var/datum/game_mode/M = new T()
		log_to_dd("Initialized game mode [M.config_tag]")

		if (M.config_tag)
			gamemode_cache[M.config_tag] = M // So we don't instantiate them repeatedly.

/datum/server_configuration/Destroy(force)
	SHOULD_CALL_PARENT(FALSE)
	// This is going to stay existing. I dont care.
	return QDEL_HINT_LETMELIVE

/datum/server_configuration/VV_hidden()
	return list("raw_data")

/datum/server_configuration/VV_static()
	return list("raw_data")

/datum/server_configuration/proc/load_configuration()
	#define RUSTG_CHECK(expr) do { var/ret = expr; if(ret != "") { CRASH(ret) } } while(FALSE)

	create_gamemodes_cache()

	RUSTG_CHECK(rustg_cfg_begin_builder())
	RUSTG_CHECK(rustg_cfg_add_source_glob("config/default/**/*"))

	var/mode = world.GetConfig("env", "MODE")

	if(mode)
		RUSTG_CHECK(rustg_cfg_add_source_glob("config/[mode]/**/*"))

	var/server_id = world.GetConfig("env", "ONYXBAY__GENERAL__SERVER_ID")

	if(server_id)
		RUSTG_CHECK(rustg_cfg_add_source_glob("config/[server_id]/**/*"))

	RUSTG_CHECK(rustg_cfg_add_source_env("ONYXBAY", "__"))
	RUSTG_CHECK(rustg_cfg_end_builder())

	raw_data = json_decode(rustg_cfg_try_deserialize())

	// Now pass through all our stuff
	load_all_sections()

	// Clear our list to save RAM
	raw_data = list()

	#undef RUSTG_CHECK

/datum/server_configuration/proc/load_all_sections()
	for(var/V in vars)
		if(!istype(vars[V], /datum/configuration_section))
			continue

		var/datum/configuration_section/section = vars[V]

		if(!raw_data[section.name])
			continue

		section.load_data(raw_data[section.name])

/datum/server_configuration/proc/get_runnable_modes_for_players(totalPlayers)
	var/list/runnable_modes = list()

	for(var/game_mode in gamemode_cache)
		var/datum/game_mode/M = gamemode_cache[game_mode]
		if(M && M.isStartRequirementsSatisfied(totalPlayers) && !isnull(config.gamemode.probabilities[M.config_tag]) && config.gamemode.probabilities[M.config_tag] > 0)
			runnable_modes[M.config_tag] = config.gamemode.probabilities[M.config_tag]
	return runnable_modes

/datum/server_configuration/proc/get_votable_modes()
	var/list/votables = list()

	for(var/datum/game_mode/M in gamemode_cache)
		if(M.votable)
			votables += M

	return votables
