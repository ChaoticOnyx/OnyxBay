////////////////////////////////////////////////////////////////////////////////
/// Food - items that are eaten normally and don't leave anything (except trash) behind.
////////////////////////////////////////////////////////////////////////////////
/obj/item/reagent_containers/food
	name = "snack"
	desc = "Yummy!"
	icon = 'icons/obj/food.dmi'
	icon_state = null
	center_of_mass = "x=16;y=16"
	w_class = ITEM_SIZE_SMALL
	randpixel = 6
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	possible_transfer_amounts = null
	volume = 10 LITERS // Gets recalculated after initialization.

	var/static_volume = FALSE // If positive, prevents volume recalculation.

	var/bitesize = 30 // Size (reagent-wise) of a single bite.
	var/bitecount = 0 // Number of bites taken.

	var/slice_path // Type of slices
	var/slices_num // Number of slices

	var/dried_type = null // Fuck if I know
	var/dry = FALSE // Dried food, may be smoked.

	var/nutriment_amt = 0 // Amount of nutriments that spawn in Initialize.
	var/list/nutriment_desc = list("food" = 1) // Taste-describing data for the nutriments spawned by the var above.

	var/filling_color = "#ffffff" // Used by sandwiches and stuff.
	var/trash = null // Type that spawns upon finishing the src.


/obj/item/reagent_containers/food/Initialize(mapload, spawn_empty = FALSE)
	. = ..()
	if(!spawn_empty)
		if(nutriment_amt)
			reagents.add_reagent(/datum/reagent/nutriment, nutriment_amt, nutriment_desc)
		recalc_max_volume()

/obj/item/reagent_containers/food/proc/recalc_max_volume()
	if(static_volume)
		return

	if(!reagents)
		return

	reagents.maximum_volume = min((reagents.total_volume * 2), (reagents.total_volume + 0.25 LITERS))
	volume = reagents.maximum_volume

/obj/item/reagent_containers/food/proc/On_Consume(mob/M, eaten_with_fork)
	if(reagents.total_volume)
		return

	if(M)
		if(eaten_with_fork)
			M.visible_message(SPAN("notice", "[M] scoops up the last piece of \the [src]."), SPAN("notice", "You scoop up the last piece of \the [src]."))
		else
			M.visible_message(SPAN("notice", "[M] finishes eating \the [src]."), SPAN("notice", "You finish eating \the [src]."))

	if(trash)
		var/obj/item/trash_item
		if(ispath(trash, /obj/item))
			trash_item = new trash(get_turf(src))
		else if(istype(trash, /obj/item))
			trash_item = trash

		if(trash_item)
			trash_item.forceMove(get_turf(src))
			if(M?.is_equipped(src))
				M.replace_item(src, trash_item, force = TRUE)

	if(istype(loc, /obj/item/organ))
		var/obj/item/organ/O = loc
		O.organ_eaten(M)

	qdel(src)
	return


/obj/item/reagent_containers/food/attack_self(mob/user)
	return


/obj/item/reagent_containers/food/attack(mob/M, mob/user, def_zone)
	if(!reagents?.total_volume)
		to_chat(user, SPAN("danger", "The empty shell of [src] crumbles in your hands!"))
		qdel(src)
		return FALSE

	if(!is_open_container())
		to_chat(user, SPAN("danger", "[src] must be opened first!"))
		return FALSE

	if(istype(M, /mob/living/carbon))
		//TODO: replace with standard_feed_mob() call.
		var/mob/living/carbon/C = M
		var/fullness = C.get_fullness()
		if(C == user)								//If you're eating it yourself
			var/complex_fullness = FALSE
			if(ishuman(C))
				var/mob/living/carbon/human/H = M
				if(!H.can_eat(src))
					return
				fullness /= H.body_build.stomach_capacity // Here we take body build into consideration
				if(H.should_have_organ(BP_STOMACH))
					var/obj/item/organ/internal/stomach/S = H.internal_organs_by_name[BP_STOMACH]
					if(S)
						complex_fullness = TRUE

			user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN) //puts a limit on how fast people can eat/drink things

			if(complex_fullness)
				var/obj/item/organ/internal/stomach/S = C.internal_organs_by_name[BP_STOMACH]
				var/stomach_fullness = S.get_fullness()
				var/hunger_stage = 3
				if(stomach_fullness >= 200) // 200% fullness, no more physical space
					hunger_stage = 0
					return FALSE
				else if(stomach_fullness >= 150) // 150% fullness, very likely to throw up
					hunger_stage = 1
				else if(stomach_fullness >= 100) // 100% fullness, softcap
					hunger_stage = 2
				else if(fullness <= STOMACH_FULLNESS_SUPER_LOW)
					hunger_stage = 5
				else if(fullness <= STOMACH_FULLNESS_LOW)
					hunger_stage = 4

				to_chat(C, get_eating_message(hunger_stage))
				if(!hunger_stage)
					return FALSE
			else
				var/hunger_stage = 3
				switch(fullness)
					if(0 to STOMACH_FULLNESS_SUPER_LOW)
						hunger_stage = 5
					if(STOMACH_FULLNESS_SUPER_LOW to STOMACH_FULLNESS_LOW)
						hunger_stage = 4
					if(STOMACH_FULLNESS_LOW to STOMACH_FULLNESS_MEDIUM)
						hunger_stage = 3
					if(STOMACH_FULLNESS_MEDIUM to STOMACH_FULLNESS_HIGH)
						hunger_stage = 2
					if(STOMACH_FULLNESS_HIGH to STOMACH_FULLNESS_SUPER_HIGH)
						hunger_stage = 1
					if(STOMACH_FULLNESS_SUPER_HIGH to INFINITY)
						hunger_stage = 0

				to_chat(C, get_eating_message(hunger_stage))
				if(!hunger_stage)
					return FALSE
		else
			if(!M.can_force_feed(user, src))
				return

			var/stomach_fullness
			var/obj/item/organ/internal/stomach/S
			if(ishuman(C))
				var/mob/living/carbon/human/H = M
				if(H.should_have_organ(BP_STOMACH))
					S = H.internal_organs_by_name[BP_STOMACH]
					stomach_fullness = S.get_fullness()

			if(S)
				if(stomach_fullness >= S.volume_hardcap)
					user.visible_message(SPAN("danger", "[user] cannot force anymore of [src] down [M]'s throat."))
					return FALSE
				else
					user.visible_message(SPAN("danger", "[user] attempts to feed [M] [src]."))
			else
				if(fullness <= STOMACH_FULLNESS_SUPER_HIGH)
					user.visible_message(SPAN("danger", "[user] attempts to feed [M] [src]."))
				else
					user.visible_message(SPAN("danger", "[user] cannot force anymore of [src] down [M]'s throat."))
					return FALSE

			user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
			if(!do_mob(user, M, time = 2 SECONDS))
				return

			if(!(user.has_in_hands(src) || user.has_in_hands(loc)))
				return

			if(!M.can_force_feed(user, src, check_resist = TRUE))
				return

			var/contained = reagentlist()
			admin_attack_log(user, M, "Fed the victim with [name] (Reagents: [contained])", "Was fed [src] (Reagents: [contained])", "used [src] (Reagents: [contained]) to feed")
			user.visible_message(SPAN("danger", "[user] feeds [M] [src]."))

		if(reagents && !(atom_flags & ATOM_FLAG_HOLOGRAM))								//Handle ingestion of the reagent.
			playsound(M.loc, SFX_EAT, rand(45, 60), FALSE)
			if(reagents.total_volume)
				if(!ishuman(C))
					reagents.trans_to_mob(C, bitesize, CHEM_INGEST)

					if(bitecount != -1)
						bitecount++

					update_icon()
					On_Consume(C)
					return TRUE

				var/mob/living/carbon/human/H = C
				var/obj/item/reagent_containers/food/ingested_chunk/IC = new (src)
				IC.split_from(src, H)

				if(!H.ingest(IC)) // We ingest it normally or fallback to the old way if something goes wrong.
					IC.reagents.trans_to_mob(H, bitesize, CHEM_INGEST)
					qdel(IC)

			return TRUE

	return FALSE

/obj/item/reagent_containers/food/proc/get_eating_message(hunger_stage)
	switch(hunger_stage)
		if(0)
			return SPAN("danger", "You cannot force any more of [src] to go down your throat.")
		if(1)
			return SPAN("danger", "You force yourself to swallow some [src].")
		if(2)
			return SPAN("notice", "You unwillingly chew a bit of [src].")
		if(3)
			return SPAN("notice", "You take a bite of [src].")
		if(4)
			return SPAN("notice", "You hungrily begin to eat [src].")
		else
			return SPAN("danger", "You hungrily chew out a piece of [src] and gobble it!")

/obj/item/reagent_containers/food/proc/get_bitecount()
	switch(bitecount)
		if(-INFINITY to 0)
			return
		if(1)
			return SPAN("notice", "\n\The [src] was bitten by someone!")
		if(2, 3)
			return SPAN("notice", "\n\The [src] was bitten [bitecount] time\s!")
		else
			return SPAN("notice", "\n\The [src] was bitten multiple times!")


/obj/item/reagent_containers/food/examine(mob/user, infix)
	. = ..()

	if(get_dist(src, user) > 1)
		return

	. += get_bitecount()

// TODO: Launcher throwing
/obj/item/reagent_containers/food/throw_impact(atom/hit_atom, datum/thrownthing/TT)
	..()
	var/mob/living/carbon/human/H = hit_atom
	if(!istype(H) || !TT.launcher || TT.target_zone != BP_MOUTH || !reagents.total_volume || !is_open_container() || !H.check_has_mouth() || H.check_mouth_coverage() || H.get_fullness() >= STOMACH_FULLNESS_SUPER_HIGH)
		return ..(hit_atom, TT)

	if(reagents.total_volume > bitesize * 2)
		reagents.trans_to_mob(H, bitesize * 2, CHEM_INGEST)
	else
		reagents.trans_to_mob(H, reagents.total_volume, CHEM_INGEST)

	if(bitecount != -1)
		bitecount++

	update_icon()
	On_Consume(H)

	playsound(H.loc, SFX_EAT, rand(45, 60), FALSE)
	if(H.stat == CONSCIOUS)
		to_chat(H, SPAN("notice", "You take a bite of [src]."))


/obj/item/reagent_containers/food/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/storage))
		return ..() // -> item/attackby()

	// Eating with forks
	if(istype(W, /obj/item/material/kitchen/utensil))
		get_scooped(W, user)
		return

	if(is_sliceable())
		//these are used to allow hiding edge items in food that is not on a table/tray
		var/can_slice_here = isturf(loc) && ((locate(/obj/structure/table) in loc) || (locate(/obj/machinery/optable) in loc) || (locate(/obj/item/tray) in loc))
		var/hide_item = !has_edge(W) || !can_slice_here

		if(hide_item)
			if(W.w_class >= w_class || is_robot_module(W))
				return
			if(length(contents) > 3)
				to_chat(user, SPAN_WARNING("There's too much stuff inside!"))
				return
			if(!user.drop(W, src))
				return

			to_chat(user, SPAN("warning", "You slip \the [W] inside \the [src]."))
			add_fingerprint(user)
			contents += W
			return

		if(has_edge(W))
			if(!can_slice_here)
				to_chat(user, SPAN("warning", "You cannot slice \the [src] here! You need a table or at least a tray to do it."))
				return

			var/slices_lost = 0
			if (W.w_class > 3)
				user.visible_message(SPAN("notice", "\The [user] crudely slices \the [src] with [W]!"), SPAN("notice", "You crudely slice \the [src] with your [W]!"))
				slices_lost = rand(1, min(1, round(slices_num / 2)))
			else
				user.visible_message(SPAN("notice", "\The [user] slices \the [src]!"), SPAN("notice", "You slice \the [src]!"))

			var/reagents_per_slice = reagents.total_volume / slices_num
			for(var/i = 1 to (slices_num - slices_lost))
				var/obj/slice = new slice_path(loc, TRUE)
				reagents.trans_to_obj(slice, reagents_per_slice)
				if(istype(slice, /obj/item/reagent_containers/food))
					var/obj/item/reagent_containers/food/F = slice
					F.recalc_max_volume()
			qdel(src)
			return
	return ..()


/obj/item/reagent_containers/food/attack_generic(mob/living/user)
	if(!isanimal(user) && !islarva(user))
		return ..()
	user.visible_message("<b>[user]</b> nibbles away at \the [src].", "You nibble away at \the [src].")

	if(bitecount != -1)
		bitecount++

	if(reagents && user.reagents)
		reagents.trans_to_mob(user, bitesize, CHEM_INGEST)
	spawn(5)
		if(!src && !user.client)
			user.custom_emote(VISIBLE_MESSAGE, pick("burps", "cries for more", "burps twice", "looks at the area where the food was"), "AUTO_EMOTE")
			qdel(src)
	On_Consume(user)


/obj/item/reagent_containers/food/Destroy()
	if(contents)
		for(var/atom/movable/thing in contents)
			thing.dropInto(loc)
	. = ..()


/obj/item/reagent_containers/food/proc/is_sliceable()
	return (slices_num && slice_path)

/obj/item/reagent_containers/food/proc/get_scooped(obj/item/material/kitchen/utensil/U, mob/user)
	if(!istype(U))
		return FALSE

	if(!U.scoop_food)
		return FALSE

	if(U.forked_chunk)
		to_chat(user, SPAN("notice", "You already have a [U.forked_chunk] on your [U]."))
		return FALSE

	user.visible_message( \
		"\The [user] scoops up some [src] with \the [U]!", \
		"<span class='notice'>You scoop up some [src] with \the [U]!</span>" \
	)

	var/obj/item/reagent_containers/food/forked_chunk/forked_chunk = new (U)
	forked_chunk.split_from(src, user)
	U.forked_chunk = forked_chunk
	U.update_icon()
	return forked_chunk
