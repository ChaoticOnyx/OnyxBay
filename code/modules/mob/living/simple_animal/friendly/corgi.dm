//Corgi
/mob/living/simple_animal/corgi
	name = "\improper corgi"
	real_name = "corgi"
	desc = "It's a corgi."
	icon_state = "corgi"
	icon_living = "corgi"
	icon_dead = "corgi_dead"
	item_state = "corgi"
	speak = list("YAP", "Woof!", "Bark!", "AUUUUUU")
	speak_emote = list("barks", "woofs")
	emote_hear = list("barks", "woofs", "yaps","pants")
	emote_see = list("shakes its head", "shivers")
	speak_chance = 1
	turns_per_move = 10
	meat_type = /obj/item/reagent_containers/food/meat/corgi
	meat_amount = 3
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"
	see_in_dark = 5
	mob_size = 8
	health = 30
	maxHealth = 30
	possession_candidate = 1
	holder_type = /obj/item/holder/corgi
	var/obj/item/hat
	var/old_dir
	var/obj/movement_target
	bodyparts = /decl/simple_animal_bodyparts/quadruped

//IAN! SQUEEEEEEEEE~
/mob/living/simple_animal/corgi/Ian
	name = "Ian"
	real_name = "Ian"	// Intended to hold the name without altering it.
	gender = MALE
	desc = "It's a corgi."
	turns_since_scan = 0
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"

/mob/living/simple_animal/corgi/Move(newloc, direct)
	. = ..()
	if(!.)
		return

	update_hat()

/mob/living/simple_animal/corgi/Life()
	..()
	update_hat() // In case somewhere something unpredictable happens - it'll fix it, I guess.

	// Feeding, chasing food, FOOOOODDDD
	if(!stat && !resting && !buckled)
		turns_since_scan++
		if(turns_since_scan > 5)
			turns_since_scan = 0
			if((movement_target) && !(isturf(movement_target.loc) || ishuman(movement_target.loc) ))
				movement_target = null
				stop_automated_movement = 0
			if( !movement_target || !(movement_target.loc in oview(src, 3)) )
				movement_target = null
				stop_automated_movement = 0
				for(var/obj/item/reagent_containers/food/S in oview(src,3))
					if(isturf(S.loc) || ishuman(S.loc))
						movement_target = S
						break
			if(movement_target)
				spawn(0) // Jesus fucking christ, do we still need that sleep(3) spamming abomination in Life proc?
					stop_automated_movement = 1
					step_to(src,movement_target,1)
					sleep(3)
					step_to(src,movement_target,1)
					sleep(3)
					step_to(src,movement_target,1)

					if(movement_target)		// Not redundant due to sleeps, Item can be gone in 6 decisecomds
						if (movement_target.loc.x < src.x)
							set_dir(WEST)
						else if (movement_target.loc.x > src.x)
							set_dir(EAST)
						else if (movement_target.loc.y < src.y)
							set_dir(SOUTH)
						else if (movement_target.loc.y > src.y)
							set_dir(NORTH)
						else
							set_dir(SOUTH)
						update_hat()

						if(isturf(movement_target.loc))
							UnarmedAttack(movement_target)
						else if(ishuman(movement_target.loc) && prob(20))
							visible_emote("stares at the [movement_target] that [movement_target.loc] has with sad puppy eyes.")

		if(prob(1))
			visible_emote(pick("dances around.","chases their tail."))
			spawn(0)
				for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2))
					set_dir(i)
					update_hat() // Too bad, it'll be better to optimize.
					sleep(1)


/mob/living/simple_animal/corgi/handle_regular_hud_updates()
	if(!..())
		return FALSE

	if(pullin)
		if(pulling)
			pullin.icon_state = "pull1"
		else
			pullin.icon_state = "pull0"
	if(fire)
		if(fire_alert)
			fire.icon_state = "fire[fire_alert]" // fire_alert is either 0 if no alert, 1 for heat and 2 for cold.
		else
			fire.icon_state = "fire0"
	if(oxygen)
		if(oxygen_alert)
			oxygen.icon_state = "oxy1"
		else
			oxygen.icon_state = "oxy0"

	if(toxin)
		if(toxins_alert)
			toxin.icon_state = "tox1"
		else
			toxin.icon_state = "tox0"

/obj/item/reagent_containers/food/meat/corgi
	name = "Corgi meat"
	desc = "Tastes like... well you know..."

/mob/living/simple_animal/corgi/show_inv(mob/user)
	user.set_machine(src)
	if(user.stat)
		return FALSE

	var/dat = 	"<meta charset=\"utf-8\"><div align='center'><b>Inventory of [name]</b></div><p>"
	if(hat)
		dat +=	"<br><b>Head:</b> [hat] (<a href='?src=\ref[src];remove_inv=hat'>Remove</a>)"
	else
		dat +=	"<br><b>Head:</b> <a href='?src=\ref[src];add_inv=hat'>Nothing</a>"
	show_browser(user, dat, text("window=mob[];size=325x325", name))
	onclose(user, "mob[real_name]")
	return TRUE

/mob/living/simple_animal/corgi/Topic(href, href_list)
	//Can the usr physically do this?
	if(!CanPhysicallyInteract(usr))
		return

	//Is the usr's mob type able to do this?
	if(ishuman(usr) || issmall(usr) || isrobot(usr))
		//Removing from inventory
		if(href_list["remove_inv"])
			var/remove_from = href_list["remove_inv"]
			switch(remove_from)
				if("hat")
					if(hat)
						hat.dropInto(loc)
						hat = null
						ClearOverlays()
					else
						to_chat(usr, SPAN_WARNING("There is nothing to remove from [name]"))
						return
		else if(href_list["add_inv"])
			var/add_to = href_list["add_inv"]
			if(!usr.get_active_hand())
				to_chat(usr, SPAN_WARNING("You have nothing in your hand to put on its [add_to]."))
				return
			switch(add_to)
				if("hat")
					if(hat)
						to_chat(usr, SPAN_WARNING("[name] is already wearing \the [hat]."))
						return
					else
						var/obj/item/item_to_add = usr.get_active_hand()
						if(!item_to_add)
							return
						if(!istype(item_to_add, /obj/item/clothing/head/))
							to_chat(usr, SPAN_WARNING("[name] cannot wear this!"))
							return
						if(istype(item_to_add, /obj/item/clothing/head/helmet)) // Looks too bad on corgi
							to_chat(usr, SPAN_WARNING("\The [item_to_add] is too small for [name] head."))
							return
						if(istype(item_to_add, /obj/item/clothing/head/kitty)) // Tail of kitty ears in not properly aligned
							to_chat(usr, SPAN_WARNING("[name] cannot wear \the [item_to_add]!"))
							return
						usr.drop(item_to_add)
						wear_hat(item_to_add)
						usr.visible_message(SPAN_WARNING("[usr] puts \the [item_to_add] on [name]."))



/mob/living/simple_animal/corgi/attackby(obj/item/O as obj, mob/user as mob)  // Marker -Agouri
/mob/living/simple_animal/corgi/attackby(obj/item/O, mob/user)  // Marker -Agouri
	if(user.a_intent == I_HELP && istype(O, /obj/item/clothing/head)) 	// Equiping corgi with a cool hat!
		if(istype(O, /obj/item/clothing/head/helmet)) 					// Looks too bad on corgi
			to_chat(user, SPAN_WARNING("\The [O] is too small for [name] head."))
			return
		if(istype(O, /obj/item/clothing/head/kitty)) // Tail of kitty ears in not properly aligned
			to_chat(user, SPAN_WARNING("[name] cannot wear \the [O]!"))
			return
		if(hat)
			to_chat(user, SPAN_WARNING("[name] is already wearing \the [hat]."))
			return
		user.drop(O)
		wear_hat(O)
		user.visible_message(SPAN_WARNING("[user] puts \the [O] on [name]."))
		return
	if(istype(O, /obj/item/newspaper))
		if(!stat)
			for(var/mob/M in viewers(user, null))
				if ((M.client && !( M.blinded )))
					M.show_message(SPAN_WARNING("[user] baps [name] on the nose with the rolled up [O]!"))
			spawn(0)
				for(var/i in list(1,2,4,8,4,2,1,2))
					set_dir(i)
					update_hat()
					sleep(1)
	else
		..()
///////////////////
//// HAT STUFF ////
//////////////////
/mob/living/simple_animal/corgi/proc/get_hat_icon(obj/item/hat, offset_x, offset_y)
	var/t_state = hat.icon_state
	if(hat.item_state_slots && hat.item_state_slots[slot_head_str])
		t_state = hat.item_state_slots[slot_head_str]
	else if(hat.item_state)
		t_state = hat.item_state
	var/key = "[t_state]_[offset_x]_[offset_y]"
	if(!mob_hat_cache[key])            // Not ideal as there's no guarantee all hat icon_states
		var/t_icon = default_onmob_icons[slot_head_str] // are unique across multiple dmis, but whatever.
		if(hat.icon_override)
			t_icon = hat.icon_override
		else if(hat.item_icons && (slot_head_str in hat.item_icons))
			t_icon = hat.item_icons[slot_head_str]
		var/image/I = image(icon = t_icon, icon_state = t_state)
		I.pixel_x = offset_x
		I.pixel_y = offset_y
		mob_hat_cache[key] = I
	return mob_hat_cache[key]

/mob/living/simple_animal/corgi/proc/wear_hat(obj/item/new_hat)
	if(hat)
		return
	hat = new_hat
	new_hat.forceMove(src)
	update_hat()

/mob/living/simple_animal/corgi/proc/update_hat()
	if(!hat)
		return
	if(is_ic_dead())
		ClearOverlays()
		hat.dropInto(loc)
		hat = null
		return
	if(old_dir == dir) // We do not need to update hat, if we did not change dir
		return
	old_dir = dir
	var/hat_offset_x = 1 		// preseting offsets to north and south
	var/hat_offset_y = -7
	if(dir == 4)			// Setting offset for east and west to properly render hats
		hat_offset_x = 8
		hat_offset_y = -8
	else if(dir == 8)
		hat_offset_x = -8
		hat_offset_y = -8
	ClearOverlays()
	AddOverlays(get_hat_icon(hat, hat_offset_x, hat_offset_y))
///////////////////////
// END OF HAT STUFF //
/////////////////////

/mob/living/simple_animal/corgi/puppy
	name = "\improper corgi puppy"
	real_name = "corgi"
	desc = "It's a corgi puppy."
	icon_state = "puppy"
	icon_living = "puppy"
	icon_dead = "puppy_dead"
	item_state = "puppy"

//pupplies cannot wear anything.
/mob/living/simple_animal/corgi/puppy/Topic(href, href_list)
	if(href_list["remove_inv"] || href_list["add_inv"])
		to_chat(usr, SPAN_WARNING("You can't fit this on [src]"))
		return
	..()

//LISA! SQUEEEEEEEEE~
/mob/living/simple_animal/corgi/Lisa
	name = "Lisa"
	real_name = "Lisa"
	gender = FEMALE
	desc = "It's a corgi with a cute pink bow."
	icon_state = "lisa"
	icon_living = "lisa"
	icon_dead = "lisa_dead"
	item_state = "lisa"
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"
	turns_since_scan = 0
	var/puppies = 0

//Lisa already has a cute bow!
/mob/living/simple_animal/corgi/Lisa/Topic(href, href_list)
	if(href_list["remove_inv"] || href_list["add_inv"])
		to_chat(usr, SPAN_WARNING("[src] already has a cute bow!"))
		return
	..()

/mob/living/simple_animal/corgi/Lisa/Life()
	..()

	if(!stat && !resting && !buckled)
		turns_since_scan++
		if(turns_since_scan > 15)
			turns_since_scan = 0
			var/alone = 1
			var/ian = 0
			for(var/mob/M in oviewers(7, src))
				if(istype(M, /mob/living/simple_animal/corgi/Ian))
					if(M.client)
						alone = 0
						break
					else
						ian = M
				else
					alone = 0
					break
			if(alone && ian && puppies < 4)
				if(near_camera(src) || near_camera(ian))
					return
				new /mob/living/simple_animal/corgi/puppy(loc)


		if(prob(1))
			visible_emote(pick("dances around.","chases her tail."))
			spawn(0)
				for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2))
					set_dir(i)
					sleep(1)
