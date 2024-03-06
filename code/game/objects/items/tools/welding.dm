
/*
 * Welding Tool
 */
/obj/item/weldingtool
	name = "welding tool"
	icon = 'icons/obj/tools.dmi'
	icon_state = "welder_m"
	item_state = "welder"
	desc = "A heavy but portable welding gun with its own interchangeable fuel tank. It features a simple toggle switch and a port for attaching an external tank."
	description_info = "Use in your hand to toggle the welder on and off. Hold in one hand and click with an empty hand to remove its internal tank. Click on an object to try to weld it. You can seal airlocks, attach heavy-duty machines like emitters and disposal chutes, and repair damaged walls - these are only a few of its uses. Each use of the welder will consume a unit of fuel. Be sure to wear protective equipment such as goggles, a mask, or certain voidsuit helmets to prevent eye damage. You can refill the welder with a welder tank by clicking on it, but be sure to turn it off first!"
	description_fluff = "One of many tools of ancient design, still used in today's busy world of engineering with only minor tweaks here and there. Compact machinery and innovations in fuel storage have allowed for conveniences like this one-piece, handheld welder to exist."
	description_antag = "You can use a welder to rapidly seal off doors, ventilation ducts, and scrubbers. It also makes for a devastating weapon. Modify it with a screwdriver and stick some metal rods on it, and you've got the beginnings of a flamethrower."
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT
	center_of_mass = "x=14;y=15"
	tool_behaviour = TOOL_WELDER

	//Amount of OUCH when it's thrown
	force = 6.5
	throwforce = 5.0
	throw_range = 5
	w_class = ITEM_SIZE_NORMAL
	mod_weight = 1.0
	mod_reach = 0.75
	mod_handy = 0.75

	//Cost to make in the autolathe
	matter = list(MATERIAL_STEEL = 70, MATERIAL_GLASS = 30)

	//R&D tech level
	origin_tech = list(TECH_ENGINEERING = 1)

	//Welding tool specific stuff
	var/welding = 0 	//Whether or not the welding tool is off(0), on(1) or currently welding(2)
	var/status = 1 		//Whether the welder is secured or unsecured (able to attach rods to it to make a flamethrower)

	var/obj/item/welder_tank/tank = /obj/item/welder_tank // where the fuel is stored

	drop_sound = SFX_DROP_WELDINGTOOL
	pickup_sound = SFX_PICKUP_WELDINGTOOL

/obj/item/weldingtool/Initialize()
	if(ispath(tank))
		tank = new tank

	update_icon()

	. = ..()

/obj/item/weldingtool/Destroy()
	QDEL_NULL(tank)

	return ..()

/obj/item/weldingtool/_examine_text(mob/user)
	. = ..()
	if(get_dist(src, user) <= 0)
		if(tank)
			. += "\n\icon[tank] \The [tank] contains [get_fuel()]/[tank.max_fuel] units of fuel!"
		else
			. += "\nThere is no tank attached."

/obj/item/weldingtool/attack(mob/living/M, mob/living/user, target_zone)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/S = H.organs_by_name[target_zone]

		if(!S || !BP_IS_ROBOTIC(S) || user.a_intent != I_HELP)
			return ..()
		if(!welding)
			to_chat(user, "<span class='warning'>You'll need to turn [src] on to patch the damage on [M]'s [S.name]!</span>")
			return 1
		if(S.robo_repair(15, BRUTE, "some dents", src, user))
			remove_fuel(1, user)
	else
		return ..()

/obj/item/weldingtool/attackby(obj/item/W as obj, mob/user as mob)
	if(welding)
		to_chat(user, "<span class='danger'>Stop welding first!</span>")
		return

	if(isScrewdriver(W))
		status = !status
		if(status)
			to_chat(user, "<span class='notice'>You secure the welder.</span>")
		else
			to_chat(user, "<span class='notice'>The welder can now be attached and modified.</span>")
		src.add_fingerprint(user)
		return

	if((!status) && (istype(W,/obj/item/pipe)))
		if(tank)
			to_chat(user, "<span class='notice'>You should detach \the [tank] first.</span>")
			return
		qdel(W)

		if(istype(src.loc,/turf))
			qdel(src)
		else
			QDEL_NULL(src)
		user.visible_message("<span class='notice'>\The [user] fits \the [W] to \the [src] as a crude barrel.</span>")
		var/obj/item/boomstickframe/F = new /obj/item/boomstickframe(user.loc)
		F.add_fingerprint(user)
		return

	if(istype(W, /obj/item/welder_tank))
		if(tank)
			to_chat(user, "Remove the current tank first.")
			return

		if(W.w_class >= w_class)
			to_chat(user, "\The [W] is too large to fit in \the [src].")
			return

		if(!user.drop(W, src))
			return
		tank = W
		user.visible_message("[user] slots \a [W] into \the [src].", "You slot \a [W] into \the [src].")
		update_icon()
		return

	..()

/obj/item/weldingtool/attack_hand(mob/user as mob)
	if(tank && user.get_inactive_hand() == src)
		if(!welding)
			if(tank.can_remove)
				user.visible_message("[user] removes \the [tank] from \the [src].", "You remove \the [tank] from \the [src].")
				user.pick_or_drop(tank)
				tank = null
				update_icon()
			else
				to_chat(user, "\The [tank] can't be removed.")
		else
			to_chat(user, "<span class='danger'>Stop welding first!</span>")

	else
		..()

/obj/item/weldingtool/think()
	if(welding)
		if(!remove_fuel(0.05))
			setWelding(0)

	set_next_think(world.time + 1 SECOND)

/obj/item/weldingtool/afterattack(obj/O, mob/user, proximity)
	if(!proximity)
		return
	if((istype(O, /obj/structure/reagent_dispensers/fueltank) || istype(O, /obj/item/backwear/reagent/welding)) && get_dist(src, O) <= 1 && !welding)
		refuel_from_obj(O, user)
		return
	if(welding)
		remove_fuel(1)
		var/turf/location = get_turf(user)
		if(isliving(O))
			var/mob/living/L = O
			L.IgniteMob()
		if(istype(location, /turf))
			location.hotspot_expose(700, 50, 1)
	return


/obj/item/weldingtool/attack_self(mob/user as mob)
	setWelding(!welding, usr)
	return

/obj/item/weldingtool/proc/refuel_from_obj(obj/O, mob/user)
	if(!O.reagents)
		return
	if(!tank)
		to_chat(user, "\The [src] has no tank attached!")
		return
	var/amount = min((tank.max_fuel - tank.reagents.total_volume), O.reagents.total_volume)
	if(!O.reagents.total_volume)
		to_chat(user, SPAN("warning", "\The [O] is empty."))
		return
	if(!amount)
		to_chat(user, SPAN("notice", "\The [src] is full."))
		return
	O.reagents.trans_to_obj(tank, amount)
	to_chat(user, SPAN("notice", "You refill \the [src] with [amount] units of fuel from \the [O]."))
	playsound(src.loc, 'sound/effects/refill.ogg', 50, 1, -6)
	return

//Returns the amount of fuel in the welder
/obj/item/weldingtool/proc/get_fuel()
	return tank ? tank.reagents.get_reagent_amount(/datum/reagent/fuel) : 0


//Removes fuel from the welding tool. If a mob is passed, it will perform an eyecheck on the mob. This should probably be renamed to use()
/obj/item/weldingtool/proc/remove_fuel(amount = 1, mob/M = null)
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

/obj/item/weldingtool/proc/burn_fuel(amount)
	if(!tank)
		return

	var/mob/living/in_mob = null

	//consider ourselves in a mob if we are in the mob's contents and not in their hands
	if(isliving(src.loc))
		var/mob/living/L = src.loc
		if(!(L.l_hand == src || L.r_hand == src))
			in_mob = L

	if(in_mob)
		amount = max(amount, 2)
		tank.reagents.trans_type_to(in_mob, /datum/reagent/fuel, amount)
		in_mob.IgniteMob()

	else
		tank.reagents.remove_reagent(/datum/reagent/fuel, amount)
		var/turf/location = get_turf(src.loc)
		if(location)
			location.hotspot_expose(700, 5)

//Returns whether or not the welding tool is currently on.
/obj/item/weldingtool/proc/isOn()
	return src.welding

/obj/item/weldingtool/get_storage_cost()
	if(isOn())
		return ITEM_SIZE_NO_CONTAINER
	return ..()

/obj/item/weldingtool/on_update_icon()
	..()
	ClearOverlays()
	item_state = welding ? "welder1" : "welder"

	if(welding)
		AddOverlays(image(icon, "[initial(icon_state)]-over"))
		AddOverlays(emissive_appearance(icon, "[initial(icon_state)]-over"))

	underlays.Cut()
	if(tank)
		var/image/tank_image = image(tank.icon, tank.icon_state)
		tank_image.pixel_z = 0
		underlays += tank_image

	var/mob/M = loc
	if(istype(M))
		M.update_inv_l_hand()
		M.update_inv_r_hand()

//Sets the welding state of the welding tool. If you see W.welding = 1 anywhere, please change it to W.setWelding(1)
//so that the welding tool updates accordingly
/obj/item/weldingtool/proc/setWelding(set_welding, mob/M)
	if(!status)	return

	var/turf/T = get_turf(src)
	//If we're turning it on
	if(set_welding && !welding)
		if(get_fuel() > 0)
			if(M)
				to_chat(M, "<span class='notice'>You switch the [src] on.</span>")
			else if(T)
				T.visible_message("<span class='danger'>\The [src] turns on.</span>")
			force = 15
			damtype = "fire"
			hitsound = 'sound/effects/flare.ogg' // Surprisingly it sounds just perfect
			welding = 1
			set_light(1.0, 0.5, 2, 4.0, "#e38f46")
			update_icon()
			set_next_think(world.time)
		else
			if(M)
				to_chat(M, "<span class='notice'>You need more welding fuel to complete this task.</span>")
			return
	//Otherwise
	else if(!set_welding && welding)
		set_next_think(0)
		if(M)
			to_chat(M, "<span class='notice'>You switch \the [src] off.</span>")
		else if(T)
			T.visible_message("<span class='warning'>\The [src] turns off.</span>")
		force = 3
		damtype = "brute"
		hitsound = initial(hitsound)
		welding = 0
		set_light(0)
		update_icon()

//Decides whether or not to damage a player's eyes based on what they're wearing as protection
//Note: This should probably be moved to mob
/obj/item/weldingtool/proc/eyecheck(mob/user as mob)
	if(!iscarbon(user) || (user.status_flags & GODMODE))
		return 1
	if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/internal/eyes/E = H.internal_organs_by_name[BP_EYES]
		if(!E || BP_IS_ROBOTIC(E))
			return
		var/safety = H.eyecheck()
		switch(safety)
			if(FLASH_PROTECTION_MODERATE)
				to_chat(H, "<span class='warning'>Your eyes sting a little.</span>")
				E.damage += rand(1, 2)
				if(E.damage > 12)
					H.eye_blurry += rand(3,6)
			if(FLASH_PROTECTION_NONE)
				to_chat(H, "<span class='warning'>Your eyes burn.</span>")
				E.damage += rand(2, 4)
				if(E.damage > 10)
					E.damage += rand(4,10)
			if(FLASH_PROTECTION_REDUCED)
				to_chat(H, "<span class='danger'>Your equipment intensifies the welder's glow. Your eyes itch and burn severely.</span>")
				H.eye_blurry += rand(12,20)
				E.damage += rand(12, 16)
		if(safety<FLASH_PROTECTION_MAJOR)
			if(E.damage > 10)
				to_chat(user, "<span class='warning'>Your eyes are really starting to hurt. This can't be good for you!</span>")

			if (E.damage >= E.min_broken_damage)
				to_chat(H, "<span class='danger'>You go blind!</span>")
				H.sdisabilities |= BLIND
			else if (E.damage >= E.min_bruised_damage)
				to_chat(H, "<span class='danger'>You go blind!</span>")
				H.eye_blind = 5
				H.eye_blurry = 5
				H.disabilities |= NEARSIGHTED
				spawn(100)
					H.disabilities &= ~NEARSIGHTED

/obj/item/weldingtool/get_temperature_as_from_ignitor()
	if(isOn())
		return 3800
	return 0

/obj/item/welder_tank
	name = "welding fuel tank"
	desc = "An interchangeable fuel tank meant for a welding tool."
	icon = 'icons/obj/tools.dmi'
	icon_state = "fuel_m"
	w_class = ITEM_SIZE_SMALL
	center_of_mass = "x=13;y=9"
	var/max_fuel = 20
	var/can_remove = 1

/obj/item/welder_tank/Initialize()
	create_reagents(max_fuel)
	reagents.add_reagent(/datum/reagent/fuel, max_fuel)
	. = ..()

/obj/item/welder_tank/afterattack(obj/O as obj, mob/user as mob, proximity)
	if(!proximity) return
	if((istype(O, /obj/structure/reagent_dispensers/fueltank) || istype(O, /obj/item/backwear/reagent/welding)) && get_dist(src,O) <= 1)
		O.reagents.trans_to_obj(src, max_fuel)
		to_chat(user, "<span class='notice'>You refuel \the [src].</span>")
		playsound(src.loc, 'sound/effects/refill.ogg', 50, 1, -6)
		return

/obj/item/weldingtool/mini
	name = "miniature welding tool"
	icon_state = "welder_s"
	item_state = "welder"
	desc = "A smaller welder, meant for quick or emergency use."
	origin_tech = list(TECH_ENGINEERING = 2)
	matter = list(MATERIAL_STEEL = 15, MATERIAL_GLASS = 5)
	w_class = ITEM_SIZE_SMALL
	force = 5.5
	mod_weight = 0.55
	mod_reach = 0.6
	mod_handy = 0.75
	tank = /obj/item/welder_tank/mini

/obj/item/welder_tank/mini
	name = "small welding fuel tank"
	icon_state = "fuel_s"
	w_class = ITEM_SIZE_TINY
	max_fuel = 5
	can_remove = 0

/obj/item/weldingtool/largetank
	name = "industrial welding tool"
	icon_state = "welder_l"
	item_state = "welder"
	desc = "A heavy-duty portable welder, made to ensure it won't suddenly go cold on you."
	origin_tech = list(TECH_ENGINEERING = 2)
	matter = list(MATERIAL_STEEL = 70, MATERIAL_GLASS = 60)
	w_class = ITEM_SIZE_NORMAL
	mod_weight = 1.2
	mod_reach = 0.75
	mod_handy = 0.75
	tank = /obj/item/welder_tank/large

/obj/item/welder_tank/large
	name = "large welding fuel tank"
	icon_state = "fuel_l"
	w_class = ITEM_SIZE_SMALL
	max_fuel = 40

/obj/item/weldingtool/hugetank
	name = "upgraded welding tool"
	icon_state = "welder_h"
	item_state = "welder"
	desc = "A sizable welding tool with room to accomodate the largest of fuel tanks."
	w_class = ITEM_SIZE_NORMAL
	mod_weight = 1.45
	mod_reach = 1.0
	mod_handy = 0.75
	origin_tech = list(TECH_ENGINEERING = 3)
	matter = list(MATERIAL_STEEL = 70, MATERIAL_GLASS = 120)
	tank = /obj/item/welder_tank/huge

/obj/item/welder_tank/huge
	name = "huge welding fuel tank"
	icon_state = "fuel_h"
	w_class = ITEM_SIZE_SMALL
	max_fuel = 80

/obj/item/weldingtool/experimental
	name = "experimental welding tool"
	icon_state = "welder_l"
	item_state = "welder"
	desc = "This welding tool feels heavier in your possession than is normal. There appears to be no external fuel port."
	w_class = ITEM_SIZE_NORMAL
	origin_tech = list(TECH_ENGINEERING = 4, TECH_PLASMA = 3)
	matter = list(MATERIAL_STEEL = 70, MATERIAL_GLASS = 120)
	tank = /obj/item/welder_tank/experimental

/obj/item/welder_tank/experimental
	name = "experimental welding fuel tank"
	icon_state = "fuel_x"
	w_class = ITEM_SIZE_SMALL
	max_fuel = 40
	can_remove = 0
	var/last_gen = 0

/obj/item/welder_tank/experimental/Initialize()
	. = ..()
	set_next_think(world.time)

/obj/item/welder_tank/experimental/think()
	var/cur_fuel = reagents.get_reagent_amount(/datum/reagent/fuel)
	if(cur_fuel < max_fuel)
		var/gen_amount = ((world.time-last_gen)/25)
		reagents.add_reagent(/datum/reagent/fuel, gen_amount)
		last_gen = world.time

	set_next_think(world.time + 1 SECOND)

/obj/item/weldingtool/old
	name = "old welding tool"
	icon_state = "legacywelder"
	item_state = "welder"
	desc = "It would go through plasteel just like energy swords go through limbs. But modern welding fuel is but a clown's piss."
	matter = list(MATERIAL_PLASTEEL = 70, MATERIAL_GLASS = 60)
	mod_weight = 1.35
	mod_reach = 0.75
	mod_handy = 0.9
	tank = /obj/item/welder_tank/large
