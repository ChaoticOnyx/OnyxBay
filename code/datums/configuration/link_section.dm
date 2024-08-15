/datum/configuration_section/link
	name = "link"

	var/wiki
	var/rules
	var/backstory
	var/discord
	var/github
	var/forum
	var/banappeals
	var/boosty

/datum/configuration_section/link/load_data(list/data)
	CONFIG_LOAD_STR(wiki, data["wiki"])
	CONFIG_LOAD_STR(rules, data["rules"])
	CONFIG_LOAD_STR(backstory, data["backstory"])
	CONFIG_LOAD_STR(discord, data["discord"])
	CONFIG_LOAD_STR(github, data["github"])
	CONFIG_LOAD_STR(forum, data["forum"])
	CONFIG_LOAD_STR(banappeals, data["banappeals"])
	CONFIG_LOAD_STR(boosty, data["boosty"])
