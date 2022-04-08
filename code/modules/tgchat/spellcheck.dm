/client/proc/spellcheck(message)
	if(!message || get_preference_value(/datum/client_preference/tgui_chat) != GLOB.PREF_YES)
		return

	tgui_panel?.window.send_message("chat/spellcheck", message)
