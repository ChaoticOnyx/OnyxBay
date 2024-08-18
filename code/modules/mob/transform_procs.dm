/mob/living/carbon/human/proc/monkeyize()
	if(HAS_TRANSFORMATION_MOVEMENT_HANDLER(src))
		return
	for(var/obj/item/I in src)
		if(I == w_uniform) // will be torn
			continue
		drop(I)
	regenerate_icons()
	ADD_TRANSFORMATION_MOVEMENT_HANDLER(src)
	stunned = 1
	icon = null
	set_invisibility(101)
	for(var/t in organs)
		qdel(t)
	var/atom/movable/fake_overlay/animation = new /atom/movable/fake_overlay(loc)
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src
	flick("h2monkey", animation)
	sleep(48)
	//animation = null

	DEL_TRANSFORMATION_MOVEMENT_HANDLER(src)
	stunned = 0
	update_canmove()
	set_invisibility(initial(invisibility))

	if(!species.primitive_form) //If the creature in question has no primitive set, this is going to be messy.
		gib()
		return

	for(var/obj/item/I in src)
		drop(I)
	set_species(species.primitive_form)

	to_chat(src, "<B>You are now [species.name]. </B>")
	qdel(animation)

	return src

/mob/new_player/AIize(move, rename)
	spawning = 1
	return ..(move, rename)

/mob/living/carbon/human/AIize(move, rename) // 'move' argument needs defining here too because BYOND is dumb
	if(HAS_TRANSFORMATION_MOVEMENT_HANDLER(src))
		return
	for(var/t in organs)
		qdel(t)
	QDEL_NULL_LIST(worn_underwear)
	return ..(move, rename)

/mob/living/carbon/AIize(move, rename)
	if(HAS_TRANSFORMATION_MOVEMENT_HANDLER(src))
		return
	for(var/obj/item/I in src)
		drop(I)
	ADD_TRANSFORMATION_MOVEMENT_HANDLER(src)
	icon = null
	set_invisibility(101)
	return ..(move, rename)

/mob/proc/AIize(move = TRUE, rename = TRUE)
	if(client)
		sound_to(src, sound(null, repeat = 0, wait = 0, volume = 85, channel = 1))// stop the jams for AIs

	var/mob/living/silicon/ai/O = new (loc, GLOB.using_map.default_law_type,,1)//No MMI but safety is in effect.
	O.set_invisibility(0)
	O.aiRestorePowerRoutine = 0
	if(mind)
		mind.transfer_to(O)
		O.mind.original_mob = weakref(O)
	else
		O.key = key

	if(move)
		var/obj/loc_landmark
		for(var/obj/effect/landmark/start/sloc in GLOB.landmarks_list)
			if (sloc.name != "AI")
				continue
			if ((locate(/mob/living) in sloc.loc) || (locate(/obj/structure/AIcore) in sloc.loc))
				continue
			loc_landmark = sloc
		if (!loc_landmark)
			for(var/obj/effect/landmark/tripai in GLOB.landmarks_list)
				if (tripai.name == "Triple AI")
					if((locate(/mob/living) in tripai.loc) || (locate(/obj/structure/AIcore) in tripai.loc))
						continue
					loc_landmark = tripai
		if (!loc_landmark)
			to_chat(O, "Oh god sorry we can't find an unoccupied AI spawn location, so we're spawning you on top of someone.")
			for(var/obj/effect/landmark/start/sloc in GLOB.landmarks_list)
				if (sloc.name == "AI")
					loc_landmark = sloc
		O.forceMove(loc_landmark.loc)
		O.on_mob_init()

	O.add_ai_verbs()

	if(rename)
		O.rename_self("ai", TRUE)

	spawn(0)	// Mobs still instantly del themselves, thus we need to spawn or O will never be returned
		qdel(src)
	return O

//human -> robot
/mob/living/carbon/human/proc/Robotize()
	if(HAS_TRANSFORMATION_MOVEMENT_HANDLER(src))
		return
	QDEL_NULL_LIST(worn_underwear)
	for(var/obj/item/I in src)
		if(I.loc != src)
			continue

		drop(I)
	regenerate_icons()
	ADD_TRANSFORMATION_MOVEMENT_HANDLER(src)
	icon = null
	set_invisibility(101)
	for(var/t in organs)
		qdel(t)

	var/mob/living/silicon/robot/O = new /mob/living/silicon/robot( loc )

	O.gender = gender
	O.set_invisibility(0)

	if(mind)		//TODO
		mind.transfer_to(O)
		if(O.mind.assigned_role == "Cyborg")
			O.mind.original_mob = weakref(O)
		else if(mind?.special_role)
			O.mind.store_memory("In case you look at this after being borged, the objectives are only here until I find a way to make them not show up for you, as I can't simply delete them without screwing up round-end reporting. --NeoFite")
	else
		O.key = key

	O.forceMove(loc)
	O.job = "Cyborg"
	if(O.mind.assigned_role == "Cyborg")
		if(O.mind.role_alt_title == "Android")
			O.mmi = new /obj/item/organ/internal/cerebrum/posibrain(O, src)
		else
			O.mmi = new /obj/item/organ/internal/cerebrum/mmi(O, src)

		O.mmi.transfer_identity(src)

		if(O.mmi.brainmob)
			O.mmi.brainmob.add_language(LANGUAGE_EAL)
			O.mmi.brainmob.add_language(LANGUAGE_ROBOT)
			O.mmi.brainmob.add_language(LANGUAGE_GALCOM)

	callHook("borgify", list(O))
	O.Namepick()

	spawn(0)	// Mobs still instantly del themselves, thus we need to spawn or O will never be returned
		qdel(src)
	return O

/mob/living/carbon/human/proc/metroidize(adult as num, reproduce as num)
	if(HAS_TRANSFORMATION_MOVEMENT_HANDLER(src))
		return
	for(var/obj/item/I in src)
		drop(I)
	regenerate_icons()
	ADD_TRANSFORMATION_MOVEMENT_HANDLER(src)
	icon = null
	set_invisibility(101)
	for(var/t in organs)
		qdel(t)

	var/mob/living/carbon/metroid/new_metroid
	if(reproduce)
		var/number = pick(14;2,3,4)	//reproduce (has a small chance of producing 3 or 4 offspring)
		var/list/babies = list()
		for(var/i=1,i<=number,i++)
			var/mob/living/carbon/metroid/M = new /mob/living/carbon/metroid(loc)
			M.set_nutrition(round(M.nutrition / number))
			step_away(M,src)
			babies += M
		new_metroid = pick(babies)
	else
		new_metroid = new /mob/living/carbon/metroid(loc)
		if(adult)
			new_metroid.is_adult = 1

	new_metroid.key = key

	to_chat(new_metroid, "<B>You are now a metroid. Skreee!</B>")
	qdel(src)
	return

/mob/living/carbon/human/proc/corgize()
	if(HAS_TRANSFORMATION_MOVEMENT_HANDLER(src))
		return
	for(var/obj/item/I in src)
		drop(I)
	regenerate_icons()
	ADD_TRANSFORMATION_MOVEMENT_HANDLER(src)
	icon = null
	set_invisibility(101)
	for(var/t in organs)	//this really should not be necessary
		qdel(t)

	var/mob/living/simple_animal/corgi/new_corgi = new /mob/living/simple_animal/corgi (loc)
	new_corgi.a_intent = I_HURT

	new_corgi.key = key

	to_chat(new_corgi, "<B>You are now a Corgi. Yap Yap!</B>")
	qdel(src)
	return

/mob/living/carbon/human/Animalize()

	var/list/mobtypes = typesof(/mob/living/simple_animal)
	var/mobpath = input("Which type of mob should [src] turn into?", "Choose a type") in mobtypes

	if(!safe_animal(mobpath))
		to_chat(usr, "<span class='warning'>Sorry but this mob type is currently unavailable.</span>")
		return

	if(HAS_TRANSFORMATION_MOVEMENT_HANDLER(src))
		return
	for(var/obj/item/I in src)
		drop(I)

	regenerate_icons()
	ADD_TRANSFORMATION_MOVEMENT_HANDLER(src)
	icon = null
	set_invisibility(101)

	for(var/t in organs)
		qdel(t)

	var/mob/new_mob = new mobpath(src.loc)

	new_mob.key = key
	new_mob.a_intent = I_HURT

	to_chat(new_mob, "You suddenly feel more... animalistic.")
	spawn()
		qdel(src)
	return

/mob/proc/Animalize()

	var/list/mobtypes = typesof(/mob/living/simple_animal)
	var/mobpath = input("Which type of mob should [src] turn into?", "Choose a type") in mobtypes

	if(!safe_animal(mobpath))
		to_chat(usr, "<span class='warning'>Sorry but this mob type is currently unavailable.</span>")
		return

	var/mob/new_mob = new mobpath(src.loc)

	new_mob.key = key

	new_mob.a_intent = I_HURT
	to_chat(new_mob, "You feel more... animalistic")

	qdel(src)

/* Certain mob types have problems and should not be allowed to be controlled by players.
 *
 * This proc is here to force coders to manually place their mob in this list, hopefully tested.
 * This also gives a place to explain -why- players shouldnt be turn into certain mobs and hopefully someone can fix them.
 */
/mob/proc/safe_animal(MP)

//Bad mobs! - Remember to add a comment explaining what's wrong with the mob
	if(!MP)
		return 0	//Sanity, this should never happen.

	if(ispath(MP, /mob/living/simple_animal/construct/behemoth))
		return 0 //I think this may have been an unfinished WiP or something. These constructs should really have their own class simple_animal/construct/subtype

	if(ispath(MP, /mob/living/simple_animal/construct/armoured))
		return 0 //Verbs do not appear for players. These constructs should really have their own class simple_animal/construct/subtype

	if(ispath(MP, /mob/living/simple_animal/construct/wraith))
		return 0 //Verbs do not appear for players. These constructs should really have their own class simple_animal/construct/subtype

	if(ispath(MP, /mob/living/simple_animal/construct/builder))
		return 0 //Verbs do not appear for players. These constructs should really have their own class simple_animal/construct/subtype

//Good mobs!
	if(ispath(MP, /mob/living/simple_animal/cat))
		return 1
	if(ispath(MP, /mob/living/simple_animal/corgi))
		return 1
	if(ispath(MP, /mob/living/simple_animal/crab))
		return 1
	if(ispath(MP, /mob/living/simple_animal/hostile/carp))
		return 1
	if(ispath(MP, /mob/living/simple_animal/mushroom))
		return 1
	if(ispath(MP, /mob/living/simple_animal/shade))
		return 1
	if(ispath(MP, /mob/living/simple_animal/hostile/tomato))
		return 1
	if(ispath(MP, /mob/living/simple_animal/mouse))
		return 1 //It is impossible to pull up the player panel for mice (Fixed! - Nodrak)
	if(ispath(MP, /mob/living/simple_animal/hostile/bear))
		return 1 //Bears will auto-attack mobs, even if they're player controlled (Fixed! - Nodrak)
	if(ispath(MP, /mob/living/simple_animal/parrot))
		return 1 //Parrots are no longer unfinished! -Nodrak

	//Not in here? Must be untested!
	return 0


//This is barely a transformation but probably best file for it.
/mob/living/carbon/human/proc/zombify()
	RemoveHairAndFacials()
	for(var/obj/item/organ/external/head/h in organs)
		h.status |= ORGAN_DISFIGURED
	mutations |= MUTATION_CLUMSY
	src.visible_message("<span class='danger'>\The [src]'s skin decays before your very eyes!</span>", "<span class='danger'>Your entire body is ripe with pain as it is consumed down to flesh and bones. You ... hunger. Not only for flesh, but to spread this gift.</span>")
	if (!src.mind || (src.mind && src.mind.special_role == "Zombie"))
		return
	if(species != all_species[SPECIES_HUMAN])
		ChangeToHusk()
	src.mind.special_role = "Zombie"
	update_body(TRUE)
	update_eyes()
	log_admin("[key_name(src)] has transformed into a zombie!")
	Weaken(5)
	if (should_have_organ(BP_HEART))
		vessel.add_reagent(/datum/reagent/blood, species.blood_volume - vessel.total_volume)
	for (var/o in organs)
		var/obj/item/organ/organ = o
		organ.vital = 0
		if (!BP_IS_ROBOTIC(organ))
			organ.rejuvenate(1)
			organ.max_damage *= 3
			organ.min_broken_damage = Floor(organ.max_damage * 0.75)
	src.no_pain = TRUE
	src.does_not_breathe = TRUE
	verbs += /mob/living/carbon/human/proc/breath_death
	verbs += /mob/living/carbon/human/proc/consume
	remove_language(LANGUAGE_GALCOM)
	playsound(src, 'sound/hallucinations/wail.ogg', 20, 1)
