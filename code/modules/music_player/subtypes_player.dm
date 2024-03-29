// Boombox
/obj/item/music_player/boombox
	name = "boombox"
	desc = "A musical audio player station, also known as boombox or ghettobox. Very robust."
	icon = 'sprites/object.dmi'
	icon_state = "boombox"
	item_state = "RPED"
	color = "#444444"

	preference = /datum/client_preference/play_jukeboxes

	w_class = ITEM_SIZE_LARGE

	throwforce = 10
	throw_speed = 2
	throw_range = 10
	force = 10

	mod_handy = 0.75
	mod_reach = 0.75
	mod_weight = 1.4

/obj/item/music_player/boombox/on_update_icon()
	ClearOverlays()

	if(mode == PLAYER_STATE_PLAY)
		AddOverlays(overlay_image(icon, "[icon_state]_playing", flags = RESET_COLOR))

	if(panel == PANEL_OPENED)
		var/image/panel_open = overlay_image(icon, "[icon_state]_p-open", flags = RESET_COLOR)
		panel_open.color = color
		AddOverlays(panel_open)

		AddOverlays(overlay_image(icon, "[icon_state]_curcit", flags = RESET_COLOR))

// This one for debug pruporses
// I'll yell on you if you will use it in game without good reason >:(
/obj/item/music_player/debug
	tape = /obj/item/music_tape/custom
	icon_state = "console"
	name = "typ3n4m3-cl4ss: CRUSH/ZER0"

#undef PLAYER_STATE_OFF
#undef PLAYER_STATE_PLAY
#undef PLAYER_STATE_PAUSE

#undef PANEL_CLOSED
#undef PANEL_UNSCREWED
#undef PANEL_OPENED
