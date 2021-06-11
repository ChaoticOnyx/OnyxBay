/client/proc/edit_human_friends()
	set name = "Human Schizophrenia Controller"
	set category = "Special Verbs"
	set desc = "Control human schizophrenia"

	if(!check_rights(R_ADMIN))
		return
	holder.edit_friends()

/datum/admins/proc/edit_friends()
	if(GAME_STATE <= RUNLEVEL_SETUP)
		to_chat(usr, SPAN_DANGER("The game hasn't started yet!"))
		return

	var/out = "<meta charset=\"utf-8\"><b>The Syndicate Operations Menu</b>"
	out += "<hr><b>Friends</b></br>"
	for(var/mob/living/imaginary_friend/IF in GLOB.friend_list)
		out += "<br><b>Friend [IF.name]:</b>, host: [IF?.host?.real_name], type: [IF.friend_type]"
		out += " <a href='?src=\ref[src];friend_remove=\ref[IF];friend_action=1'>\[delete friend]</a>"
	out += "<hr><a href='?src=\ref[src];friend_add=1;friend_action=1'>\[add friend]</a><br><br>"
	show_browser(usr, out, "window=edit_friends[src]")

//If the friend goes afk, make a brand new friend. Plenty of fish in the sea of imagination.
/mob/living/imaginary_friend/proc/reroll_friend()
	if(src.client) //reconnected
		friend_initialized = TRUE
		return
	friend_initialized = FALSE
	make_friend()

/mob/living/imaginary_friend/proc/make_friend()
	get_ghost()

/mob/living/imaginary_friend/proc/get_ghost()
	set waitfor = FALSE
	if(host.stat == DEAD)
		qdel(src)
		return
	var/datum/ghosttrap/friend/S = get_ghost_trap("imaginary friend")
	S.request_player(src, "The [host.real_name] brain broke, the imaginary friend ready to appear. ", 1 MINUTE)
	addtimer(CALLBACK(src, .proc/reroll_friend), 1.1 MINUTE)
