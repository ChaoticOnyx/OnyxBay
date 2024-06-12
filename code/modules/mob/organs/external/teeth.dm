/obj/item/tooth
	name = "Human tooth"
	desc = ""
	icon = 'icons/mob/human_races/teeth.dmi'
	/// Teeth can not be re-installed after ~5 minutes from the moment they were knocked out.
	var/death_time

/obj/item/tooth/Initialize(mapload)
	. = ..()
	icon_state = "toothh_[rand(1, 3)]"
	pixel_x = rand(1,13)
	pixel_y = rand(1,13)

/obj/item/tooth/synthetic
	name = "synthetic tooth"

/obj/item/tooth/synthetic/Initialize(mapload)
	. = ..()
	icon_state = "toothr_[rand(1, 3)]"
