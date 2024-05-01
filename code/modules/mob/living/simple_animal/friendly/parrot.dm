/* Parrots!
 * Contains
 * 		Defines
 *		Inventory (headset stuff)
 *		Attack responces
 *		AI
 *		Procs / Verbs (usable by players)
 *		Sub-types
 */

/*
 * Defines
 */

//Only a maximum of one action and one intent should be active at any given time.
//Actions
#define PARROT_PERCH 1		//Sitting/sleeping, not moving
#define PARROT_SWOOP 2		//Moving towards or away from a target
#define PARROT_WANDER 4		//Moving without a specific target in mind

//Intents
#define PARROT_STEAL 8		//Flying towards a target to steal it/from it
#define PARROT_ATTACK 16	//Flying towards a target to attack it
#define PARROT_RETURN 32	//Flying towards its perch
#define PARROT_FLEE 64		//Flying away from its attacker


/mob/living/simple_animal/parrot
	name = "\improper Parrot"
	desc = "The parrot squaks, \"It's a Parrot! BAWWK!\""
	icon = 'icons/mob/animal.dmi'
	icon_state = "parrot_fly"
	item_state = "parrot"
	icon_living = "parrot_fly"
	icon_dead = "parrot_dead"
	pass_flags = PASS_FLAG_TABLE
	mob_size = MOB_SMALL

	speak = list("Привет","Крекер?","РЯЯЯЯ Фрэд Коллон убивает в техах")
	speak_emote = list("squawks","says","yells")
	emote_hear = list("squawks","bawks")
	emote_see = list("flutters its wings")

	speak_chance = 5//5% (5 in 100) chance every tick; So about once per 30 seconds, assuming an average tick is 1.5s; (FAKE)
	turns_per_move = 1
	meat_type = /obj/item/reagent_containers/food/cracker/

	response_help  = "pets"
	response_disarm = "gently moves aside"
	response_harm   = "swats"
	stop_automated_movement = 1
	universal_speak = 1

	blocks_emissive = EMISSIVE_BLOCK_UNIQUE

	var/phrase_chance = 15 // 15% chance every tick to add phrase from buffer to speaklist

	var/parrot_state = PARROT_WANDER //Hunt for a perch when created
	var/parrot_sleep_max = 25 //The time the parrot sits while perched before looking around. Mosly a way to avoid the parrot's AI in life() being run every single tick.
	var/parrot_sleep_dur = 25 //Same as above, this is the var that physically counts down
	var/parrot_dam_zone = list(BP_CHEST, BP_HEAD, BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG) //For humans, select a bodypart to attack

	var/parrot_speed = 3 //"Delay in world ticks between movement." according to byond. Yeah, that's BS but it does directly affect movement. Higher number = slower.
	var/parrot_been_shot = 0 //Parrots get a speed bonus after being shot. This will deincrement every Life() and at 0 the parrot will return to regular speed.

	var/list/speech_buffer = list()
	var/list/available_channels = list()

	//Headset for Poly to yell at engineers :)
	var/obj/item/device/radio/headset/ears = null

	//The thing the parrot is currently interested in. This gets used for items the parrot wants to pick up, mobs it wants to steal from,
	//mobs it wants to attack or mobs that have attacked it
	var/atom/movable/parrot_interest = null

	//Parrots will generally sit on their pertch unless something catches their eye.
	//These vars store their preffered perch and if they dont have one, what they can use as a perch
	var/obj/parrot_perch = null
	var/obj/desired_perches = list(/obj/structure/computerframe, 		/obj/structure/displaycase, \
									/obj/structure/filingcabinet,		/obj/machinery/teleporter_gate, \
									/obj/machinery/computer,			/obj/machinery/telecomms, \
									/obj/machinery/nuclearbomb,			/obj/machinery/particle_accelerator, \
									/obj/machinery/recharge_station,	/obj/machinery/smartfridge, \
									/obj/machinery/suit_storage_unit)
	//Parrots are kleptomaniacs. This variable ... stores the item a parrot is holding.
	var/obj/item/held_item = null

	can_pull_size = ITEM_SIZE_SMALL
	can_pull_mobs = MOB_PULL_SAME

	holder_type = /obj/item/holder/parrot
	bodyparts = /decl/simple_animal_bodyparts/bird


/mob/living/simple_animal/parrot/Initialize()
	. = ..()
	if(!ears)
		var/headset = pick(/obj/item/device/radio/headset/headset_sec, \
						/obj/item/device/radio/headset/headset_eng, \
						/obj/item/device/radio/headset/headset_med, \
						/obj/item/device/radio/headset/headset_sci, \
						/obj/item/device/radio/headset/headset_cargo)
		ears = new headset(src)

	parrot_sleep_dur = parrot_sleep_max //In case someone decides to change the max without changing the duration var

	grant_verb(src, list(
		/mob/living/simple_animal/parrot/proc/steal_from_ground,
		/mob/living/simple_animal/parrot/proc/steal_from_mob,
		/mob/living/simple_animal/parrot/verb/drop_held_item_player,
		/mob/living/simple_animal/parrot/proc/perch_player,
	))

/mob/living/simple_animal/parrot/Destroy()
	drop_held_item()
	QDEL_NULL(ears)
	QDEL_NULL(held_item)
	set_interest(null)
	set_perch(null)
	return ..()

/mob/living/simple_animal/parrot/death(gibbed, deathmessage, show_dead_message)
	if(held_item)
		held_item.forceMove(loc)
		held_item = null
	walk(src, 0)
	..(gibbed, deathmessage, show_dead_message)

/mob/living/simple_animal/parrot/get_status_tab_items()
	. = ..()

	. += "Held Item: [held_item]"

// These two are used often AF, it's easier to handle them this way than resolve weakrefs everywhere.
/mob/living/simple_animal/parrot/proc/set_interest(atom/movable/AM)
	if(parrot_interest)
		unregister_signal(parrot_interest, SIGNAL_QDELETING)
	parrot_interest = AM
	if(!QDELETED(parrot_interest) && !client)
		register_signal(parrot_interest, SIGNAL_QDELETING, nameof(.proc/_interest_deleted))

/mob/living/simple_animal/parrot/proc/_interest_deleted()
	set_interest(null)

/mob/living/simple_animal/parrot/proc/set_perch(obj/O)
	if(parrot_perch)
		unregister_signal(parrot_perch, SIGNAL_QDELETING)
	parrot_perch = O
	if(!QDELETED(parrot_perch) && !client)
		register_signal(parrot_perch, SIGNAL_QDELETING, nameof(.proc/_perch_deleted))

/mob/living/simple_animal/parrot/proc/_perch_deleted()
	set_perch(null)


/*
 * Inventory
 */
/mob/living/simple_animal/parrot/show_inv(mob/user as mob)
	user.set_machine(src)
	if(user.stat)
		return FALSE

	var/dat = 	"<meta charset=\"utf-8\"><div align='center'><b>Inventory of [name]</b></div><p>"
	if(ears)
		dat +=	"<br><b>Headset:</b> [ears] (<a href='?src=\ref[src];remove_inv=ears'>Remove</a>)"
	else
		dat +=	"<br><b>Headset:</b> <a href='?src=\ref[src];add_inv=ears'>Nothing</a>"
	if(held_item)
		dat +=	"<br><b>Claws:</b> [held_item] <a href='?src=\ref[src];remove_inv=claws'>Remove</a>"
	else
		dat +=	"<br><b>Claws:</b> <a href='?src=\ref[src];add_inv=claws'>Nothing</a>"


	show_browser(user, dat, text("window=mob[];size=325x500", name))
	onclose(user, "mob[real_name]")
	return TRUE

/mob/living/simple_animal/parrot/Topic(href, href_list)

	//Can the usr physically do this?
	if(!CanPhysicallyInteract(usr))
		return

	//Is the usr's mob type able to do this?
	if(ishuman(usr) || issmall(usr) || isrobot(usr))

		//Removing from inventory
		if(href_list["remove_inv"])
			var/remove_from = href_list["remove_inv"]
			switch(remove_from)
				if("ears")
					if(ears)
						if(available_channels.len)
							src.say("[pick(available_channels)] РРРЯЯЯЯ ОСТАВЬ НАУШНИК РРЯЯЯЯЯЯ!")
						else
							src.say("РРЯЯЯЯЯ ОСТАВЬ НАУШНИК РРРЯЯЯЯЯ!")
						ears.dropInto(loc)
						ears = null
						for(var/possible_phrase in speak)
							if(copytext(possible_phrase, 1, 3) in department_radio_keys)
								possible_phrase = copytext(possible_phrase, 3, length(possible_phrase))
					else
						to_chat(usr, SPAN_WARNING("There is nothing to remove from its [remove_from]."))
						return
				if("claws")
					if(!held_item)
						to_chat(usr, SPAN_WARNING("There is nothing to remove from its [remove_from]!"))
						return
					if(available_channels.len)
						src.say("[pick(available_channels)] РРРЯЯЯЯЯ ПОЛОЖИ НА МЕСТО РРЯЯЯЯЯЯ!")
					else
						src.say("РРРЯЯЯЯ ПОЛОЖИ НА МЕСТО РРРЯЯЯЯЯЯ!")
					held_item.dropInto(loc)
					held_item = null

		//Adding things to inventory
		else if(href_list["add_inv"])
			var/add_to = href_list["add_inv"]
			if(!usr.get_active_hand())
				to_chat(usr, SPAN_WARNING("You have nothing in your hand to put on its [add_to]."))
				return
			switch(add_to)
				if("ears")
					if(ears)
						to_chat(usr, SPAN_WARNING("It's already wearing something."))
						return

					var/obj/item/item_to_add = usr.get_active_hand()
					if(!item_to_add)
						return

					if(!istype(item_to_add, /obj/item/device/radio/headset))
						to_chat(usr, SPAN_WARNING("This object won't fit."))
						return

					if(!usr.drop(item_to_add, src))
						return

					var/obj/item/device/radio/headset/headset_to_add = item_to_add
					ears = headset_to_add
					to_chat(usr, "You fit the headset onto [src].")

					clearlist(available_channels)
					for(var/ch in headset_to_add.channels)
						switch(ch)
							if("Engineering")
								available_channels.Add(":e")
							if("Command")
								available_channels.Add(":c")
							if("Security")
								available_channels.Add(":s")
							if("Science")
								available_channels.Add(":n")
							if("Medical")
								available_channels.Add(":m")
							if("Mining")
								available_channels.Add(":d")
							if("Cargo")
								available_channels.Add(":q")
				if("claws")
					if(held_item)
						to_chat(usr, SPAN_WARNING("It's already wearing something."))
						return

					var/obj/item/item_to_add = usr.get_active_hand()
					if(!item_to_add)
						return

					if(!usr.drop(item_to_add, src))
						return

					held_item = item_to_add
					to_chat(usr, SPAN_NOTICE("You put the item into claws."))
					if(istype(src, /mob/living/simple_animal/parrot/Poly))
						if(prob(90))
							say("Поли нравится!")
						else
							say("Поли хочет ЕЩЁ!")
		else
			..()


/*
 * Attack responces
 */
//Humans, monkeys, aliens
/mob/living/simple_animal/parrot/attack_hand(mob/living/carbon/M as mob)
	..()
	if(client) return
	if(!stat && M.a_intent == I_HURT)

		icon_state = "parrot_fly" //It is going to be flying regardless of whether it flees or attacks

		if(parrot_state == PARROT_PERCH)
			parrot_sleep_dur = parrot_sleep_max //Reset it's sleep timer if it was perched

		set_interest(M)
		parrot_state = PARROT_SWOOP //The parrot just got hit, it WILL move, now to pick a direction..

		if(M.health < 50) //Weakened mob? Fight back!
			parrot_state |= PARROT_ATTACK
		else
			parrot_state |= PARROT_FLEE		//Otherwise, fly like a bat out of hell!
			drop_held_item(0)
	return

//Mobs with objects
/mob/living/simple_animal/parrot/attackby(obj/item/O, mob/user)
	..()
	if(!stat && !client && !istype(O, /obj/item/stack/medical))
		if(O.force)
			if(parrot_state == PARROT_PERCH)
				parrot_sleep_dur = parrot_sleep_max //Reset it's sleep timer if it was perched

			set_interest(user)
			parrot_state = PARROT_SWOOP | PARROT_FLEE
			icon_state = "parrot_fly"
			drop_held_item(0)
	return

//Bullets
/mob/living/simple_animal/parrot/bullet_act(obj/item/projectile/Proj)
	..()
	if(!stat && !client)
		if(parrot_state == PARROT_PERCH)
			parrot_sleep_dur = parrot_sleep_max //Reset it's sleep timer if it was perched

		set_interest(null)
		parrot_state = PARROT_WANDER //OWFUCK, Been shot! RUN LIKE HELL!
		parrot_been_shot += 5
		icon_state = "parrot_fly"
		drop_held_item(0)
	return


/*
 * AI - Not really intelligent, but I'm calling it AI anyway.
 */
/mob/living/simple_animal/parrot/Life()
	..()

	//Sprite and AI update for when a parrot gets pulled
	if(pulledby && stat == CONSCIOUS)
		icon_state = "parrot_fly"
		if(!client)
			parrot_state = PARROT_WANDER
		return

	if(client || stat)
		return //Lets not force players or dead/incap parrots to move

	if(!isturf(src.loc))
		return // Let's not bother in nullspace

	if(client && stat == CONSCIOUS && parrot_state != "parrot_fly")
		icon_state = "parrot_fly"

//-----SPEECH
	/* Parrot speech mimickry!
	   Phrases that the parrot hears in mob/living/say() get added to speach_buffer.
	   Every once in a while, the parrot picks one of the lines from the buffer and replaces an element of the 'speech' list.
	   Then it clears the buffer to make sure they dont magically remember something from hours ago. */
	if(speech_buffer.len && prob(phrase_chance))
		if(speak.len)
			speak.Remove(pick(speak))

		speak.Add(pick(speech_buffer))
		clearlist(speech_buffer)


//-----SLEEPING
	if(parrot_state == PARROT_PERCH)
		if(parrot_perch && parrot_perch.loc != src.loc) //Make sure someone hasnt moved our perch on us
			if(parrot_perch in view(src))
				parrot_state = PARROT_SWOOP | PARROT_RETURN
				icon_state = "parrot_fly"
				return
			else
				parrot_state = PARROT_WANDER
				icon_state = "parrot_fly"
				return

		if(--parrot_sleep_dur) //Zzz
			return

		else
			//This way we only call the stuff below once every [sleep_max] ticks.
			parrot_sleep_dur = parrot_sleep_max

			//Cycle through message modes for the headset
			if(speak.len)
				var/list/newspeak = list()

				if(available_channels.len && src.ears)
					for(var/possible_phrase in speak)

						//50/50 chance to not use the radio at all
						var/useradio = 0
						if(prob(50))
							useradio = 1

						if(copytext(possible_phrase, 1, 3) in department_radio_keys)
							possible_phrase = "[useradio?pick(available_channels):""] [copytext(possible_phrase, 3, length(possible_phrase)+1)]" //crop out the channel prefix
						else
							possible_phrase = "[useradio?pick(available_channels):""] [possible_phrase]"

						newspeak.Add(possible_phrase)

				else //If we have no headset or channels to use, dont try to use any!
					for(var/possible_phrase in speak)
						if(copytext(possible_phrase, 1, 3) in department_radio_keys)
							possible_phrase = "[copytext(possible_phrase, 3, length(possible_phrase)+1)]" //crop out the channel prefix
						newspeak.Add(possible_phrase)
				speak = newspeak

			//Search for item to steal
			set_interest(search_for_item())
			if(parrot_interest)
				visible_emote("looks in [parrot_interest]'s direction and takes flight.")
				parrot_state = PARROT_SWOOP | PARROT_STEAL
				icon_state = "parrot_fly"
			return

//-----WANDERING - This is basically a 'I dont know what to do yet' state
	else if(parrot_state == PARROT_WANDER)
		//Stop movement, we'll set it later
		walk(src, 0)
		set_interest(null)

		//Wander around aimlessly. This will help keep the loops from searches down
		//and possibly move the mob into a new are in view of something they can use
		if(prob(90))
			SelfMove(pick(GLOB.cardinal))
			return

		if(!held_item && !parrot_perch) //If we've got nothing to do.. look for something to do.
			var/atom/movable/AM = search_for_perch_and_item() //This handles checking through lists so we know it's either a perch or stealable item
			if(AM)
				if(istype(AM, /obj/item) || isliving(AM))	//If stealable item
					set_interest(AM)
					visible_emote("turns and flies towards [parrot_interest].")
					parrot_state = PARROT_SWOOP | PARROT_STEAL
					return
				else	//Else it's a perch
					set_perch(AM)
					parrot_state = PARROT_SWOOP | PARROT_RETURN
					return
			return

		if(parrot_interest && (parrot_interest in view(src)))
			parrot_state = PARROT_SWOOP | PARROT_STEAL
			return

		if(parrot_perch && (parrot_perch in view(src)))
			parrot_state = PARROT_SWOOP | PARROT_RETURN
			return

		else //Have an item but no perch? Find one!
			set_perch(search_for_perch())
			if(parrot_perch)
				parrot_state = PARROT_SWOOP | PARROT_RETURN
				return
//-----STEALING
	else if(parrot_state == (PARROT_SWOOP | PARROT_STEAL))
		walk(src, 0)
		if(!parrot_interest || held_item)
			parrot_state = PARROT_SWOOP | PARROT_RETURN
			return

		if(!(parrot_interest in view(src)))
			parrot_state = PARROT_SWOOP | PARROT_RETURN
			return

		if(in_range(src, parrot_interest))

			if(isliving(parrot_interest))
				steal_from_mob()

			else //This should ensure that we only grab the item we want, and make sure it's not already collected on our perch
				if(!parrot_perch || parrot_interest.loc != parrot_perch.loc)
					held_item = parrot_interest
					parrot_interest.forceMove(src)
					visible_message("[src] grabs the [held_item]!", SPAN_NOTICE("You grab the [held_item]!"), "You hear the sounds of wings flapping furiously.")

			set_interest(null)
			parrot_state = PARROT_SWOOP | PARROT_RETURN
			return

		walk_to(src, parrot_interest, 1, parrot_speed)
		return

//-----RETURNING TO PERCH
	else if(parrot_state == (PARROT_SWOOP | PARROT_RETURN))
		walk(src, 0)
		if(!parrot_perch || !isturf(parrot_perch.loc)) //Make sure the perch exists and somehow isnt inside of something else.
			set_perch(null)
			parrot_state = PARROT_WANDER
			return

		if(in_range(src, parrot_perch))
			forceMove(parrot_perch.loc)
			drop_held_item()
			parrot_state = PARROT_PERCH
			icon_state = "parrot_sit"
			return

		walk_to(src, parrot_perch, 1, parrot_speed)
		return

//-----FLEEING
	else if(parrot_state == (PARROT_SWOOP | PARROT_FLEE))
		walk(src, 0)
		if(!parrot_interest || !isliving(parrot_interest)) //Sanity
			parrot_state = PARROT_WANDER

		walk_away(src, parrot_interest, 1, parrot_speed-parrot_been_shot)
		parrot_been_shot--
		return

//-----ATTACKING
	else if(parrot_state == (PARROT_SWOOP | PARROT_ATTACK))

		//If we're attacking a nothing, an object, a turf or a ghost for some stupid reason, switch to wander
		if(!parrot_interest || !isliving(parrot_interest))
			set_interest(null)
			parrot_state = PARROT_WANDER
			return

		var/mob/living/L = parrot_interest

		//If the mob is close enough to interact with
		if(in_range(src, parrot_interest))

			//If the mob we've been chasing/attacking dies or falls into crit, check for loot!
			if(L.stat)
				set_interest(null)
				if(!held_item)
					held_item = steal_from_ground()
					if(!held_item)
						held_item = steal_from_mob() //Apparently it's possible for dead mobs to hang onto items in certain circumstances.
				if(parrot_perch in view(src)) //If we have a home nearby, go to it, otherwise find a new home
					parrot_state = PARROT_SWOOP | PARROT_RETURN
				else
					parrot_state = PARROT_WANDER
				return

			//Time for the hurt to begin!
			var/damage = rand(5, 10)

			if(ishuman(parrot_interest))
				var/mob/living/carbon/human/H = parrot_interest
				var/obj/item/organ/external/affecting = H.get_organ(ran_zone(pick(parrot_dam_zone)))

				H.apply_damage(damage, BRUTE, affecting, H.run_armor_check(affecting, "melee"), DAM_SHARP|DAM_EDGE)
				visible_emote(pick("pecks [H]'s [affecting].", "cuts [H]'s [affecting] with its talons."))

			else
				L.adjustBruteLoss(damage)
				visible_emote(pick("pecks at [L].", "claws [L]."))
			return

		//Otherwise, fly towards the mob!
		else
			walk_to(src, parrot_interest, 1, parrot_speed)
		return
//-----STATE MISHAP
	else //This should not happen. If it does lets reset everything and try again
		walk(src, 0)
		set_interest(null)
		set_perch(null)
		drop_held_item()
		parrot_state = PARROT_WANDER
		return

/*
 * Procs
 */

/mob/living/simple_animal/parrot/proc/search_for_item()
	for(var/atom/movable/AM in view(src))
		//Skip items we already stole or are wearing or are too big
		if(parrot_perch && AM.loc == parrot_perch.loc || AM.loc == src)
			continue

		if(istype(AM, /obj/item))
			var/obj/item/I = AM
			if(I.w_class <= ITEM_SIZE_SMALL)
				return I

		if(iscarbon(AM))
			var/mob/living/carbon/C = AM
			if((C.l_hand && C.l_hand.w_class <= ITEM_SIZE_SMALL) || (C.r_hand && C.r_hand.w_class <= ITEM_SIZE_SMALL))
				return C
	return null

/mob/living/simple_animal/parrot/proc/search_for_perch()
	for(var/obj/O in view(src))
		for(var/path in desired_perches)
			if(istype(O, path))
				return O
	return null

//This proc was made to save on doing two 'in view' loops seperatly
/mob/living/simple_animal/parrot/proc/search_for_perch_and_item()
	for(var/atom/movable/AM in view(src))
		for(var/perch_path in desired_perches)
			if(istype(AM, perch_path))
				return AM

		//Skip items we already stole or are wearing or are too big
		if(parrot_perch && AM.loc == parrot_perch.loc || AM.loc == src)
			continue

		if(istype(AM, /obj/item))
			var/obj/item/I = AM
			if(I.w_class <= ITEM_SIZE_SMALL)
				return I

		if(iscarbon(AM))
			var/mob/living/carbon/C = AM
			if(C.l_hand && C.l_hand.w_class <= ITEM_SIZE_SMALL || C.r_hand && C.r_hand.w_class <= ITEM_SIZE_SMALL)
				return C
	return null


/*
 * Verbs - These are actually procs, but can be used as verbs by player-controlled parrots.
 */
/mob/living/simple_animal/parrot/proc/steal_from_ground()
	set name = "Steal from ground"
	set category = "Parrot"
	set desc = "Grabs a nearby item."

	if(stat)
		return -1

	if(held_item)
		to_chat(src, SPAN_WARNING("You are already holding the [held_item]"))
		return 1

	for(var/obj/item/I in view(1,src))
		//Make sure we're not already holding it and it's small enough
		if(I.loc != src && I.w_class <= ITEM_SIZE_SMALL)

			//If we have a perch and the item is sitting on it, continue
			if(!client && parrot_perch && I.loc == parrot_perch.loc)
				continue

			held_item = I
			I.forceMove(src)
			visible_message("[src] grabs the [held_item]!", SPAN_NOTICE("You grab the [held_item]!"), "You hear the sounds of wings flapping furiously.")
			return held_item

	to_chat(src, SPAN_WARNING("There is nothing of interest to take."))
	return 0

/mob/living/simple_animal/parrot/proc/steal_from_mob()
	set name = "Steal from mob"
	set category = "Parrot"
	set desc = "Steals an item right out of a person's hand!"

	if(stat)
		return -1

	if(held_item)
		to_chat(src, SPAN_WARNING("You are already holding the [held_item]."))
		return 1

	var/obj/item/stolen_item = null

	for(var/mob/living/carbon/C in view(1,src))
		if(C.l_hand && C.l_hand.w_class <= ITEM_SIZE_SMALL)
			stolen_item = C.l_hand

		if(C.r_hand && C.r_hand.w_class <= ITEM_SIZE_SMALL)
			stolen_item = C.r_hand

		if(stolen_item && C.drop(stolen_item, src))
			held_item = stolen_item
			visible_message("[src] grabs the [held_item] out of [C]'s hand!",
			                SPAN_WARNING("You snag the [held_item] out of [C]'s hand!"),
			                "You hear the sounds of wings flapping furiously.")
			return held_item

	to_chat(src, SPAN_WARNING("There is nothing of interest to take."))
	return 0

/mob/living/simple_animal/parrot/verb/drop_held_item_player()
	set name = "Drop held item"
	set category = "Parrot"
	set desc = "Drop the item you're holding."

	if(stat)
		return

	src.drop_held_item()

	return


/mob/living/simple_animal/parrot/proc/drop_held_item(drop_gently = 1)
	set name = "Drop held item"
	set category = "Parrot"
	set desc = "Drop the item you're holding."

	if(stat)
		return -1

	if(!held_item)
		if(drop_gently)
			to_chat(src, SPAN("warning", "You have nothing to drop!"))
		return 0

	if(!drop_gently)
		if(istype(held_item, /obj/item/grenade))
			var/obj/item/grenade/G = held_item
			G.dropInto(loc)
			G.detonate()
			to_chat(src, "You let go of the [held_item]!")
			held_item = null
			return 1

	to_chat(src, "You drop the [held_item].")

	held_item.dropInto(loc)
	held_item = null
	return 1

/mob/living/simple_animal/parrot/proc/perch_player()
	set name = "Sit"
	set category = "Parrot"
	set desc = "Sit on a nice comfy perch."

	if(stat || !client)
		return

	if(icon_state == "parrot_fly")
		for(var/atom/movable/AM in view(src,1))
			for(var/perch_path in desired_perches)
				if(istype(AM, perch_path))
					forceMove(AM.loc)
					icon_state = "parrot_sit"
					return
	to_chat(src, SPAN_WARNING("There is no perch nearby to sit on."))
	return

/*
 * Sub-types
 */
/mob/living/simple_animal/parrot/Poly
	name = "Poly"
	desc = "Poly the Parrot. An expert on quantum cracker theory."

/mob/living/simple_animal/parrot/Poly/Initialize()
	ears = new /obj/item/device/radio/headset/headset_eng(src)
	available_channels = list(":e")
	speak = GLOB.poly_phrases
	..()

/mob/living/simple_animal/parrot/say(message)

	if(stat)
		return

	var/verb = "says"
	if(speak_emote.len)
		verb = pick(speak_emote)


	var/message_mode=""
	if(copytext(message, 1, 2) == get_prefix_key(/decl/prefix/radio_main_channel))
		message_mode = "headset"
		message = copytext(message,2)

	if(length(message) >= 2)
		var/channel_prefix = copytext(message, 1 ,3)
		message_mode = department_radio_keys[channel_prefix]

	if(copytext(message, 1, 2) == get_prefix_key(/decl/prefix/radio_channel_selection))
		var/positioncut = 3
		message = trim(copytext(message,positioncut))

	message = capitalize(trim_left(message))

	if(message_mode)
		if(message_mode in GLOB.radio_channels)
			if(ears && istype(ears,/obj/item/device/radio))
				ears.talk_into(src,sanitize(message), message_mode, verb, null)


	..(message)


/mob/living/simple_animal/parrot/hear_say(message, verb = "says", datum/language/language = null, alt_name = "", italics = 0, mob/speaker = null, sound/speech_sound, sound_vol)
	if(prob(50) && !istype(speaker, /mob/living/simple_animal/parrot))
		parrot_hear(message)
	..()



/mob/living/simple_animal/parrot/hear_radio(message, verb="says", datum/language/language=null, part_a, part_b, part_c, mob/speaker = null, hard_to_hear = 0)
	if(prob(50) && available_channels.len)
		parrot_hear("[pick(available_channels)] [message]")
	..()


/mob/living/simple_animal/parrot/proc/parrot_hear(message="")
	if(!message || stat)
		return
	speech_buffer.Add(message)

/mob/living/simple_animal/parrot/attack_generic(mob/user, damage, attack_message)

	var/success = ..()

	if(client)
		return success

	if(parrot_state == PARROT_PERCH)
		parrot_sleep_dur = parrot_sleep_max //Reset it's sleep timer if it was perched

	if(!success)
		return 0

	set_interest(user)
	parrot_state = PARROT_SWOOP | PARROT_ATTACK //Attack other animals regardless
	icon_state = "parrot_fly"
	return success
