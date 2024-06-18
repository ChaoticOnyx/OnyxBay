
/**
 * The weapon has malfunctioned and needs maintenance. Set the flag and do some effects to let people know.
 */
/obj/machinery/ship_weapon/proc/weapon_malfunction()
	malfunction = TRUE
	playsound(src, malfunction_sound, 100, TRUE)
	visible_message(SPAN_DANGER("Malfunction detected in [src]! Firing sequence aborted!")) //perhaps additional flavour text of a non angry red kind?
	for(var/mob/living/M in range(10, get_turf(src)))
		shake_camera(M, 10, 1)

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(6, 0, src)
	s.start()
	light_color = COLOR_RED
	set_light(3)

/**
 * Tries to use item I to lubricate the machinery.
 */
/obj/machinery/ship_weapon/proc/oil(obj/item/I, mob/user)
	if((maint_state == MSTATE_UNBOLTED) && istype(I, /obj/item/reagent_containers))
		if(I.reagents.has_reagent(/datum/reagent/lube, 10))
			to_chat(user, SPAN_NOTICE("You start lubricating the inner workings of [src]..."))
			if(!do_after(user, 2 SECONDS, target=src))
				return

			if(!I.reagents.has_reagent(/datum/reagent/lube, 10)) //Since things can change during the doafter, we need to check again.
				to_chat(user, SPAN_NOTICE("You don't have enough oil left to lubricate [src]!"))
				return

			to_chat(user, SPAN_NOTICE("You lubricate the inner workings of [src]."))
			if(malfunction)
				malfunction = FALSE
				visible_message(SPAN_NOTICE("The red warning lights on [src] fade away."))
				set_light(0)
			maint_req = max(maint_req, rand(15,25))
			I.reagents.trans_to(src, 10)
			reagents.clear_reagents()
			return

		else if(I.reagents.has_reagent(/datum/reagent/lube))
			to_chat(user, SPAN_NOTICE("You need at least 10 units of oil to lubricate [src]!"))
			return

		else
			visible_message(SPAN_WARNING("Warning: Contaminants detected, flushing systems."))
			new /obj/effect/decal/cleanable/blood/oil(user.loc)
			I.reagents.trans_to(src, 10)
			reagents.clear_reagents()
			return

	else
		to_chat(user, SPAN_NOTICE("You can't lubricate the [src] with [I]!"))

/obj/machinery/ship_weapon/on_update_icon()
	ClearOverlays()
	switch(maint_state)
		if(MSTATE_UNSCREWED)
			AddOverlays("[initial(icon_state)]_screwdriver")
		if(MSTATE_UNBOLTED)
			AddOverlays("[initial(icon_state)]_wrench")
		if(MSTATE_PRIEDOUT)
			AddOverlays("[initial(icon_state)]_crowbar")
