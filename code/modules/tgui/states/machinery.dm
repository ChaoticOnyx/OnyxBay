GLOBAL_DATUM_INIT(tgui_machinery_state, /datum/ui_state/machinery, new)

/datum/ui_state/machinery/can_use_topic(obj/machinery/src_object, mob/user)
	ASSERT(istype(src_object))

	if(src_object.stat & ( BROKEN | NOPOWER ))
		return UI_CLOSE

	if(!src_object.allowed(user))
		return UI_UPDATE

	return user.tgui_default_can_use_topic(src_object)
