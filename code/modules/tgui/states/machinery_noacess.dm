GLOBAL_DATUM_INIT(tgui_machinery_noaccess_state, /datum/ui_state/machinery_noaccess, new)

/datum/ui_state/machinery_noaccess/can_use_topic(obj/machinery/src_object, mob/user)
	ASSERT(istype(src_object))

	if(src_object.stat & (BROKEN | NOPOWER))
		return UI_CLOSE

	return user.tgui_default_can_use_topic(src_object)
