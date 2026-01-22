/obj/structure/table/rack
	name = "rack"
	desc = "Different from the Middle Ages version."
	icon = 'icons/obj/objects.dmi'
	icon_state = "rack"
	can_plate = 0
	can_reinforce = 0
	flipped = -1
	turf_height_offset = 5

	var/has_overlay = TRUE

/obj/structure/table/rack/New()
	..()
	verbs -= /obj/structure/table/verb/do_flip
	verbs -= /obj/structure/table/proc/do_put

/obj/structure/table/rack/Initialize()
	auto_align()
	. = ..()
	if(has_overlay)
		AddOverlays(OVERLAY(icon, "[icon_state]over", layer = DEPTH_OVERLAY_LAYER))

/obj/structure/table/rack/update_connections()
	return

/obj/structure/table/rack/update_desc()
	return

/obj/structure/table/rack/on_update_icon()
	return

/obj/structure/table/rack/can_connect()
	return FALSE

/obj/structure/table/rack/headbumped()
	return

/obj/structure/table/rack/can_be_crawled_under()
	return FALSE

/obj/structure/table/rack/dark
	color = COLOR_GRAY40

/obj/structure/table/rack/bograck
	name = "strange rack"
	desc = "Must be the color."
	icon_state = "bograck"

/obj/structure/table/rack/alt
	desc = "This one looks a bit different. Or is it?"
	icon_state = "rack_alt"

