
/obj/machinery/microwave
	name = "microwave"
	desc = "Cooks and boils stuff."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "mw"
	layer = BELOW_OBJ_LAYER
	density = 1
	anchored = 1
	idle_power_usage = 5
	active_power_usage = 100
	atom_flags = ATOM_FLAG_NO_REACT
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	var/operating = 0 // Is it on?
	var/dirty = 0 // = {0..100} Does it need cleaning?
	var/broken = 0 // ={0,1,2} How broken is it???
	var/global/list/datum/recipe/available_recipes // List of the recipes you can use
	var/global/list/acceptable_items // List of the items you can put in
	var/global/list/acceptable_reagents // List of the reagents you can put in
	var/global/max_n_of_items = 0

	var/static/radial_eject = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_eject")
	var/static/radial_use = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_use")

	// we show the button even if the proc will not work
	var/static/list/radial_options = list("eject" = radial_eject, "use" = radial_use)
	var/static/list/ai_radial_options = list("use" = radial_use)

// see code/modules/food/recipes_microwave.dm for recipes

/*******************
*   Initialising
********************/

/obj/machinery/microwave/Initialize()
	. = ..()
	create_reagents(100)
	if (!available_recipes)
		available_recipes = new
		for (var/type in (typesof(/datum/recipe) - /datum/recipe))
			available_recipes += new type
		acceptable_items = new
		acceptable_reagents = new
		for (var/datum/recipe/recipe in available_recipes)
			for (var/item in recipe.items)
				acceptable_items |= item
			for (var/reagent in recipe.reagents)
				acceptable_reagents |= reagent
			if (recipe.items)
				max_n_of_items = max(max_n_of_items,recipe.items.len)
		// This will do until I can think of a fun recipe to use dionaea in -
		// will also allow anything using the holder item to be microwaved into
		// impure carbon. ~Z
		acceptable_items |= /obj/item/weapon/holder
		acceptable_items |= /obj/item/weapon/reagent_containers/food/snacks/grown
		update_examine()

/*******************
*   Item Adding
********************/

/obj/machinery/microwave/attackby(obj/item/O as obj, mob/user as mob)
	if(src.broken)
		if(src.broken == 2 && isScrewdriver(O)) // If it's broken and they're using a screwdriver
			user.visible_message( \
				SPAN("notice", "\The [user] starts to fix part of the microwave."), \
				SPAN("notice", "You start to fix part of the microwave.") \
			)
			if (do_after(user, 20, src))
				user.visible_message( \
					SPAN("notice", "\The [user] fixes part of the microwave."), \
					SPAN("notice", "You have fixed part of the microwave.") \
				)
				src.broken = 1 // Fix it a bit
		else if(src.broken == 1 && isWrench(O)) // If it's broken and they're doing the wrench
			user.visible_message( \
				SPAN("notice", "\The [user] starts to fix part of the microwave."), \
				SPAN("notice", "You start to fix part of the microwave.") \
			)
			if (do_after(user, 20, src))
				user.visible_message( \
					SPAN("notice", "\The [user] fixes the microwave."), \
					SPAN("notice", "You have fixed the microwave.") \
				)
				src.broken = 0 // Fix it!
				src.dirty = 0 // just to be sure
				src.update_icon()
				src.atom_flags = ATOM_FLAG_OPEN_CONTAINER
		else
			to_chat(user, SPAN("warning", "It's broken!"))
			return 1
	else if(src.dirty == 100) // The microwave is all dirty so can't be used!
		if(istype(O, /obj/item/weapon/reagent_containers/spray/cleaner) || istype(O, /obj/item/weapon/reagent_containers/glass/rag)) // If they're trying to clean it then let them
			user.visible_message( \
				SPAN("notice", "\The [user] starts to clean the microwave."), \
				SPAN("notice", "You start to clean the microwave.") \
			)
			if (do_after(user, 20, src))
				user.visible_message( \
					SPAN("notice", "\The [user] has cleaned the microwave."), \
					SPAN("notice", "You have cleaned the microwave.") \
				)
				src.dirty = 0 // It's clean!
				src.broken = 0 // just to be sure
				src.update_icon()
				src.atom_flags = ATOM_FLAG_OPEN_CONTAINER
		else //Otherwise bad luck!!
			to_chat(user, SPAN("warning", "It's dirty!"))
			return 1
	else if(is_type_in_list(O, acceptable_items))
		if (contents.len >= max_n_of_items)
			to_chat(user, SPAN("warning", "This [src] is full of ingredients, you cannot put more."))
			return 1
		if(istype(O, /obj/item/stack)) // This is bad, but I can't think of how to change it
			var/obj/item/stack/S = O
			if(S.get_amount() > 1)
				new O.type (src)
				S.use(1)
			else
				user.drop_item(src)
			user.visible_message( \
					SPAN("notice", "\The [user] has added one of [O] to \the [src]."), \
					SPAN("notice", "You add one of [O] to \the [src]."))
			src.update_examine()
			return
		else
			if(!user.drop_from_inventory(O))
				return
			O.forceMove(src)
			user.visible_message( \
				SPAN("notice", "\The [user] has added \the [O] to \the [src]."), \
				SPAN("notice", "You add \the [O] to \the [src]."))
			src.update_examine()
			return
	else if(istype(O,/obj/item/weapon/reagent_containers/glass) || \
	        istype(O,/obj/item/weapon/reagent_containers/food/drinks) || \
	        istype(O,/obj/item/weapon/reagent_containers/food/condiment) \
		)
		if (!O.reagents)
			return 1
		for (var/datum/reagent/R in O.reagents.reagent_list)
			if (!(R.type in acceptable_reagents))
				to_chat(user, SPAN("warning", "Your [O] contains components unsuitable for cookery."))
				return 1
		return
	else if(istype(O, /obj/item/grab))
		var/obj/item/grab/G = O
		to_chat(user, SPAN("warning", "This is ridiculous. You can not fit \the [G.affecting] in this [src]."))
		return 1
	else if(isCrowbar(O))
		user.visible_message( \
			SPAN("notice", "\The [user] begins [src.anchored ? "unsecuring" : "securing"] the microwave."), \
			SPAN("notice", "You attempt to [src.anchored ? "unsecure" : "secure"] the microwave.")
			)
		if(do_after(user,20, src))
			src.anchored = !src.anchored
			user.visible_message( \
			SPAN("notice", "\The [user] [src.anchored ? "secures" : "unsecures"] the microwave."), \
			SPAN("notice", "You [src.anchored ? "secure" : "unsecure"] the microwave.")
			)
		else
			to_chat(user, SPAN("notice", "You decide not to do that."))
		return 1
	else
		to_chat(user, SPAN("warning", "You have no idea what you can cook with this [O]."))
	..()

/obj/machinery/microwave/attack_ai(mob/user as mob)
	attack_hand(user)

/obj/machinery/microwave/attack_hand(mob/user as mob)
	user.set_machine(src)
	interact(user)

/*******************
*   Microwave Menu
********************/

/obj/machinery/microwave/interact(mob/user as mob) // The microwave Menu

	if(src.broken)
		to_chat(user, SPAN("warning", "It's broken!"))
		return

	if(src.dirty == 100)
		to_chat(user, SPAN("warning", "It's dirty!"))
		return

	if(operating)
		return

	var/list/complete_options = radial_options.Copy()

	if(!reagents.total_volume && !contents.len)
		complete_options.Remove("eject")

	var/choice = show_radial_menu(user, src, isAI(user) ? ai_radial_options : complete_options, require_near = !issilicon(user))

	switch(choice)
		if("eject")
			dispose()
		if("use")
			cook()

/obj/machinery/microwave/proc/update_examine() // The microwave examine
	desc = "Cooks and boils stuff.\n"

	var/list/items_counts = new
	var/list/items_measures = new
	var/list/items_measures_p = new
	var/new_desc = ""

	if (!items_counts.len && !reagents.total_volume)
		new_desc += "<B>The microwave is empty</B>"
	else
		new_desc += "<B>Ingredients:</B>\n"

	for (var/obj/O in InsertedContents())
		var/display_name = O.name
		if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/egg))
			items_measures[display_name] = "egg"
			items_measures_p[display_name] = "eggs"
		if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/tofu))
			items_measures[display_name] = "tofu chunk"
			items_measures_p[display_name] = "tofu chunks"
		if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/meat)) //any meat
			items_measures[display_name] = "slab of meat"
			items_measures_p[display_name] = "slabs of meat"
		if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/donkpocket))
			display_name = "Turnovers"
			items_measures[display_name] = "turnover"
			items_measures_p[display_name] = "turnovers"
		if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/carpmeat))
			items_measures[display_name] = "fillet of meat"
			items_measures_p[display_name] = "fillets of meat"
		items_counts[display_name]++

	for (var/O in items_counts)
		var/N = items_counts[O]
		if (!(O in items_measures))
			new_desc += "<B>[capitalize(O)]:</B> [N] [lowertext(O)]\s\n"
		else
			if (N == 1)
				new_desc += "<B>[capitalize(O)]:</B> [N] [items_measures[O]]\n"
			else
				new_desc += "<B>[capitalize(O)]:</B> [N] [items_measures_p[O]]\n"

	for (var/datum/reagent/R in reagents.reagent_list)
		var/display_name = R.name
		if (R.type == /datum/reagent/capsaicin)
			display_name = "Hotsauce"
		if (R.type == /datum/reagent/frostoil)
			display_name = "Coldsauce"
		new_desc += "<B>[capitalize(display_name)]:</B> [R.volume] unit\s\n"

	desc += new_desc

/***********************************
*   Microwave Menu Handling/Cooking
************************************/

/obj/machinery/microwave/proc/cook()
	if((stat & (NOPOWER|BROKEN)) || operating)
		return
	start()
	if (!reagents.total_volume && !contents.len) //dry run
		if (!wzhzhzh(10))
			abort()
			return
		stop()
		return

	var/datum/recipe/recipe = select_recipe(available_recipes,src)
	var/obj/cooked
	if (!recipe)
		dirty += 1
		if (prob(max(10, dirty * 5)))
			if (!wzhzhzh(4))
				abort()
				return
			muck_start()
			wzhzhzh(4)
			muck_finish()
			cooked = fail()
			cooked.dropInto(loc)
			update_examine()
			return
		else if (has_extra_item())
			if (!wzhzhzh(4))
				abort()
				return
			broke()
			cooked = fail()
			cooked.dropInto(loc)
			update_examine()
			return
		else
			if (!wzhzhzh(10))
				abort()
				return
			stop()
			cooked = fail()
			cooked.dropInto(loc)
			update_examine()
			return
	else
		var/halftime = round((recipe.time / 10) / 2)
		if (!wzhzhzh(halftime))
			abort()
			return
		if (!wzhzhzh(halftime))
			abort()
			cooked = fail()
			cooked.dropInto(loc)
			update_examine()
			return
		cooked = recipe.make_food(src)
		stop()
		if(cooked)
			cooked.dropInto(loc)
			update_examine()
		return

/obj/machinery/microwave/proc/wzhzhzh(seconds as num) // Whoever named this proc is fucking literally Satan. ~ Z
	for (var/i = 1 to seconds)
		if (stat & (NOPOWER|BROKEN))
			return 0
		use_power_oneoff(500)
		sleep(10)
	return 1

/obj/machinery/microwave/proc/has_extra_item()
	for (var/obj/O in src)
		if (!istype(O,/obj/item/weapon/reagent_containers/food) && !istype(O, /obj/item/weapon/grown))
			return 1
	return 0

/obj/machinery/microwave/proc/start()
	src.visible_message(SPAN("notice", "The microwave turns on."), SPAN("notice", "You hear a microwave."))
	src.operating = 1
	src.update_icon()

/obj/machinery/microwave/proc/abort()
	src.operating = 0 // Turn it off again aferwards
	src.update_icon()

/obj/machinery/microwave/proc/stop()
	playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
	src.operating = 0 // Turn it off again aferwards
	src.update_icon()
	src.update_examine()

/obj/machinery/microwave/proc/dispose()
	if(operating)
		return
	for (var/obj/O in src)
		O.dropInto(loc)
	if (src.reagents.total_volume)
		src.dirty++
	src.reagents.clear_reagents()
	to_chat(usr, SPAN("notice", "You dispose of the microwave contents."))
	src.update_examine()

/obj/machinery/microwave/proc/muck_start()
	playsound(src.loc, 'sound/effects/splat.ogg', 50, 1) // Play a splat sound
	src.update_icon()

/obj/machinery/microwave/proc/muck_finish()
	playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
	src.visible_message(SPAN("warning", "The microwave gets covered in muck!"))
	src.dirty = 100 // Make it dirty so it can't be used util cleaned
	src.obj_flags = null //So you can't add condiments
	src.operating = 0 // Turn it off again aferwards
	src.update_icon()

/obj/machinery/microwave/proc/broke()
	var/datum/effect/effect/system/spark_spread/s = new
	s.set_up(2, 1, src)
	s.start()
	src.visible_message(SPAN("warning", "The microwave breaks!")) //Let them know they're stupid
	src.broken = 2 // Make it broken so it can't be used util fixed
	src.obj_flags = null //So you can't add condiments
	src.operating = 0 // Turn it off again aferwards
	src.update_icon()

/obj/machinery/microwave/update_icon()
	if(dirty == 100)
		src.icon_state = "mwbloody[operating]"
	else if(broken)
		src.icon_state = "mwb"
	else
		src.icon_state = "mw[operating]"

/obj/machinery/microwave/proc/fail()
	var/amount = 0
	for (var/obj/O in contents)
		amount++
		if (O.reagents)
			var/reagent_type = O.reagents.get_master_reagent_type()
			if (reagent_type)
				amount += O.reagents.get_reagent_amount(reagent_type)
		qdel(O)
	src.reagents.clear_reagents()
	var/obj/item/weapon/reagent_containers/food/snacks/badrecipe/ffuu = new(src)
	ffuu.reagents.add_reagent(/datum/reagent/carbon, amount)
	ffuu.reagents.add_reagent(/datum/reagent/toxin, amount/10)
	return ffuu
