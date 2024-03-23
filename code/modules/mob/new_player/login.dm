/atom/movable/screen/splash
	name = "Chaotic Onyx"
	desc = "This shouldn't be read."
	screen_loc = "WEST,SOUTH"
	icon = 'maps/exodus/exodus_lobby.dmi'
	icon_state = "title"
	layer = FULLSCREEN_LAYER
	plane = FULLSCREEN_PLANE
	var/client/holder

/atom/movable/screen/splash/New(client/C, visible) //TODO: Make this use INITIALIZE_IMMEDIATE, except its not easy
	. = ..()

	holder = C

	if(!visible)
		alpha = 0

	holder.screen += src
	icon_state = ""
	icon = GLOB.current_lobbyscreen

/atom/movable/screen/splash/proc/Fade(out, qdel_after = TRUE)
	if(QDELETED(src))
		return
	if(out)
		animate(src, alpha = 0, time = 30)
	else
		alpha = 0
		animate(src, alpha = 255, time = 30)
	if(qdel_after)
		QDEL_IN(src, 30)

/atom/movable/screen/splash/Destroy()
	if(holder)
		holder.screen -= src
		holder = null
	return ..()

/mob/new_player/Login()
	SHOULD_CALL_PARENT(FALSE)
	update_Login_details()	//handles setting lastKnownIP and computer_id for use by the ban systems as well as checking for multikeying
	if(join_motd)
		to_chat(src, "<div class=\"motd\">[join_motd]</div>")
	client.show_regular_announcement()
	to_chat(src, "<div class='info'>Game ID: <div class='danger'>[GLOB.round_id]</div></div>")

	if(!mind)
		mind = new /datum/mind(key)
		mind.active = 1
		mind.set_current(src)

	loc = null
	my_client = client
	set_sight(sight|SEE_OBJS|SEE_TURFS)
	GLOB.player_list |= src
	new /atom/movable/screen/splash(client, TRUE)

	if(!SScharacter_setup.initialized)
		SScharacter_setup.newplayers_requiring_init += src
	else
		deferred_login()

/mob/new_player/proc/handle_changelog()
	if(client.prefs.lastchangelog == changelog_hash)
		return

	client.prefs.lastchangelog = changelog_hash
	SScharacter_setup.queue_preferences_save(client.prefs)

	to_chat(client, SPAN("info", "You have unread updates in the changelog."))

	if(config.general.aggressive_changelog)
		client.changes()

// This is called when the charcter setup system has been sufficiently initialized and prefs are available.
// Do not make any calls in mob/Login which may require prefs having been loaded.
// It is safe to assume that any UI or sound related calls will fall into that category.
/mob/new_player/proc/deferred_login()
	if(!client)
		return

	client.prefs.apply_post_login_preferences(client)
	client.playtitlemusic()

	new_player_panel(TRUE)
	handle_changelog()
