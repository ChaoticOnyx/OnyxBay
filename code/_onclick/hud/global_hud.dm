/*
	The global hud:
	Uses the same visual objects for all players.
*/

GLOBAL_DATUM_INIT(global_hud, /datum/global_hud, new())

/datum/global_hud
	var/atom/movable/screen/nvg
	var/atom/movable/screen/thermal
	var/atom/movable/screen/meson
	var/atom/movable/screen/science
	var/atom/movable/screen/material
	var/atom/movable/screen/gasmask
	var/atom/movable/screen/darktint

/datum/global_hud/proc/setup_overlay(icon_state)
	var/atom/movable/screen/screen = new /atom/movable/screen()
	screen.screen_loc = ui_entire_screen
	screen.icon = 'icons/hud/screen.dmi'
	screen.icon_state = icon_state
	screen.mouse_opacity = 0

	return screen

/datum/global_hud/New()
	nvg = setup_overlay("nvg_hud")
	thermal = setup_overlay("thermal_hud")
	meson = setup_overlay("meson_hud")
	science = setup_overlay("science_hud")
	material = setup_overlay("material_hud")
	gasmask = setup_overlay("gasmask_hud")
	darktint = setup_overlay("darktint_hud")
