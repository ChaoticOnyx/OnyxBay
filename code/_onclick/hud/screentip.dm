/atom/movable/screen/screentip
	icon = null
	icon_state = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = ui_screentip
	maptext_height = 480
	maptext_width = 480
	maptext = ""
	layer = SCREENTIP_LAYER //Added to make screentips appear above action buttons (and other /atom/movable/screen objects)
	var/datum/hud/hud

/atom/movable/screen/screentip/Destroy()
	hud = null
	return ..()

/atom/movable/screen/screentip/Initialize(mapload, datum/hud/hud)
	. = ..()
	src.hud = hud
	update_view()

/atom/movable/screen/screentip/proc/update_view()
	SIGNAL_HANDLER
	if(!hud || !hud.mymob.client?.view)
		return

	maptext_width = view_to_pixels(hud.mymob.client.view)[1]
