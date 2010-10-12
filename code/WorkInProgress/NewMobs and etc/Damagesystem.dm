/mob/living/carbon/human/name = "human"
/mob/living/carbon/human/voice_name = "human"
/mob/living/carbon/human/icon = 'mob.dmi'
/mob/living/carbon/human/icon_state = "m-none"

/mob/living/carbon/human/random_events = list("blink")
/mob/living/carbon/human/species = "Human"
/mob/living/carbon/human/var/bloodloss = 0
/mob/living/carbon/human/var/r_hair = 0.0
/mob/living/carbon/human/var/g_hair = 0.0
/mob/living/carbon/human/var/b_hair = 0.0
/mob/living/carbon/human/var/h_style = "Short Hair"
/mob/living/carbon/human/var/r_facial = 0.0
/mob/living/carbon/human/var/g_facial = 0.0
/mob/living/carbon/human/var/b_facial = 0.0
/mob/living/carbon/human/var/f_style = "Shaved"
/mob/living/carbon/human/var/r_eyes = 0.0
/mob/living/carbon/human/var/g_eyes = 0.0
/mob/living/carbon/human/var/b_eyes = 0.0
/mob/living/carbon/human/var/s_tone = 0.0
/mob/living/carbon/human/var/age = 30.0
/mob/living/carbon/human/var/b_type = "A+"

/mob/living/carbon/human/var/obj/item/weapon/r_store = null
/mob/living/carbon/human/var/obj/item/weapon/l_store = null

/mob/living/carbon/human/var/icon/stand_icon = null
/mob/living/carbon/human/var/icon/lying_icon = null

/mob/living/carbon/human/var/last_b_state = 1.0

/mob/living/carbon/human/var/image/face_standing = null
/mob/living/carbon/human/var/image/face_lying = null

/mob/living/carbon/human/var/hair_icon_state = "hair_a"
/mob/living/carbon/human/var/face_icon_state = "bald"

/mob/living/carbon/human/var/list/body_standing = list()
/mob/living/carbon/human/var/list/body_lying = list()

/mob/living/carbon/human/var/mutantrace = null
/mob/living/carbon/human/var/bot = 0
/mob/living/carbon/human/var/zombie = 0
/mob/living/carbon/human/var/pale = 0
/mob/living/carbon/human/var/zombietime = 0
/mob/living/carbon/human/var/zombifying = 0
/mob/living/carbon/human/var/image/zombieimage = null
/mob/living/carbon/human/var/organs2 = list()
/mob/living/carbon/human/var/datum/organ/external/DEBUG_lfoot
/mob/living/carbon/human/var/datum/reagents/vessel

/mob/living/carbon/human/dummy
	real_name = "Test Dummy"
	nodamage = 1

/mob/living/carbon/human/New()
	..()
	var/datum/reagents/R = new/datum/reagents(1000)
//	random_events += "blink"
	reagents = R
	R.my_atom = src

	if (!dna)
		dna = new /datum/dna( null )
	var/datum/organ/external/chest/chest = new /datum/organ/external/chest( src )
	chest.owner = src
	var/datum/organ/external/groin/groin = new /datum/organ/external/groin( src )
	groin.owner = src
	var/datum/organ/external/head/head = new /datum/organ/external/head( src )
	head.owner = src
	var/datum/organ/external/l_arm/l_arm = new /datum/organ/external/l_arm( src )
	l_arm.owner = src
	var/datum/organ/external/r_arm/r_arm = new /datum/organ/external/r_arm( src )
	r_arm.owner = src
	var/datum/organ/external/l_hand/l_hand = new /datum/organ/external/l_hand( src )
	l_hand.owner = src
	l_hand.parent = l_arm
	var/datum/organ/external/r_hand/r_hand = new /datum/organ/external/r_hand( src )
	r_hand.owner = src
	r_hand.parent = r_arm
	var/datum/organ/external/l_leg/l_leg = new /datum/organ/external/l_leg( src )
	l_leg.owner = src
	var/datum/organ/external/r_leg/r_leg = new /datum/organ/external/r_leg( src )
	r_leg.owner = src
	var/datum/organ/external/l_foot/l_foot = new /datum/organ/external/l_foot( src )
	l_foot.owner = src
	l_foot.parent = l_leg
	var/datum/organ/external/r_foot/r_foot = new /datum/organ/external/r_foot( src )
	r_foot.owner = src
	r_foot.parent = r_leg
	//blood
	organs["chest"] += chest
	organs["groin"] += groin
	organs["head"] += head
	organs["l_arm"] += l_arm
	organs["r_arm"] += r_arm
	organs["l_hand"] += l_hand
	organs["r_hand"] += r_hand
	organs["l_leg"] += l_leg
	organs["r_leg"] += r_leg
	organs["l_foot"] += l_foot
	organs["r_foot"] += r_foot

	organs2 += chest
	organs2 += groin
	organs2 += head
	organs2 += l_arm
	organs2 += r_arm
	organs2 += l_hand
	organs2 += r_hand
	organs2 += l_leg
	organs2 += r_leg
	organs2 += l_foot
	organs2 += r_foot
	DEBUG_lfoot = l_foot

	var/g = "m"
	if (gender == MALE)
		g = "m"
	else if (gender == FEMALE)
		g = "f"
	else
		gender = MALE
		g = "m"

	if(!stand_icon)
		stand_icon = new /icon('human.dmi', "body_[g]_s")
	if(!lying_icon)
		lying_icon = new /icon('human.dmi', "body_[g]_l")
	icon = stand_icon

	src << "\blue Your icons have been generated!"
	vessel = new/datum/reagents(560)
	vessel.my_atom = src
	vessel.add_reagent("blood",560)
	update_clothing()
	spawn(1) fixblood()
/mob/living/carbon/human/proc/fixblood()
	for(var/datum/reagent/blood/B in vessel.reagent_list)
		if(B.id == "blood")
			B.blood_type = src.b_type
			B.blood_DNA = src.dna.unique_enzymes
/mob/living/carbon/human/Bump(atom/movable/AM as mob|obj, yes)
	if ((!( yes ) || now_pushing))
		return
	now_pushing = 1
	if (ismob(AM))
		var/mob/tmob = AM
		if(tmob.a_intent == "help" && a_intent == "help" && tmob.canmove && canmove) // mutual brohugs all around!
			var/turf/oldloc = loc
			loc = tmob.loc
			tmob.loc = oldloc
			now_pushing = 0
			return
		if(istype(equipped(), /obj/item/weapon/baton)) // add any other item paths you think are necessary
			if(loc:ul_Luminosity() < 3 || blinded)
				var/obj/item/weapon/baton/W = equipped()
				if (world.time > lastDblClick+2)
					lastDblClick = world.time
					if(((prob(40)) || (prob(95) && mutations & 16)) && W.status)
						src << "\red You accidentally stun yourself with the [W.name]."
						weakened = max(12, weakened)
						playsound(loc, 'Egloves.ogg', 50, 1, -1)
						W:charges--
					else if(W.status)
						for(var/mob/M in viewers(src, null))
							if(M.client)
								M << "\red <B>[src] accidentally bumps into [tmob] with the [W.name]."
						tmob.weakened = max(4, tmob.weakened)
						tmob.stunned = max(4, tmob.stunned)
						playsound(loc, 'Egloves.ogg', 50, 1, -1)
						W:charges--
					now_pushing = 0
					return
		if(istype(tmob, /mob/living/carbon/human) && tmob.mutations & 32)
			if(prob(40) && !(mutations & 32))
				for(var/mob/M in viewers(src, null))
					if(M.client)
						M << "\red <B>[src] fails to push [tmob]'s fat ass out of the way.</B>"
				now_pushing = 0
				return
	now_pushing = 0
	spawn(0)
		..()
		if (!istype(AM, /atom/movable))
			return
		if (!now_pushing)
			now_pushing = 1
			if (!AM.anchored)
				var/t = get_dir(src, AM)
				step(AM, t)
			now_pushing = null
		return
	return

/mob/living/carbon/human/movement_delay()
	var/tally = 1.3

	if(zombie)
		return 4

	if(reagents.has_reagent("hyperzine")) return -1

	var/health_deficiency = (health_full - health)
	if(health_deficiency >= 40) tally += (health_deficiency / 25)


	for(var/organ in list("l_leg","l_foot","r_leg","r_foot"))
		var/datum/organ/external/o = organs["[organ]"]
		if(o.broken)
			tally += 6

	if(wear_suit)
		switch(wear_suit.type)
			if(/obj/item/clothing/suit/straight_jacket)
				tally += 15
			if(/obj/item/clothing/suit/fire)	//	firesuits slow you down a bit
				tally += 1.3
			if(/obj/item/clothing/suit/fire/heavy)	//	firesuits slow you down a bit
				tally += 1.7
			if(/obj/item/clothing/suit/space)
				if(!istype(loc, /turf/space))		//	space suits slow you down a bit unless in space
					tally += 3

	if (istype(shoes, /obj/item/clothing/shoes))
		if (shoes.chained)
			tally += 15
		else
			tally += -1.0
	if(mutations & 32)
		tally += 1.5
	if (bodytemperature < 283.222)
		tally += (283.222 - bodytemperature) / 10 * 1.25

	return tally

/mob/living/carbon/human/Stat()
	..()
	if(ticker.mode.name == "AI malfunction")
		if(ticker.mode:malf_mode_declared)
			stat(null, "Time left: [ ticker.mode:AI_win_timeleft]")
//	if(main_shuttle.online && main_shuttle.location < 2)
//		var/timeleft = LaunchControl.timeleft()
//		if (timeleft)
//			stat(null, "ETA-[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]")

	if (client.statpanel == "Status")
		if (internal)
			if (!internal.air_contents)
				del(internal)
			else
				stat("Internal Atmosphere Info", internal.name)
				stat("Tank Pressure", internal.air_contents.return_pressure())
				stat("Distribution Pressure", internal.distribute_pressure)


/mob/living/carbon/human/bullet_act(flag, A as obj)
	var/shielded = 0
	for(var/obj/item/device/shield/S in src)
		if (S.active)
			if (flag == "bullet")
				return
			shielded = 1
			S.active = 0
			S.icon_state = "shield0"
	for(var/obj/item/weapon/cloaking_device/S in src)
		if (S.active)
			shielded = 1
			S.active = 0
			S.icon_state = "shield0"
	if ((shielded && flag != "bullet"))
		if (!flag)
			src << "\blue Your shield was disturbed by a laser!"
			if(paralysis <= 120)	paralysis = 120
			updatehealth()
	if (locate(/obj/item/weapon/grab, src))
		var/mob/safe = null
		if (istype(l_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = l_hand
			if ((G.state == 3 && get_dir(src, A) == dir))
				safe = G.affecting
		if (istype(r_hand, /obj/item/weapon/grab))
			var/obj/item/weapon.grab/G = r_hand
			if ((G.state == 3 && get_dir(src, A) == dir))
				safe = G.affecting
		if (safe)
			return safe.bullet_act(flag, A)
	if (flag == PROJECTILE_BULLET)
		var/d = 51
		if (istype(wear_suit, /obj/item/clothing/suit/armor))
			if (prob(70))
				show_message("\red Your armor absorbs the hit!", 4)
				return
			else
				if (prob(40))
					show_message("\red Your armor only softens the hit!", 4)
					if (prob(20))
						d = d / 2
					d = d / 4
		else
			if (istype(wear_suit, /obj/item/clothing/suit/swat_suit))
				if (prob(90))
					show_message("\red Your armor absorbs the blow!", 4)
					return
				else
					if (prob(90))
						show_message("\red Your armor only softens the blow!", 4)
						if (prob(60))
							d = d / 2
						d = d / 5
		if (stat != 2)
			var/organ = organs[ran_zone("chest")]
			if (istype(organ, /datum/organ/external))
				var/datum/organ/external/temp = organ
				if(temp.destoryed)
					return
				temp.take_damage(d, 0)
			UpdateDamageIcon()
			updatehealth()
			if (prob(50))
				if(weakened <= 5)	weakened = 5
		return
	else if (flag == PROJECTILE_TASER)
		if (istype(wear_suit, /obj/item/clothing/suit/armor))
			if (prob(5))
				show_message("\red Your armor absorbs the hit!", 4)
				return
		else
			if (istype(wear_suit, /obj/item/clothing/suit/swat_suit))
				if (prob(70))
					show_message("\red Your armor absorbs the hit!", 4)
					return
		if (prob(75) && stunned <= 10)
			stunned = 10
		else
			weakened = 10
		if (stuttering < 10)
			stuttering = 10
	else if(flag == PROJECTILE_LASER)
		var/d = 20
		if (istype(wear_suit, /obj/item/clothing/suit/armor))
			if (prob(40))
				show_message("\red Your armor absorbs the hit!", 4)
				return
			else
				if (prob(40))
					show_message("\red Your armor only softens the hit!", 4)
					if (prob(20))
						d = d / 2
					d = d / 2
		else
			if (istype(wear_suit, /obj/item/clothing/suit/swat_suit))
				if (prob(70))
					show_message("\red Your armor absorbs the blow!", 4)
					return
				else
					if (prob(90))
						show_message("\red Your armor only softens the blow!", 4)
						if (prob(60))
							d = d / 2
						d = d / 2

		if (!eye_blurry) eye_blurry = 4 //This stuff makes no sense but lasers need a buff.
		if (prob(25)) stunned++

		if (stat != 2)
			var/organ = organs[ran_zone("chest")]
			if (istype(organ, /datum/organ/external))
				var/datum/organ/external/temp = organ
				if(temp.destoryed)
					return
				temp.take_damage(d, 0)
			UpdateDamageIcon()
			updatehealth()
			if (prob(25))
				stunned = 1
	else if(flag == PROJECTILE_PULSE)
		var/d = 40
		if (istype(wear_suit, /obj/item/clothing/suit/armor))
			if (prob(20))
				show_message("\red Your armor absorbs the hit!", 4)
				return
			else
				if (prob(20))
					show_message("\red Your armor only softens the hit!", 4)
					if (prob(20))
						d = d / 2
					d = d / 2
		else
			if (istype(wear_suit, /obj/item/clothing/suit/swat_suit))
				if (prob(50))
					show_message("\red Your armor absorbs the blow!", 4)
					return
				else
					if (prob(50))
						show_message("\red Your armor only softens the blow!", 4)
						if (prob(50))
							d = d / 2
						d = d / 2
		if (stat != 2)
			var/organ = organs[ran_zone("chest")]
			if (istype(organ, /datum/organ/external))
				var/datum/organ/external/temp = organ
				if(temp.destoryed)
					return
				temp.take_damage(d, 0)
			UpdateDamageIcon()
			updatehealth()
			if (prob(50))
				stunned = min(stunned, 5)
	else if(flag == PROJECTILE_BOLT)
		toxloss += 3
		radiation += 100
		updatehealth()
		stuttering += 5
		drowsyness += 5
	return

/mob/living/carbon/human/ex_act(severity)
	flick("flash", flash)

	if (stat == 2 && client)
		gib(1)
		return

	else if (stat == 2 && !client)
		gibs(loc, virus)
		del(src)
		return

	var/shielded = 0
	for(var/obj/item/device/shield/S in src)
		if (S.active)
			shielded = 1
			break

	var/b_loss = null
	var/f_loss = null
	switch (severity)
		if (1.0)
			b_loss += 500
			gib(1)
			return

		if (2.0)
			if (!shielded)
				b_loss += 60

			f_loss += 60

			if (!istype(ears, /obj/item/clothing/ears/earmuffs))
				ear_damage += 30
				ear_deaf += 120

		if(3.0)
			b_loss += 30
			if (prob(50) && !shielded)
				paralysis += 10
			if (!istype(ears, /obj/item/clothing/ears/earmuffs))
				ear_damage += 15
				ear_deaf += 60

	for(var/organ in organs)
		var/datum/organ/external/temp = organs[text("[]", organ)]
		if (istype(temp, /datum/organ/external))
			switch(temp.name)
				if("head")
					temp.take_damage(b_loss * 0.2, f_loss * 0.2)
				if("chest")
					temp.take_damage(b_loss * 0.4, f_loss * 0.4)
				if("groin")
					temp.take_damage(b_loss * 0.1, f_loss * 0.1)
				if("l_arm")
					temp.take_damage(b_loss * 0.05, f_loss * 0.05)
				if("r_arm")
					temp.take_damage(b_loss * 0.05, f_loss * 0.05)
				if("l_hand")
					temp.take_damage(b_loss * 0.0225, f_loss * 0.0225)
				if("r_hand")
					temp.take_damage(b_loss * 0.0225, f_loss * 0.0225)
				if("l_leg")
					temp.take_damage(b_loss * 0.05, f_loss * 0.05)
				if("r_leg")
					temp.take_damage(b_loss * 0.05, f_loss * 0.05)
				if("l_foot")
					temp.take_damage(b_loss * 0.0225, f_loss * 0.0225)
				if("r_foot")
					temp.take_damage(b_loss * 0.0225, f_loss * 0.0225)

	UpdateDamageIcon()

/mob/living/carbon/human/blob_act()
	if (stat == 2)
		return
	var/shielded = 0
	for(var/obj/item/device/shield/S in src)
		if (S.active)
			shielded = 1
	var/damage = null
	if (stat != 2)
		damage = rand(1,20)

	if(shielded)
		damage /= 4

		//paralysis += 1

	show_message("\red The blob attacks you!")
	var/list/zones = list()
	for(var/datum/organ/external/part in organs2)
		if(!part.destoryed)
			zones += part.name
	var/zone = pick(zones)
	if(!zone)
		return
	var/datum/organ/external/temp = organs["[zone]"]
	if(temp.destoryed)
		return
	switch(zone)
		if ("head")
			if ((((head && head.body_parts_covered & HEAD) || (wear_mask && wear_mask.body_parts_covered & HEAD)) && prob(99)))
				if (prob(20))
					temp.take_damage(damage, 0)
				else
					show_message("\red You have been protected from a hit to the head.")
				return
			if (damage > 4.9)
				if (weakened < 10)
					weakened = rand(10, 15)
				for(var/mob/O in viewers(src, null))
					O.show_message(text("\red <B>The blob has weakened []!</B>", src), 1, "\red You hear someone fall.", 2)
			temp.take_damage(damage)
		if ("chest")
			if ((((wear_suit && wear_suit.body_parts_covered & UPPER_TORSO) || (w_uniform && w_uniform.body_parts_covered & UPPER_TORSO)) && prob(85)))
				show_message("\red You have been protected from a hit to the chest.")
				return
			if (damage > 4.9)
				if (prob(50))
					if (weakened < 5)
						weakened = 5
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>The blob has knocked down []!</B>", src), 1, "\red You hear someone fall.", 2)
				else
					if (stunned < 5)
						stunned = 5
					for(var/mob/O in viewers(src, null))
						if(O.client)	O.show_message(text("\red <B>The blob has stunned []!</B>", src), 1)
				if(stat != 2)	stat = 1
			temp.take_damage(damage)
		if ("groin")
			if ((((wear_suit && wear_suit.body_parts_covered & LOWER_TORSO) || (w_uniform && w_uniform.body_parts_covered & LOWER_TORSO)) && prob(75)))
				show_message("\red You have been protected from a hit to the lower chest.")
				return
			else
				temp.take_damage(damage, 0)


		if("l_arm")
			temp.take_damage(damage, 0)
		if("r_arm")
			temp.take_damage(damage, 0)
		if("l_hand")
			temp.take_damage(damage, 0)
		if("r_hand")
			temp.take_damage(damage, 0)
		if("l_leg")
			temp.take_damage(damage, 0)
		if("r_leg")
			temp.take_damage(damage, 0)
		if("l_foot")
			temp.take_damage(damage, 0)
		if("r_foot")
			temp.take_damage(damage, 0)

	UpdateDamageIcon()
	return

/mob/living/carbon/human/u_equip(obj/item/W as obj)
	if (W == wear_suit)
		wear_suit = null
	else if (W == w_uniform)
		W = r_store
		if (W)
			u_equip(W)
			if (client)
				client.screen -= W
			if (W)
				W.loc = loc
				W.dropped(src)
				W.layer = initial(W.layer)
		W = l_store
		if (W)
			u_equip(W)
			if (client)
				client.screen -= W
			if (W)
				W.loc = loc
				W.dropped(src)
				W.layer = initial(W.layer)
		W = wear_id
		if (W)
			u_equip(W)
			if (client)
				client.screen -= W
			if (W)
				W.loc = loc
				W.dropped(src)
				W.layer = initial(W.layer)
		W = belt
		if (W)
			u_equip(W)
			if (client)
				client.screen -= W
			if (W)
				W.loc = loc
				W.dropped(src)
				W.layer = initial(W.layer)
		w_uniform = null
	else if (W == gloves)
		gloves = null
	else if (W == glasses)
		glasses = null
	else if (W == head)
		head = null
	else if (W == ears)
		ears = null
	else if (W == shoes)
		shoes = null
	else if (W == belt)
		belt = null
	else if (W == wear_mask)
		if(internal)
			if (internals)
				internals.icon_state = "internal0"
			internal = null
		wear_mask = null
	else if (W == wear_id)
		wear_id = null
	else if (W == r_store)
		r_store = null
	else if (W == l_store)
		l_store = null
	else if (W == back)
		back = null
	else if (W == handcuffed)
		handcuffed = null
	else if (W == r_hand)
		r_hand = null

	else if (W == l_hand)
		l_hand = null

	update_clothing()

/mob/living/carbon/human/db_click(text, t1)
	var/obj/item/W = equipped()
	var/emptyHand = (W == null)
	if ((!emptyHand) && (!istype(W, /obj/item)))
		return
	if (emptyHand)
		usr.next_move = usr.prev_move
		usr:lastDblClick -= 3	//permit the double-click redirection to proceed.
	switch(text)
		if("mask")
			if (wear_mask)
				if (emptyHand)
					wear_mask.DblClick()
				return
			if (!( istype(W, /obj/item/clothing/mask) ))
				return
			u_equip(W)
			wear_mask = W
			W.equipped(src, text)
		if("back")
			if (back)
				if (emptyHand)
					back.DblClick()
				return
			if (!istype(W, /obj/item))
				return
			if (!( W.flags & ONBACK ))
				return
			u_equip(W)
			back = W
			W.equipped(src, text)

/*		if("headset")
			if (ears)
				if (emptyHand)
					ears.DblClick()
				return
			if (!( istype(W, /obj/item/device/radio/headset) ))
				return
			u_equip(W)
			w_radio = W
			W.equipped(src, text) */
		if("o_clothing")
			if (wear_suit)
				if (emptyHand)
					wear_suit.DblClick()
				return
			if (!( istype(W, /obj/item/clothing/suit) ))
				return
			if (mutations & 32 && !(W.flags & ONESIZEFITSALL))
				src << "\red You're too fat to wear the [W.name]!"
				return
			u_equip(W)
			wear_suit = W
			W.equipped(src, text)
		if("gloves")
			if (gloves)
				if (emptyHand)
					gloves.DblClick()
				return
			if (!( istype(W, /obj/item/clothing/gloves) ))
				return
			u_equip(W)
			gloves = W
			W.equipped(src, text)
		if("shoes")
			if (shoes)
				if (emptyHand)
					shoes.DblClick()
				return
			if (!( istype(W, /obj/item/clothing/shoes) ))
				return
			u_equip(W)
			shoes = W
			W.equipped(src, text)
		if("belt")
			if (belt)
				if (emptyHand)
					belt.DblClick()
				return
			if (!W || !W.flags || !( W.flags & ONBELT ))
				return
			u_equip(W)
			belt = W
			W.equipped(src, text)
		if("eyes")
			if (glasses)
				if (emptyHand)
					glasses.DblClick()
				return
			if (!( istype(W, /obj/item/clothing/glasses) ))
				return
			u_equip(W)
			glasses = W
			W.equipped(src, text)
		if("head")
			if (head)
				if (emptyHand)
					head.DblClick()
				return
			if (( istype(W, /obj/item/weapon/paper) ))
				u_equip(W)
				head = W
			else if (!( istype(W, /obj/item/clothing/head) ))
				return
			u_equip(W)
			head = W
			W.equipped(src, text)
		if("ears")
			if (ears)
				if (emptyHand)
					ears.DblClick()
				return
			if (!( istype(W, /obj/item/clothing/ears) ) && !( istype(W, /obj/item/device/radio/headset) ))
				return
			u_equip(W)
			ears = W
			W.equipped(src, text)
		if("i_clothing")
			if (w_uniform)
				if (emptyHand)
					w_uniform.DblClick()
				return
			if (!( istype(W, /obj/item/clothing/under) ))
				return
			if (mutations & 32 && !(W.flags & ONESIZEFITSALL))
				src << "\red You're too fat to wear the [W.name]!"
				return
			u_equip(W)
			w_uniform = W
			W.equipped(src, text)
		if("id")
			if (wear_id)
				if (emptyHand)
					wear_id.DblClick()
				return
			if (!w_uniform)
				return
			if (!( istype(W, /obj/item/weapon/card/id) ))
				return
			u_equip(W)
			wear_id = W
			W.equipped(src, text)
		if("storage1")
			if (l_store)
				if (emptyHand)
					l_store.DblClick()
				return
			if ((!( istype(W, /obj/item) ) || W.w_class > 2 || !( w_uniform )))
				return
			u_equip(W)
			l_store = W
		if("storage2")
			if (r_store)
				if (emptyHand)
					r_store.DblClick()
				return
			if ((!( istype(W, /obj/item) ) || W.w_class > 2 || !( w_uniform )))
				return
			u_equip(W)
			r_store = W

	update_clothing()

	return

/mob/living/carbon/human/meteorhit(O as obj)
	for(var/mob/M in viewers(src, null))
		if ((M.client && !( M.blinded )))
			M.show_message(text("\red [] has been hit by []", src, O), 1)
	if (health > 0)
		var/dam_zone = pick("chest", "chest", "chest", "head", "groin")
		if (istype(organs[dam_zone], /datum/organ/external))
			var/datum/organ/external/temp = organs[dam_zone]
			if(temp.destoryed)
				return
			temp.take_damage((istype(O, /obj/meteor/small) ? 10 : 25), 30)
			UpdateDamageIcon()
		updatehealth()
	return

/mob/living/carbon/human/update_clothing()
	..()

	if (monkeyizing)
		return

	overlays = null

	// lol
	var/fat = ""
	if (mutations & 32)
		fat = "fat"

	if (mutations & 8)
		overlays += image("icon" = 'genetics.dmi', "icon_state" = "hulk[fat][!lying ? "_s" : "_l"]")

	if (mutations & 2)
		overlays += image("icon" = 'genetics.dmi', "icon_state" = "fire[fat][!lying ? "_s" : "_l"]")

	if (mutations & 1)
		overlays += image("icon" = 'genetics.dmi', "icon_state" = "telekinesishead[fat][!lying ? "_s" : "_l"]")

	if (mutantrace)
		overlays += image("icon" = 'genetics.dmi', "icon_state" = "[mutantrace][fat][!lying ? "_s" : "_l"]")
		if(face_standing)
			del(face_standing)
		if(face_lying)
			del(face_lying)
		if(stand_icon)
			del(stand_icon)
		if(lying_icon)
			del(lying_icon)
	else
		if(!face_standing || !face_lying)
			update_face()
		if(!stand_icon || !lying_icon)
			update_body()

	if(buckled)
		if(istype(buckled, /obj/stool/bed))
			lying = 1
		else
			lying = 0

	// Automatically drop anything in store / id / belt if you're not wearing a uniform.
	if (!w_uniform)
		for (var/obj/item/thing in list(r_store, l_store, wear_id, belt))
			if (thing)
				u_equip(thing)
				if (client)
					client.screen -= thing

				if (thing)
					thing.loc = loc
					thing.dropped(src)
					thing.layer = initial(thing.layer)


	//if (zone_sel)
	//	zone_sel.overlays = null
	//	zone_sel.overlays += body_standing
	//	zone_sel.overlays += image("icon" = 'zone_sel.dmi', "icon_state" = text("[]", zone_sel.selecting))

	if (lying)
		icon = lying_icon

		overlays += body_lying

		if (face_lying)
			overlays += face_lying
	else
		icon = stand_icon

		overlays += body_standing

		if (face_standing)
			overlays += face_standing

	// Uniform
	if (w_uniform)
		if (mutations & 32 && !(w_uniform.flags & ONESIZEFITSALL))
			src << "\red You burst out of the [w_uniform.name]!"
			var/obj/item/clothing/c = w_uniform
			u_equip(c)
			if(client)
				client.screen -= c
			if(c)
				c:loc = loc
				c:dropped(src)
				c:layer = initial(c:layer)
		w_uniform.screen_loc = ui_iclothing
		if (istype(w_uniform, /obj/item/clothing/under))
			var/t1 = w_uniform.color
			if (!t1)
				t1 = icon_state
			if (mutations & 32)
				overlays += image("icon" = 'uniform_fat.dmi', "icon_state" = "[t1][!lying ? "_s" : "_l"]", "layer" = MOB_LAYER)
			else
				if(!lying)
					var/datum/organ/external/rhand = organs["r_hand"]
					var/datum/organ/external/lhand = organs["l_hand"]
					var/iconx = text("[][][][]",t1, (!(lying) ? "_s" : "_l"),(rhand.destoryed ? "_rhand" : null),(lhand.destoryed ? "_lhand" : null))
					overlays += image('uniform.dmi',"[iconx]",MOB_LAYER)
				else
					var/iconx = "[t1]_l"
					overlays += image('uniform.dmi',"[iconx]",MOB_LAYER)
			if (w_uniform.blood_DNA)
				var/icon/stain_icon = icon('blood.dmi', "uniformblood[!lying ? "" : "2"]")
				overlays += image("icon" = stain_icon, "layer" = MOB_LAYER)

	if (wear_id)
		overlays += image("icon" = 'mob.dmi', "icon_state" = "id[!lying ? null : "2"]", "layer" = MOB_LAYER)

	if (client)
		client.screen -= hud_used.intents
		client.screen -= hud_used.mov_int


	//Screenlocs for these slots are handled by the huds other_update()
	//because theyre located on the 'other' inventory bar.

	// Gloves
	if (gloves)
		var/datum/organ/external/rhand = organs["r_hand"]
		var/datum/organ/external/lhand = organs["l_hand"]
		var/t1 = gloves.item_state
		if (!t1)
			t1 = gloves.icon_state
		if(!lying)
			if(!rhand.destoryed)
				overlays += image('hands.dmi',"[t1]_rhand",MOB_LAYER)
			if(!lhand.destoryed)
				overlays += image('hands.dmi',"[t1]_lhand",MOB_LAYER)
		else
			if(!rhand.destoryed)
				overlays += image('hands.dmi',"[t1]2_rhand",MOB_LAYER)
			if(!lhand.destoryed)
				overlays += image('hands.dmi',"[t1]2_lhand",MOB_LAYER)
		if (gloves.blood_DNA)
			var/icon/stain_icon = icon('blood.dmi', "bloodyhands[!lying ? "" : "2"]")
			overlays += image("icon" = stain_icon, "layer" = MOB_LAYER)
	else if (blood_DNA)
		var/icon/stain_icon = icon('blood.dmi', "bloodyhands[!lying ? "" : "2"]")
		overlays += image("icon" = stain_icon, "layer" = MOB_LAYER)
	// Glasses
	if (glasses)
		var/t1 = glasses.icon_state
		overlays += image("icon" = 'eyes.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = MOB_LAYER)
	// Ears
	if (ears)
		var/t1 = ears.icon_state
		overlays += image("icon" = 'ears.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = MOB_LAYER)
	// Shoes
	if (shoes)
		var/t1 = shoes.icon_state
		overlays += image("icon" = 'feet.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = MOB_LAYER)
		if (shoes.blood_DNA)
			var/icon/stain_icon = icon('blood.dmi', "shoesblood[!lying ? "" : "2"]")
			overlays += image("icon" = stain_icon, "layer" = MOB_LAYER)	// Radio
/*	if (w_radio)
		overlays += image("icon" = 'ears.dmi', "icon_state" = "headset[!lying ? "" : "2"]", "layer" = MOB_LAYER) */

	if(client) hud_used.other_update() //Update the screenloc of the items on the 'other' inventory bar
											   //to hide / show them.

	if (wear_mask)
		if (istype(wear_mask, /obj/item/clothing/mask))
			var/t1 = wear_mask.icon_state
			overlays += image("icon" = 'mask.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = MOB_LAYER)
			if (!istype(wear_mask, /obj/item/clothing/mask/cigarette))
				if (wear_mask.blood_DNA)
					var/icon/stain_icon = icon('blood.dmi', "maskblood[!lying ? "" : "2"]")
					overlays += image("icon" = stain_icon, "layer" = MOB_LAYER)
			wear_mask.screen_loc = ui_mask


	if (client)
		if (i_select)
			if (intent)
				client.screen += hud_used.intents

				var/list/L = dd_text2list(intent, ",")
				L[1] += ":-11"
				i_select.screen_loc = dd_list2text(L,",") //ICONS4, FUCKING SHIT
			else
				i_select.screen_loc = null
		if (m_select)
			if (m_int)
				client.screen += hud_used.mov_int

				var/list/L = dd_text2list(m_int, ",")
				L[1] += ":-11"
				m_select.screen_loc = dd_list2text(L,",") //ICONS4, FUCKING SHIT
			else
				m_select.screen_loc = null


	if (wear_suit)
		if (mutations & 32 && !(wear_suit.flags & ONESIZEFITSALL))
			src << "\red You burst out of the [wear_suit.name]!"
			var/obj/item/clothing/c = wear_suit
			u_equip(c)
			if(client)
				client.screen -= c
			if(c)
				c:loc = loc
				c:dropped(src)
				c:layer = initial(c:layer)
		if (istype(wear_suit, /obj/item/clothing/suit))
			var/t1 = wear_suit.icon_state
			overlays += image("icon" = 'suit.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = MOB_LAYER)
		if (wear_suit.blood_DNA)
			var/icon/stain_icon = null
			if (istype(wear_suit, /obj/item/clothing/suit/armor/vest || /obj/item/clothing/suit/wcoat || /obj/item/clothing/suit/armor/a_i_a_ptank))
				stain_icon = icon('blood.dmi', "armorblood[!lying ? "" : "2"]")
			else if (istype(wear_suit, /obj/item/clothing/suit/det_suit || /obj/item/clothing/suit/labcoat))
				stain_icon = icon('blood.dmi', "coatblood[!lying ? "" : "2"]")
			else
				stain_icon = icon('blood.dmi', "suitblood[!lying ? "" : "2"]")
			overlays += image("icon" = stain_icon, "layer" = MOB_LAYER)
		wear_suit.screen_loc = ui_oclothing
		if (istype(wear_suit, /obj/item/clothing/suit/straight_jacket))
			if (handcuffed)
				handcuffed.loc = loc
				handcuffed.layer = initial(handcuffed.layer)
				handcuffed = null
			if ((l_hand || r_hand))
				var/h = hand
				hand = 1
				drop_item()
				hand = 0
				drop_item()
				hand = h

	// Head
	if (head)
		var/t1 = head.icon_state
		var/icon/head_icon = icon('head.dmi', text("[][]", t1, (!( lying ) ? null : "2")))
		overlays += image("icon" = head_icon, "layer" = MOB_LAYER)
		if (head.blood_DNA)
			var/icon/stain_icon = icon('blood.dmi', "helmetblood[!lying ? "" : "2"]")
			overlays += image("icon" = stain_icon, "layer" = MOB_LAYER)
		head.screen_loc = ui_head

	// Belt
	if (belt)
		var/t1 = belt.item_state
		if (!t1)
			t1 = belt.icon_state
		overlays += image("icon" = 'belt.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = MOB_LAYER)
		belt.screen_loc = ui_belt

	if ((wear_mask && !(wear_mask.see_face)) || (head && !(head.see_face))) // can't see the face
		if (wear_id && wear_id.registered)
			name = wear_id.registered
		else
			name = "Unknown"
	else
		if (wear_id && wear_id.registered != real_name)
			name = "[real_name] (as [wear_id.registered])"
		else
			name = real_name

	if (wear_id)
		wear_id.screen_loc = ui_id

	if (l_store)
		l_store.screen_loc = ui_storage1

	if (r_store)
		r_store.screen_loc = ui_storage2

	if (back)
		var/t1 = back.icon_state
		overlays += image("icon" = 'back.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = MOB_LAYER)
		back.screen_loc = ui_back

	if (handcuffed)
		pulling = null
		if (!lying)
			overlays += image("icon" = 'mob.dmi', "icon_state" = "handcuff1", "layer" = MOB_LAYER)
		else
			overlays += image("icon" = 'mob.dmi', "icon_state" = "handcuff2", "layer" = MOB_LAYER)

	if (client)
		client.screen -= contents
		client.screen += contents

	if (r_hand)
		overlays += image("icon" = 'items_righthand.dmi', "icon_state" = r_hand.item_state ? r_hand.item_state : r_hand.icon_state, "layer" = MOB_LAYER+1)
		r_hand.screen_loc = ui_rhand
	if (l_hand)
		overlays += image("icon" = 'items_lefthand.dmi', "icon_state" = l_hand.item_state ? l_hand.item_state : l_hand.icon_state, "layer" = MOB_LAYER+1)
		l_hand.screen_loc = ui_lhand



	var/shielded = 0
	for (var/obj/item/device/shield/S in src)
		if (S.active)
			shielded = 1
			break

	for (var/obj/item/weapon/cloaking_device/S in src)
		if (S.active)
			shielded = 2
			break

	if(client && client.admin_invis)
		invisibility = 100
	else if (shielded == 2)
		invisibility = 2
	else
		invisibility = 0

	if (shielded)
		overlays += image("icon" = 'mob.dmi', "icon_state" = "shield", "layer" = MOB_LAYER)

	for (var/mob/M in viewers(1, src))
		if ((M.client && M.machine == src))
			spawn (0)
				show_inv(M)
				return

	last_b_state = stat

/mob/living/carbon/human/hand_p(mob/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (M.a_intent == "hurt")
		if (istype(M.wear_mask, /obj/item/clothing/mask/muzzle))
			return
		if (health > 0)
			if (istype(wear_suit, /obj/item/clothing/suit/space))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			else if (istype(wear_suit, /obj/item/clothing/suit/space/santa))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			else if (istype(wear_suit, /obj/item/clothing/suit/bio_suit))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			else if (istype(wear_suit, /obj/item/clothing/suit/armor))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			else if (istype(wear_suit, /obj/item/clothing/suit/swat_suit))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			else
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[M.name] has bit []!</B>", src), 1)
				var/damage = rand(1, 3)
				for(var/datum/organ/external/p in organs2)
					if(!p.destoryed)
						zones += p.name
				if(!zones)
					return
				var/dam_zone = pick(zones)
				if (istype(organs[text("[]", dam_zone)], /datum/organ/external))
					var/datum/organ/external/temp = organs[text("[]", dam_zone)]
					if (temp.take_damage(damage, 0))
						UpdateDamageIcon()
					else
						UpdateDamage()
				updatehealth()
				if(istype(M.virus, /datum/disease/jungle_fever))
					monkeyize()
	return

/mob/living/carbon/human/attack_paw(mob/M as mob)
	if (M.a_intent == "help")
		sleeping = 0
		resting = 0
		if (paralysis >= 3) paralysis -= 3
		if (stunned >= 3) stunned -= 3
		if (weakened >= 3) weakened -= 3
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\blue The monkey shakes [] trying to wake him up!", src), 1)
	else
		if (istype(wear_mask, /obj/item/clothing/mask/muzzle))
			return
		if (health > 0)
			if (istype(wear_suit, /obj/item/clothing/suit/space))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			else if (istype(wear_suit, /obj/item/clothing/suit/space/santa))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			else if (istype(wear_suit, /obj/item/clothing/suit/bio_suit))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			else if (istype(wear_suit, /obj/item/clothing/suit/armor))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			else if (istype(wear_suit, /obj/item/clothing/suit/swat_suit))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			else
				for(var/mob/O in viewers(src, null))
					O.show_message(text("\red <B>[M.name] has bit []!</B>", src), 1)
				var/damage = rand(1, 3)
				for(var/datum/organ/external/p in organs2)
					if(!p.destoryed)
						zones += p.name
				if(!zones)
					return
				var/dam_zone = pick(zones)
				if (istype(organs[text("[]", dam_zone)], /datum/organ/external))
					var/datum/organ/external/temp = organs[text("[]", dam_zone)]
					if (temp.take_damage(damage, 0))
						UpdateDamageIcon()
					else
						UpdateDamage()
				updatehealth()
				if(istype(M.virus, /datum/disease/jungle_fever))
					monkeyize()
	return

/mob/living/carbon/human/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (istype(loc, /turf) && istype(loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return

	if (M.a_intent == "help")
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\blue [M] caresses [src] with its sythe like arm."), 1)
	else
		//This will be changed to skin, where we can skin a dead human corpse
		if (M.a_intent == "grab")
			if (M == src)
				return
			if (w_uniform)
				w_uniform.add_fingerprint(M)
			var/obj/item/weapon/grab/G = new /obj/item/weapon/grab( M )
			G.assailant = M
			if (M.hand)
				M.l_hand = G
			else
				M.r_hand = G
			G.layer = 20
			G.affecting = src
			grabbed_by += G
			G.synch()
			playsound(loc, 'thudswoosh.ogg', 50, 1, -1)
			for(var/mob/O in viewers(src, null))
				O.show_message(text("\red [] has grabbed [] passively!", M, src), 1)
		else
			if (M.a_intent == "hurt")
				if (w_uniform)
					w_uniform.add_fingerprint(M)
				var/damage = rand(10, 20)
				var/datum/organ/external/affecting = organs["chest"]
				var/t = M.zone_sel.selecting
				if ((t in list( "eyes", "mouth" )))
					t = "head"
				var/def_zone = ran_zone(t)
				if (organs[def_zone])
					affecting = organs[def_zone]
				if ((istype(affecting, /datum/organ/external) && prob(90)))
					playsound(loc, "punch", 25, 1, -1)
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[] has slashed at []!</B>", M, src), 1)
					if (def_zone == "head")
						if ((((head && head.body_parts_covered & HEAD) || (wear_mask && wear_mask.body_parts_covered & HEAD)) && prob(99)))
							if (prob(20))
								affecting.take_damage(damage, 0)
							else
								show_message("\red You have been protected from a hit to the head.")
							return
						if (damage > 4.9)
							if (weakened < 10)
								weakened = rand(10, 15)
							for(var/mob/O in viewers(M, null))
								O.show_message(text("\red <B>[] has weakened []!</B>", M, src), 1, "\red You hear someone fall.", 2)
						affecting.take_damage(damage)
					else
						if (def_zone == "chest")
							if ((((wear_suit && wear_suit.body_parts_covered & UPPER_TORSO) || (w_uniform && w_uniform.body_parts_covered & LOWER_TORSO)) && prob(85)))
								show_message("\red You have been protected from a hit to the chest.")
								return
							if (damage > 4.9)
								if (prob(50))
									if (weakened < 5)
										weakened = 5
									playsound(loc, 'thudswoosh.ogg', 50, 1, -1)
									for(var/mob/O in viewers(src, null))
										O.show_message(text("\red <B>[] has knocked down []!</B>", M, src), 1, "\red You hear someone fall.", 2)
								else
									if (stunned < 5)
										stunned = 5
									for(var/mob/O in viewers(src, null))
										O.show_message(text("\red <B>[] has stunned []!</B>", M, src), 1)
								if(stat != 2)	stat = 1
							affecting.take_damage(damage)
						else
							if (def_zone == "groin")
								if ((((wear_suit && wear_suit.body_parts_covered & LOWER_TORSO) || (w_uniform && w_uniform.body_parts_covered & LOWER_TORSO)) && prob(75)))
									show_message("\red You have been protected from a hit to the lower chest.")
									return
								if (damage > 4.9)
									if (prob(50))
										if (weakened < 3)
											weakened = 3
										for(var/mob/O in viewers(src, null))
											O.show_message(text("\red <B>[] has knocked down []!</B>", M, src), 1, "\red You hear someone fall.", 2)
									else
										if (stunned < 3)
											stunned = 3
										for(var/mob/O in viewers(src, null))
											O.show_message(text("\red <B>[] has stunned []!</B>", M, src), 1)
									if(stat != 2)	stat = 1
								affecting.take_damage(damage)
							else
								affecting.take_damage(damage)

					UpdateDamageIcon()

					updatehealth()
				else
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M] has lunged at [src] but missed!</B>"), 1)
					return
			else
			//disarm
				if (!( lying ))
					if (w_uniform)
						w_uniform.add_fingerprint(M)
					var/randn = rand(1, 100)
					if (randn <= 25)
						weakened = 2
						for(var/mob/O in viewers(src, null))
							O.show_message(text("\red <B>[] has knocked over []!</B>", M, src), 1)
					else
						if (randn <= 60)
							drop_item()
							for(var/mob/O in viewers(src, null))
								O.show_message(text("\red <B>[] has knocked the item out of []'s hand!</B>", M, src), 1)
						else
							for(var/mob/O in viewers(src, null))
								O.show_message(text("\red <B>[] has tried to knock the item out of []'s hand!</B>", M, src), 1)
	return

/mob/living/carbon/human/attack_hand(mob/living/carbon/human/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (istype(loc, /turf) && istype(loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return

	if ((M.gloves && M.gloves.elecgen == 1 && M.a_intent == "hurt") /*&& (!istype(src:wear_suit, /obj/item/clothing/suit/judgerobe))*/)
		if(M.gloves.uses > 0)
			M.gloves.uses--
			if (weakened < 5)
				weakened = 5
			if (stuttering < 5)
				stuttering = 5
			if (stunned < 5)
				stunned = 5
			for(var/mob/O in viewers(src, null))
				if (O.client)
					O.show_message("\red <B>[src] has been touched with the stun gloves by [M]!</B>", 1, "\red You hear someone fall", 2)
		else
			M.gloves.elecgen = 0
			M << "\red Not enough charge! "
			return

	if (M.a_intent == "help")
		if (M.zombie)
			return
		if (health > 0)
			if (w_uniform)
				w_uniform.add_fingerprint(M)
			sleeping = 0
			resting = 0
			if (paralysis >= 3) paralysis -= 3
			if (stunned >= 3) stunned -= 3
			if (weakened >= 3) weakened -= 3
			playsound(loc, 'thudswoosh.ogg', 50, 1, -1)
			for(var/mob/O in viewers(src, null))
				O.show_message(text("\blue [] shakes [] trying to wake [] up!", M, src, src), 1)
		else
			if (M.health >= -75.0)
				if (((M.head && M.head.flags & 4) || ((M.wear_mask && !( M.wear_mask.flags & 32 )) || ((head && head.flags & 4) || (wear_mask && !( wear_mask.flags & 32 ))))))
					M << "\blue <B>Remove that mask!</B>"
					return
				var/obj/equip_e/human/O = new /obj/equip_e/human(  )
				O.source = M
				O.target = src
				O.s_loc = M.loc
				O.t_loc = loc
				O.place = "CPR"
				requests += O
				spawn( 0 )
					O.process()
					return
	else
		if (M.a_intent == "grab")
			if (M == src)
				return
			if (M.zombie)
				return
			if (w_uniform)
				w_uniform.add_fingerprint(M)
			var/obj/item/weapon/grab/G = new /obj/item/weapon/grab( M )
			G.assailant = M
			if (M.hand)
				M.l_hand = G
			else
				M.r_hand = G
			G.layer = 20
			G.affecting = src
			grabbed_by += G
			G.synch()
			playsound(loc, 'thudswoosh.ogg', 50, 1, -1)
			for(var/mob/O in viewers(src, null))
				O.show_message(text("\red [] has grabbed [] passively!", M, src), 1)
		else
			if (M.a_intent == "hurt" && !(M.gloves && M.gloves.elecgen == 1))
				if (w_uniform)
					w_uniform.add_fingerprint(M)
				var/damage = rand(1, 9)
				var/datum/organ/external/affecting = organs["chest"]
				var/t
				if(M.zombie)
					var/def_zone = ran_zone(t)
					if(organs["[def_zone]"])
						affecting = organs["[def_zone]"]
					if (!affecting.destoryed)
						//Attack with zombie
						if(!zombie && !zombifying && prob(60))
							for(var/mob/O in viewers(src, null))
								O.show_message(text("\red <B>[] has bit []!</B>", M, src), 1)
								affecting.take_damage(5,0)
							if(prob(50))
								zombifying = 1
								zombietime = rand(50,200)
								UpdateZombieIcons()
						else
							var/mes = pick(list("clawed","scraped"))
							for(var/mob/O in viewers(src, null))
								O.show_message(text("\red <B>[M] has [mes] [src]!"),1)
							affecting.take_damage(rand(1,7),0)
					else
						for(var/mob/O in viewers(src, null))
							O.show_message(text("\red <B>[] has misses []!</B>", M, src), 1)
						return
					UpdateDamageIcon()
					updatehealth()
					return
				t = M.zone_sel.selecting
				if ((t in list( "eyes", "mouth" )))
					t = "head"
				var/def_zone = ran_zone(t)
				if (organs["[def_zone]"])
					affecting = organs["[def_zone]"]
				if ((istype(affecting, /datum/organ/external) && prob(90) && !affecting.destoryed))
					if (M.mutations & 8)
						damage += 5
						spawn(0)
							paralysis += 1
							step_away(src,M,15)
							sleep(3)
							step_away(src,M,15)
					playsound(loc, "punch", 25, 1, -1)
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[] has punched []!</B>", M, src), 1)

					if (def_zone == "head")
						if ((((head && head.body_parts_covered & HEAD) || (wear_mask && wear_mask.body_parts_covered & HEAD)) && prob(99)))
							if (prob(20))
								affecting.take_damage(damage, 0)
							else
								show_message("\red You have been protected from a hit to the head.")
							return
						if (damage > 4.9)
							if (weakened < 10)
								weakened = rand(10, 15)
							for(var/mob/O in viewers(M, null))
								O.show_message(text("\red <B>[] has weakened []!</B>", M, src), 1, "\red You hear someone fall.", 2)
						affecting.take_damage(damage)
					else
						if (def_zone == "chest")
							if ((((wear_suit && wear_suit.body_parts_covered & UPPER_TORSO) || (w_uniform && w_uniform.body_parts_covered & LOWER_TORSO)) && prob(85)))
								show_message("\red You have been protected from a hit to the chest.")
								return
							if (damage > 4.9)
								if (prob(50))
									if (weakened < 5)
										weakened = 5
									playsound(loc, 'thudswoosh.ogg', 50, 1, -1)
									for(var/mob/O in viewers(src, null))
										O.show_message(text("\red <B>[] has knocked down []!</B>", M, src), 1, "\red You hear someone fall.", 2)
								else
									if (stunned < 5)
										stunned = 5
									for(var/mob/O in viewers(src, null))
										O.show_message(text("\red <B>[] has stunned []!</B>", M, src), 1)
								if(stat != 2)	stat = 1
							affecting.take_damage(damage)
						else
							if (def_zone == "groin")
								if ((((wear_suit && wear_suit.body_parts_covered & LOWER_TORSO) || (w_uniform && w_uniform.body_parts_covered & LOWER_TORSO)) && prob(75)))
									show_message("\red You have been protected from a hit to the lower chest.")
									return
								if (damage > 4.9)
									if (prob(50))
										if (weakened < 3)
											weakened = 3
										for(var/mob/O in viewers(src, null))
											O.show_message(text("\red <B>[] has knocked down []!</B>", M, src), 1, "\red You hear someone fall.", 2)
									else
										if (stunned < 3)
											stunned = 3
										for(var/mob/O in viewers(src, null))
											O.show_message(text("\red <B>[] has stunned []!</B>", M, src), 1)
									if(stat != 2)	stat = 1
								affecting.take_damage(damage)
							else
								affecting.take_damage(damage)

					UpdateDamageIcon()

					updatehealth()
				else
					playsound(loc, 'punchmiss.ogg', 25, 1, -1)
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[] has attempted to punch []!</B>", M, src), 1)
					return
			else
				if (!( lying ) && !(M.gloves && M.gloves.elecgen == 1))
					if (w_uniform)
						w_uniform.add_fingerprint(M)
					var/randn = rand(1, 100)
					if (randn <= 25)
						weakened = 2
						playsound(loc, 'thudswoosh.ogg', 50, 1, -1)
						for(var/mob/O in viewers(src, null))
							O.show_message(text("\red <B>[] has pushed down []!</B>", M, src), 1)
					else
						if (randn <= 60)
							drop_item()
							playsound(loc, 'thudswoosh.ogg', 50, 1, -1)
							for(var/mob/O in viewers(src, null))
								O.show_message(text("\red <B>[] has disarmed []!</B>", M, src), 1)
						else
							playsound(loc, 'punchmiss.ogg', 25, 1, -1)
							for(var/mob/O in viewers(src, null))
								O.show_message(text("\red <B>[] has attempted to disarm []!</B>", M, src), 1)
	return

/mob/living/carbon/human/restrained()
	if (handcuffed)
		return 1
	if (istype(wear_suit, /obj/item/clothing/suit/straight_jacket))
		return 1
	return 0

/mob/living/carbon/human/proc/update_body()
	if(stand_icon)
		del(stand_icon)
	if(lying_icon)
		del(lying_icon)

	if (mutantrace)
		return

	var/g = "m"
	if (gender == MALE)
		g = "m"
	else if (gender == FEMALE)
		g = "f"

	stand_icon = new /icon('human.dmi', "blank")
	lying_icon = new /icon('human.dmi', "blank")

	var/husk = (mutations & 64)
	var/obese = (mutations & 32)
	if (husk)
		stand_icon.Blend(new /icon('human.dmi', "husk_s"), ICON_OVERLAY)
		lying_icon.Blend(new /icon('human.dmi', "husk_l"), ICON_OVERLAY)
	for(var/datum/organ/external/part in organs2)
		if(istype(part,/datum/organ/external/groin))
			stand_icon.Blend(new /icon('human.dmi', "groin_[g]_s"), ICON_OVERLAY)
			lying_icon.Blend(new /icon('human.dmi', "groin_[g]_l"), ICON_OVERLAY)
			continue
		if(istype(part,/datum/organ/external/chest))
			stand_icon.Blend(new /icon('human.dmi', "chest_[g]_s"), ICON_OVERLAY)
			lying_icon.Blend(new /icon('human.dmi', "chest_[g]_l"), ICON_OVERLAY)
			continue
		if (underwear > 0)
			if(!obese)
				stand_icon.Blend(new /icon('human.dmi', "underwear[underwear]_[g]_s"), ICON_OVERLAY)
				lying_icon.Blend(new /icon('human.dmi', "underwear[underwear]_[g]_l"), ICON_OVERLAY)
		if(!part.destoryed)
			stand_icon.Blend(new /icon('human.dmi', "[part.icon_name]_s"), ICON_OVERLAY)
			lying_icon.Blend(new /icon('human.dmi', "[part.icon_name]_l"), ICON_OVERLAY)



	// Skin tone
	if (s_tone >= 0)
		stand_icon.Blend(rgb(s_tone, s_tone, s_tone), ICON_ADD)
		lying_icon.Blend(rgb(s_tone, s_tone, s_tone), ICON_ADD)
	else
		stand_icon.Blend(rgb(-s_tone,  -s_tone,  -s_tone), ICON_SUBTRACT)
		lying_icon.Blend(rgb(-s_tone,  -s_tone,  -s_tone), ICON_SUBTRACT)
	if(zombie)
		stand_icon.Blend(rgb(100,100,100))
		lying_icon.Blend(rgb(100,100,100))
	if(pale)
		stand_icon.Blend(rgb(100,100,100))
		lying_icon.Blend(rgb(100,100,100))

/mob/living/carbon/human/proc/update_face()
	if(organs)
		var/datum/organ/external/org = organs["head"]
		if(org)
			if(org.destoryed)
				del(face_standing)
				del(face_lying)
				return
	del(face_standing)
	del(face_lying)

	if (mutantrace)
		return

	var/g = "m"
	if (gender == MALE)
		g = "m"
	else if (gender == FEMALE)
		g = "f"

	var/icon/eyes_s = new/icon("icon" = 'human_face.dmi', "icon_state" = "eyes_s")
	var/icon/eyes_l = new/icon("icon" = 'human_face.dmi', "icon_state" = "eyes_l")
	eyes_s.Blend(rgb(r_eyes, g_eyes, b_eyes), ICON_ADD)
	eyes_l.Blend(rgb(r_eyes, g_eyes, b_eyes), ICON_ADD)

	var/icon/hair_s = new/icon("icon" = 'human_face.dmi', "icon_state" = "[hair_icon_state]_s")
	var/icon/hair_l = new/icon("icon" = 'human_face.dmi', "icon_state" = "[hair_icon_state]_l")
	hair_s.Blend(rgb(r_hair, g_hair, b_hair), ICON_ADD)
	hair_l.Blend(rgb(r_hair, g_hair, b_hair), ICON_ADD)

	var/icon/facial_s = new/icon("icon" = 'human_face.dmi', "icon_state" = "[face_icon_state]_s")
	var/icon/facial_l = new/icon("icon" = 'human_face.dmi', "icon_state" = "[face_icon_state]_l")
	facial_s.Blend(rgb(r_facial, g_facial, b_facial), ICON_ADD)
	facial_l.Blend(rgb(r_facial, g_facial, b_facial), ICON_ADD)

	var/icon/mouth_s = new/icon("icon" = 'human_face.dmi', "icon_state" = "mouth_[g]_s")
	var/icon/mouth_l = new/icon("icon" = 'human_face.dmi', "icon_state" = "mouth_[g]_l")

	eyes_s.Blend(hair_s, ICON_OVERLAY)
	eyes_l.Blend(hair_l, ICON_OVERLAY)
	eyes_s.Blend(mouth_s, ICON_OVERLAY)
	eyes_l.Blend(mouth_l, ICON_OVERLAY)
	eyes_s.Blend(facial_s, ICON_OVERLAY)
	eyes_l.Blend(facial_l, ICON_OVERLAY)

	face_standing = new /image()
	face_lying = new /image()
	face_standing.icon = eyes_s
	face_lying.icon = eyes_l

	del(mouth_l)
	del(mouth_s)
	del(facial_l)
	del(facial_s)
	del(hair_l)
	del(hair_s)
	del(eyes_l)
	del(eyes_s)

/obj/equip_e/human/process()
	if (item)
		item.add_fingerprint(source)
	if (!item)
		switch(place)
			if("mask")
				if (!( target.wear_mask ))
					//SN src = null
					del(src)
					return
/*			if("headset")
				if (!( target.w_radio ))
					//SN src = null
					del(src)
					return */
			if("l_hand")
				if (!( target.l_hand ))
					//SN src = null
					del(src)
					return
			if("r_hand")
				if (!( target.r_hand ))
					//SN src = null
					del(src)
					return
			if("suit")
				if (!( target.wear_suit ))
					//SN src = null
					del(src)
					return
			if("uniform")
				if (!( target.w_uniform ))
					//SN src = null
					del(src)
					return
			if("back")
				if (!( target.back ))
					//SN src = null
					del(src)
					return
			if("syringe")
				return
			if("pill")
				return
			if("fuel")
				return
			if("drink")
				return
			if("dnainjector")
				return
			if("handcuff")
				if (!( target.handcuffed ))
					//SN src = null
					del(src)
					return
			if("id")
				if ((!( target.wear_id ) || !( target.w_uniform )))
					//SN src = null
					del(src)
					return
			if("internal")
				if ((!( (istype(target.wear_mask, /obj/item/clothing/mask) && istype(target.back, /obj/item/weapon/tank) && !( target.internal )) ) && !( target.internal )))
					//SN src = null
					del(src)
					return

	var/list/L = list( "syringe", "pill", "drink", "dnainjector", "fuel")
	if ((item && !( L.Find(place) )))
		for(var/mob/O in viewers(target, null))
			O.show_message(text("\red <B>[] is trying to put \a [] on []</B>", source, item, target), 1)
	else
		if (place == "syringe")
			for(var/mob/O in viewers(target, null))
				O.show_message(text("\red <B>[] is trying to inject []!</B>", source, target), 1)
		else
			if (place == "pill")
				for(var/mob/O in viewers(target, null))
					O.show_message(text("\red <B>[] is trying to force [] to swallow []!</B>", source, target, item), 1)
			else
				if(place == "fuel")
					for(var/mob/O in viewers(target, null))
						O.show_message(text("\red [source] is trying to force [target] to eat the [item:content]!"), 1)
				else
					if (place == "drink")
						for(var/mob/O in viewers(target, null))
							O.show_message(text("\red <B>[] is trying to force [] to swallow a gulp of []!</B>", source, target, item), 1)
					else
						if (place == "dnainjector")
							for(var/mob/O in viewers(target, null))
								O.show_message(text("\red <B>[] is trying to inject [] with the []!</B>", source, target, item), 1)
						else
							var/message = null
							switch(place)
								if("mask")
									message = text("\red <B>[] is trying to take off \a [] from []'s head!</B>", source, target.wear_mask, target)
/*								if("headset")
									message = text("\red <B>[] is trying to take off \a [] from []'s face!</B>", source, target.w_radio, target) */
								if("l_hand")
									message = text("\red <B>[] is trying to take off \a [] from []'s left hand!</B>", source, target.l_hand, target)
								if("r_hand")
									message = text("\red <B>[] is trying to take off \a [] from []'s right hand!</B>", source, target.r_hand, target)
								if("gloves")
									message = text("\red <B>[] is trying to take off the [] from []'s hands!</B>", source, target.gloves, target)
								if("eyes")
									message = text("\red <B>[] is trying to take off the [] from []'s eyes!</B>", source, target.glasses, target)
								if("ears")
									message = text("\red <B>[] is trying to take off the [] from []'s ears!</B>", source, target.ears, target)
								if("head")
									message = text("\red <B>[] is trying to take off the [] from []'s head!</B>", source, target.head, target)
								if("shoes")
									message = text("\red <B>[] is trying to take off the [] from []'s feet!</B>", source, target.shoes, target)
								if("belt")
									message = text("\red <B>[] is trying to take off the [] from []'s belt!</B>", source, target.belt, target)
								if("suit")
									message = text("\red <B>[] is trying to take off \a [] from []'s body!</B>", source, target.wear_suit, target)
								if("back")
									message = text("\red <B>[] is trying to take off \a [] from []'s back!</B>", source, target.back, target)
								if("handcuff")
									message = text("\red <B>[] is trying to unhandcuff []!</B>", source, target)
								if("uniform")
									message = text("\red <B>[] is trying to take off \a [] from []'s body!</B>", source, target.w_uniform, target)
								if("pockets")
									for(var/obj/item/weapon/mousetrap/MT in  list(target.l_store, target.r_store))
										if(MT.armed)
											for(var/mob/O in viewers(target, null))
												if(O == source)
													O.show_message(text("\red <B>You reach into the [target]'s pockets, but there was a live mousetrap in there!</B>"), 1)
												else
													O.show_message(text("\red <B>[source] reaches into [target]'s pockets and sets off a hidden mousetrap!</B>"), 1)
											target.u_equip(MT)
											if (target.client)
												target.client.screen -= MT
											MT.loc = source.loc
											MT.triggered(source, source.hand ? "l_hand" : "r_hand")
											MT.layer = OBJ_LAYER
											return
									message = text("\red <B>[] is trying to empty []'s pockets!!</B>", source, target)
								if("CPR")
									if (target.cpr_time >= world.time + 3)
										//SN src = null
										del(src)
										return
									message = text("\red <B>[] is trying perform CPR on []!</B>", source, target)
								if("id")
									message = text("\red <B>[] is trying to take off [] from []'s uniform!</B>", source, target.wear_id, target)
								if("internal")
									if (target.internal)
										message = text("\red <B>[] is trying to remove []'s internals</B>", source, target)
									else
										message = text("\red <B>[] is trying to set on []'s internals.</B>", source, target)
								else
							for(var/mob/M in viewers(target, null))
								M.show_message(message, 1)
	spawn( 40 )
		done()
		return
	return

/obj/equip_e/human/done()
	if(!source || !target)						return
	if(source.loc != s_loc)						return
	if(target.loc != t_loc)						return
	if(LinkBlocked(s_loc,t_loc))				return
	if(item && source.equipped() != item)	return
	if ((source.restrained() || source.stat))	return
	switch(place)
		if("mask")
			if (target.wear_mask)
				var/obj/item/W = target.wear_mask
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
				W.add_fingerprint(source)
			else
				if (istype(item, /obj/item/clothing/mask))
					source.drop_item()
					loc = target
					item.layer = 20
					target.wear_mask = item
					item.loc = target
/*		if("headset")
			if (target.w_radio)
				var/obj/item/W = target.w_radio
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
			else
				if (istype(item, /obj/item/device/radio/headset))
					source.drop_item()
					loc = target
					item.layer = 20
					target.w_radio = item
					item.loc = target*/
		if("gloves")
			if (target.gloves)
				var/obj/item/W = target.gloves
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
				W.add_fingerprint(source)
			else
				if (istype(item, /obj/item/clothing/gloves))
					source.drop_item()
					loc = target
					item.layer = 20
					target.gloves = item
					item.loc = target
		if("eyes")
			if (target.glasses)
				var/obj/item/W = target.glasses
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
				W.add_fingerprint(source)
			else
				if (istype(item, /obj/item/clothing/glasses))
					source.drop_item()
					loc = target
					item.layer = 20
					target.glasses = item
					item.loc = target
		if("belt")
			if (target.belt)
				var/obj/item/W = target.belt
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
				W.add_fingerprint(source)
			else
				if ((istype(item, /obj) && item.flags & 128 && target.w_uniform))
					source.drop_item()
					loc = target
					item.layer = 20
					target.belt = item
					item.loc = target
		if("head")
			if (target.head)
				var/obj/item/W = target.head
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
				W.add_fingerprint(source)
			else
				if (istype(item, /obj/item/clothing/head))
					source.drop_item()
					loc = target
					item.layer = 20
					target.head = item
					item.loc = target
		if("ears")
			if (target.ears)
				var/obj/item/W = target.ears
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
				W.add_fingerprint(source)
			else
				if (istype(item, /obj/item/clothing/ears))
					source.drop_item()
					loc = target
					item.layer = 20
					target.ears = item
					item.loc = target
				else if (istype(item, /obj/item/device/radio/headset))
					source.drop_item()
					loc = target
					item.layer = 20
					target.ears = item
					item.loc = target
		if("shoes")
			if (target.shoes)
				var/obj/item/W = target.shoes
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
				W.add_fingerprint(source)
			else
				if (istype(item, /obj/item/clothing/shoes))
					source.drop_item()
					loc = target
					item.layer = 20
					target.shoes = item
					item.loc = target
		if("l_hand")
			if (istype(target, /obj/item/clothing/suit/straight_jacket))
				//SN src = null
				del(src)
				return
			if (target.l_hand)
				var/obj/item/W = target.l_hand
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
				W.add_fingerprint(source)
			else
				if (istype(item, /obj/item))
					source.drop_item()
					loc = target
					item.layer = 20
					target.l_hand = item
					item.loc = target
					item.add_fingerprint(target)
		if("r_hand")
			if (istype(target, /obj/item/clothing/suit/straight_jacket))
				//SN src = null
				del(src)
				return
			if (target.r_hand)
				var/obj/item/W = target.r_hand
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
				W.add_fingerprint(source)
			else
				if (istype(item, /obj/item))
					source.drop_item()
					loc = target
					item.layer = 20
					target.r_hand = item
					item.loc = target
					item.add_fingerprint(target)
		if("uniform")
			if (target.w_uniform)
				var/obj/item/W = target.w_uniform
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
				W.add_fingerprint(source)
				W = target.l_store
				if (W)
					target.u_equip(W)
					if (target.client)
						target.client.screen -= W
					if (W)
						W.loc = target.loc
						W.dropped(target)
						W.layer = initial(W.layer)
				W = target.r_store
				if (W)
					target.u_equip(W)
					if (target.client)
						target.client.screen -= W
					if (W)
						W.loc = target.loc
						W.dropped(target)
						W.layer = initial(W.layer)
				W = target.wear_id
				if (W)
					target.u_equip(W)
					if (target.client)
						target.client.screen -= W
					if (W)
						W.loc = target.loc
						W.dropped(target)
						W.layer = initial(W.layer)
			else
				if (istype(item, /obj/item/clothing/under))
					source.drop_item()
					loc = target
					item.layer = 20
					target.w_uniform = item
					item.loc = target
		if("suit")
			if (target.wear_suit)
				var/obj/item/W = target.wear_suit
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
				W.add_fingerprint(source)
			else
				if (istype(item, /obj/item/clothing/suit))
					source.drop_item()
					loc = target
					item.layer = 20
					target.wear_suit = item
					item.loc = target
		if("id")
			if (target.wear_id)
				var/obj/item/W = target.wear_id
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
				W.add_fingerprint(source)
			else
				if ((istype(item, /obj/item/weapon/card/id) && target.w_uniform))
					source.drop_item()
					loc = target
					item.layer = 20
					target.wear_id = item
					item.loc = target
		if("back")
			if (target.back)
				var/obj/item/W = target.back
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
				W.add_fingerprint(source)
			else
				if ((istype(item, /obj/item) && item.flags & 1))
					source.drop_item()
					loc = target
					item.layer = 20
					target.back = item
					item.loc = target
		if("handcuff")
			if (target.handcuffed)
				var/obj/item/W = target.handcuffed
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
				W.add_fingerprint(source)
			else
				if (istype(item, /obj/item/weapon/handcuffs))
					target.drop_from_slot(target.r_hand)
					target.drop_from_slot(target.l_hand)
					source.drop_item()
					target.handcuffed = item
					item.loc = target
		if("CPR")
			if (target.cpr_time >= world.time + 30)
				//SN src = null
				del(src)
				return
			if ((target.health >= -75.0 && target.health < 0))
				target.cpr_time = world.time
				if (target.health >= -40.0)
					var/suff = min(target.oxyloss, 5)
					target.oxyloss -= suff
					target.updatehealth()
				if(target.reagents.get_reagent_amount("inaprovaline") < 10)
					target.reagents.add_reagent("inaprovaline", 10)
				for(var/mob/O in viewers(source, null))
					O.show_message(text("\red [] performs CPR on []!", source, target), 1)
				source << "\red Repeat every 7 seconds AT LEAST."
		if("fuel")
			var/obj/item/weapon/fuel/S = item
			if (!( istype(S, /obj/item/weapon/fuel) ))
				//SN src = null
				del(src)
				return
			if (S.s_time >= world.time + 30)
				//SN src = null
				del(src)
				return
			S.s_time = world.time
			var/a = S.content
			for(var/mob/O in viewers(source, null))
				O.show_message(text("\red [source] forced [target] to eat the [a]!"), 1)
			S.injest(target)
		if("dnainjector")
			if (item)
				var/obj/item/weapon/dnainjector/S = item
				item.add_fingerprint(source)
				item:inject(target, null)
				if (!( istype(S, /obj/item/weapon/dnainjector) ))
					//SN src = null
					del(src)
					return
				if (S.s_time >= world.time + 30)
					//SN src = null
					del(src)
					return
				S.s_time = world.time
				for(var/mob/O in viewers(source, null))
					O.show_message(text("\red [] injects [] with the DNA Injector!", source, target), 1)
		if("pockets")
			if (target.l_store)
				var/obj/item/W = target.l_store
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
				W.add_fingerprint(source)
			if (target.r_store)
				var/obj/item/W = target.r_store
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
				W.add_fingerprint(source)
		if("internal")
			if (target.internal)
				target.internal.add_fingerprint(source)
				target.internal = null
			else
				if (target.internal)
					target.internal = null
				if (!( istype(target.wear_mask, /obj/item/clothing/mask) ))
					return
				else
					if (istype(target.back, /obj/item/weapon/tank))
						target.internal = target.back
						for(var/mob/M in viewers(target, 1))
							M.show_message(text("[] is now running on internals.", target), 1)
						target.internal.add_fingerprint(source)
		else
	if(source)
		source.update_clothing()
	if(target)
		target.update_clothing()
	//SN src = null
	del(src)
	return

/mob/living/carbon/human/proc/HealDamage(zone, brute, burn)

	var/datum/organ/external/E = organs[text("[]", zone)]
	if (istype(E, /datum/organ/external))
		if(E.destoryed)
			return
		if (E.heal_damage(brute, burn))
			UpdateDamageIcon()
		else
			UpdateDamage()
	else
		return 0
	return
/mob/living/carbon/human/verb/eat(var/text as text)
	set src in view(5)
	for(var/datum/organ/external/l in organs2)
		if(l.name == text)
			l.destoryed = 1
			break
	update_body()
// new damage icon system
// now constructs damage icon for each organ from mask * damage field

/mob/living/carbon/human/UpdateDamageIcon()
	var/list/L = list(  )
	for (var/t in organs)
		if (istype(organs[t], /datum/organ/external))
			L += organs[t]

	del(body_standing)
	body_standing = list()
	del(body_lying)
	body_lying = list()

	bruteloss = 0
	fireloss = 0

	for (var/datum/organ/external/O in L)
		if(!O.destoryed)
			O.update_icon()
			bruteloss += O.brute_dam
			fireloss += O.burn_dam

			var/icon/DI = new /icon('dam_human.dmi', O.damage_state)			// the damage icon for whole human
			DI.Blend(new /icon('dam_mask.dmi', O.icon_name), ICON_MULTIPLY)		// mask with this organ's pixels

//		world << "[O.icon_name] [O.damage_state] \icon[DI]"

			body_standing += DI

			DI = new /icon('dam_human.dmi', "[O.damage_state]-2")				// repeat for lying icons
			DI.Blend(new /icon('dam_mask.dmi', "[O.icon_name]2"), ICON_MULTIPLY)

//		world << "[O.r_name]2 [O.d_i_state]-2 \icon[DI]"

			body_lying += DI

		//body_standing += new /icon( 'dam_zones.dmi', text("[]", O.d_i_state) )
		//body_lying += new /icon( 'dam_zones.dmi', text("[]2", O.d_i_state) )

/mob/living/carbon/human/show_inv(mob/user as mob)

	user.machine = src
	var/dat = {"
	<B><HR><FONT size=3>[name]</FONT></B>
	<BR><HR>
	<BR><B>Head(Mask):</B> <A href='?src=\ref[src];item=mask'>[(wear_mask ? wear_mask : "Nothing")]</A>
	<BR><B>Left Hand:</B> <A href='?src=\ref[src];item=l_hand'>[(l_hand ? l_hand  : "Nothing")]</A>
	<BR><B>Right Hand:</B> <A href='?src=\ref[src];item=r_hand'>[(r_hand ? r_hand : "Nothing")]</A>
	<BR><B>Gloves:</B> <A href='?src=\ref[src];item=gloves'>[(gloves ? gloves : "Nothing")]</A>
	<BR><B>Eyes:</B> <A href='?src=\ref[src];item=eyes'>[(glasses ? glasses : "Nothing")]</A>
	<BR><B>Ears:</B> <A href='?src=\ref[src];item=ears'>[(ears ? ears : "Nothing")]</A>
	<BR><B>Head:</B> <A href='?src=\ref[src];item=head'>[(head ? head : "Nothing")]</A>
	<BR><B>Shoes:</B> <A href='?src=\ref[src];item=shoes'>[(shoes ? shoes : "Nothing")]</A>
	<BR><B>Belt:</B> <A href='?src=\ref[src];item=belt'>[(belt ? belt : "Nothing")]</A> [((istype(wear_mask, /obj/item/clothing/mask) && istype(belt, /obj/item/weapon/tank) && !( internal )) ? text(" <A href='?src=\ref[];item=internal'>Set Internal</A>", src) : "")]
	<BR><B>Uniform:</B> <A href='?src=\ref[src];item=uniform'>[(w_uniform ? w_uniform : "Nothing")]</A>
	<BR><B>(Exo)Suit:</B> <A href='?src=\ref[src];item=suit'>[(wear_suit ? wear_suit : "Nothing")]</A>
	<BR><B>Back:</B> <A href='?src=\ref[src];item=back'>[(back ? back : "Nothing")]</A> [((istype(wear_mask, /obj/item/clothing/mask) && istype(back, /obj/item/weapon/tank) && !( internal )) ? text(" <A href='?src=\ref[];item=internal'>Set Internal</A>", src) : "")]
	<BR><B>ID:</B> <A href='?src=\ref[src];item=id'>[(wear_id ? wear_id : "Nothing")]</A>
	<BR>[(handcuffed ? text("<A href='?src=\ref[src];item=handcuff'>Handcuffed</A>") : text("<A href='?src=\ref[src];item=handcuff'>Not Handcuffed</A>"))]
	<BR>[(internal ? text("<A href='?src=\ref[src];item=internal'>Remove Internal</A>") : "")]
	<BR><A href='?src=\ref[src];item=pockets'>Empty Pockets</A>
	<BR><A href='?src=\ref[user];mach_close=mob[name]'>Close</A>
	<BR>"}
	user << browse(dat, text("window=mob[name];size=340x480"))
	onclose(user, "mob[name]")
	return


/mob/living/carbon/human/verb/fuck()
	set hidden = 1
	alert("Go play HellMOO if you wanna do that.")


// called when something steps onto a human
// this could be made more general, but for now just handle mulebot
/mob/living/carbon/human/HasEntered(var/atom/movable/AM)
	var/obj/machinery/bot/mulebot/MB = AM
	if(istype(MB))
		MB.RunOver(src)

/mob/living/carbon/human/proc/zombify()
	zombietime = 0
	zombifying = 0
	zombie = 1
	update_body()
	src << "\red You've become a zombie"
	if(l_hand)
		if (client)
			client.screen -= l_hand
		if (l_hand)
			l_hand.loc = loc
			l_hand.dropped(src)
			l_hand.layer = initial(r_hand.layer)
			l_hand = null
	if(r_hand)
		if (client)
			client.screen -= r_hand
		if (r_hand)
			r_hand.loc = loc
			r_hand.dropped(src)
			r_hand.layer = initial(r_hand.layer)
			r_hand = null
	sight |= SEE_MOBS
	see_in_dark = 4
	see_invisible = 2
	for(var/mob/O in viewers(src, null))
		O.show_message(text("\red <B>[src] seizes up and falls limp, \his eyes dead and lifeless...</B>"), 1)
	UpdateZombieIcons()


/proc/UpdateZombieIcons()
	spawn(0)
		for(var/mob/living/carbon/human/H in world)
			del(H.zombieimage)
			if(H.zombie)
				H.zombieimage = image('mob.dmi', loc = H, icon_state = "rev")
			else if(H.zombifying)
				H.zombieimage = image('mob.dmi', loc = H, icon_state = "rev_head")
			else
				H.zombieimage = null
		for(var/mob/living/carbon/human/H in world)
			if(H.zombie)
				for(var/mob/living/carbon/human/N in world)
					H << N.zombieimage


/mob/living/carbon/human/relaymove(var/mob/user, direction)
	if(user in stomach_contents)
		if(prob(40))
			for(var/mob/M in hearers(4, src))
				if(M.client)
					M.show_message(text("\red You hear something rumbling inside [src]'s stomach..."), 2)
			var/obj/item/I = user.equipped()
			if(I && I.force)
				var/d = rand(round(I.force / 4), I.force)
				if(istype(src, /mob/living/carbon/human))
					var/mob/living/carbon/human/H = src
					var/organ = H.organs["chest"]
					if (istype(organ, /datum/organ/external))
						var/datum/organ/external/temp = organ
						temp.take_damage(d, 0)
					H.UpdateDamageIcon()
					H.updatehealth()
				else
					bruteloss += d
				for(var/mob/M in viewers(user, null))
					if(M.client)
						M.show_message(text("\red <B>[user] attacks [src]'s stomach wall with the [I.name]!"), 2)
				playsound(user.loc, 'attackblob.ogg', 50, 1)

				if(prob(bruteloss - 50))
					gib()