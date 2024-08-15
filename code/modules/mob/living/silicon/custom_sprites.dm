//list(ckey = custom_icon_state,)
//Since the ckey is used as the icon_state, the current system will only permit a single custom robot sprite per ckey.
//While it might be possible for a ckey to use that custom sprite for several real_names, it seems rather pointless to support it.
GLOBAL_LIST_EMPTY(robot_custom_icons)
GLOBAL_LIST_EMPTY(ai_custom_icons)

/datum/custom_sprite
	var/ckey
	var/sprite
	var/footstep_sound

/datum/custom_sprite/New(ckey, sprite, footstep_sound)
	src.ckey = ckey
	src.sprite = sprite
	src.footstep_sound = footstep_sound

/hook/startup/proc/load_silicon_custom_sprites()
#ifdef CUSTOM_ITEM_AI_HOLO
	for(var/datum/custom_sprite/sprite in config.custom.sprites?["ai_holo"])
		var/ckey = sprite.ckey
		var/custom_icon_state = sprite.sprite

		var/datum/ai_holo/H = new(custom_icon_state, CUSTOM_ITEM_AI_HOLO, custom_icon_state, TRUE, FALSE)
		H.ckey = ckey

		GLOB.AI_holos.Add(H)
#endif

#ifdef CUSTOM_ITEM_ROBOTS
	var/list/custom_robot_icon_states = icon_states(CUSTOM_ITEM_ROBOTS)

	for(var/datum/custom_sprite/sprite in config.custom.sprites?["robot"])
		var/ckey = sprite.ckey
		var/custom_icon_state = sprite.sprite
		var/footstep_sound = sprite.footstep_sound
		if(!length(GLOB.robot_custom_icons[ckey]))
			GLOB.robot_custom_icons[ckey] = list()

		if(!(custom_icon_state in custom_robot_icon_states))
			to_chat(src, SPAN_WARNING("Could not locate [custom_icon_state] sprite. Please report this to local developer"))
			continue

		GLOB.robot_custom_icons[ckey] += list(list("item_state" = custom_icon_state, "footstep" = footstep_sound))
#endif

#ifdef CUSTOM_ITEM_AI
	var/list/custom_ai_icon_states = icon_states(CUSTOM_ITEM_AI)
	var/custom_index = 0

	for(var/datum/custom_sprite/sprite in config.custom.sprites?["ai_core"])
		var/ckey = sprite.ckey
		var/custom_icon_state = sprite.sprite

		var/datum/ai_icon/selected_sprite

		var/alive_icon_state = "[custom_icon_state]-ai"
		var/dead_icon_state = "[custom_icon_state]-ai-crash"

		if(!(alive_icon_state in custom_ai_icon_states))
			to_chat(src, SPAN_WARNING("Custom display entry found but the icon state '[alive_icon_state]' is missing! Please report this to local developer."))
			continue

		if(!(dead_icon_state in custom_ai_icon_states))
			dead_icon_state = ""

		selected_sprite = new /datum/ai_icon("Custom Icon [custom_index++]", alive_icon_state, dead_icon_state, COLOR_WHITE, CUSTOM_ITEM_AI, ckey)

		GLOB.ai_custom_icons += selected_sprite
#endif
	return TRUE

/mob/living/silicon/robot/proc/set_custom_sprite()
	if(!(ckey in GLOB.robot_custom_icons))
		return

	if(!(custom_sprite && CUSTOM_ITEM_ROBOTS))
		return

	var/list/custom_data = GLOB.robot_custom_icons[ckey][1]
	var/custom_state = custom_data["item_state"]
	var/custom_step = custom_data["footstep"]

	module_hulls[custom_state] = new /datum/robot_hull(CUSTOM_ITEM_ROBOTS, custom_state, custom_step)
	apply_hull(custom_state)

	return TRUE
