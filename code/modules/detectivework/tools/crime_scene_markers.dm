#define PIXEL_DROPPED -6

/obj/item/storage/csmarkers
	name = "crime scene markers kit"
	desc = "A box containing crime scene markers."
	icon = 'icons/obj/forensics.dmi'
	icon_state = "marker_box"
	w_class = ITEM_SIZE_SMALL
	can_hold = list(/obj/item/crime_scene_marker)

/obj/item/storage/csmarkers/Initialize()
	. = ..()
	for(var/i = 1 to 7)
		new /obj/item/crime_scene_marker(src, i)
	make_exact_fit()

/obj/item/crime_scene_marker
	name = "crime scene marker"
	desc = "Stay organized during investigation."
	icon = 'icons/obj/forensics.dmi'
	icon_state = "card"
	w_class = ITEM_SIZE_TINY
	layer = BASE_ABOVE_OBJ_LAYER
	randpixel = 2
	can_get_wet = FALSE
	can_be_wrung_out = FALSE

/obj/item/crime_scene_marker/Initialize(loc, number)
	. = ..()
	icon_state = "[icon_state][number]"

/obj/item/crime_scene_marker/dropped()
	pixel_y = PIXEL_DROPPED
	pixel_x = PIXEL_DROPPED
	return ..()

#undef PIXEL_DROPPED
