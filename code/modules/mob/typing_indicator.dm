/*Typing indicators, when a mob uses the F3/F4 keys to bring the say/emote input boxes up this little buddy is
made and follows them around until they are done (or something bad happens), helps tell nearby people that 'hey!
I IS TYPIN'!'
*/

/mob
	var/atom/movable/overlay/typing_indicator/typing_indicator = null

/atom/movable/overlay/typing_indicator
	icon = 'icons/mob/talk.dmi'
	icon_state = "typing"
	plane = MOUSE_INVISIBLE_PLANE
	layer = FLOAT_LAYER

/atom/movable/overlay/typing_indicator/New(newloc, mob/master)
	..(newloc)
	if(master.typing_indicator)
		qdel(master.typing_indicator)

	master.typing_indicator = src
	src.master = master
	name = master.name

	GLOB.moved_event.register(master, src, /atom/movable/proc/move_to_turf_or_null)

	GLOB.stat_set_event.register(master, src, /datum/proc/qdel_self) // Making the assumption master is conscious at creation
	GLOB.logged_out_event.register(master, src, /datum/proc/qdel_self)
	GLOB.destroyed_event.register(master, src, /datum/proc/qdel_self)

/atom/movable/overlay/typing_indicator/Destroy()
	var/mob/M = master

	GLOB.moved_event.unregister(master, src)
	GLOB.stat_set_event.unregister(master, src)
	GLOB.logged_out_event.unregister(master, src)
	GLOB.destroyed_event.unregister(master, src)

	M.typing_indicator = null
	master = null

	. = ..()

/mob/proc/create_typing_indicator()
	if(client && !stat && get_preference_value(/datum/client_preference/show_typing_indicator) == GLOB.PREF_SHOW)
		new /atom/movable/overlay/typing_indicator(get_turf(src), src)

/mob/proc/remove_typing_indicator() // A bit excessive, but goes with the creation of the indicator I suppose
	QDEL_NULL(typing_indicator)


/client/proc/show_saywindow()
	winset(src, "saywindow", "is-visible=true;focus=true")

/client/proc/center_and_show_saywindow()
	first_say = FALSE
	var/our_size = winget(src, "saywindow", "outer-size")
	var/list/our_size_split = splittext(our_size, "x")
	var/our_size_x = text2num(our_size_split[1])
	var/our_size_y = text2num(our_size_split[2])
	var/main_params = winget(src, "mainwindow", "outer-size;pos;is-maximized")
	var/list/main_params_parsed = params2list(main_params)
	var/maximized = main_params_parsed["is-maximized"] == "true"
	var/list/main_pos = splittext(main_params_parsed["pos"], ",")
	var/main_pos_x = maximized ? 0 : text2num(main_pos[1])
	var/main_pos_y = maximized ? 0 : text2num(main_pos[2])
	var/list/main_size = splittext(main_params_parsed["outer-size"], "x")
	var/main_size_x = text2num(main_size[1])
	var/main_size_y = text2num(main_size[2])

	var/resulting_x = main_pos_x + main_size_x / 2 - our_size_x / 2
	var/resulting_y = main_pos_y + main_size_y / 2 - our_size_y / 2

	winset(src, "saywindow", "is-visible=true;focus=true;pos=[resulting_x],[resulting_y]")

/client/proc/close_saywindow()
	var/text = winget(src, "saywindow.sayinput", "text")
	winset(src, "saywindow", "is-visible=false;focus=false")
	winset(src, "saywindow.sayinput", "text=\"\"")
	return text

/mob/verb/say_wrapper()
	set name = "Say verb"
	set category = "IC"

	ASSERT(client && usr == src)

	create_typing_indicator()
	if (!client.first_say)
		client.show_saywindow()
		return
	client.center_and_show_saywindow()

/mob/verb/me_wrapper()
	set name = ".Me"
	set hidden = 1

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
