/*
Burning extracts:
	Have a unique, primarily offensive effect when
	filled with 10u plasma and activated in-hand.
*/
/obj/item/metroidcross/burning
	name = "burning extract"
	desc = "It's boiling over with barely-contained energy."
	effect = "burning"
	icon_state = "burning"
	var/plasma_value = 10

/obj/item/metroidcross/burning/Initialize(mapload)
	. = ..()
	create_reagents(400)
	plasma_value = rand(10,20)

/obj/item/metroidcross/burning/attack_self(mob/user)
	if(!reagents.has_reagent(/datum/reagent/toxin/plasma, plasma_value))
		to_chat(user, SPAN_WARNING("This extract needs some amount of plasma to activate!"))
		return
	reagents.remove_reagent(/datum/reagent/toxin/plasma, plasma_value)
	to_chat(user, SPAN_NOTICE("You squeeze the extract, and it absorbs the plasma!"))
	playsound(src, 'sound/effects/bubbles.ogg', 50, TRUE)
	playsound(src, 'sound/effects/explosions/fuel_explosion1.ogg', 50, TRUE)
	do_effect(user)

/obj/item/metroidcross/burning/proc/do_effect(mob/user) //If, for whatever reason, you don't want to delete the extract, don't do ..()
	qdel(src)
	return

/obj/item/metroidcross/burning/green
	colour = "green"
	effect_desc = "Creates a hungry and speedy metroid that will love you forever."

/obj/item/metroidcross/burning/green/do_effect(mob/user)
	var/mob/living/carbon/metroid/S = new(get_turf(user),"green")
	S.visible_message(SPAN_DANGER("A baby metroid emerges from [src], and it nuzzles [user] before burbling hungrily!"))
	S.Friends += user
	S.bodytemperature = 400 + 0 CELSIUS //We gonna step on the gas.
	S.nutrition=S.get_hunger_nutrition() //Tonight, we fight!
	..()

/obj/item/metroidcross/burning/orange
	colour = "orange"
	effect_desc = "Expels pepperspray in a radius when activated."

/obj/item/metroidcross/burning/orange/do_effect(mob/user)
	user.visible_message(SPAN_DANGER("[src] boils over with a caustic gas!"))
	var/obj/item/reagent_containers/vessel/beaker/large/B1 = new(src)
	var/obj/item/reagent_containers/vessel/beaker/large/B2 = new(src)

	B1.reagents.add_reagent(/datum/reagent/phosphorus, 40)
	B1.reagents.add_reagent(/datum/reagent/potassium, 40)
	B1.reagents.add_reagent(/datum/reagent/capsaicin/condensed, 40)
	B2.reagents.add_reagent(/datum/reagent/sugar, 40)
	B2.reagents.add_reagent(/datum/reagent/capsaicin/condensed, 80)

	for(var/obj/item/reagent_containers/vessel/G in list(B1,B2))
		G.reagents.trans_to_obj(src, G.reagents.total_volume)

	if(src.reagents.total_volume) //The possible reactions didnt use up all reagents.
		var/datum/effect/effect/system/steam_spread/steam = new /datum/effect/effect/system/steam_spread()
		steam.set_up(10, 0, get_turf(src))
		steam.attach(src)
		steam.start()

		for(var/atom/A in view(3, loc))
			if( A == src ) continue
			src.reagents.touch(A)

	if(istype(loc, /mob/living/carbon)) // drop dat if it goes off in your hand
		var/mob/living/carbon/C = loc
		C.drop(src)
		C.throw_mode_off()

	set_invisibility(INVISIBILITY_MAXIMUM) //Why am i doing this?
	spawn(50)		   //To make sure all reagents can work
		qdel(src)

/obj/item/metroidcross/burning/purple
	colour = "purple"
	effect_desc = "Creates a clump of invigorating gel, it has healing properties and makes you feel good."

/obj/item/metroidcross/burning/purple/do_effect(mob/user)
	user.visible_message(SPAN_NOTICE("[src] fills with a bubbling liquid!"))
	new /obj/item/metroidcrossbeaker/autoinjector/metroidstimulant(get_turf(user))
	if(isliving(user))
		var/mob/living/L = user
		ADD_TRAIT(L, /datum/modifier/status_effect/burningpurple)
	return ..()

/obj/item/metroidcross/burning/blue
	colour = "blue"
	effect_desc = "Freezes the floor around you and chills nearby people."

/obj/item/metroidcross/burning/blue/do_effect(mob/user)
	user.visible_message(SPAN_DANGER("[src] flash-freezes the area!"))
	for(var/turf/simulated/T in range(3, get_turf(user)))
		T.wet_floor(4)
	for(var/mob/living/carbon/M in range(5, get_turf(user)))
		if(M != user)
			M.bodytemperature = BODYTEMP_COLD_DAMAGE_LIMIT + 10 //Not quite cold enough to hurt.
			to_chat(M, SPAN_DANGER("You feel a chill run down your spine, and the floor feels a bit slippery with frost..."))
	..()

/obj/item/metroidcross/burning/metal
	colour = "metal"
	effect_desc = "Instantly destroys walls around you."

/obj/item/metroidcross/burning/metal/do_effect(mob/user)
	for(var/turf/simulated/wall/W in range(1,get_turf(user)))
		W.dismantle_wall(no_product=TRUE)
		playsound(W, 'sound/effects/break_stone.ogg', 50, TRUE)
	user.visible_message(SPAN_DANGER("[src] pulses violently, and shatters the walls around it!"))
	..()

/obj/item/metroidcross/burning/yellow
	colour = "yellow"
	effect_desc = "Electrocutes people near you."

/obj/item/metroidcross/burning/yellow/do_effect(mob/user)
	user.visible_message(SPAN_DANGER("[src] explodes into an electrical field!"))
	playsound(get_turf(src), 'sound/weapons/resonator_blast.ogg', 50, TRUE)
	for(var/mob/living/M in range(4,get_turf(user)))
		if(M != user)
			var/mob/living/carbon/C = M
			if(istype(C))
				C.electrocute_act(25,src)
			else
				M.adjustFireLoss(25)
			to_chat(M, SPAN_DANGER("You feel a sharp electrical pulse!"))
	..()

/obj/item/metroidcross/burning/darkpurple
	colour = "dark purple"
	effect_desc = "Creates a cloud of plasma."

/obj/item/metroidcross/burning/darkpurple/do_effect(mob/user)
	user.visible_message(SPAN_DANGER("[src] sublimates into a cloud of plasma!"))
	var/turf/T = get_turf(user)
	T.assume_gas("plasma", 100, 20 CELSIUS)
	..()

/obj/item/metroidcross/burning/darkblue
	colour = "dark blue"
	effect_desc = "Expels a burst of chilling smoke while also filling you with regenerative jelly."

/obj/item/metroidcross/burning/darkblue/do_effect(mob/user)
	user.visible_message(SPAN_DANGER("[src] releases a burst of chilling smoke!"))
	var/obj/item/reagent_containers/vessel/beaker/large/B1 = new(src)
	var/obj/item/reagent_containers/vessel/beaker/large/B2 = new(src)

	B1.reagents.add_reagent(/datum/reagent/phosphorus, 40)
	B1.reagents.add_reagent(/datum/reagent/potassium, 40)
	B1.reagents.add_reagent(/datum/reagent/frostoil, 40)
	B2.reagents.add_reagent(/datum/reagent/sugar, 40)
	B2.reagents.add_reagent(/datum/reagent/regen_jelly, 20)
	B2.reagents.add_reagent(/datum/reagent/frostoil, 60)

	for(var/obj/item/reagent_containers/vessel/G in list(B1,B2))
		G.reagents.trans_to_obj(src, G.reagents.total_volume)

	if(src.reagents.total_volume) //The possible reactions didnt use up all reagents.
		var/datum/effect/effect/system/steam_spread/steam = new /datum/effect/effect/system/steam_spread()
		steam.set_up(10, 0, get_turf(src))
		steam.attach(src)
		steam.start()

		for(var/atom/A in view(3, loc))
			if( A == src ) continue
			src.reagents.touch(A)

	if(istype(loc, /mob/living/carbon)) // drop dat if it goes off in your hand
		var/mob/living/carbon/C = loc
		C.drop(src)
		C.throw_mode_off()

	set_invisibility(INVISIBILITY_MAXIMUM) //Why am i doing this?
	spawn(50)		   //To make sure all reagents can work
		qdel(src)

/obj/item/metroidcross/burning/silver
	colour = "silver"
	effect_desc = "Creates a few pieces of metroid jelly laced food."

/obj/item/metroidcross/burning/silver/do_effect(mob/user)
	var/amount = rand(3,6)
	var/list/turfs = list()
	for(var/turf/simulated/T in range(1,get_turf(user)))
		turfs += T
	for(var/i in 1 to amount)
		var/path = pick(typesof(/obj/item/reagent_containers/food) - /obj/item/reagent_containers/food)
		var/obj/item/reagent_containers/food/food = new path(pick(turfs))
		food.reagents.add_reagent(/datum/reagent/metroidjelly,5) //Oh god it burns
		if(prob(50))
			food.desc += " It smells strange..."
	user.visible_message(SPAN_DANGER("[src] produces a few pieces of food!"))
	..()

/obj/item/metroidcross/burning/bluespace
	colour = "bluespace"
	effect_desc = "Teleports anyone directly next to you."

/obj/item/metroidcross/burning/bluespace/do_effect(mob/user)
	user.visible_message(SPAN_DANGER("[src] sparks, and lets off a shockwave of bluespace energy!"))
	for(var/mob/living/L in range(5, get_turf(user)))
		if(L != user)
			do_teleport(L, get_turf(user))
			playsound(get_turf(user), GET_SFX(SFX_SPARK_MEDIUM), 100, TRUE)
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread()
			s.set_up(5, 1, user)
			s.start()
	..()

/obj/item/metroidcross/burning/sepia
	colour = "sepia"
	effect_desc = "Turns into a special camera that seems to be kinda hot."

/obj/item/metroidcross/burning/sepia/do_effect(mob/user)
	user.visible_message(SPAN_NOTICE("[src] shapes itself into a camera!"))
	new /obj/item/device/camera/fiery(get_turf(user))
	..()

/obj/item/metroidcross/burning/cerulean
	colour = "cerulean"
	effect_desc = "Produces an extract cloning potion, which copies an extract, as well as its extra uses."

/obj/item/metroidcross/burning/cerulean/do_effect(mob/user)
	user.visible_message(SPAN_NOTICE("[src] produces a potion!"))
	new /obj/item/metroidpotion/extract_cloner(get_turf(user))
	..()

/obj/item/metroidcross/burning/pyrite
	colour = "pyrite"
	effect_desc = "Shatters all lights in the current room."

/obj/item/metroidcross/burning/pyrite/do_effect(mob/user)
	user.visible_message(SPAN_DANGER("[src] releases a colorful wave of energy, which shatters the lights!"))
	var/area/A = get_area(user.loc)
	for(var/obj/machinery/light/L in A) //Shamelessly copied from the APC effect.
		L.on = TRUE
		L.broken()
		stoplag()
	..()

/obj/item/metroidcross/burning/red
	colour = "red"
	effect_desc = "Makes nearby metroids rabid, and they'll also attack their friends."

/obj/item/metroidcross/burning/red/do_effect(mob/user)
	user.visible_message(SPAN_DANGER("[src] pulses a hazy red aura for a moment, which wraps around [user]!"))
	for(var/mob/living/carbon/metroid/S in view(7, get_turf(user)))
		if(user in S.Friends)
			S.Friends.Cut()
			S.Friends += user
		else
			S.Friends.Cut()
		S.rabid = 1
		S.visible_message(SPAN_DANGER("The [S] is driven into a dangerous frenzy!"))
	..()

/obj/item/metroidcross/burning/grey
	colour = "grey"
	effect_desc = "The user gets a dull arm blade in the hand it is used in."

/obj/item/metroidcross/burning/grey/do_effect(mob/user)
	var/mob/living/carbon/human/target
	if(ishuman(user))
		target = user
	else
		return

	spawn(10 SECONDS)
		to_chat(user, SPAN("danger", "You feel strange spasms in your hand."))
		target.visible_message("<b>[target]</b>'s arm twitches.")

	spawn(15 SECONDS)
		playsound(target.loc, 'sound/effects/blob/blobattack.ogg', 30, 1)

		var/hand = pick(list(BP_R_HAND, BP_L_HAND))
		var/failed = FALSE
		switch(hand)
			if(BP_R_HAND)
				if(!isProsthetic(target.r_hand))
					target.drop_r_hand()
				else if(!isProsthetic(target.l_hand))
					target.drop_l_hand()
					hand = BP_L_HAND
				else
					failed = TRUE

			if(BP_L_HAND)
				if(!isProsthetic(target.l_hand))
					target.drop_l_hand()
				else if(!isProsthetic(target.r_hand))
					target.drop_r_hand()
					hand = BP_R_HAND
				else
					failed = TRUE

		if(!failed)
			user.visible_message(SPAN_DANGER("[src] sublimates the flesh around [user]'s arm, transforming the bone into a gruesome blade!"))
			user.emote("scream")
			new /obj/item/melee/prosthetic/bio/fake_arm_blade(target, target.organs_by_name[hand])
	..()

/obj/item/metroidcross/burning/pink
	colour = "pink"
	effect_desc = "Creates a beaker of synthpax."

/obj/item/metroidcross/burning/pink/do_effect(mob/user)
	user.visible_message(SPAN_NOTICE("[src] shrinks into a small, gel-filled pellet!"))
	new /obj/item/metroidcrossbeaker/pax(get_turf(user))
	..()

/obj/item/metroidcross/burning/gold
	colour = "gold"
	effect_desc = "Creates a gank squad of monsters that are friendly to the user."

/obj/item/metroidcross/burning/gold/do_effect(mob/user)
	user.visible_message(SPAN_DANGER("[src] shudders violently, and summons an army for [user]!"))
	var/list/possible_mobs = list(
							/mob/living/simple_animal/hostile/faithless,
							/mob/living/simple_animal/hostile/creature,
							/mob/living/simple_animal/hostile/bear,
							/mob/living/simple_animal/hostile/maneater,
							/mob/living/simple_animal/hostile/mimic,
							/mob/living/simple_animal/hostile/carp/pike,
							/mob/living/simple_animal/hostile/tree,
							/mob/living/simple_animal/hostile/vagrant,
							/mob/living/simple_animal/hostile/voxslug
							)
	for(var/i in 1 to 3) //Less than gold normally does, since it's safer and faster.
		var/mob/living/path = pick(possible_mobs)
		var/mob/living/spawned_mob = new path(get_turf(user))
		spawned_mob.faction |= "\ref[user.name]"
		user.faction |= "\ref[user.name]"
		if(prob(50))
			for(var/j in 1 to rand(1, 3))
				step(spawned_mob, pick(NORTH,SOUTH,EAST,WEST))
	..()

/obj/item/metroidcross/burning/oil
	colour = "oil"
	effect_desc = "Creates an explosion after a few seconds."

/obj/item/metroidcross/burning/oil/do_effect(mob/user)
	user.visible_message(SPAN_WARNING("[user] activates [src]. It's going to explode!"), SPAN_DANGER("You activate [src]. It crackles in anticipation"))
	addtimer(CALLBACK(src, .proc/boom), 50)

/// Inflicts a blastwave upon every mob within a small radius.
/obj/item/metroidcross/burning/oil/proc/boom()
	var/turf/T = get_turf(src)
	playsound(T, 'sound/effects/explosions/explosion2.ogg', 200, TRUE)
	for(var/turf/simulated/target in range(2, T))
		new /obj/effect/explosion(target)
		SSexplosions.med_mov_atom += target
	qdel(src)

/obj/item/metroidcross/burning/black
	colour = "black"
	effect_desc = "Transforms the user into a metroid. They can transform back at will and do not lose any items."

/obj/item/metroidcross/burning/black/do_effect(mob/user)
	if(!isliving(user))
		return

	user.visible_message(SPAN_DANGER("[src] absorbs [user], transforming [user] into a metroid!"))
	var/datum/spell/targeted/shapeshift/metroid_form/transform = new()
	transform.cast(user)
	return ..()

/obj/item/metroidcross/burning/lightpink
	colour = "light pink"
	effect_desc = "Paxes everyone in sight."

/obj/item/metroidcross/burning/lightpink/do_effect(mob/user)
	user.visible_message(SPAN_DANGER("[src] lets off a hypnotizing pink glow!"))
	for(var/mob/living/carbon/C in view(7, get_turf(user)))
		C.reagents.add_reagent(/datum/reagent/paroxetine,5)
	..()

/obj/item/metroidcross/burning/adamantine
	colour = "adamantine"
	effect_desc = "Creates a mighty adamantine shield."

/obj/item/metroidcross/burning/adamantine/do_effect(mob/user)
	user.visible_message(SPAN_NOTICE("[src] crystallizes into a large shield!"))
	new /obj/item/shield/adamantineshield(get_turf(user))
	..()

/obj/item/metroidcross/burning/rainbow
	colour = "rainbow"
	effect_desc = "Creates the Rainbow Knife, a kitchen knife that deals random types of damage."

/obj/item/metroidcross/burning/rainbow/do_effect(mob/user)
	user.visible_message(SPAN_NOTICE("[src] flattens into a glowing rainbow blade."))
	new /obj/item/material/hatchet/tacknife/rainbowknife(get_turf(user))
	..()
