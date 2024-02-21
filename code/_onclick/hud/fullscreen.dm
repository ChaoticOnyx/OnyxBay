
/mob
	var/list/screens = list()

/mob/proc/set_fullscreen(condition, screen_name, screen_type, arg)
	condition ? overlay_fullscreen(screen_name, screen_type, arg) : clear_fullscreen(screen_name)

/mob/proc/set_renderer_filter(condition, renderer_name = SCENE_GROUP_RENDERER, filter_name, priority, list/params)
	if(isnull(renderers))
		return FALSE

	if(!(renderer_name in renderers))
		return FALSE

	condition?renderers[renderer_name].add_filter(filter_name, priority, params) : renderers[renderer_name].remove_filter(filter_name)

/mob/proc/overlay_fullscreen(category, type, severity)
	var/atom/movable/screen/fullscreen/screen = screens[category]

	if(screen)
		if(screen.type != type)
			clear_fullscreen(category, FALSE)
			screen = null
		else if(!severity || severity == screen.severity)
			return null

	if(!screen)
		screen = new type()

	screen.icon_state = "[initial(screen.icon_state)][severity]"
	screen.severity = severity

	screens[category] = screen
	if(client && (!is_ooc_dead() || screen.allstate))
		client.screen += screen
	return screen

/mob/proc/clear_fullscreen(category, animated = 10)
	var/atom/movable/screen/fullscreen/screen = screens[category]
	if(!screen)
		return

	screens -= category

	if(animated)
		spawn(0)
			animate(screen, alpha = 0, time = animated)
			sleep(animated)
			if(client)
				client.screen -= screen
			qdel(screen)
	else
		if(client)
			client.screen -= screen
		qdel(screen)

/mob/proc/clear_fullscreens()
	for(var/category in screens)
		clear_fullscreen(category)

/mob/proc/hide_fullscreens()
	if(client)
		for(var/category in screens)
			client.screen -= screens[category]

/mob/proc/reload_fullscreen()
	if(client)
		for(var/category in screens)
			client.screen |= screens[category]

//this is used for changing color of lighting backdrop
/mob/proc/set_fullscreen_color(category, new_color)
	var/atom/movable/screen/fullscreen/screen = screens[category]
	if(!screen)
		return

	screen.color = new_color

/atom/movable/screen/fullscreen
	icon = 'icons/hud/screen_full.dmi'
	icon_state = "default"
	screen_loc = "CENTER-7,CENTER-7"
	plane = FULLSCREEN_PLANE
	layer = FULLSCREEN_LAYER
	mouse_opacity = 0
	var/severity = 0
	var/allstate = 0 //shows if it should show up for dead people too

/atom/movable/screen/fullscreen/Destroy()
	severity = 0
	return ..()

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
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	layer = BLIND_LAYER

/atom/movable/screen/fullscreen/impaired
	icon_state = "impairedoverlay"
	layer = IMPAIRED_LAYER

/atom/movable/screen/fullscreen/blurry
	icon = 'icons/hud/screen.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "blurry"

/atom/movable/screen/fullscreen/flash
	icon = 'icons/hud/screen.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "flash"

/atom/movable/screen/fullscreen/flash/noise
	icon_state = "noise"

/atom/movable/screen/fullscreen/flash/persistent
	icon_state = "flash_const"

/atom/movable/screen/fullscreen/red
	icon = 'icons/hud/screen.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "red"

/atom/movable/screen/fullscreen/high
	icon = 'icons/hud/screen.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "druggy"

/atom/movable/screen/fullscreen/noise
	icon = 'icons/effects/static.dmi'
	icon_state = "1 light"
	screen_loc = ui_entire_screen
	alpha = 127

/atom/movable/screen/fullscreen/fadeout
	icon = 'icons/hud/screen.dmi'
	icon_state = "black"
	screen_loc = ui_entire_screen
	alpha = 0
	allstate = 1

/atom/movable/screen/fullscreen/fadeout/Initialize()
	. = ..()
	animate(src, alpha = 255, time = 10)

/atom/movable/screen/fullscreen/scanline
	icon = 'icons/effects/static.dmi'
	icon_state = "scanlines"
	screen_loc = ui_entire_screen
	alpha = 50
	blend_mode = BLEND_DEFAULT

/atom/movable/screen/fullscreen/cam_corners
	icon = 'icons/hud/screen_full.dmi'
	icon_state = "cam_corners"
	allstate = 1
	blend_mode = BLEND_OVERLAY

/atom/movable/screen/fullscreen/fishbed
	icon_state = "fishbed"
	allstate = 1

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
