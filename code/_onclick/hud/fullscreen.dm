/// Associative list of string -> object, where object is instance of `atom/movable/screen/fullscreen`.
/mob/var/list/screens = list()

/mob/proc/set_fullscreen(condition, screen_name, screen_type, arg)
	condition ? overlay_fullscreen(screen_name, screen_type, arg) : clear_fullscreen(screen_name)

/mob/proc/overlay_fullscreen(category, type, severity)
	var/atom/movable/screen/fullscreen/screen = screens[category]
	if(isnull(screen) || screen.type != type)
		clear_fullscreen(category, FALSE)
		screens[category] = screen = new type()
	else if((screen?.severity == severity) || (screen?.screen_loc != ui_fullscreen) || (client?.view == screen?.view))
		return

	screen.icon_state = "[initial(screen.icon_state)][severity]"
	screen.severity = severity

	if(client && screen.should_show_to(src))
		screen.stretch_to_view(client.view)
		client.screen += screen

/mob/proc/clear_fullscreen(category, animate = 10)
	var/atom/movable/screen/fullscreen/screen = screens[category]
	if(isnull(screen))
		return

	screens -= category

	if(!QDELETED(src) && animate)
		animate(screen, alpha = 0, time = animate)

		spawn(animate)
			client?.screen -= screen
			qdel(screen)
	else
		client?.screen -= screen
		qdel(screen)

/mob/proc/clear_fullscreens()
	for(var/category in screens)
		clear_fullscreen(category)

/mob/proc/hide_fullscreens()
	if(isnull(client))
		return

	for(var/category in screens)
		client.screen -= screens[category]

/mob/proc/reload_fullscreen()
	if(isnull(client))
		return

	var/atom/movable/screen/fullscreen/screen
	for(var/category in screens)
		screen = screens[category]

		if(screen.should_show_to(src))
			screen.stretch_to_view(client.view)
			client.screen |= screen
		else
			client.screen -= screen

//this is used for changing color of lighting backdrop
/mob/proc/set_fullscreen_color(category, new_color)
	var/atom/movable/screen/fullscreen/screen = screens[category]
	if(!screen)
		return

	screen.color = new_color

/atom/movable/screen/fullscreen
	icon = 'icons/hud/screen_full.dmi'
	icon_state = "default"
	screen_loc = ui_fullscreen
	plane = FULLSCREEN_PLANE
	layer = FULLSCREEN_LAYER
	mouse_opacity = MOUSE_OPACITY_UNCLICKABLE

	var/severity = 0
	/// String representing client's view its fitted for.
	var/view
	/// Whether it should always be visible regardless of mob's condition.
	var/allstate = FALSE

/atom/movable/screen/fullscreen/proc/should_show_to(mob/viewer)
	return allstate || !viewer.is_ooc_dead()

/atom/movable/screen/fullscreen/proc/stretch_to_view(view)
	if(screen_loc != ui_fullscreen)
		return

	var/list/temp = get_view_size(view)

	src.view = view
	transform = matrix(temp[1] / DEFAULT_FULLSCREEN_WIDTH, temp[2] / DEFAULT_FULLSCREEN_HEIGHT, MATRIX_SCALE)

/atom/movable/screen/fullscreen/brute
	icon_state = "brutedamageoverlay"
	layer = DAMAGE_LAYER

/atom/movable/screen/fullscreen/oxy
	icon_state = "oxydamageoverlay"
	layer = DAMAGE_LAYER

/atom/movable/screen/fullscreen/crit
	icon_state = "passage"
	layer = CRIT_LAYER

/atom/movable/screen/fullscreen/blind
	icon_state = "blackimageoverlay"
	layer = BLIND_LAYER

/atom/movable/screen/fullscreen/blackout
	icon = 'icons/hud/screen.dmi'
	icon_state = "black"
	screen_loc = ui_entire_screen
	layer = BLIND_LAYER

/atom/movable/screen/fullscreen/impaired
	icon_state = "impairedoverlay"
	layer = IMPAIRED_LAYER

/atom/movable/screen/fullscreen/flash
	icon = 'icons/hud/screen.dmi'
	screen_loc = ui_entire_screen
	icon_state = "flash"

/atom/movable/screen/fullscreen/flash/persistent
	icon_state = "flash_const"

/atom/movable/screen/fullscreen/red
	icon = 'icons/hud/screen.dmi'
	screen_loc = ui_entire_screen
	icon_state = "red"

/atom/movable/screen/fullscreen/high
	icon = 'icons/hud/screen.dmi'
	screen_loc = ui_entire_screen
	icon_state = "druggy"

/atom/movable/screen/fullscreen/scanline
	icon = 'icons/hud/screen.dmi'
	screen_loc = ui_entire_screen
	icon_state = "scanlines"
	allstate = TRUE
	alpha = 50

/atom/movable/screen/fullscreen/cam_corners
	icon_state = "cam_corners"
	allstate = TRUE

/atom/movable/screen/fullscreen/rec
	icon = 'icons/effects/effects.dmi'
	screen_loc = "TOP-2,WEST+2"
	icon_state = "rec"
	allstate = TRUE

/atom/movable/screen/fullscreen/fishbed
	icon_state = "fishbed"
	allstate = TRUE

/atom/movable/screen/fullscreen/pain
	icon_state = "brutedamageoverlay6"
	alpha = 0

//Provides darkness to the back of the lighting plane
/atom/movable/screen/fullscreen/lighting_backdrop
	icon = LIGHTING_ICON
	icon_state = LIGHTING_ICON_STATE_DARK
	plane = LIGHTING_PLANE
	layer = LIGHTING_LAYER
	transform = matrix(200, 0, 0, 0, 200, 0)
	blend_mode = BLEND_MULTIPLY
	color = "#ffffff" //Lighting plane colors are negative, so this is actually black.
	allstate = TRUE

/atom/movable/screen/fullscreen/lighting_backdrop/stretch_to_view(view)
	return // Special snowflake
