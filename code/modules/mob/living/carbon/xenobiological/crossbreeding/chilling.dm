/*
Chilling extracts:
	Have a unique, primarily defensive effect when
	filled with 10u plasma and activated in-hand.
*/
/obj/item/slimecross/chilling
	name = "chilling extract"
	desc = "It's cold to the touch, as if frozen solid."
	effect = "chilling"
	icon_state = "chilling"

/obj/item/slimecross/chilling/Initialize(mapload)
	. = ..()
	create_reagents(10)

/obj/item/slimecross/chilling/attack_self(mob/user)
	if(!reagents.has_reagent(/datum/reagent/toxin/plasma,10))
		to_chat(user, SPAN_WARNING("This extract needs to be full of plasma to activate!"))
		return
	reagents.remove_reagent(/datum/reagent/toxin/plasma,10)
	to_chat(user, SPAN_NOTICE("You squeeze the extract, and it absorbs the plasma!"))
	playsound(src, 'sound/effects/bubbles.ogg', 50, TRUE)
	//FIXME playsound(src, 'sound/effects/glassbr1.ogg', 50, TRUE)
	do_effect(user)

/obj/item/slimecross/chilling/proc/do_effect(mob/user) //If, for whatever reason, you don't want to delete the extract, don't do ..()
	qdel(src)
	return

/obj/item/slimecross/chilling/grey
	colour = "grey"
	effect_desc = "Creates some slime barrier cubes. When used they create slimy barricades."

/obj/item/slimecross/chilling/grey/do_effect(mob/user)
	user.visible_message(SPAN_NOTICE("[src] produces a few small, grey cubes"))
	for(var/i in 1 to 3)
		//FIXME new /obj/item/barriercube(get_turf(user))
	..()

/obj/item/slimecross/chilling/orange
	colour = "orange"
	effect_desc = "Creates a ring of fire one tile away from the user."

/obj/item/slimecross/chilling/orange/do_effect(mob/user)
	user.visible_message(SPAN_DANGER("[src] shatters, and lets out a jet of heat!"))
	/*FIXME for(var/turf/T in orange(get_turf(user),2))
		if(get_dist(get_turf(user), T) > 1)
			new /obj/effect/hotspot(T)*/
	..()

/obj/item/slimecross/chilling/purple
	colour = "purple"
	effect_desc = "Injects everyone in the area with some regenerative jelly."

/obj/item/slimecross/chilling/purple/do_effect(mob/user)
	var/area/A = get_area(get_turf(user))
	/*FIXME if(A.outdoors)
		to_chat(user, SPAN_WARNING("[src] can't affect such a large area."))
		return
	user.visible_message(SPAN_NOTICE("[src] shatters, and a healing aura fills the room briefly."))
	for(var/mob/living/carbon/C in A)
		C.reagents.add_reagent(/datum/reagent/medicine/regen_jelly,10)*/
	..()

/obj/item/slimecross/chilling/blue
	colour = "blue"
	effect_desc = "Creates a rebreather, a tankless mask."

/obj/item/slimecross/chilling/blue/do_effect(mob/user)
	user.visible_message(SPAN_NOTICE("[src] cracks, and spills out a liquid goo, which reforms into a mask!"))
	//FIXME new /obj/item/clothing/mask/nobreath(get_turf(user))
	..()

/obj/item/slimecross/chilling/metal
	colour = "metal"
	effect_desc = "Temporarily surrounds the user with unbreakable walls."

/obj/item/slimecross/chilling/metal/do_effect(mob/user)
	user.visible_message(SPAN_DANGER("[src] melts like quicksilver, and surrounds [user] in a wall!"))
	/*FIXME for(var/turf/T in orange(get_turf(user),1))
		if(get_dist(get_turf(user), T) > 0)
			new /obj/effect/forcefield/slimewall(T)*/
	..()

/obj/item/slimecross/chilling/yellow
	colour = "yellow"
	effect_desc = "Recharges the room's APC by 50%."

/obj/item/slimecross/chilling/yellow/do_effect(mob/user)
	var/area/A = get_area(get_turf(user))
	user.visible_message(SPAN_NOTICE("[src] shatters, and a the air suddenly feels charged for a moment."))
	for(var/obj/machinery/power/apc/C in A)
		if(C.cell)
			C.cell.charge = min(C.cell.charge + C.cell.maxcharge/2, C.cell.maxcharge)
	..()

/obj/item/slimecross/chilling/darkpurple
	colour = "dark purple"
	effect_desc = "Removes all plasma gas in the area."

/obj/item/slimecross/chilling/darkpurple/do_effect(mob/user)
	var/area/A = get_area(get_turf(user))
	/*FIXME if(A.outdoors)
		to_chat(user, SPAN_WARNING("[src] can't affect such a large area."))
		return
	var/filtered = FALSE
	for(var/turf/open/T in A)
		var/datum/gas_mixture/G = T.return_air()
		if(istype(G))
			G.gas["plasma"] = 0
			filtered = TRUE
			G.update_values()
	if(filtered)
		user.visible_message(SPAN_NOTICE("Cracks spread throughout [src], and some air is sucked in!"))
	else
		user.visible_message(SPAN_NOTICE("[src] cracks, but nothing happens."))*/
	..()

/obj/item/slimecross/chilling/darkblue
	colour = "dark blue"
	effect_desc = "Seals the user in a protective block of ice."

/obj/item/slimecross/chilling/darkblue/do_effect(mob/user)
	if(isliving(user))
		user.visible_message(SPAN_NOTICE("[src] freezes over [user]'s entire body!"))
		var/mob/living/M = user
		//FIXME M.apply_status_effect(/datum/status_effect/frozenstasis)
	..()

/obj/item/slimecross/chilling/silver
	colour = "silver"
	effect_desc = "Creates several ration packs."

/obj/item/slimecross/chilling/silver/do_effect(mob/user)
	user.visible_message(SPAN_NOTICE("[src] crumbles into icy powder, leaving behind several emergency food supplies!"))
	var/amount = rand(5, 10)
	for(var/i in 1 to amount)
		new /obj/item/reagent_containers/food/liquidfood(get_turf(user))
	..()

/obj/item/slimecross/chilling/bluespace
	colour = "bluespace"
	effect_desc = "Touching people with this extract adds them to a list, when it is activated it teleports everyone on that list to the user."
	var/list/allies = list()
	var/active = FALSE

/obj/item/slimecross/chilling/bluespace/afterattack(atom/target, mob/user, proximity)
	if(!proximity || !isliving(target) || active)
		return
	if(target in allies)
		allies -= target
		to_chat(user, SPAN_NOTICE("You unlink [src] with [target]."))
	else
		allies |= target
		to_chat(user, SPAN_NOTICE("You link [src] with [target]."))
	return
//FIXME
/*/obj/item/slimecross/chilling/bluespace/do_effect(mob/user)
	if(allies.len <= 0)
		to_chat(user, SPAN_WARNING("[src] is not linked to anyone!"))
		return
	to_chat(user, SPAN_NOTICE("You feel [src] pulse as it begins charging bluespace energies..."))
	active = TRUE
	for(var/mob/living/M in allies)
		var/datum/status_effect/slimerecall/S = M.apply_status_effect(/datum/status_effect/slimerecall)
		S.target = user
	if(do_after(user, 100, target=src))
		to_chat(user, SPAN_NOTICE("[src] shatters as it tears a hole in reality, snatching the linked individuals from the void!"))
		for(var/mob/living/M in allies)
			var/datum/status_effect/slimerecall/S = M.has_status_effect(/datum/status_effect/slimerecall)
			M.remove_status_effect(S)
	else
		to_chat(user, SPAN_WARNING("[src] falls dark, dissolving into nothing as the energies fade away."))
		for(var/mob/living/M in allies)
			var/datum/status_effect/slimerecall/S = M.has_status_effect(/datum/status_effect/slimerecall)
			if(istype(S))
				S.interrupted = TRUE
				M.remove_status_effect(S)
	..()*/

/obj/item/slimecross/chilling/sepia
	colour = "sepia"
	effect_desc = "Touching someone with it adds/removes them from a list. Activating the extract stops time for 30 seconds, and everyone on the list is immune, except the user."
	var/list/allies = list()

/obj/item/slimecross/chilling/sepia/afterattack(atom/target, mob/user, proximity)
	if(!proximity || !isliving(target))
		return
	if(target in allies)
		allies -= target
		to_chat(user, SPAN_NOTICE("You unlink [src] with [target]."))
	else
		allies |= target
		to_chat(user, SPAN_NOTICE("You link [src] with [target]."))
	return

/obj/item/slimecross/chilling/sepia/do_effect(mob/user)
	user.visible_message(SPAN_WARNING("[src] shatters, freezing time itself!"))
	allies -= user //support class
	//FIXME new /obj/effect/timestop(get_turf(user), 2, 300, allies)
	..()

/obj/item/slimecross/chilling/cerulean
	colour = "cerulean"
	effect_desc = "Creates a flimsy copy of the user, that they control."

/obj/item/slimecross/chilling/cerulean/do_effect(mob/user)
	if(isliving(user))
		user.visible_message(SPAN_WARNING("[src] creaks and shifts into a clone of [user]!"))
		var/mob/living/M = user
		//FIXME M.apply_status_effect(/datum/status_effect/slime_clone)
	..()

/obj/item/slimecross/chilling/pyrite
	colour = "pyrite"
	effect_desc = "Creates a pair of Prism Glasses, which allow the wearer to place colored light crystals."

/obj/item/slimecross/chilling/pyrite/do_effect(mob/user)
	user.visible_message(SPAN_NOTICE("[src] crystallizes into a pair of spectacles!"))
	//FIXME new /obj/item/clothing/glasses/prism_glasses(get_turf(user))
	..()

/obj/item/slimecross/chilling/red
	colour = "red"
	effect_desc = "Confuses every slime in your vacinity."

/obj/item/slimecross/chilling/red/do_effect(mob/user)
	var/slimesfound = FALSE
	for(var/mob/living/carbon/metroid/S in view(get_turf(user), 7))
		slimesfound = TRUE
		S.confused = 30
	if(slimesfound)
		user.visible_message(SPAN_NOTICE("[src] lets out a peaceful ring as it shatters, and nearby slimes seem confused."))
	else
		user.visible_message(SPAN_NOTICE("[src] lets out a peaceful ring as it shatters, but nothing happens..."))
	return ..()

/obj/item/slimecross/chilling/green
	colour = "green"
	effect_desc = "Creates a bone gun in the hand it is used in, which uses blood as ammo."

/obj/item/slimecross/chilling/green/do_effect(mob/user)
	var/mob/living/L = user
	if(!istype(user))
		return
	L.drop_active_hand()
	/*FIXME var/obj/item/gun/magic/bloodchill/gun = new(user)
	if(!L.put_in_hands(gun))
		qdel(gun)
		user.visible_message(SPAN_WARNING("[src] flash-freezes [user]'s arm, cracking the flesh horribly!"))
	else
		user.visible_message(SPAN_DANGER("[src] chills and snaps off the front of the bone on [user]'s arm, leaving behind a strange, gun-like structure!"))*/
	user.emote("scream")
	L.apply_damage(30,BURN, L.hand ? BP_L_HAND : BP_R_HAND)
	..()

/obj/item/slimecross/chilling/pink
	colour = "pink"
	effect_desc = "Creates a slime corgi puppy."

/obj/item/slimecross/chilling/pink/do_effect(mob/user)
	user.visible_message(SPAN_NOTICE("[src] cracks like an egg, and an adorable puppy comes tumbling out!"))
	//FIXME new /mob/living/simple_animal/pet/dog/corgi/puppy/slime(get_turf(user))
	..()

/obj/item/slimecross/chilling/gold
	colour = "gold"
	effect_desc = "Produces a golden capture device"

/obj/item/slimecross/chilling/gold/do_effect(mob/user)
	user.visible_message(SPAN_NOTICE("[src] lets off golden light as it melts and reforms into an egg-like device!"))
	//FIXME new /obj/item/capturedevice(get_turf(user))
	..()

/obj/item/slimecross/chilling/oil
	colour = "oil"
	effect_desc = "It creates a weak, but wide-ranged explosion."

/obj/item/slimecross/chilling/oil/do_effect(mob/user)
	user.visible_message(SPAN_DANGER("[src] begins to shake with muted intensity!"))
	addtimer(CALLBACK(src, .proc/boom), 50)

/obj/item/slimecross/chilling/oil/proc/boom()
	explosion(src, devastation_range = -1, heavy_impact_range = -1, light_impact_range = 10) //Large radius, but mostly light damage, and no flash.
	qdel(src)

/obj/item/slimecross/chilling/black
	colour = "black"
	effect_desc = "Transforms the user into a  golem."

/obj/item/slimecross/chilling/black/do_effect(mob/user)
	if(ishuman(user))
		user.visible_message(SPAN_NOTICE("[src] crystallizes along [user]'s skin, turning into metallic scales!"))
		var/mob/living/carbon/human/H = user
		H.set_species(SPECIES_GOLEM)
	..()

/obj/item/slimecross/chilling/lightpink
	colour = "light pink"
	effect_desc = "Creates a Heroine Bud, a special flower that pacifies whoever wears it on their head. They will not be able to take it off without help."

/obj/item/slimecross/chilling/lightpink/do_effect(mob/user)
	user.visible_message(SPAN_NOTICE("[src] blooms into a beautiful flower!"))
	//FIXME new /obj/item/clothing/head/peaceflower(get_turf(user))
	..()

/obj/item/slimecross/chilling/adamantine
	colour = "adamantine"
	effect_desc = "Solidifies into a set of adamantine armor."

/obj/item/slimecross/chilling/adamantine/do_effect(mob/user)
	user.visible_message(SPAN_NOTICE("[src] creaks and breaks as it shifts into a heavy set of armor!"))
	//FIXME new /obj/item/clothing/suit/armor/heavy/adamantine(get_turf(user))
	..()

/obj/item/slimecross/chilling/rainbow
	colour = "rainbow"
	effect_desc = "Makes an unpassable wall in every door in the area."

/obj/item/slimecross/chilling/rainbow/do_effect(mob/user)
	var/area/area = get_area(user)
	/* FIXME if(area.outdoors)
		to_chat(user, SPAN_WARNING("[src] can't affect such a large area."))
		return*/
	user.visible_message(SPAN_WARNING("[src] reflects an array of dazzling colors and light, energy rushing to nearby doors!"))
	for(var/obj/machinery/door/airlock/door in area)
		//FIXME new /obj/effect/forcefield/slimewall/rainbow(door.loc)
	return ..()
