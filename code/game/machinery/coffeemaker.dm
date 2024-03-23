#define BEAN_CAPACITY 10 //amount of coffee beans that can fit inside the impressa coffeemaker

/obj/machinery/coffeemaker
	name = "coffeemaker"
	desc = "A Modello 3 Coffeemaker that brews coffee and holds it at the perfect temperature of 176 fahrenheit. Made by Piccionaia Home Appliances."
	icon = 'icons/obj/machines/coffeemaker.dmi'
	icon_state = "coffeemaker_impressa"
	base_icon_state = "coffeemaker_impressa"
	obj_flags = OBJ_FLAG_ANCHORABLE
	density = TRUE
	var/obj/item/reagent_containers/vessel/coffeepot/coffeepot = null
	var/brewing = FALSE
	var/brew_time = 8 SECONDS
	var/speed = 1
	/// The number of cups left
	var/coffee_cups = 0
	var/max_coffee_cups = 15
	/// The amount of sugar packets left
	var/sugar_packs = 0
	var/max_sugar_packs = 10
	/// The amount of sweetener packets left
	var/sweetener_packs = 0
	var/max_sweetener_packs = 10
	/// The amount of creamer packets left
	var/creamer_packs = 0
	var/max_creamer_packs = 10
	/// Current amount of coffee beans stored
	var/coffee_amount = 0
	/// List of coffee bean objects are stored
	var/list/coffee = list()

	var/static/image/coffeepot_empty = image(icon = 'icons/obj/machines/coffeemaker.dmi', icon_state = "pot_full")
	var/static/image/coffeepot_halffull = image(icon = 'icons/obj/machines/coffeemaker.dmi', icon_state = "pot_halffull")
	var/static/image/coffeepot_full = image(icon = 'icons/obj/machines/coffeemaker.dmi', icon_state = "pot_empty")
	var/static/image/cups_1 = image(icon = 'icons/obj/machines/coffeemaker.dmi', icon_state = "cups_1")
	var/static/image/cups_2 = image(icon = 'icons/obj/machines/coffeemaker.dmi', icon_state = "cups_2")
	var/static/image/cups_3 = image(icon = 'icons/obj/machines/coffeemaker.dmi', icon_state = "cups_3")
	var/static/image/sugar_packs_overlay = image(icon = 'icons/obj/machines/coffeemaker.dmi', icon_state = "extras_1")
	var/static/image/creamer_packs_overlay = image(icon = 'icons/obj/machines/coffeemaker.dmi', icon_state = "extras_1")
	var/static/image/sweetener_packs_overlay = image(icon = 'icons/obj/machines/coffeemaker.dmi', icon_state = "extras_1")
	var/static/image/grinder_half = image(icon = 'icons/obj/machines/coffeemaker.dmi', icon_state = "grinder_half")
	var/static/image/grinder_full = image(icon = 'icons/obj/machines/coffeemaker.dmi', icon_state = "grinder_full")

	var/static/image/radial_examine = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_examine")
	var/static/image/radial_brew = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_brew")
	var/static/image/radial_eject_pot = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_eject_pot")
	var/static/image/radial_take_cup = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_take_cup")
	var/static/image/radial_take_sugar = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_take_sugar")
	var/static/image/radial_take_sweetener = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_take_sweetener")
	var/static/image/radial_take_creamer = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_take_creamer")

/obj/machinery/coffeemaker/Initialize(mapload)
	. = ..()
	if(mapload)
		coffeepot = new /obj/item/reagent_containers/vessel/coffeepot(src)
		coffee_cups = max_coffee_cups
		sugar_packs = max_sugar_packs
		sweetener_packs = max_sweetener_packs
		creamer_packs = max_creamer_packs

	update_icon()

/obj/machinery/coffeemaker/Destroy()
	QDEL_NULL(coffeepot)
	QDEL_NULL(coffee)
	return ..()

/obj/machinery/coffeemaker/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == coffeepot)
		coffeepot = null

	if(gone in coffee)
		coffee -= gone

	update_icon()

/obj/machinery/coffeemaker/_examine_text(mob/user)
	. = ..()
	if(!in_range(user, src) && !issilicon(user) && !isobserver(user))
		. += SPAN_WARNING("You're too far away to examine [src]'s contents and display! \n")
		return

	if(brewing)
		. += SPAN_WARNING("\The [src] is brewing. \n")
		return

	if(panel_open)
		. += SPAN_NOTICE("[src]'s maintenance hatch is open! \n")
		return

	if(coffeepot)
		. += SPAN_NOTICE("\The [src] contains: \n")
		. += SPAN_NOTICE("- \A [coffeepot]. \n")

	if(!(stat & (NOPOWER|BROKEN)))
		. += "[SPAN_NOTICE("The status display reads:")]\n"+\
		SPAN_NOTICE("- Brewing coffee at <b>[speed*100]%</b>.\n")
		if(coffeepot)
			for(var/datum/reagent/drink/cawfee as anything in coffeepot.reagents.reagent_list)
				. += SPAN_NOTICE("- [cawfee.volume] units of coffee in pot.\n")

	if(coffee_cups >= 1)
		. += SPAN_NOTICE("There [coffee_cups == 1 ? "is" : "are"] [coffee_cups] coffee cup[coffee_cups != 1 && "s"] left.\n")
	else
		. += SPAN_NOTICE("There are no cups left.\n")

	if(sugar_packs >= 1)
		. += SPAN_NOTICE("There [sugar_packs == 1 ? "is" : "are"] [sugar_packs] packet[sugar_packs != 1 && "s"] of sugar left.\n")
	else
		. += SPAN_NOTICE("There is no sugar left.\n")

	if(sweetener_packs >= 1)
		. += SPAN_NOTICE("There [sweetener_packs == 1 ? "is" : "are"] [sweetener_packs] packet[sweetener_packs != 1 && "s"] of sweetener left.\n")
	else
		. += SPAN_NOTICE("There is no sweetener left.\n")

	if(creamer_packs > 1)
		. += SPAN_NOTICE("There [creamer_packs == 1 ? "is" : "are"] [creamer_packs] packet[creamer_packs != 1 && "s"] of creamer left.\n")
	else
		. += SPAN_NOTICE("There is no creamer left.\n")

	if(coffee)
		. += SPAN_NOTICE("The internal grinder contains [coffee.len] scoop\s of coffee beans\n")

/obj/machinery/coffeemaker/on_update_icon()
	. = ..()

	CutOverlays(coffeepot_empty)
	CutOverlays(coffeepot_full)
	CutOverlays(coffeepot_halffull)
	if(coffeepot)
		if(coffeepot.reagents.total_volume > 0 && coffeepot.reagents.total_volume < coffeepot.reagents.maximum_volume)
			AddOverlays(coffeepot_halffull)
		else if(coffeepot.reagents.total_volume > 0)
			AddOverlays(coffeepot_full)
		else
			AddOverlays(coffeepot_empty)

	CutOverlays(cups_1)
	CutOverlays(cups_2)
	CutOverlays(cups_3)

	if(coffee_cups > 0)
		if(coffee_cups >= max_coffee_cups / 3)
			if(coffee_cups > max_coffee_cups / 1.5)
				AddOverlays(cups_3)
			else
				AddOverlays(cups_2)
		else
			AddOverlays(cups_1)

	if(sugar_packs)
		AddOverlays(sugar_packs_overlay)
	else
		CutOverlays(sugar_packs_overlay)

	if(creamer_packs)
		AddOverlays(creamer_packs_overlay)
	else
		CutOverlays(creamer_packs_overlay)

	if(sweetener_packs)
		AddOverlays(sweetener_packs_overlay)
	else
		CutOverlays(sweetener_packs_overlay)

	CutOverlays(grinder_full)
	CutOverlays(grinder_half)
	if(coffee_amount)
		if(coffee_amount < 0.7 * BEAN_CAPACITY)
			AddOverlays(grinder_half)
		else
			AddOverlays(grinder_full)

/obj/machinery/coffeemaker/proc/replace_pot(mob/living/user, obj/item/reagent_containers/vessel/coffeepot/new_coffeepot)
	if(!user)
		return FALSE

	if(coffeepot)
		user.pick_or_drop(coffeepot, get_turf(src))
		show_splash_text(user, "ejected pot")

	if(new_coffeepot)
		coffeepot = new_coffeepot
		show_splash_text(user, "instered pot")

	update_icon()
	return TRUE

/obj/machinery/coffeemaker/attackby(obj/item/attack_item, mob/living/user, params)
	if(!coffeepot && default_deconstruction_screwdriver(user, icon_state, icon_state, attack_item))
		return

	if(default_deconstruction_crowbar(attack_item))
		return

	if(panel_open) //Can't insert objects when its screwed open
		return

	if(istype(attack_item, /obj/item/reagent_containers/vessel/coffeepot) && attack_item.is_open_container())
		var/obj/item/reagent_containers/vessel/coffeepot/new_pot = attack_item
		if(!user.drop(new_pot, src))
			return

		replace_pot(user, new_pot)
		update_icon()
		return

	if(istype(attack_item, /obj/item/reagent_containers/vessel/takeaway))
		var/obj/item/reagent_containers/vessel/takeaway/new_cup = attack_item //different type of cup
		if(new_cup.reagents.total_volume > 0 )
			show_splash_text(user, "the cup must be empty!")
			return

		if(coffee_cups >= max_coffee_cups)
			show_splash_text(user, "the cup holder is full!")
			return

		if(!user.drop(attack_item, src))
			return

		coffee_cups++
		update_icon()
		return

	if(istype(attack_item, /obj/item/reagent_containers/vessel/condiment/pack/sugar))
		var/obj/item/reagent_containers/vessel/condiment/pack/sugar/new_pack = attack_item
		if(new_pack.reagents.total_volume < new_pack.reagents.maximum_volume)
			show_splash_text(user, "the pack must be full!")
			return

		if(sugar_packs >= max_sugar_packs)
			show_splash_text(user, "the sugar compartment is full!")
			return

		if(!user.drop(attack_item, src))
			return

		sugar_packs++
		update_icon()
		return

	if(istype(attack_item, /obj/item/reagent_containers/vessel/condiment/pack/creamer))
		var/obj/item/reagent_containers/vessel/condiment/pack/creamer/new_pack = attack_item
		if(new_pack.reagents.total_volume < new_pack.reagents.maximum_volume)
			show_splash_text(user, "the pack must be full!")
			return

		if(creamer_packs >= max_creamer_packs)
			show_splash_text(user, "the creamer compartment is full!")
			return

		if(!user.drop(attack_item, src))
			return

		creamer_packs++
		update_icon()
		return

	if(istype(attack_item, /obj/item/reagent_containers/vessel/condiment/pack/astrotame))
		var/obj/item/reagent_containers/vessel/condiment/pack/astrotame/new_pack = attack_item
		if(new_pack.reagents.total_volume < new_pack.reagents.maximum_volume)
			show_splash_text(user, "the pack must be full!")
			return

		if(sweetener_packs >= max_sweetener_packs)
			show_splash_text(user, "the sweetener compartment is full!")
			return

		if(!user.drop(attack_item, src))
			return

		sweetener_packs++
		update_icon()
		return

	if(istype(attack_item, /obj/item/reagent_containers/food/grown/coffee))
		if(coffee_amount >= BEAN_CAPACITY)
			show_splash_text(user, "the coffee container is full!")
			return

		var/obj/item/reagent_containers/food/grown/coffee/new_coffee = attack_item
		if(!user.drop(new_coffee, src))
			return

		coffee += new_coffee
		coffee_amount++
		show_splash_text(user, "added coffee")
		return

	if(istype(attack_item, /obj/item/storage/box/coffeepack))
		if(coffee_amount >= BEAN_CAPACITY)
			show_splash_text(user, "the coffee container is full!")
			return

		var/obj/item/storage/box/coffeepack/new_coffee_pack = attack_item
		for(var/obj/item/reagent_containers/food/grown/coffee/new_coffee in new_coffee_pack.contents)
			if(coffee_amount < BEAN_CAPACITY)
				if(user.drop(new_coffee, src))
					coffee += new_coffee
					coffee_amount++
					new_coffee.forceMove(src)
					show_splash_text(user, "added coffee")
					update_icon()
					return

	update_icon()
	return ..()

/obj/machinery/coffeemaker/proc/try_brew()
	if(coffee_amount <= 0)
		show_splash_text(usr, "no coffee beans added!")
		return FALSE

	if(!coffeepot)
		show_splash_text(usr, "no coffeepot inside!")
		return FALSE

	if(stat & (NOPOWER|BROKEN) )
		show_splash_text(usr, "machine unpowered!")
		return FALSE

	if(coffeepot.reagents.total_volume >= coffeepot.reagents.maximum_volume)
		show_splash_text(usr, "the coffeepot is already full!")
		return FALSE

	return TRUE

/obj/machinery/coffeemaker/attack_hand(mob/user)
	. = ..()

	if(issilicon(user))
		return // Fuck u synth

	if(brewing || panel_open || !anchored || !CanUseTopic(user))
		return

	var/list/options = list()

	if(coffeepot)
		options["Eject Pot"] = radial_eject_pot

	options["Brew"] = radial_brew //brew is always available as an option, when the machine is unable to brew the player is told by balloon alerts whats exactly wrong

	if(coffee_cups > 0)
		options["Take Cup"] = radial_take_cup

	if(sugar_packs > 0)
		options["Take Sugar"] = radial_take_sugar

	if(sweetener_packs > 0)
		options["Take Sweetener"] = radial_take_sweetener

	if(creamer_packs > 0)
		options["Take Creamer"] = radial_take_creamer

	if(isAI(user))
		if(stat & NOPOWER)
			return
		options["Examine"] = radial_examine

	var/choice

	if(length(options) < 1)
		return

	if(length(options) == 1)
		choice = options[1]
	else
		choice = show_radial_menu(user, src, options, require_near = !issilicon(user))

	// post choice verification
	if(brewing || panel_open || !anchored || !CanUseTopic(user))
		return

	switch(choice)
		if("Brew")
			brew(user)
		if("Eject Pot")
			eject_pot(user)
		if("Examine")
			examine(user)
		if("Take Cup")
			take_cup(user)
		if("Take Sugar")
			take_sugar(user)
		if("Take Sweetener")
			take_sweetener(user)
		if("Take Creamer")
			take_creamer(user)

/obj/machinery/coffeemaker/proc/eject_pot(mob/user)
	if(coffeepot)
		replace_pot(user)

/obj/machinery/coffeemaker/proc/take_cup(mob/user)
	if(!coffee_cups) //shouldn't happen, but we all know how stuff manages to break
		show_splash_text(user, "no cups left!")
		return

	var/obj/item/reagent_containers/vessel/takeaway/new_cup = new(get_turf(src))
	if(Adjacent(user))
		user.put_in_hands(new_cup)
	else
		new_cup.dropInto(get_turf(src))
	coffee_cups--
	update_icon()

/obj/machinery/coffeemaker/proc/take_sugar(mob/user)
	if(!sugar_packs)
		show_splash_text(user, "no sugar left!")
		return

	var/obj/item/reagent_containers/vessel/condiment/pack/sugar/new_pack = new(get_turf(src))
	if(Adjacent(user))
		user.put_in_hands(new_pack)
	else
		new_pack.dropInto(get_turf(src))
	sugar_packs--
	update_icon()

/obj/machinery/coffeemaker/proc/take_sweetener(mob/user)
	if(!sweetener_packs)
		show_splash_text(user, "no sweetener left!")
		return

	var/obj/item/reagent_containers/vessel/condiment/pack/astrotame/new_pack = new(get_turf(src))
	if(Adjacent(user))
		user.put_in_hands(new_pack)
	else
		new_pack.dropInto(get_turf(src))
	sweetener_packs--
	update_icon()

/obj/machinery/coffeemaker/proc/take_creamer(mob/user)
	if(!creamer_packs)
		show_splash_text(user, "no creamer left!")
		return

	var/obj/item/reagent_containers/vessel/condiment/pack/creamer/new_pack = new(drop_location())
	if(Adjacent(user))
		user.put_in_hands(new_pack)
	else
		new_pack.dropInto(get_turf(src))
	creamer_packs--
	update_icon()

///Updates the smoke state to something else, setting particles if relevant
/obj/machinery/coffeemaker/proc/toggle_steam()
	QDEL_NULL(particles)
	if(brewing)
		particles = new /particles/smoke/steam/mild()
		particles.position = list(-2, 1, 0)

/obj/machinery/coffeemaker/proc/operate_for(time, silent = FALSE)
	brewing = TRUE
	if(!silent)
		playsound(src, 'sound/machines/coffeemaker_brew.ogg', 20, vary = TRUE)

	toggle_steam()
	use_power_oneoff(active_power_usage * time * 0.1) // .1 needed here to convert time (in deciseconds) to seconds such that watts * seconds = joules
	addtimer(CALLBACK(src, nameof(.proc/stop_operating)), time / speed)

/obj/machinery/coffeemaker/proc/stop_operating()
	brewing = FALSE
	toggle_steam()

/obj/machinery/coffeemaker/proc/brew(mob/user)
	power_change()
	if(!try_brew())
		return

	operate_for(brew_time)
	coffeepot.reagents.add_reagent(/datum/reagent/caffeine/coffee, 120)
	coffee.Cut(1,2) //remove the first item from the list
	coffee_amount--
	update_icon()

#undef BEAN_CAPACITY
