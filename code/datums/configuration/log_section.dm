/datum/configuration_section/log
	name = "log"

	var/say
	var/asay
	var/emote
	var/ooc
	var/whisper
	var/pda
	var/attack
	var/vote
	var/admin
	var/adminchat
	var/adminwarn
	var/access
	var/game
	var/debug
	var/debug_verbose
	var/hrefs
	var/runtime
	var/world_output
	var/story

/datum/configuration_section/log/load_data(list/data)
	CONFIG_LOAD_BOOL(say, data["say"])
	CONFIG_LOAD_BOOL(asay, data["asay"])
	CONFIG_LOAD_BOOL(emote, data["emote"])
	CONFIG_LOAD_BOOL(ooc, data["ooc"])
	CONFIG_LOAD_BOOL(whisper, data["whisper"])
	CONFIG_LOAD_BOOL(pda, data["pda"])
	CONFIG_LOAD_BOOL(attack, data["attack"])
	CONFIG_LOAD_BOOL(vote, data["vote"])
	CONFIG_LOAD_BOOL(admin, data["admin"])
	CONFIG_LOAD_BOOL(adminchat, data["adminchat"])
	CONFIG_LOAD_BOOL(adminwarn, data["adminwarn"])
	CONFIG_LOAD_BOOL(access, data["access"])
	CONFIG_LOAD_BOOL(game, data["game"])
	CONFIG_LOAD_BOOL(debug, data["debug"])
	CONFIG_LOAD_BOOL(debug_verbose, data["debug_verbose"])
	CONFIG_LOAD_BOOL(hrefs, data["hrefs"])
	CONFIG_LOAD_BOOL(runtime, data["runtime"])
	CONFIG_LOAD_BOOL(world_output, data["world_output"])
	CONFIG_LOAD_BOOL(story, data["story"])
