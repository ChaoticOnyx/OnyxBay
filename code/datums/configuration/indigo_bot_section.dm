/datum/configuration_section/indigo_bot
	name = "indigo-bot"
	protection_state = PROTECTION_PRIVATE

	var/secret
	var/address
	var/ooc_webhook
	var/emote_webhook
	var/ahelp_webhook
	var/round_end_webhook
	var/ban_webhook
	var/bug_report_webhook

/datum/configuration_section/indigo_bot/load_data(list/data)
	CONFIG_LOAD_STR(secret, data["secret"])
	CONFIG_LOAD_STR(address, data["address"])
	CONFIG_LOAD_STR(ooc_webhook, data["ooc_webhook"])
	CONFIG_LOAD_STR(emote_webhook, data["emote_webhook"])
	CONFIG_LOAD_STR(ahelp_webhook, data["ahelp_webhook"])
	CONFIG_LOAD_STR(round_end_webhook, data["round_end_webhook"])
	CONFIG_LOAD_STR(ban_webhook, data["ban_webhook"])
	CONFIG_LOAD_STR(bug_report_webhook, data["bug_report_webhook"])
