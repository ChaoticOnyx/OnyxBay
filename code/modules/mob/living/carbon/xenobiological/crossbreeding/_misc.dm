//Hypercharged metroid cell - Charged Yellow
/obj/item/cell/high/metroid_hypercharged
	name = "hypercharged metroid core"
	desc = "A charged yellow metroid extract, infused with plasma. It almost hurts to touch."
	icon = 'icons/mob/metroids.dmi'
	icon_state = "yellow metroid extract"
	maxcharge = 3000

//Barrier cube - Chilling Grey
/obj/item/barriercube
	name = "barrier cube"
	desc = "A compressed cube of metroid. When squeezed, it grows to massive size!"
	icon = 'icons/obj/xenobiology/metroidcrossing.dmi'
	icon_state = "barriercube"
	w_class = ITEM_SIZE_TINY

/obj/item/barriercube/attack_self(mob/user)
	if(locate(/obj/structure/barricade/metroid) in get_turf(loc))
		to_chat(user, SPAN_WARNING("You can't fit more than one barrier in the same space!"))
		return
	to_chat(user, SPAN_NOTICE("You squeeze [src]."))
	var/obj/B = new /obj/structure/barricade/metroid(get_turf(loc))
	B.visible_message(SPAN_WARNING("[src] suddenly grows into a large, gelatinous barrier!"))
	qdel(src)

//metroid barricade - Chilling Grey
/obj/structure/barricade/metroid
	name = "gelatinous barrier"
	desc = "A huge chunk of grey metroid. Bullets might get stuck in it."

	icon = 'icons/obj/xenobiology/metroidcrossing.dmi'
	icon_state = "metroidbarrier"

	atom_flags = ATOM_FLAG_FULLTILE_OBJECT

	maxdamage = 60


/obj/structure/barricade/metroid/bullet_act(obj/item/projectile/proj, def_zone)
	if(!(proj.damage_type == BRUTE || proj.damage_type == BURN))
		return

	take_damage(proj.damage)


//metroid forcefield - Chilling Metal
/obj/effect/forcefield/metroidwall
	name = "solidified gel"
	desc = "A mass of solidified metroid gel - completely impenetrable, but it's melting away!"
	icon = 'icons/obj/xenobiology/metroidcrossing.dmi'
	icon_state = "metroidbarrier_thick"

/obj/effect/forcefield/metroidwall/New()
	addtimer(CALLBACK(src, nameof(.proc/finish_existance)), 300)

/obj/effect/forcefield/metroidwall/proc/finish_existance()
	qdel(src)
	return

//Rainbow barrier - Chilling Rainbow
/obj/effect/forcefield/metroidwall/rainbow
	name = "rainbow barrier"
	desc = "Despite others' urgings, you probably shouldn't taste this."
	icon_state = "rainbowbarrier"

//Frozen stasis - Chilling Dark Blue
/obj/structure/ice_stasis
	name = "ice block"
	desc = "A massive block of ice. You can see something vaguely humanoid inside."
	icon = 'icons/obj/xenobiology/metroidcrossing.dmi'
	icon_state = "frozen"
	density = TRUE
	var/health = 40

/obj/structure/ice_stasis/attackby(obj/item/W, mob/user)
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)

	if(W.attack_verb.len)
		visible_message("<span class='warning'>\The [src] have been [pick(W.attack_verb)] with \the [W][(user ? " by [user]." : ".")]</span>")
	else
		visible_message("<span class='warning'>\The [src] have been attacked with \the [W][(user ? " by [user]." : ".")]</span>")

	var/damage = W.force / 4.0

	if(isWelder(W))
		var/obj/item/weldingtool/WT = W

		if(WT.remove_fuel(0, user))
			damage = 15
			playsound(loc, 'sound/items/Welder.ogg', 100, 1)

	health -= damage
	if(health <= 0)
		qdel(src)


/obj/structure/ice_stasis/Initialize(mapload)
	. = ..()
	playsound(src, 'sound/effects/ethereal_exit.ogg', 50, TRUE)

/obj/structure/ice_stasis/Destroy()
	for(var/atom/movable/M in contents)
		M.forceMove(loc)
	playsound(src, 'sound/effects/materials/glass/glassbr.ogg', 50, TRUE)
	return ..()

/atom/movable/screen/movable/alert/status_effect/freon/stasis
	name = "Frozen Solid"
	desc = "You're frozen inside of a protective ice cube! While inside, you can't do anything, but are immune! Resist to get out."
	icon_state = "frozen"

/obj/item/flame/lighter/zippo/metroid
	name = "metroid zippo"
	desc = "A specialty zippo made from metroids and industry. Has a much hotter flame than normal."
	icon_state = "zippo-metroid"
	light_color = COLOR_PALE_GREEN_GRAY
	flame_overlay = "metroidoverlay"

//Gold capture device - Chilling Gold
/obj/item/capturedevice
	name = "gold capture device"
	desc = "Bluespace technology packed into a roughly egg-shaped device, used to store nonhuman creatures. Can't catch them all, though - it only fits one."
	w_class = ITEM_SIZE_SMALL
	icon = 'icons/obj/xenobiology/metroidcrossing.dmi'
	icon_state = "capturedevice"
	var/hacked = FALSE

/obj/item/capturedevice/hacked
	hacked = TRUE

/obj/item/capturedevice/emag_act(remaining_charges, mob/user, emag_source)
	var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
	spark_system.set_up(5, 0, src.loc)
	if(!hacked)
		playsound(loc, 'sound/effects/computer_emag.ogg', 25)
		to_chat(user, SPAN("warning", "You swipe [emag_source] at [src] and you feel something changed inside it!"))
		hacked = TRUE
		return 1

/obj/item/capturedevice/resolve_attackby(atom/A, mob/user, click_params)
	..()

	if(length(contents))
		to_chat(user, SPAN_WARNING("The device already has something inside."))
		return

	if(!istype(A, /mob/living/simple_animal) && !hacked)
		to_chat(user, SPAN_WARNING("The capture device only works on simple creatures."))
		return

	if(!istype(A, /mob/living) && hacked)
		to_chat(user, SPAN_WARNING("The capture device only works on living creatures."))
		return

	var/mob/living/pokemon = A


	if(pokemon.mind)
		if(!hacked)
			to_chat(user, SPAN_NOTICE("You offer the device to [pokemon]."))
			if(tgui_alert(pokemon, "Would you like to enter [user]'s capture device?", "Gold Capture Device", list("Yes", "No")) == "Yes")
				if(user.incapacitated(INCAPACITATION_DEFAULT))
					to_chat(pokemon, SPAN_NOTICE("The world warps around you, and you're suddenly in an endless void, with a window to the outside floating in front of you."))
				else
					to_chat(user, SPAN_WARNING("You were too far away from [pokemon]."))
					to_chat(pokemon, SPAN_WARNING("You were too far away from [user]."))
			else
				to_chat(user, SPAN_WARNING("[pokemon] refused to enter the device."))
				return

		else
			if(user==pokemon)
				to_chat(user, SPAN_NOTICE("You peeking inside strange gold egg."))
				if(!do_after(user, 100))
					return

				to_chat(user, SPAN_NOTICE("You feeling that something looking on you."))

				if(!do_after(user, 100))
					return
				to_chat(pokemon, SPAN_NOTICE("The world warps around you, and you're suddenly in an endless void, with a window to the outside floating in front of you."))
				pokemon.drop(src, force = TRUE)
				to_chat(user, SPAN_NOTICE("You store [pokemon] in the capture device."))
				store(pokemon)
				return

			if(!user.incapacitated(INCAPACITATION_DEFAULT) && do_after(user, 300, pokemon))
				to_chat(pokemon, SPAN_NOTICE("The world warps around you, and you're suddenly in an endless void, with a window to the outside floating in front of you."))
			else
				to_chat(user, SPAN_WARNING("You were too far away from [pokemon]."))
				to_chat(pokemon, SPAN_WARNING("You were too far away from [user]."))

	else if(!("neutral" == pokemon.faction) && !hacked)
		to_chat(user, SPAN_WARNING("This creature is too aggressive to capture."))
		return

	to_chat(user, SPAN_NOTICE("You store [pokemon] in the capture device."))
	store(pokemon)

/obj/item/capturedevice/attack_self(mob/user)
	if(contents.len)
		to_chat(user, SPAN_NOTICE("You open the capture device!"))
		release()
	else
		to_chat(user, SPAN_WARNING("The device is empty..."))

/obj/item/capturedevice/proc/store(mob/living/M)
	M.forceMove(src)
	register_signal(M, SIGNAL_MOB_RESIST, nameof(.proc/resist_act))

/obj/item/capturedevice/proc/resist_act(mob/living/M)
	to_chat(M, SPAN_NOTICE("You trying to release yourself."))
	if(do_after(M, 300))
		release()

/obj/item/capturedevice/proc/release()
	for(var/atom/movable/M in contents)
		M.forceMove(get_turf(loc))
