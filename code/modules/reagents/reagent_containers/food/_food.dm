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

	var/food_quality = 1 //Result of cooking effort
	var/food_tier //Where on the tier scale the food falls on, determines multiplier
	var/cooking_description_modifier
	var/food_descriptor //Feedback on quality on examine
	var/bite_descriptor //Feedback on quality per bite

	var/filling_color = "#ffffff" // Used by sandwiches and stuff.
	var/trash = null // Type that spawns upon finishing the src.

/obj/item/reagent_containers/food/New()
	..()
	get_food_tier()

/obj/item/reagent_containers/food/Initialize()
	. = ..()
	if(nutriment_amt)
		reagents.add_reagent(/datum/reagent/nutriment, nutriment_amt, nutriment_desc)


/obj/item/reagent_containers/food/proc/On_Consume(mob/M)
	if(!reagents.total_volume)
		M.visible_message(SPAN("notice", "[M] finishes eating \the [src]."), SPAN("notice", "You finish eating \the [src]."))
		if(trash)
			var/obj/item/trash_item
			if(ispath(trash, /obj/item))
				trash_item = new trash(get_turf(src))
			else if(istype(trash, /obj/item))
				trash_item = trash

			if(trash_item)
				trash_item.forceMove(get_turf(src))
				if(M.is_equipped(src))
					M.replace_item(src, trash_item, force = TRUE)

		if(istype(loc, /obj/item/organ))
			var/obj/item/organ/O = loc
			O.organ_eaten(M)

		qdel(src)
	return


/obj/item/reagent_containers/food/attack_self(mob/user)
	return


/obj/item/reagent_containers/food/attack(mob/M, mob/user, def_zone)
	if(!reagents.total_volume)
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

		if(reagents && !(atom_flags & ATOM_FLAG_HOLOGRAM))								//Handle ingestion of the reagent.
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


/obj/item/reagent_containers/food/examine(mob/user, infix)
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
			U.ClearOverlays()
			U.loaded = "[src]"
			var/image/I = new(U.icon, "loadedfood")
			I.color = src.filling_color
			U.AddOverlays(I)
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
				var/obj/slice = new slice_path(src.loc)
				reagents.trans_to_obj(slice, reagents_per_slice)
				if(istype(slice, /obj/item/reagent_containers/food))
					slice.food_quality = src.food_quality
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

/obj/item/reagent_containers/food/proc/get_food_tier()
	if(food_quality < -9)
		food_tier = CWJ_QUALITY_GARBAGE
		food_descriptor = "It looks gross. Someone cooked this poorly."
		bite_descriptor = " Eating this makes you regret every decision that lead you to this moment."
	else if (food_quality >= 100)
		food_tier = CWJ_QUALITY_ELDRITCH
		food_descriptor = "What cruel twist of fate it must be, for this unparalleled artistic masterpiece can only be truly appreciated through its destruction. Does this dish's transient form belie the true nature of all things? You see the totality of existence reflected through \the [src]."
		bite_descriptor = " It's like reliving the happiest moments of your life, nothing is better than this!"
	else
		switch(food_quality)
			if(-9 to 0)
				food_tier = CWJ_QUALITY_GROSS
				food_descriptor = "It looks like an unappetizing a meal."
				bite_descriptor = " Your stomach turns as you chew."
			if(1 to 10)
				food_tier = CWJ_QUALITY_MEH
				food_descriptor = "The food is edible, but frozen dinners have been reheated with more skill."
				bite_descriptor = " It could be worse, but it certainly isn't good."
			if(11 to 20)
				food_tier = CWJ_QUALITY_NORMAL
				food_descriptor = "It looks adequately made."
				bite_descriptor = " It's food, alright."
			if(21 to 30)
				food_tier = CWJ_QUALITY_GOOD
				food_descriptor = "The quality of the food is is pretty good."
				bite_descriptor = " This ain't half bad!"
			if(31 to 50)
				food_tier = CWJ_QUALITY_VERY_GOOD
				food_descriptor = "This food looks very tasty."
				bite_descriptor = " So tasty!"
			if(61 to 70)
				food_tier = CWJ_QUALITY_CUISINE
				food_descriptor = "There's a special spark in this cooking, a measure of love and care unseen by the casual chef."
				bite_descriptor = " You can taste the attention to detail like a fine spice on top of the excellently prepared dish."
			if(81 to 99)
				food_tier = CWJ_QUALITY_LEGENDARY
				food_descriptor = "The quality of this food is legendary. Words fail to describe it further. It must be eaten"
				bite_descriptor = " This food is unreal, the textures blend perfectly with the flavor, could food get any better than this?"
