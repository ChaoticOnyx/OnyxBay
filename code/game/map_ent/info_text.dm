/obj/map_ent/info_text
	name = "info_text"
	icon_state = "info_text"

	ev_activate_at_startup = TRUE

	var/ev_text = "Hello, world!"

/obj/map_ent/info_text/activate()
	var/turf/T = get_turf(src)

	T.maptext = "<font size=3 style=\"font: 'Small Fonts';\">[ev_text]</font>"
	T.maptext_width = length_char(ev_text) * 5
	T.maptext_height = 32
