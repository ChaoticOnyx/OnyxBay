/mob/Logout()
	SSnano.user_logout(src) // this is used to clean up (remove) this user's Nano UIs
	SStgui && SStgui.on_logout(src)
	GLOB.player_list -= src
	log_access("Logout: [key_name(src, include_name = FALSE)]")
	handle_admin_logout()
	if(my_client)
		my_client.screen -= l_general
		my_client.screen -= l_plane
	QDEL_NULL(l_general)
	QDEL_NULL(l_plane)
	hide_client_images()
	..()

	SEND_GLOBAL_SIGNAL(SIGNAL_LOGGED_OUT, src, client)
	SEND_SIGNAL(src, SIGNAL_LOGGED_OUT, src, client)

	my_client = null
	return 1

/mob/proc/handle_admin_logout()
	if(admin_datums[ckey] && GAME_STATE == RUNLEVEL_GAME) //Only report this stuff if we are currently playing.
		var/datum/admins/holder = admin_datums[ckey]
		message_staff("[holder.rank] logout: [key_name(src)]")
		if(!GLOB.admins.len) //Apparently the admin logging out is no longer an admin at this point, so we have to check this towards 0 and not towards 1. Awell.
			message_staff("[key_name(src)] logged out - no more admins online.")
			if(config.admin.delist_when_no_admins && world.visibility)
				world.visibility = FALSE
				message_staff("Toggled hub visibility. The server is now invisible ([world.visibility]).")
