// Landmarks activating upon successful roundstart
/obj/effect/landmark/roundstart
	delete_after = FALSE

/obj/effect/landmark/roundstart/Initialize()
	. = ..()
	register_global_signal(SIGNAL_ROUNDSTART, nameof(.proc/activate))

/obj/effect/landmark/proc/activate()
	qdel_self()

/obj/effect/landmark/roundstart/puncube
	name = "Pun Pun cube"
	icon_state = "landmark_monkeycube"

/obj/effect/landmark/roundstart/puncube/activate()
	for(var/mob/M in GLOB.player_list)
		if(M.mind?.assigned_role == "Waiter")
			return ..()
	new /obj/item/reagent_containers/food/monkeycube/punpuncube(loc)
	..()

/obj/effect/landmark/roundstart/monkeyportrait
	name = "Mr. Deempisi"
	icon_state = "landmark_monkeyportrait"

/obj/effect/landmark/roundstart/monkeyportrait/activate()
	for(var/mob/M in GLOB.player_list)
		if(M.mind?.assigned_role == "Waiter")
			return ..()
	var/obj/structure/sign/monkey_painting/P = new /obj/structure/sign/monkey_painting(loc)
	P.pixel_x = pixel_x
	P.pixel_y = pixel_y
	..()
