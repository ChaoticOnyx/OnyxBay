/mob/new_player/Login()
	SHOULD_CALL_PARENT(FALSE)
	update_Login_details()	//handles setting lastKnownIP and computer_id for use by the ban systems as well as checking for multikeying
	if(join_motd)
		to_chat(src, "<div class=\"motd\">[join_motd]</div>")
	client.show_regular_announcement()
	to_chat(src, "<div class='info'>Game ID: <div class='danger'>[game_id]</div></div>")

	if(!mind)
		mind = new /datum/mind(key)
		mind.active = 1
		mind.current = src

	loc = null
	GLOB.using_map.show_titlescreen(client)
	my_client = client
	set_sight(sight|SEE_TURFS)
	GLOB.player_list |= src

	if(!SScharacter_setup.initialized)
		SScharacter_setup.newplayers_requiring_init += src
	else
		deferred_login()

// This is called when the charcter setup system has been sufficiently initialized and prefs are available.
// Do not make any calls in mob/Login which may require prefs having been loaded.
// It is safe to assume that any UI or sound related calls will fall into that category.
/mob/new_player/proc/deferred_login()
	if(!client)
		return
	
	client.prefs.apply_post_login_preferences(client)
	client.playtitlemusic()

	// bolds the changelog button on the interface so we know there are updates.
	if(client.prefs.lastchangelog != changelog_hash)
		to_chat(client, SPAN("info", "You have unread updates in the changelog."))
		if(config.aggressive_changelog)
			client.changes()
