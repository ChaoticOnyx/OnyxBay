// TO-DO: move all mob variables to one file 'cause it's cringe. - N
/mob
	// Icon state name for speech bubble.
	var/bubble_icon = "default"

	// Icon used for the typing indicator's bubble.
	var/active_typing_indicator
	// Icon used for the thinking inicator's bubble.
	var/active_thinking_indicator

	// Is user typing in character.
	var/thinking_IC = FALSE

// Adds a typing indicator over the mob.
/mob/proc/create_typing_indicator()
	return

// Removes the typing indicator over the mob.
/mob/proc/remove_typing_indicator()
	return

// Adds a thinking indicator over the mob.
/mob/proc/create_thinking_indicator()
	return

// Removes the thinking indicator over the mob.
/mob/proc/remove_thinking_indicator()
	return

// Removes all indicators and marks mob as not speaking IC.
/mob/proc/remove_all_indicators()
	return

/mob/set_stat(new_stat)
	. = ..()
	if(.)
		remove_all_indicators()

/mob/Logout()
	remove_all_indicators()
	..()

// TO-DO: move on to TGUI say, it's just better. - N
/client/proc/close_saywindow(return_content = FALSE)
	winset(src, null, "saywindow.is-visible=false;mapwindow.map.focus=true")
	if (return_content)
		. = winget(src, "saywindow.saywindow-input", "text")
	winset(src, "saywindow.saywindow-input", "text=\"\"")
	mob.remove_all_indicators()

/mob/verb/add_speech_bubble(is_sayinput as num|null)
	set name = ".add_speech_bubble"
	set hidden = TRUE

	ASSERT(client && src == usr)

	if(is_sayinput)
		thinking_IC = TRUE
		start_typing()
		return

	var/text = winget(usr, ":input", "text")
	if(findtext(text, "Say ", 1, 5))
		thinking_IC = TRUE
		start_typing()
	else
		remove_all_indicators()

/mob/verb/remove_speech_bubble()
	set name = ".remove_speech_bubble"
	set hidden = TRUE

	ASSERT(client && src == usr)

	stop_typing()

/mob/verb/me_wrapper()
	set name = ".Me"
	set hidden = TRUE

	thinking_IC = TRUE
	start_typing()
	var/message = input("","me (text)") as text
	remove_all_indicators()
	if(message)
		me_verb(message)

/mob/proc/should_show_indicator()
	if(!client)
		return FALSE
	return (get_preference_value(/datum/client_preference/show_typing_indicator) == GLOB.PREF_SHOW) == (client.shift_released_at <= world.time - 2)

/mob/proc/start_typing()
	remove_thinking_indicator()
	if(!thinking_IC || !should_show_indicator())
		return FALSE
	create_typing_indicator()

/mob/proc/stop_typing()
	if(!src)
		return FALSE
	remove_typing_indicator()
	if(!thinking_IC || !should_show_indicator())
		return FALSE
	create_thinking_indicator()

/mob/living/create_thinking_indicator()
	if(active_thinking_indicator || active_typing_indicator || !thinking_IC || stat != CONSCIOUS)
		return FALSE
	active_thinking_indicator = create_speech_bubble_image(bubble_icon, 3, src)
	LAZYADD(overlays, active_thinking_indicator)

/mob/living/remove_thinking_indicator()
	if(!active_thinking_indicator)
		return FALSE
	LAZYREMOVE(overlays, active_thinking_indicator)
	active_thinking_indicator = null

/mob/living/create_typing_indicator()
	if(active_typing_indicator || active_thinking_indicator || !thinking_IC || stat != CONSCIOUS)
		return FALSE
	active_typing_indicator = create_speech_bubble_image(bubble_icon, 3, src)
	LAZYADD(overlays, active_typing_indicator)

/mob/living/remove_typing_indicator()
	if(!active_typing_indicator)
		return FALSE
	LAZYREMOVE(overlays, active_typing_indicator)
	active_typing_indicator = null

/mob/living/remove_all_indicators()
	thinking_IC = FALSE
	remove_thinking_indicator()
	remove_typing_indicator()
