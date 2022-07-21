/obj/map_ent/info_maptext
	name = "info_maptext"
	icon_state = "info_maptext"

	ev_activate_at_startup = TRUE

	var/ev_text = "Hello, world!"

/obj/map_ent/info_maptext/activate()
	var/turf/T = get_turf(src)

	T.maptext = "<font size=3 style=\"font: 'Small Fonts';\">[ev_text]</font>"
	T.maptext_width = length_char(ev_text) * 5
	T.maptext_height = 32
