/datum/configuration_section/indigo_bot
	name = "indigo_bot"
	protection_state = PROTECTION_PRIVATE

	var/secret = null
	var/address = "127.0.0.1:4774"
	var/ooc_webhook = null
	var/emote_webhook = null
	var/ahelp_webhook = null
	var/round_end_webhook = null
	var/ban_webhook = null

/datum/configuration_section/indigo_bot/load_data(list/data)
	CONFIG_LOAD_STR(secret, data["secret"])
	CONFIG_LOAD_STR(address, data["address"])
	CONFIG_LOAD_STR(ooc_webhook, data["ooc_webhook"])
	CONFIG_LOAD_STR(emote_webhook, data["emote_webhook"])
	CONFIG_LOAD_STR(ahelp_webhook, data["ahelp_webhook"])
	CONFIG_LOAD_STR(round_end_webhook, data["round_end_webhook"])
	CONFIG_LOAD_STR(ban_webhook, data["ban_webhook"])
