/obj/lighting_plane
	screen_loc = "1,1"
	plane = LIGHTING_PLANE
	layer = LIGHTING_LAYER

	blend_mode = BLEND_MULTIPLY
	appearance_flags = DEFAULT_APPEARANCE_FLAGS | PLANE_MASTER | NO_CLIENT_COLOR
	// use 20% ambient lighting; be sure to add full alpha

	color = list(
			-1, 00, 00, 00,
			00, -1, 00, 00,
			00, 00, -1, 00,
			00, 00, 00, 00,
			01, 01, 01, 01
		)

	mouse_opacity = 0 // nothing on this plane is mouse-visible

/obj/lighting_general
	plane = LIGHTING_PLANE
	layer = LIGHTING_LAYER
	screen_loc = "8,8"

	icon = LIGHTING_ICON
	icon_state = LIGHTING_ICON_STATE_DARK

	color = "#ffffff"

	blend_mode = BLEND_MULTIPLY

/obj/lighting_general/Initialize()
	. = ..()
	SetTransform(scale = world.view * 2.2)

/mob
	var/obj/lighting_plane/l_plane
	var/obj/lighting_general/l_general

/mob/proc/change_light_color(new_color)
	if(l_general)
		l_general.color = new_color
