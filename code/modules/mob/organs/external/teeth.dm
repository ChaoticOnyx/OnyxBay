/obj/item/tooth
	icon = 'icons/mob/human_races/teeth.dmi'

/obj/item/tooth/Initialize(mapload)
	. = ..()
	icon_state = "toothh_[rand(1, 3)]"
	pixel_x = rand(1,13)
	pixel_y = rand(1,13)
