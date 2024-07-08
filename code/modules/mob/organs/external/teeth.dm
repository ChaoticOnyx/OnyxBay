/obj/item/tooth
	name = "Human tooth"
	desc = "Someone had their teeth knocked out."
	icon = 'icons/mob/human_races/teeth.dmi'
	/// Teeth can not be re-installed after ~5 minutes from the moment they were knocked out.
	var/death_time
	/// Whether this tooth will be shown in examine.
	var/shown_in_examine = FALSE
	can_get_wet = FALSE
	can_be_wrung_out = FALSE

/obj/item/tooth/Initialize(mapload)
	. = ..()
	icon_state = "toothh_[rand(1, 3)]"
	pixel_x = rand(1,13)
	pixel_y = rand(1,13)

/obj/item/tooth/unathi
	name = "Unathi tooth"

/obj/item/tooth/unathi/Initialize(mapload)
	. = ..()
	icon_state = "toothu_[rand(1 ,3)]"

/obj/item/tooth/prosthetic
	name = "prosthetic tooth"

/obj/item/tooth/prosthetic/Initialize(mapload)
	. = ..()
	icon_state = "toothp_[rand(1, 3)]"

/obj/item/tooth/robotic
	name = "robotic tooth"
	shown_in_examine = TRUE

/obj/item/tooth/robotic/Initialize(mapload)
	. = ..()
	icon_state = "toothr_[rand(1, 3)]"
