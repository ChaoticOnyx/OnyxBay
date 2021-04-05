
/obj/item/weapon/backwear/reagent/welding
	name = "welding kit"
	desc = "An unwieldy, heavy backpack with two massive fuel tanks and a connected welding tool. Includes a connector for most models of portable welding tools."
	description_info = "This pack acts as a portable source of welding fuel. Use a welder on it to refill its tank - but make sure it's not lit! You can use this kit on a fuel tank or appropriate reagent dispenser to replenish its reserves."
	description_fluff = "The Shenzhen Chain of 2380 was an industrial accident of noteworthy infamy that occurred at Earth's L3 Lagrange Point. An apprentice welder, working for the Shenzhen Space Fabrication Group, failed to properly seal her fuel port, triggering a chain reaction that spread from laborer to laborer, instantly vaporizing a crew of fourteen. Don't let this happen to you!"
	description_antag = "In theory, you could hold an open flame to this pack and produce some pretty catastrophic results. The trick is getting out of the blast radius."
	icon_state = "fuel0"
	base_icon = "fuel"
	item_state = "backwear_welding"
	hitsound = 'sound/effects/fighting/smash.ogg'
	gear_detachable = FALSE
	gear = /obj/item/weapon/weldingtool/linked
	atom_flags = null
	initial_capacity = 500
	initial_reagent_types = list(/datum/reagent/fuel = 1)
	origin_tech = list(TECH_ENGINEERING = 3)
	matter = list(MATERIAL_STEEL = 1500, MATERIAL_GLASS = 500)

/obj/item/weapon/backwear/reagent/welding/afterattack(obj/O, mob/user, proximity)
	if(!proximity)
		return
	if(istype(O, /obj/structure/reagent_dispensers/fueltank))
		if(!O.reagents.total_volume)
			to_chat(user, SPAN("notice", "\The [O] is empty."))
			return
		if(reagents.total_volume >= initial_capacity)
			to_chat(user, SPAN("notice", "\The [src] is already full!"))
			return
		O.reagents.trans_to_obj(src, initial_capacity)
		to_chat(user, SPAN("notice", "You crack the cap off the top of your [src] and fill it back up again from \the [O]."))
		playsound(src.loc, 'sound/effects/refill.ogg', 50, 1, -6)
		return

/obj/item/weapon/backwear/reagent/welding/reattach_gear(mob/user)
	..()
	if(istype(gear, /obj/item/weapon/weldingtool/linked))
		var/obj/item/weapon/weldingtool/W = gear
		W.setWelding(0)

/obj/item/weapon/backwear/reagent/welding/attackby(obj/item/weapon/W, mob/user)
	if(W.get_temperature_as_from_ignitor())
		if(!reagents.total_volume)
			to_chat(user, SPAN("danger", "You put \the [W] to \the [src] and with a moment of lucidity you realize, this might not have been the smartest thing you've ever done. Luckily, \the [src] is empty."))
			return
		else
			log_and_message_admins("triggered a welding kit explosion with [W].")
			user.visible_message(SPAN("danger", "[user] puts [W] to [src]!"), SPAN("danger", "You put \the [W] to \the [src] and with a moment of lucidity you realize, this might not have been the smartest thing you've ever done."))
			explosion(get_turf(src), 0, 1, 3)
			if(src)
				qdel(src)
			return
	return ..()


/obj/item/weapon/weldingtool/linked
	name = "welding tool"
	desc = "A lightweight welding tool connected to a welding kit."
	icon = 'icons/obj/backwear.dmi'
	icon_state = "welder"
	item_state = "welder"
	w_class = ITEM_SIZE_NORMAL
	force = 5.5
	mod_weight = 0.55
	mod_reach = 0.6
	mod_handy = 0.75
	canremove = 0
	unacidable = 1 //TODO: make these replaceable so we won't need such ducttaping
	slot_flags = null
	tank = null
	matter = null
	var/obj/item/weapon/backwear/reagent/base_unit

/obj/item/weapon/weldingtool/linked/New(newloc, obj/item/weapon/backwear/base)
	base_unit = base
	..(newloc)

/obj/item/weapon/weldingtool/linked/Destroy() //it shouldn't happen unless the base unit is destroyed but still
	if(base_unit)
		if(base_unit.gear == src)
			base_unit.gear = null
			base_unit.update_icon()
		base_unit = null
	return ..()

/obj/item/weapon/weldingtool/linked/dropped(mob/user)
	..()
	if(base_unit)
		base_unit.reattach_gear(user)

/obj/item/weapon/weldingtool/linked/get_fuel()
	return base_unit ? base_unit.reagents.get_reagent_amount(/datum/reagent/fuel) : 0

/obj/item/weapon/weldingtool/linked/remove_fuel(amount = 1, mob/M = null)
	if(!welding)
		return 0
	if(get_fuel() >= amount)
		burn_fuel(amount)
		if(M)
			eyecheck(M)
			playsound(M.loc, 'sound/items/Welder.ogg', 20, 1)
		return 1
	else
		if(M)
			to_chat(M, "<span class='notice'>You need more welding fuel to complete this task.</span>")
		return 0

/obj/item/weapon/weldingtool/linked/burn_fuel(amount)
	if(!base_unit)
		return

	var/mob/living/in_mob = null

	if(isliving(src.loc))
		var/mob/living/L = src.loc
		if(!(L.l_hand == src || L.r_hand == src))
			in_mob = L

	if(in_mob)
		amount = max(amount, 2)
		base_unit.reagents.trans_type_to(in_mob, /datum/reagent/fuel, amount)
		in_mob.IgniteMob()

	else
		base_unit.reagents.remove_reagent(/datum/reagent/fuel, amount)
		var/turf/location = get_turf(src.loc)
		if(location)
			location.hotspot_expose(700, 5)

/obj/item/weapon/weldingtool/linked/afterattack(obj/O, mob/user, proximity)
	if(!proximity)
		return
	if((istype(O, /obj/structure/reagent_dispensers/fueltank) || istype(O, /obj/item/weapon/backwear)) && !welding)
		return
	..()

/obj/item/weapon/weldingtool/linked/attackby(obj/item/W, mob/user)
	if(welding)
		return
	if(isScrewdriver(W))
		return
	if(istype(W,/obj/item/pipe))
		return
	if(istype(W, /obj/item/weapon/welder_tank))
		return
	..()

/obj/item/weapon/weldingtool/linked/refuel_from_obj(obj/O, mob/user)
	return
