/*
Chilling extracts:
	Have a unique, primarily defensive effect when
	filled with 10u plasma and activated in-hand.
*/
/obj/item/metroidcross/chilling
	name = "chilling extract"
	desc = "It's cold to the touch, as if frozen solid."
	effect = "chilling"
	icon_state = "chilling"

/obj/item/metroidcross/chilling/Initialize(mapload)
	. = ..()
	create_reagents(10)

/obj/item/metroidcross/chilling/attack_self(mob/user)
	if(!reagents.has_reagent(/datum/reagent/toxin/plasma,10))
		to_chat(user, SPAN_WARNING("This extract needs to be full of plasma to activate!"))
		return
	reagents.remove_reagent(/datum/reagent/toxin/plasma,10)
	to_chat(user, SPAN_NOTICE("You squeeze the extract, and it absorbs the plasma!"))
	playsound(src, 'sound/effects/bubbles.ogg', 50, TRUE)
	playsound(src, 'sound/effects/glass_step.ogg', 50, TRUE)
	do_effect(user)

/obj/item/metroidcross/chilling/proc/do_effect(mob/user) //If, for whatever reason, you don't want to delete the extract, don't do ..()
	qdel(src)
	return

/obj/item/metroidcross/chilling/green
	colour = "green"
	effect_desc = "Creates some metroid barrier cubes. When used they create slimy barricades."

/obj/item/metroidcross/chilling/green/do_effect(mob/user)
	user.visible_message(SPAN_NOTICE("[src] produces a few small, green cubes"))
	for(var/i in 1 to 3)
		new /obj/item/barriercube(get_turf(user))
	..()

/obj/item/metroidcross/chilling/orange
	colour = "orange"
	effect_desc = "Creates a ring of fire one tile away from the user."

/obj/item/metroidcross/chilling/orange/do_effect(mob/user)
	user.visible_message(SPAN_DANGER("[src] shatters, and lets out a jet of heat!"))
	for(var/turf/T in orange(get_turf(user),2))
		if(get_dist(get_turf(user), T) > 1)
			if(!iswall(T))
				new /obj/effect/decal/cleanable/liquid_fuel(T)
				T.hotspot_expose((40 CELSIUS) + 380, 500)

	..()

/obj/item/metroidcross/chilling/purple
	colour = "purple"
	effect_desc = "Injects everyone in the area with some regenerative jelly."

/obj/item/metroidcross/chilling/purple/do_effect(mob/user)
	var/area/A = get_area(get_turf(user))
	if(A.environment_type == ENVIRONMENT_OUTSIDE)
		to_chat(user, SPAN_WARNING("[src] can't affect such a large area."))
		return
	user.visible_message(SPAN_NOTICE("[src] shatters, and a healing aura fills the room briefly."))
	for(var/mob/living/carbon/C in A)
		C.reagents.add_reagent(/datum/reagent/regen_jelly, 20)
	..()

/obj/item/metroidcross/chilling/blue
	colour = "blue"
	effect_desc = "Creates a rebreather, a tankless mask."

/obj/item/metroidcross/chilling/blue/do_effect(mob/user)
	user.visible_message(SPAN_NOTICE("[src] cracks, and spills out a liquid goo, which reforms into a mask!"))
	new /obj/item/clothing/mask/nobreath(get_turf(user))
	..()

/obj/item/metroidcross/chilling/metal
	colour = "metal"
	effect_desc = "Temporarily surrounds the user with unbreakable walls."

/obj/item/metroidcross/chilling/metal/do_effect(mob/user)
	user.visible_message(SPAN_DANGER("[src] melts like quicksilver, and surrounds [user] in a wall!"))
	for(var/turf/T in orange(get_turf(user),1))
		if(get_dist(get_turf(user), T) > 0)
			new /obj/effect/forcefield/metroidwall(T)
	..()

/obj/item/metroidcross/chilling/yellow
	colour = "yellow"
	effect_desc = "Recharges the room's APC by 50%."

/obj/item/metroidcross/chilling/yellow/do_effect(mob/user)
	var/area/A = get_area(get_turf(user))
	user.visible_message(SPAN_NOTICE("[src] shatters, and a the air suddenly feels charged for a moment."))
	for(var/obj/machinery/power/apc/C in A)
		if(C.cell)
			C.cell.charge = min(C.cell.charge + C.cell.maxcharge/2, C.cell.maxcharge)
	..()

/obj/item/metroidcross/chilling/darkpurple
	colour = "dark purple"
	effect_desc = "Removes all plasma gas in the area."

/obj/item/metroidcross/chilling/darkpurple/do_effect(mob/user)
	var/area/A = get_area(get_turf(user))
	if(A.environment_type == ENVIRONMENT_OUTSIDE)
		to_chat(user, SPAN_WARNING("[src] can't affect such a large area."))
		return
	var/filtered = FALSE
	for(var/turf/simulated/T in A)
		var/datum/gas_mixture/G = T.return_air()
		if(istype(G))
			G.gas["plasma"] = 0
			filtered = TRUE
			G.update_values()
	if(filtered)
		user.visible_message(SPAN_NOTICE("Cracks spread throughout [src], and some air is sucked in!"))
	else
		user.visible_message(SPAN_NOTICE("[src] cracks, but nothing happens."))
	..()

/obj/item/metroidcross/chilling/darkblue
	colour = "dark blue"
	effect_desc = "Seals the user in a protective block of ice."

/obj/item/metroidcross/chilling/darkblue/do_effect(mob/user)
	if(isliving(user))
		user.visible_message(SPAN_NOTICE("[src] freezes over [user]'s entire body!"))
		var/mob/living/M = user
		M.add_modifier(/datum/modifier/status_effect/frozenstasis)
	..()

/obj/item/metroidcross/chilling/silver
	colour = "silver"
	effect_desc = "Creates several ration packs."

/obj/item/metroidcross/chilling/silver/do_effect(mob/user)
	user.visible_message(SPAN_NOTICE("[src] crumbles into icy powder, leaving behind several emergency food supplies!"))
	var/amount = rand(5, 10)
	for(var/i in 1 to amount)
		new /obj/item/reagent_containers/food/liquidfood(get_turf(user))
	..()

/obj/item/metroidcross/chilling/bluespace
	colour = "bluespace"
	effect_desc = "Touching people with this extract adds them to a list, when it is activated it teleports everyone on that list to the user."
	var/list/allies = list()
	var/active = FALSE

/obj/item/metroidcross/chilling/bluespace/afterattack(atom/target, mob/user, proximity)
	if(!proximity || !isliving(target) || active)
		return
	if(target in allies)
		allies -= target
		to_chat(user, SPAN_NOTICE("You unlink [src] with [target]."))
	else
		allies |= target
		to_chat(user, SPAN_NOTICE("You link [src] with [target]."))
	return

/obj/item/metroidcross/chilling/bluespace/do_effect(mob/user)
	if(allies.len <= 0)
		to_chat(user, SPAN_WARNING("[src] is not linked to anyone!"))
		return

	to_chat(user, SPAN_NOTICE("You feel [src] pulse as it begins charging bluespace energies..."))
	active = TRUE

	for(var/mob/living/M in allies)
		ADD_TRAIT(M, TRAIT_METROIDRECALL)

	if(do_after(user, 80, target=src))
		to_chat(user, SPAN_NOTICE("[src] shatters as it tears a hole in reality, snatching the linked individuals from the void!"))
		for(var/mob/living/M in allies)

			if(!HAS_TRAIT(M, TRAIT_METROIDRECALL))
				continue

			REMOVE_TRAIT(M, TRAIT_METROIDRECALL)
			do_teleport(M, src, 3)
	else
		to_chat(user, SPAN_WARNING("[src] falls dark, dissolving into nothing as the energies fade away."))

		for(var/mob/living/M in allies)
			if(!HAS_TRAIT(M, TRAIT_METROIDRECALL))
				continue

			REMOVE_TRAIT(M, TRAIT_METROIDRECALL)

		allies.Cut()
	..()

/obj/item/metroidcross/chilling/sepia
	colour = "sepia"
	effect_desc = "Creates a camera with a magnifier."

/obj/item/metroidcross/chilling/sepia/do_effect(mob/user)
	user.visible_message(SPAN_NOTICE("[src] shapes itself into a camera!"))
	new /obj/item/device/camera/random(get_turf(loc))
	..()

/obj/item/metroidcross/chilling/cerulean
	colour = "cerulean"
	effect_desc = "Creates a flimsy copy of the user, that they control."

/obj/item/metroidcross/chilling/cerulean/do_effect(mob/user)
	if(isliving(user))
		user.visible_message(SPAN_WARNING("[src] creaks and shifts into a clone of [user]!"))
		var/mob/living/M = user
		M.add_modifier(/datum/modifier/status_effect/metroid_clone)
	..()

/obj/item/metroidcross/chilling/pyrite
	colour = "pyrite"
	effect_desc = "Creates a pair of Prism Glasses, which allow the wearer to place colored light crystals."

/obj/item/metroidcross/chilling/pyrite/do_effect(mob/user)
	user.visible_message(SPAN_NOTICE("[src] crystallizes into a pair of spectacles!"))
	new /obj/item/clothing/glasses/prism_glasses(get_turf(user))
	..()

/obj/item/metroidcross/chilling/red
	colour = "red"
	effect_desc = "Confuses every metroid in your vacinity."

/obj/item/metroidcross/chilling/red/do_effect(mob/user)
	var/metroidsfound = FALSE
	for(var/mob/living/carbon/metroid/S in view(get_turf(user), 7))
		metroidsfound = TRUE
		S.confused = 30
	if(metroidsfound)
		user.visible_message(SPAN_NOTICE("[src] lets out a peaceful ring as it shatters, and nearby metroids seem confused."))
	else
		user.visible_message(SPAN_NOTICE("[src] lets out a peaceful ring as it shatters, but nothing happens..."))
	return ..()

/obj/item/metroidcross/chilling/grey
	colour = "grey"
	effect_desc = "Creates a bone gun in the hand it is used in, which uses blood as ammo."

/obj/item/metroidcross/chilling/grey/do_effect(mob/user)
	var/mob/living/L = user
	if(!istype(user))
		return
	L.drop_active_hand()
	var/obj/item/gun/projectile/magic/bloodchill/gun = new(user)
	if(!L.put_in_hands(gun))
		qdel(gun)
		user.visible_message(SPAN_WARNING("[src] flash-freezes [user]'s arm, cracking the flesh horribly!"))
	else
		user.visible_message(SPAN_DANGER("[src] chills and snaps off the front of the bone on [user]'s arm, leaving behind a strange, gun-like structure!"))
		gun.think()
	user.emote("scream")
	L.apply_damage(30,BURN, L.hand ? BP_L_HAND : BP_R_HAND)
	..()

/obj/item/metroidcross/chilling/pink
	colour = "pink"
	effect_desc = "Creates a metroid corgi puppy."

/obj/item/metroidcross/chilling/pink/do_effect(mob/user)
	user.visible_message(SPAN_NOTICE("[src] cracks like an egg, and an adorable puppy comes tumbling out!"))
	new /mob/living/simple_animal/corgi/puppy/metroid(get_turf(user))
	..()

/obj/item/metroidcross/chilling/gold
	colour = "gold"
	effect_desc = "Produces a golden capture device"

/obj/item/metroidcross/chilling/gold/do_effect(mob/user)
	user.visible_message(SPAN_NOTICE("[src] lets off golden light as it melts and reforms into an egg-like device!"))
	new /obj/item/capturedevice(get_turf(user))
	..()

/obj/item/metroidcross/chilling/oil
	colour = "oil"
	effect_desc = "It creates a weak, but wide-ranged explosion."

/obj/item/metroidcross/chilling/oil/do_effect(mob/user)
	user.visible_message(SPAN_DANGER("[src] begins to shake with muted intensity!"))
	addtimer(CALLBACK(src, nameof(.proc/boom)), 50)

/obj/item/metroidcross/chilling/oil/proc/boom()
	explosion(src, devastation_range = -1, heavy_impact_range = -1, light_impact_range = 10) //Large radius, but mostly light damage, and no flash.
	qdel(src)

/obj/item/metroidcross/chilling/black
	colour = "black"
	effect_desc = "Transforms the user into a golem."

/obj/item/metroidcross/chilling/black/do_effect(mob/user)
	if(ishuman(user))
		user.visible_message(SPAN_NOTICE("[src] crystallizes along [user]'s skin, turning into metallic scales!"))
		var/mob/living/carbon/human/H = user

		var/static/list/random_golem_types= list(
			SPECIES_GOLEM,
			SPECIES_GOLEM_ADAMANTINE,
			SPECIES_GOLEM_PLASMA,
			SPECIES_GOLEM_DIAMOND,
			SPECIES_GOLEM_GOLD,
			SPECIES_GOLEM_SILVER,
			SPECIES_GOLEM_PLASTEEL,
			SPECIES_GOLEM_TITANIUM,
			SPECIES_GOLEM_PLASTITANIUM,
			SPECIES_GOLEM_WOOD,
			SPECIES_GOLEM_URANIUM,
			SPECIES_GOLEM_SAND,
			SPECIES_GOLEM_GLASS,
			SPECIES_GOLEM_BLUESPACE,
			SPECIES_GOLEM_CLOTH,
			SPECIES_GOLEM_PLASTIC,
			SPECIES_GOLEM_BRONZE,
			SPECIES_GOLEM_CARDBOARD,
			SPECIES_GOLEM_LEATHER,
			SPECIES_GOLEM_HYDROGEN,
			)
		H.set_species(pick(random_golem_types))
	..()

/obj/item/metroidcross/chilling/lightpink
	colour = "light pink"
	effect_desc = "Creates a Heroine Bud, a special flower that pacifies whoever wears it on their head. They will not be able to take it off without help."

/obj/item/metroidcross/chilling/lightpink/do_effect(mob/user)
	user.visible_message(SPAN_NOTICE("[src] blooms into a beautiful flower!"))
	new /obj/item/clothing/head/hairflower/peaceflower(get_turf(user))
	..()

/obj/item/metroidcross/chilling/adamantine
	colour = "adamantine"
	effect_desc = "Solidifies into a set of adamantine armor."

/obj/item/metroidcross/chilling/adamantine/do_effect(mob/user)
	user.visible_message(SPAN_NOTICE("[src] creaks and breaks as it shifts into a heavy set of armor!"))
	new /obj/item/clothing/suit/armor/heavy/adamantine(get_turf(user))
	..()

/obj/item/metroidcross/chilling/rainbow
	colour = "rainbow"
	effect_desc = "Makes an unpassable wall in every door in the area."

/obj/item/metroidcross/chilling/rainbow/do_effect(mob/user)
	var/area/area = get_area(user)
	if(area.environment_type==ENVIRONMENT_OUTSIDE)
		to_chat(user, SPAN_WARNING("[src] can't affect such a large area."))
		return
	user.visible_message(SPAN_WARNING("[src] reflects an array of dazzling colors and light, energy rushing to nearby doors!"))
	for(var/obj/machinery/door/airlock/door in area)
		new /obj/effect/forcefield/metroidwall/rainbow(door.loc)
	return ..()
