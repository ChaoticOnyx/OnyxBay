// look in config/custom_sprites.json for example.
//list(ckey = real_name,)
//Since the ckey is used as the icon_state, the current system will only permit a single custom robot sprite per ckey.
//While it might be possible for a ckey to use that custom sprite for several real_names, it seems rather pointless to support it.
GLOBAL_LIST_EMPTY(robot_custom_icons)
GLOBAL_LIST_EMPTY(ai_custom_icons)

/hook/startup/proc/load_silicon_custom_sprites()
	var/list/config_json = json_decode(file2text("config/custom_sprites.json"))
#ifdef CUSTOM_ITEM_AI_HOLO
	for(var/list/item in config_json["aiholo"])
		var/ckey = item["ckey"]
		var/real_name = item["sprite"]

		var/datum/ai_holo/H = new(real_name, CUSTOM_ITEM_AI_HOLO, real_name, TRUE, FALSE)
		H.ckey = ckey

		GLOB.AI_holos.Add(H)
#endif

#ifdef CUSTOM_ITEM_ROBOTS
	GLOB.robot_custom_icons = list()
	for(var/list/item in config_json["robot"])
		var/ckey = item["ckey"]
		var/real_name = item["sprite"]

		GLOB.robot_custom_icons[ckey] = real_name
#endif

#ifdef CUSTOM_ITEM_AI
	var/list/custom_icon_states = icon_states(CUSTOM_ITEM_AI)
	var/custom_index = 0

	for(var/list/item in config_json["aicore"])
		var/ckey = item["ckey"]
		var/real_name = item["sprite"]

		var/datum/ai_icon/selected_sprite

		var/alive_icon_state = "[real_name]-ai"
		var/dead_icon_state = "[real_name]-ai-crash"

		if(!(alive_icon_state in custom_icon_states))
			to_chat(src, SPAN("warning", "Custom display entry found but the icon state '[alive_icon_state]' is missing! Please report this to local developer."))
			continue

		if(!(dead_icon_state in custom_icon_states))
			dead_icon_state = ""

		selected_sprite = new /datum/ai_icon("Custom Icon [custom_index++]", alive_icon_state, dead_icon_state, COLOR_WHITE, CUSTOM_ITEM_AI, ckey)

		GLOB.ai_custom_icons += selected_sprite
#endif
	return 1

/mob/living/silicon/robot/proc/set_custom_sprite()
	var/rname = GLOB.robot_custom_icons[ckey]
	if(rname && CUSTOM_ITEM_ROBOTS)
		custom_sprite = TRUE
		icon = CUSTOM_ITEM_ROBOTS
		var/list/valid_states = icon_states(icon)
		if(icon_state == "robot")
			if("[ckey]-Standard" in valid_states)
				icon_state = "[ckey]-Standard"
			else
				to_chat(src, SPAN("warning", "Could not locate [ckey]-Standard sprite. Please report this to local developer"))
				icon =  'icons/mob/robots.dmi'

