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
	volume = 50 // Sets the default container amount for all food items.

	var/bitesize = 1 // Size (reagent-wise) of a single bite.
	var/bitecount = 0 // Number of possible bites.

	var/slice_path // Type of slices
	var/slices_num // Number of slices

	var/dried_type = null // Fuck if I know
	var/dry = FALSE // Dried food, may be smoked.

	var/nutriment_amt = 0 // Amount of nutriments that spawn in Initialize.
	var/list/nutriment_desc = list("food" = 1) // Taste-describing data for the nutriments spawned by the var above.

	var/filling_color = "#ffffff" // Used by sandwiches and stuff.
	var/trash = null // Type that spawns upon finishing the src.


/obj/item/reagent_containers/food/Initialize()
	. = ..()
	if(nutriment_amt)
		reagents.add_reagent(/datum/reagent/nutriment, nutriment_amt, nutriment_desc)


/obj/item/reagent_containers/food/proc/On_Consume(mob/M)
	if(!reagents.total_volume)
		M.visible_message(SPAN("notice", "[M] finishes eating \the [src]."), SPAN("notice", "You finish eating \the [src]."))
		var/is_held = (M == loc)
		if(is_held)
			M.drop_item()

		if(trash)
			var/obj/item/trash_item
			if(ispath(trash, /obj/item))
				trash_item = new trash(get_turf(src))
			else if(istype(trash, /obj/item))
				trash_item = trash

			if(trash_item)
				trash_item.forceMove(get_turf(src))
				if(is_held)
					M.put_in_hands(trash_item)

		if(istype(loc, /obj/item/organ))
			var/obj/item/organ/O = loc
			O.organ_eaten(M)

		qdel(src)
	return


/obj/item/reagent_containers/food/attack_self(mob/user)
	return


/obj/item/reagent_containers/food/attack(mob/M, mob/user, def_zone)
	if(!reagents.total_volume)
		to_chat(user, SPAN("danger", "None of [src] left!"))
		user.drop_from_inventory(src)
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
			if(ishuman(C))
				var/mob/living/carbon/human/H = M
				if(!H.check_has_mouth())
					to_chat(user, "Where do you intend to put \the [src]? You don't have a mouth!")
					return
				var/obj/item/blocked = H.check_mouth_coverage()
				if(blocked)
					to_chat(user, SPAN("warning", "\The [blocked] is in the way!"))
					return
				fullness /= H.body_build.stomach_capacity // Here we take body build into consideration

			user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN) //puts a limit on how fast people can eat/drink things
			if(fullness <= STOMACH_FULLNESS_SUPER_LOW)
				to_chat(C, SPAN("danger", "You hungrily chew out a piece of [src] and gobble it!"))
			if(fullness > STOMACH_FULLNESS_SUPER_LOW && fullness <= STOMACH_FULLNESS_LOW)
				to_chat(C, SPAN("notice", "You hungrily begin to eat [src]."))
			if(fullness > STOMACH_FULLNESS_LOW && fullness <= STOMACH_FULLNESS_MEDIUM)
				to_chat(C, SPAN("notice", "You take a bite of [src]."))
			if(fullness > STOMACH_FULLNESS_MEDIUM && fullness <= STOMACH_FULLNESS_HIGH)
				to_chat(C, SPAN("notice", "You unwillingly chew a bit of [src]."))
			if(fullness > STOMACH_FULLNESS_HIGH && fullness <= STOMACH_FULLNESS_SUPER_HIGH)
				to_chat(C, SPAN("danger", "You force yourself to swallow some [src]."))
			if(fullness > STOMACH_FULLNESS_SUPER_HIGH)
				to_chat(C, SPAN("danger", "You cannot force any more of [src] to go down your throat."))
				return FALSE
		else
			if(!M.can_force_feed(user, src))
				return

			if(fullness <= STOMACH_FULLNESS_SUPER_HIGH)
				user.visible_message(SPAN("danger", "[user] attempts to feed [M] [src]."))
			else
				user.visible_message(SPAN("danger", "[user] cannot force anymore of [src] down [M]'s throat."))
				return FALSE

			user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
			if(!do_mob(user, M))
				return

			if(user.get_active_hand() != src)
				return

			var/contained = reagentlist()
			admin_attack_log(user, M, "Fed the victim with [name] (Reagents: [contained])", "Was fed [src] (Reagents: [contained])", "used [src] (Reagents: [contained]) to feed")
			user.visible_message(SPAN("danger", "[user] feeds [M] [src]."))

		if(reagents)								//Handle ingestion of the reagent.
			playsound(M.loc, SFX_EAT, rand(45, 60), FALSE)
			if(reagents.total_volume)
				if(reagents.total_volume > bitesize)
					reagents.trans_to_mob(M, bitesize, CHEM_INGEST)
				else
					reagents.trans_to_mob(M, reagents.total_volume, CHEM_INGEST)
				bitecount++
				update_icon()
				On_Consume(M)
			return TRUE

	return FALSE


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


/obj/item/reagent_containers/food/_examine_text(mob/user)
	. = ..()
	if(get_dist(src, user) > 1)
		return
	. += get_bitecount()


/obj/item/reagent_containers/food/throw_impact(atom/hit_atom, speed, thrown_with, target_zone)
	var/mob/living/carbon/human/H = hit_atom
	if(!istype(H) || !istype(thrown_with, /obj/item/gun/launcher) || target_zone != BP_MOUTH || !reagents.total_volume || !is_open_container() || !H.check_has_mouth() || H.check_mouth_coverage() || H.get_fullness() >= STOMACH_FULLNESS_SUPER_HIGH)
		return ..(hit_atom, speed)

	if(reagents.total_volume > bitesize * 2)
		reagents.trans_to_mob(H, bitesize * 2, CHEM_INGEST)
	else
		reagents.trans_to_mob(H, reagents.total_volume, CHEM_INGEST)
	bitecount++
	throwing = FALSE
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
		var/obj/item/material/kitchen/utensil/U = W
		if(U.scoop_food)
			if(!U.reagents)
				U.create_reagents(5)

			if (U.reagents.total_volume > 0)
				to_chat(user, SPAN("warning", "You already have something on your [U]."))
				return

			user.visible_message( \
				"\The [user] scoops up some [src] with \the [U]!", \
				"<span class='notice'>You scoop up some [src] with \the [U]!</span>" \
			)

			bitecount++
			// TODO: Replace with U.update_icon()
			U.overlays.Cut()
			U.loaded = "[src]"
			var/image/I = new(U.icon, "loadedfood")
			I.color = src.filling_color
			U.overlays += I
			// /TODO

			if(!reagents)
				CRASH("[type] doesnt has a reagent holder [W.type]! Well, it will [QDELETED(src) ? "" : "not"] be deleted.")

			reagents.trans_to_obj(U, min(reagents.total_volume, 5))
			On_Consume(user)
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

			to_chat(user, SPAN("warning", "You slip \the [W] inside \the [src]."))
			user.drop_from_inventory(W, src)
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
				var/obj/slice = new slice_path(src.loc)
				reagents.trans_to_obj(slice, reagents_per_slice)
			qdel(src)
			return
	return ..()


/obj/item/reagent_containers/food/attack_generic(mob/living/user)
	if(!isanimal(user) && !isalien(user))
		return ..()
	user.visible_message("<b>[user]</b> nibbles away at \the [src].", "You nibble away at \the [src].")
	bitecount++
	if(reagents && user.reagents)
		reagents.trans_to_mob(user, bitesize, CHEM_INGEST)
	spawn(5)
		if(!src && !user.client)
			user.custom_emote(1,"[pick("burps", "cries for more", "burps twice", "looks at the area where the food was")]")
			qdel(src)
	On_Consume(user)


/obj/item/reagent_containers/food/Destroy()
	if(contents)
		for(var/atom/movable/thing in contents)
			thing.dropInto(loc)
	. = ..()


/obj/item/reagent_containers/food/proc/is_sliceable()
	return (slices_num && slice_path)
