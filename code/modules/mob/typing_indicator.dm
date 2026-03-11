/// Checks whether a typing indicator should be created, 'FALSE' by default
/mob/proc/should_show_typing_indicator()
	return FALSE

/// Adds a typing indicator over the mob.
/mob/proc/create_typing_indicator()
	return

/// Removes the typing indicator over the mob.
/mob/proc/remove_typing_indicator()
	return

/// Adds a thinking indicator over the mob.
/mob/proc/create_thinking_indicator()
	return

/// Removes the thinking indicator over the mob.
/mob/proc/remove_thinking_indicator()
	return

/// Removes all indicators and marks mob as not speaking IC.
/mob/proc/remove_all_indicators()
	return

/mob/set_stat(new_stat)
	. = ..()
	if(.)
		remove_all_indicators()

/mob/Logout()
	remove_all_indicators()
	..()

/client/proc/open_saywindow()
	// I know it looks weird, believe me I do. But this is the way.
	if(winget(src, "saywindow", "is-visible") == "false")
		winset(src, null, "saywindow.is-visible=true;saywindow-input.focus=true")

/client/proc/close_saywindow(return_content = FALSE)
	winset(src, null, "saywindow.is-visible=false;mapwindow.map.focus=true")
	if (return_content)
		. = winget(src, "saywindow.saywindow-input", "text")
	winset(src, "saywindow.saywindow-input", "text=\"\"")
	mob.remove_speech_bubble()

/mob/verb/add_speech_bubble(is_sayinput as num|null)
	set name = ".add_speech_bubble"
	set hidden = TRUE

	_add_speech_bubble(is_sayinput)

/mob/proc/_add_speech_bubble(is_sayinput)
	return

/mob/living/_add_speech_bubble(is_sayinput)
	if(!client)
		return

	thinking_silent = should_show_typing_indicator()

	if(is_sayinput)
		thinking_IC = TRUE
		start_typing()
		return

	var/text = winget(src, ":input", "text")
	if(findtext(text, "Say ", 1, 5))
		thinking_IC = TRUE
		start_typing()
		return

/mob/verb/remove_speech_bubble()
	set name = ".remove_speech_bubble"
	set hidden = TRUE

	_remove_speech_bubble()

/mob/proc/_remove_speech_bubble()
	return

/mob/living/_remove_speech_bubble()
	if(client)
		var/visible = winget(src, "saywindow", "is-visible")
		if(cmptext(visible, "true"))
			stop_typing()
			return

	if(client) // Apparently it can get lost since the last check because winget() sleeps the proc as it checks the client's skin state.
		var/focus = winget(src, ":input", "focus")
		if(cmptext(focus, "false"))
			var/text = winget(src, ":input", "text")
			if(findtext(text, "Say ", 1, 5) && length(text) > 5)
				stop_typing()
				return

	remove_all_indicators()

/mob/verb/me_wrapper()
	set name = ".Me"
	set hidden = TRUE

	thinking_IC = TRUE
	start_typing()
	var/message = input("","me (text)") as text
	remove_all_indicators()
	if(message)
		me_verb(message)

/mob/proc/start_typing()
	remove_thinking_indicator()
	if(!thinking_IC || thinking_silent)
		return FALSE
	create_typing_indicator()

/mob/proc/stop_typing()
	if(!src)
		return FALSE
	remove_typing_indicator()
	if(!thinking_IC || thinking_silent)
		return FALSE
	create_thinking_indicator()

/mob/living/should_show_typing_indicator()
	if(!client)
		return FALSE
	var/pref = cmptext(get_preference_value("SHOW_TYPING"), GLOB.PREF_SHOW)
	return client.shift_released_at <= world.time - 2 ? !pref : pref

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
