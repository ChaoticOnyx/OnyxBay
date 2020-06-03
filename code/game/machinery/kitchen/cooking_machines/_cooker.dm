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
	var/can_cook_mobs = FALSE		// Whether or not this machine accepts grabbed mobs.
	var/food_color					// Colour of resulting food item.
	var/cooked_sound				// Sound played when cooking completes.
	var/can_burn_food = FALSE		// Can the object burn food that is left inside?
	var/burn_chance = 10			// How likely is the food to burn?
	var/obj/item/cooking_obj		// Holder for the currently cooking object.

	// Variables for internal usage
	var/cooking_done_time
	var/next_burn_time
	var/cooking_is_done = FALSE

	// If the machine has multiple output modes, define them here.
	var/selected_option
	var/list/output_options = list()

/obj/machinery/cooker/Destroy()
	if(cooking_obj)
		qdel(cooking_obj)
		cooking_obj = null
	if(is_cooking)
		stop()
	return ..()

/obj/machinery/cooker/examine()
	. = ..()
	if(Adjacent(usr))
		switch(product_status())
			//if NO_PRODUCT, say no more
			if(COOKING)
				to_chat(usr, "You can see \a [cooking_obj] inside.")
			if(COOKED)
				var/smell = "good"
				if(istype(cooking_obj, /obj/item/weapon/reagent_containers/food/snacks))
					var/obj/item/weapon/reagent_containers/food/snacks/S = cooking_obj
					if(islist(S.nutriment_desc) && length(S.nutriment_desc))
						smell = pick(S.nutriment_desc)
				to_chat(usr, "You can see \a [cooking_obj] inside. It smells [smell]")
			if(BURNED)
				to_chat(usr, SPAN_WARNING("Inside is covered by dirt, and it smells smoke!"))

/obj/machinery/cooker/attackby(obj/item/I, mob/user)
	set waitfor = 0  //So that any remaining parts of calling proc don't have to wait for the long cooking time ahead.

	if(!cook_type || (stat & (NOPOWER|BROKEN)))
		to_chat(user, SPAN_WARNING("\The [src] is not working"))
		return

	if(product_status() != NO_PRODUCT)
		to_chat(user, SPAN_WARNING("There is no more space in \the [src]. \A [cooking_obj] is already there!"))
		return

	// We are trying to cook a grabbed mob.
	var/obj/item/grab/G = I
	if(istype(G))

		if(!can_cook_mobs)
			to_chat(user, "<span class='warning'>That's not going to fit.</span>")
			return

		if(!isliving(G.affecting))
			to_chat(user, "<span class='warning'>You can't cook that.</span>")
			return

		cook_mob(G.affecting, user)
		return

	if(istype(I, /obj/item/weapon/reagent_containers/food/snacks/badrecipe))
		to_chat(user, SPAN_WARNING("Making [I] [cook_type] shouldn't help"))
		return 0
	else if(istype(I, /obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/food/snacks/check = I
		if(cook_type in check.cooked_types)
			to_chat(user, SPAN_WARNING("\The [I] has already been [cook_type]."))
			return 0
	else if(istype(I, /obj/item/weapon/reagent_containers/food/condiment))
		to_chat(user, SPAN_WARNING("You can't make \the [I] [cook_type]"))
		return 0
	else if(istype(I, /obj/item/weapon/reagent_containers/glass))
		to_chat(user, SPAN_WARNING("That would probably break [src]."))
		return 0
	else if(istype(I, /obj/item/weapon/disk/nuclear))
		to_chat(user, SPAN_WARNING("Central Command would kill you if you [cook_type] that."))
		return 0
	else if(!istype(I, /obj/item/weapon/holder))
		to_chat(user, SPAN_WARNING("That's not edible."))
		return 0

	// Not sure why a food item that passed the previous checks would fail to drop, but safety first.
	if(!user.unEquip(I))
		return

	// We can actually start cooking now.
	user.visible_message("<span class='notice'>\The [user] puts \the [I] into \the [src].</span>")
	cooking_obj = I
	cooking_obj.forceMove(src)
	is_cooking = 1
	cooking_is_done = FALSE
	icon_state = on_icon

	// Gotta hurt.
	if(istype(cooking_obj, /obj/item/weapon/holder))
		for(var/mob/living/M in cooking_obj.contents)
			M.apply_damage(rand(30,40), BURN, BP_CHEST)

	// Doop de doo. Jeopardy theme goes here.
	cooking_done_time = world.time + cook_time
	if(can_burn_food)
		next_burn_time = cooking_done_time + max(Floor(cook_time/5),1)
	START_PROCESSING(SSmachines, src)

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
				if(istype(cooking_obj, /obj/item/weapon/holder))
					for(var/mob/living/M in cooking_obj.contents)
						M.death()
						qdel(M)

				if(selected_option && output_options.len)
					var/cook_path = output_options[selected_option]
					var/obj/item/weapon/reagent_containers/food/snacks/result = new cook_path(src)

					result = change_product_strings(result, cooking_obj)
					result = change_product_appearance(result, cooking_obj)

					if(cooking_obj.reagents && cooking_obj.reagents.total_volume)
						cooking_obj.reagents.trans_to(result, cooking_obj.reagents.total_volume)
					if(istype(cooking_obj, /obj/item/weapon/reagent_containers/food/snacks))
						var/obj/item/weapon/reagent_containers/food/snacks/I = cooking_obj
						result.cooked_types = I.cooked_types.Copy()

					qdel(cooking_obj)
					cooking_obj = result
				else
					cooking_obj = change_product_strings(cooking_obj)
					cooking_obj = change_product_appearance(cooking_obj)

				if(istype(cooking_obj, /obj/item/weapon/reagent_containers/food/snacks))
					var/obj/item/weapon/reagent_containers/food/snacks/I = cooking_obj
					I.cooked_types |= cook_type

				src.visible_message("<span class='notice'>\The [src] pings!</span>")
				if(cooked_sound)
					playsound(get_turf(src), cooked_sound, 50, 1)
				cooking_is_done = TRUE
		if(COOKED)
			if(!can_burn_food)
				eject()
			else
				ASSERT(next_burn_time)
				if(world.time > next_burn_time)
					next_burn_time += max(Floor(cook_time/5),1)
					if(prob(burn_chance))
						qdel(cooking_obj) // TODO: Check it doesn't delete reference to the new cooking_obj
						cooking_obj = new /obj/item/weapon/reagent_containers/food/snacks/badrecipe()
						// Produce nasty smoke.
						visible_message("<span class='danger'>\The [src] vomits a gout of rancid smoke!</span>")
						var/datum/effect/effect/system/smoke_spread/bad/smoke = new /datum/effect/effect/system/smoke_spread/bad()
						smoke.attach(src)
						smoke.set_up(10, 0, loc)
						smoke.start()
		//if BURNED, just keep running
		else
			CRASH("Something weird happened during product_status() check in [src]")

/obj/machinery/cooker/proc/product_status()
	if(!cooking_obj || cooking_obj.loc != src)
		return NO_PRODUCT
	if(istype(cooking_obj, /obj/item/weapon/reagent_containers/food/snacks/badrecipe))
		return BURNED
	if(cooking_is_done)
		return COOKED
	if(istype(cooking_obj, /obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/food/snacks/check = cooking_obj
		if(cook_type in check.cooked_types)
			return COOKED
	return COOKING

/obj/machinery/cooker/proc/eject(mob/receiver)
	if(!cooking_obj)
		return
	if(receiver)
		to_chat(receiver, SPAN_NOTICE("You grab \the [cooking_obj] from \the [src]."))
		receiver.put_in_hands(cooking_obj)
	else
		cooking_obj.forceMove(get_turf(src)) // <-- TODO: Heavily track everything around this for holders
		if(istype(cooking_obj, /obj/item/weapon/holder))
			cooking_obj.dropped()
	cooking_obj = null
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

	if(output_options.len)

		var/choice = input("What specific food do you wish to make with \the [src]?") as null|anything in output_options+"Default"
		if(!choice)
			return
		if(choice == "Default")
			selected_option = null
			to_chat(user, SPAN_NOTICE("You decide not to make anything specific with \the [src]."))
		else
			selected_option = choice
			to_chat(user, SPAN_NOTICE("You prepare \the [src] to make \a [selected_option]."))

	..()

/obj/machinery/cooker/proc/cook_mob(mob/living/victim, mob/user)
	return

/obj/machinery/cooker/proc/change_product_strings(obj/item/weapon/product, obj/item/origin)
	if(!origin)
		product.SetName("[cook_type] [product.name]")
		product.desc = "[product.desc] It has been [cook_type]."
	else
		product.SetName("[origin.name] [product.name]")
	return product

/obj/machinery/cooker/proc/change_product_appearance(obj/item/weapon/product, obj/item/origin)
	if(!origin)
		product.color = food_color
		if(istype(product, /obj/item/weapon/reagent_containers/food))
			var/obj/item/weapon/reagent_containers/food/food_item = product
			food_item.filling_color = food_color

		// Make 'em into a corpse.
		if(istype(product, /obj/item/weapon/holder))
			var/matrix/M = matrix()
			M.Turn(90)
			M.Translate(1,-6)
			product.transform = M
			for(var/mob/living/L in product.contents)
				L.color = food_color
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