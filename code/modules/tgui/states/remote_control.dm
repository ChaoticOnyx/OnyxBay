GLOBAL_DATUM_INIT(remote_control_state, /datum/ui_state/remote_control, new)

/datum/ui_state/remote_control/can_use_topic(src_object, mob/user)
	if(hascall(src_object, "tgui_remote_control_status"))
		return call(src_object, "tgui_remote_control_status")(user)

	return GLOB.tgui_default_state.can_use_topic(src_object, user)
