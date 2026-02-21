/datum/element/preview
	element_flags = ELEMENT_DETACH | ELEMENT_BESPOKE
	id_arg_index = 2

	/// Cached preview icon that is shared between similar elements.
	var/icon/preview_icon

/datum/element/preview/attach(datum/target, icon, icon_state)
	. = ..()
	var/list/preview_icon_states = icon_states(icon)
	if (!LAZYISIN(preview_icon_states, icon_state))
		return ELEMENT_INCOMPATIBLE

	if (!preview_icon)
		preview_icon = icon(icon, icon_state)

	register_signal(target, SIGNAL_EXAMINED, nameof(.proc/on_examined))

/datum/element/preview/proc/on_examined(mob/user, list/examine_result)
	examine_result += "Something else catches your eye. <a href='?src=\ref[src];show_preview=1'>Look closer?</a"

/datum/element/preview/detach(datum/source, ...)
	. = ..()
	source.unregister_signal(src, SIGNAL_EXAMINED)

/datum/element/preview/Topic(href, href_list)
	. = ..()
	if (href_list["show_preview"])
		tgui_interact(usr)

/datum/element/preview/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "IconPreview", "Preview")
		ui.open()

/datum/element/preview/tgui_data(mob/user)
	return list(
		"icon" = icon2base64html(preview_icon),
	)

/datum/element/preview/tgui_state(mob/user)
	return GLOB.tgui_always_state
