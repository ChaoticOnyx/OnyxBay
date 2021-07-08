// This folder contains code that was originally ported from Apollo Station and then refactored/optimized/changed. Twice
//Product status
#define NO_PRODUCT 0
#define COOKING    1
#define COOKED     2
#define BURNED     3

// Tracks precooked food to stop deep fried baked grilled grilled grilled diona nymph cereal.
/obj/item/weapon/reagent_containers/food/snacks
	var/list/cooked_types = list()

// Root type for cooking machines. See following files for specific implementations.
/obj/machinery/cooker
	name = "cooker"
	desc = "You shouldn't be seeing this!"
	icon = 'icons/obj/cooking_machines.dmi'
	density = 1
	anchored = 1
	idle_power_usage = 5

	var/on_icon						// Icon state used when cooking.
	var/off_icon					// Icon state used when not cooking.
	var/is_cooking = FALSE			// Whether or not the machine is currently operating.
	var/cook_type					// A string value used to track what kind of food this machine makes.
	var/cook_time = 200				// How many ticks the cooking will take.
	var/mob_fitting_size = MOB_SMALL// Maximum size of a mob can be cooked (humans are MOB_MEDIUM)
	var/food_color					// Colour of resulting food item.
	var/cooked_sound				// Sound played when cooking completes.
	var/can_burn_food = FALSE		// Can the object burn food that is left inside?
	var/burn_chance = 10			// How likely is the food to burn?
	var/atom/movable/thing_inside	// Holder for the currently cooking object.

	// If the machine has multiple output modes, define them here.
	var/selected_option
	var/list/output_options = list()

	// Variables for internal usage
	var/cooking_done_time
	var/next_burn_time
	var/cooking_is_done = FALSE

/obj/machinery/cooker/Destroy()
	if(thing_inside)
		qdel(thing_inside)
		thing_inside = null
	if(is_cooking)
		stop()
	return ..()

/obj/machinery/cooker/examine(mob/user)
	. = ..()
	if(Adjacent(user))
		switch(product_status())
			//if NO_PRODUCT, say no more
			if(COOKING)
				. += "\nYou can see \a [thing_inside] inside."
			if(COOKED)
				var/smell = "good"
				if(istype(thing_inside, /obj/item/weapon/reagent_containers/food/snacks))
					var/obj/item/weapon/reagent_containers/food/snacks/S = thing_inside
					if(islist(S.nutriment_desc) && length(S.nutriment_desc))
						smell = pick(S.nutriment_desc)
				. += "\nYou can see \a [thing_inside] inside. It smells [smell]."
			if(BURNED)
				. += "\n[SPAN("warning", "Inside is covered by dirt, and it smells smoke!")]"

/obj/machinery/cooker/attackby(obj/item/I, mob/user)
	set waitfor = 0  //So that any remaining parts of calling proc don't have to wait for the long cooking time ahead.

	if(!cook_type || (stat & (NOPOWER|BROKEN)))
		to_chat(user, SPAN("warning", "\The [src] is not working."))
		return 0

	if(product_status() != NO_PRODUCT)
		to_chat(user, SPAN("warning", "There is no more space in \the [src]. \A [thing_inside] is already there!"))
		return 0

	var/mob/living/inserted_mob
	var/obj/item/weapon/reagent_containers/food/snacks/check
	if(istype(I, /obj/item/weapon/reagent_containers/food/snacks/badrecipe))
		to_chat(user, SPAN("warning", "Making [I] [cook_type] shouldn't help."))
		return 0
	else if(istype(I.return_item(), /obj/item/weapon/reagent_containers/food/snacks))
		check = I.return_item()
		if(cook_type in check.cooked_types)
			to_chat(user, SPAN("warning", "\The [I] has already been [cook_type]."))
			return 0
	else if(istype(I, /obj/item/weapon/reagent_containers/food/condiment))
		to_chat(user, SPAN("warning", "You can't make \the [I] [cook_type]."))
		return 0
	else if(istype(I, /obj/item/weapon/reagent_containers/glass))
		to_chat(user, SPAN("warning", "That would probably break [src]."))
		return 0
	else if(istype(I, /obj/item/weapon/holder) || istype(I, /obj/item/grab))
		if(istype(I, /obj/item/weapon/holder))
			for(var/mob/living/M in I.contents)
				inserted_mob = M
				break
		else
			var/obj/item/grab/G = I
			inserted_mob = G.affecting
	else
		to_chat(user, SPAN("warning", "That's not edible."))
		return 0

	if(inserted_mob && (!isliving(inserted_mob) || isbot(inserted_mob) || issilicon(inserted_mob)))
		to_chat(user, SPAN("warning", "You can't cook that."))
		return 0

	if(inserted_mob && inserted_mob.mob_size > mob_fitting_size)
		hurt_big_mob(inserted_mob, user)
		return 0

	// Not sure why a food item that passed the previous checks would fail to drop, but safety first.
	if(!user.drop_from_inventory(I))
		return

	if(inserted_mob)
		thing_inside = inserted_mob
	else
		thing_inside = I
	user.visible_message(SPAN("notice", "\The [user] puts \the [thing_inside] into \the [src]."))
	thing_inside.forceMove(src)
	is_cooking = 1
	cooking_is_done = FALSE
	icon_state = on_icon

	if(inserted_mob)
		inserted_mob.apply_damage(rand(30,40), BURN, BP_CHEST)

	// Doop de doo. Jeopardy theme goes here.
	cooking_done_time = world.time + cook_time
	if(can_burn_food)
		next_burn_time = cooking_done_time + max(Floor(cook_time/5),1)
	START_PROCESSING(SSmachines, src)
	return 1

/obj/machinery/cooker/proc/return_item_data()
	var/list/data = list() // contents: reagents, total_volume, the value from return_item if item, or src if something else.
	if(istype(thing_inside, /obj/item))
		var/obj/item/I = thing_inside
		data["item"] = I.return_item()
	else
		data["item"] = src

	data["reagents"] = data["item"]?.reagents
	data["total_volume"] = data["reagents"]?.total_volume

	return data

/obj/machinery/cooker/Process()
	if(!is_cooking || !cook_type || (stat & (NOPOWER|BROKEN)))
		stop()
		return
	switch(product_status())
		if(NO_PRODUCT)
			stop()
		if(COOKING)
			ASSERT(cooking_done_time)
			if(world.time > cooking_done_time)
				var/list/product_data = return_item_data()
				if(isliving(thing_inside))
					var/mob/living/L = thing_inside
					L.death()

				if(selected_option && output_options.len)
					var/cook_path = output_options[selected_option]
					var/obj/item/weapon/reagent_containers/food/snacks/result = new cook_path(src)

					result = change_product_strings(result, product_data["item"])
					result = change_product_appearance(result, product_data["item"])

					if(product_data["reagents"] && product_data["total_volume"])
						product_data["reagents"].trans_to(result, product_data["total_volume"])
					if(istype(product_data["item"], /obj/item/weapon/reagent_containers/food/snacks))
						var/obj/item/weapon/reagent_containers/food/snacks/I = product_data["item"]
						result.cooked_types = I.cooked_types.Copy()

					qdel(thing_inside)
					thing_inside = result
				else
					thing_inside = change_product_strings(thing_inside)
					thing_inside = change_product_appearance(thing_inside)

				if(istype(product_data["item"], /obj/item/weapon/reagent_containers/food/snacks))
					var/obj/item/weapon/reagent_containers/food/snacks/I = product_data["item"]
					I.cooked_types |= cook_type
				cooking_is_done = TRUE

				src.visible_message(SPAN("notice", "\The [src] pings!"))
				if(cooked_sound)
					playsound(src, cooked_sound, 50, 1)
		if(COOKED)
			if(!can_burn_food)
				eject()
			else
				ASSERT(next_burn_time)
				if(world.time > next_burn_time)
					next_burn_time += max(Floor(cook_time/5),1)
					if(prob(burn_chance))
						qdel(thing_inside)
						thing_inside = new /obj/item/weapon/reagent_containers/food/snacks/badrecipe(src)
						visible_message(SPAN("danger", "\The [src] vomits a gout of rancid smoke!"))
						var/datum/effect/effect/system/smoke_spread/bad/smoke = new /datum/effect/effect/system/smoke_spread/bad()
						smoke.attach(src)
						smoke.set_up(10, 0, loc)
						smoke.start()
		if(BURNED) // Just keep running
		else
			stop()
			CRASH("Something weird happened during product_status() check in [src].")

/obj/machinery/cooker/proc/product_status()
	if(!thing_inside || thing_inside.loc != src)
		return NO_PRODUCT
	if(istype(thing_inside, /obj/item/weapon/reagent_containers/food/snacks/badrecipe))
		return BURNED
	if(cooking_is_done)
		return COOKED
	return COOKING

/obj/machinery/cooker/proc/eject(mob/receiver)
	if(!thing_inside)
		if(is_cooking)
			stop()
		return
	if(receiver)
		if(isliving(thing_inside))
			var/mob/living/L = thing_inside
			L.get_scooped(receiver, self_grab = FALSE)
		else
			to_chat(receiver, SPAN("notice", "You grab \the [thing_inside] from \the [src]."))
			receiver.put_in_hands(thing_inside)
	else
		thing_inside.forceMove(get_turf(src))

	thing_inside = null
	cooking_is_done = FALSE
	if(is_cooking)
		stop()

/obj/machinery/cooker/proc/stop()
	is_cooking = FALSE
	icon_state = off_icon
	STOP_PROCESSING(SSmachines, src)

/obj/machinery/cooker/attack_hand(mob/user)

	if(product_status() != NO_PRODUCT)
		eject(user)
		return

	if(output_options.len > 1)

		var/choice = input("What specific food do you wish to make with \the [src]?") as null|anything in output_options+"Default"
		if(!choice)
			return
		if(choice == "Default")
			selected_option = null
			to_chat(user, SPAN("notice", "You decide not to make anything specific with \the [src]."))
		else
			selected_option = choice
			to_chat(user, SPAN("notice", "You prepare \the [src] to make \a [selected_option]."))

	..()

/obj/machinery/cooker/proc/hurt_big_mob(mob/living/victim, mob/user)
	to_chat(user, SPAN("warning", "That's not going to fit."))
	return

/obj/machinery/cooker/proc/change_product_strings(atom/movable/product, atom/movable/origin)
	if(!origin)
		product.SetName("[cook_type] [product.name]")
		product.desc = "[product.desc] It has been [cook_type]."
	else
		var/origin_name = origin.name
		if(isliving(origin))
			var/open_bkt = findtext(origin.name, "(")
			var/close_bkt = findtext(origin.name, "(")
			if(open_bkt && close_bkt)
				origin_name = copytext(origin.name, 1, open_bkt - 1) + copytext(origin.name, close_bkt + 1)
		product.SetName("[origin_name] [product.name]")
	return product

/obj/machinery/cooker/proc/change_product_appearance(atom/movable/product, atom/movable/origin)
	if(!origin)
		product.color = food_color
		if(istype(product, /obj/item/weapon/reagent_containers/food))
			var/obj/item/weapon/reagent_containers/food/food_item = product
			food_item.filling_color = food_color
	else
		var/image/I = image(product.icon, "[product.icon_state]_filling")
		if(istype(origin, /obj/item/weapon/reagent_containers/food/snacks))
			var/obj/item/weapon/reagent_containers/food/snacks/S = origin
			I.color = S.filling_color
		if(!I.color)
			I.color = food_color
		product.overlays += I
	return product

#undef NO_PRODUCT
#undef COOKING
#undef COOKED
#undef BURNED
