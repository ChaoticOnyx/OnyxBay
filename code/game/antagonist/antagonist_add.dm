/datum/antagonist/proc/add_antagonist(datum/mind/player, ignore_role, do_not_equip, move_to_spawn, do_not_announce, preserve_appearance, max_stat, team)

	if(!add_antagonist_mind(player, ignore_role, max_stat = max_stat))
		return FALSE

	//do this again, just in case
	if(flags & ANTAG_OVERRIDE_JOB)
		player.assigned_role = role_text
	player.special_role = role_text

	if(isghostmind(player) || isnewplayer(player.current))
		create_default(player.current, team)
	else
		create_antagonist(player, move_to_spawn, do_not_announce, preserve_appearance, team)
		if(!do_not_equip)
			equip(player.current)

	if(player.current)
		BITSET(player.current.hud_updateflag, SPECIALROLE_HUD)

	player.current.faction = faction
	return TRUE

/datum/antagonist/proc/add_antagonist_mind(datum/mind/player, ignore_role, nonstandard_role_type, nonstandard_role_msg, max_stat)
	if(!istype(player))
		return FALSE
	if(!player.current)
		return FALSE
	if(player in current_antagonists)
		return FALSE
	if(!can_become_antag(player, ignore_role, max_stat = max_stat))
		return FALSE
	current_antagonists |= player

	if(faction_verb)
		player.current.verbs |= faction_verb

	if(config.gamemode.disable_objectives == CONFIG_OBJECTIVE_VERB)
		player.current.verbs += /mob/proc/add_objectives

	if(player.current.client)
		player.current.client.verbs += /client/proc/aooc

	spawn(1 SECOND) //Added a delay so that this should pop up at the bottom and not the top of the text flood the new antag gets.
		to_chat(player.current, SPAN("notice", "Once you decide on a goal to pursue, you can optionally display it to \
			everyone at the end of the shift with the <b>Set Ambition</b> verb, located in the IC tab.  You can change this at any time, \
			and it otherwise has no bearing on your round."))
	player.current.verbs += /mob/living/proc/write_ambition

	if(player.assigned_role == "Clown")
		to_chat(player.current, SPAN("notice", "Your diligent training has helped you overcome your clownish nature."))
		player.current.mutations = list()

	// Handle only adding a mind and not bothering with gear etc.
	if(nonstandard_role_type)
		faction_members |= player
		to_chat(player.current, SPAN("danger", "<font size=3>You are \a [nonstandard_role_type]!</font>"))
		player.special_role = nonstandard_role_type
		if(nonstandard_role_msg)
			to_chat(player.current, SPAN("notice", "[nonstandard_role_msg]"))
		update_icons_added(player)
		BITSET(player.current.hud_updateflag, SPECIALROLE_HUD)

	return TRUE

/datum/antagonist/proc/remove_antagonist(datum/mind/player, show_message, implanted)
	if(!istype(player))
		return 0
	if(player.current && faction_verb)
		player.current.verbs -= faction_verb
	if(player in current_antagonists)
		to_chat(player.current, "<span class='danger'><font size = 3>You are no longer a [role_text]!</font></span>")
		current_antagonists -= player
		faction_members -= player
		player.special_role = null
		update_icons_removed(player)

		if(player.current)
			BITSET(player.current.hud_updateflag, SPECIALROLE_HUD)

		if(!is_special_character(player))
			if(player.current)
				player.current.verbs -= /mob/living/proc/write_ambition
				if(player.current.client)
					player.current.client.verbs -= /client/proc/aooc
			player.ambitions = ""
		return 1
	return 0
