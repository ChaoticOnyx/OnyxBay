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

/atom/movable/screen/screentip/proc/move_to_atom(atom/target, mob/user)
	if(!istype(user))
		return

	if(user.client?.pixel_x || user?.client.pixel_y)
		return

	if(!target.x || !target.y)
		return

	var/atom/screen_center = user.client.virtual_eye
	var/dx = target.x - screen_center.x
	var/dy = target.y - screen_center.y
	screen_loc = "CENTER+[dx]:8,CENTER+[dy]:32"
