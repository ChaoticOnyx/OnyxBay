/datum/configuration_section/log
	name = "log"

	var/log_say = TRUE
	var/log_asay = TRUE
	var/log_emote = TRUE
	var/log_ooc = TRUE
	var/log_whisper = TRUE
	var/log_pda = TRUE
	var/log_attack = TRUE
	var/log_vote = TRUE
	var/log_admin = TRUE
	var/log_adminchat = TRUE
	var/log_adminwarn = TRUE
	var/log_access = TRUE
	var/log_game = TRUE
	var/log_debug = TRUE
	var/log_debug_verbose = TRUE
	var/log_hrefs = TRUE
	var/log_runtime = TRUE
	var/log_world_output = TRUE
	var/log_story = TRUE

/datum/configuration_section/log/load_data(list/data)
	CONFIG_LOAD_BOOL(log_say, data["log_say"])
	CONFIG_LOAD_BOOL(log_asay, data["log_asay"])
	CONFIG_LOAD_BOOL(log_emote, data["log_emote"])
	CONFIG_LOAD_BOOL(log_ooc, data["log_ooc"])
	CONFIG_LOAD_BOOL(log_whisper, data["log_whisper"])
	CONFIG_LOAD_BOOL(log_pda, data["log_pda"])
	CONFIG_LOAD_BOOL(log_attack, data["log_attack"])
	CONFIG_LOAD_BOOL(log_vote, data["log_vote"])
	CONFIG_LOAD_BOOL(log_admin, data["log_admin"])
	CONFIG_LOAD_BOOL(log_adminchat, data["log_adminchat"])
	CONFIG_LOAD_BOOL(log_adminwarn, data["log_adminwarn"])
	CONFIG_LOAD_BOOL(log_access, data["log_access"])
	CONFIG_LOAD_BOOL(log_game, data["log_game"])
	CONFIG_LOAD_BOOL(log_debug, data["log_debug"])
	CONFIG_LOAD_BOOL(log_debug_verbose, data["log_debug_verbose"])
	CONFIG_LOAD_BOOL(log_hrefs, data["log_hrefs"])
	CONFIG_LOAD_BOOL(log_runtime, data["log_runtime"])
	CONFIG_LOAD_BOOL(log_world_output, data["log_world_output"])
	CONFIG_LOAD_BOOL(log_story, data["log_story"])
