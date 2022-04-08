GLOBAL_DATUM_INIT(tgui_debug_state, /datum/ui_state/debug_state, new)

/datum/ui_state/debug_state/can_use_topic(src_object, mob/user)
	if(check_rights(R_DEBUG, FALSE, user.client))
		return UI_INTERACTIVE
	return UI_CLOSE
