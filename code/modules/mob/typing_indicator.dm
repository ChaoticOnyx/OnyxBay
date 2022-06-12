/*Typing indicators, when a mob uses the F3/F4 keys to bring the say/emote input boxes up this little buddy is
made and follows them around until they are done (or something bad happens), helps tell nearby people that 'hey!
I AM TYPING!'
*/

/mob
	var/atom/movable/overlay/typing_indicator/typing_indicator = null

/atom/movable/overlay/typing_indicator
	icon = 'icons/mob/talk.dmi'
	icon_state = "typing"
	plane = MOUSE_INVISIBLE_PLANE
	layer = FLOAT_LAYER
	appearance_flags = DEFAULT_APPEARANCE_FLAGS | LONG_GLIDE

/atom/movable/overlay/typing_indicator/New(newloc, mob/master)
	..(newloc)
	if(master.typing_indicator)
		qdel(master.typing_indicator)

	master.typing_indicator = src
	src.master = master
	name = master.name
	glide_size = master.glide_size

	register_signal(master, SIGNAL_MOVED, /atom/movable/proc/move_to_turf_or_null)
	register_signal(master, SIGNAL_STAT_SET, /datum/proc/qdel_self) // Making the assumption master is conscious at creation.
	register_signal(master, SIGNAL_LOGGED_OUT, /datum/proc/qdel_self)
	register_signal(master, SIGNAL_QDELETING, /datum/proc/qdel_self)

/atom/movable/overlay/typing_indicator/Destroy()
	var/mob/M = master

	unregister_signal(master, SIGNAL_MOVED)
	unregister_signal(master, SIGNAL_STAT_SET)
	unregister_signal(master, SIGNAL_LOGGED_OUT)
	unregister_signal(master, SIGNAL_QDELETING)

	M.typing_indicator = null
	master = null

	. = ..()

/mob/proc/create_typing_indicator()
	if(!client || stat)
		return
	if((get_preference_value(/datum/client_preference/show_typing_indicator) == GLOB.PREF_SHOW) == (client.shift_released_at <= world.time - 2))
		new /atom/movable/overlay/typing_indicator(get_turf(src), src)

/mob/proc/remove_typing_indicator() // A bit excessive, but goes with the creation of the indicator I suppose
	QDEL_NULL(typing_indicator)

/client/proc/close_saywindow(return_content = FALSE)
	winset(src, null, "saywindow.is-visible=false;mapwindow.map.focus=true")
	if (return_content)
		. = winget(src, "saywindow.saywindow-input", "text")
	winset(src, "saywindow.saywindow-input", "text=\"\"")

/mob/verb/add_typing_indicator(is_sayinput as num|null)
	set name = ".add_typing_indicator"
	set hidden = TRUE

	ASSERT(client && src == usr)

	if (is_sayinput)
		create_typing_indicator()
		return

	var/text = winget(usr, "input", "text")
	if(findtextEx(text, "Say ", 1, 5))
		create_typing_indicator()

/mob/verb/remove_typing_indicator_verb()
	set name = ".remove_typing_indicator"
	set hidden = TRUE

	ASSERT(client && src == usr)

	remove_typing_indicator()

/mob/verb/me_wrapper()
	set name = ".Me"
	set hidden = TRUE

	create_typing_indicator()
	var/message = input("","me (text)") as text
	remove_typing_indicator()
	if(message)
		me_verb(message)

/*
/mob/Topic(href, href_list)
	if(href_list["choice"])
		switch(href_list["choice"])
			if("Say")
				var/msg = href_list["mobsay"]
				say_verb(msg)
	else
		return ..()
*/
