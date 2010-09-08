/mob/living/carbon/monkey/name = "monkey"
/mob/living/carbon/monkey/voice_name = "monkey"
/mob/living/carbon/monkey/voice_message = "chimpers"
/mob/living/carbon/monkey/icon = 'monkey.dmi'
/mob/living/carbon/monkey/icon_state = "monkey1"
/mob/living/carbon/monkey/gender = NEUTER
/mob/living/carbon/monkey/flags = 258.0
/mob/living/carbon/monkey/random_events = list("scratch")
/mob/living/carbon/human/species = "Monkey"

/mob/living/carbon/monkey/New()
	..()
//	random_events += "scratch"
	var/datum/reagents/R = new/datum/reagents(1000)
	reagents = R
	R.my_atom = src
	if (!(dna))
		if(gender == NEUTER)
			gender = pick(MALE, FEMALE)
		dna = new /datum/dna( null )
		dna.uni_identity = "00600200A00E0110148FC01300B009"
		dna.struc_enzymes = "0983E840344C39F4B059D5145FC5785DC6406A4BB8"
		dna.unique_enzymes = md5(name)
				//////////blah
		var/gendervar
		if (gender == "male")
			gendervar = add_zero2(num2hex((rand(1,2049)),1), 3)
		else
			gendervar = add_zero2(num2hex((rand(2051,4094)),1), 3)
		dna.uni_identity += gendervar
		dna.uni_identity += "12C"
		dna.uni_identity += "4E2"

	if(name == "monkey") name = text("monkey ([rand(1, 1000)])")

	real_name = name
	return

/mob/living/carbon/monkey/movement_delay()
	var/tally = 0

	if(reagents.has_reagent("hyperzine")) return -1

	var/health_deficiency = (health_full - health)
	if(health_deficiency >= 45) tally += (health_deficiency / 25)

	if (bodytemperature < 283.222)
		tally += (283.222 - bodytemperature) / 10 * 1.75
	return tally

/mob/living/carbon/monkey/Bump(atom/movable/AM as mob|obj, yes)

	spawn( 0 )
		if ((!( yes ) || now_pushing))
			return
		now_pushing = 1
		if(ismob(AM))
			var/mob/tmob = AM
			if(istype(tmob, /mob/living/carbon/human) && tmob.mutations & 32)
				if(prob(70))
					for(var/mob/M in viewers(src, null))
						if(M.client)
							M << "\red <B>[src] fails to push [tmob]'s fat ass out of the way.</B>"
					now_pushing = 0
					return
		now_pushing = 0
		..()
		if (!( istype(AM, /atom/movable) ))
			return
		if (!( now_pushing ))
			now_pushing = 1
			if (!( AM.anchored ))
				var/t = get_dir(src, AM)
				step(AM, t)
			now_pushing = null
		return
	return

/mob/living/carbon/monkey/Topic(href, href_list)
	..()
	if (href_list["mach_close"])
		var/t1 = text("window=[]", href_list["mach_close"])
		machine = null
		src << browse(null, t1)
	if ((href_list["item"] && !( usr.stat ) && !( usr.restrained() ) && in_range(src, usr) ))
		var/obj/equip_e/monkey/O = new /obj/equip_e/monkey(  )
		O.source = usr
		O.target = src
		O.item = usr.equipped()
		O.s_loc = usr.loc
		O.t_loc = loc
		O.place = href_list["item"]
		requests += O
		spawn( 0 )
			O.process()
			return
	..()
	return

/mob/living/carbon/monkey/meteorhit(obj/O as obj)
	for(var/mob/M in viewers(src, null))
		M.show_message(text("\red [] has been hit by []", src, O), 1)
	if (health > 0)
		var/shielded = 0
		for(var/obj/item/device/shield/S in src)
			if (S.active)
				shielded = 1
			else
		bruteloss += 30
		if ((O.icon_state == "flaming" && !( shielded )))
			fireloss += 40
		health = health_full - oxyloss - toxloss - fireloss - bruteloss
	return

/mob/living/carbon/monkey/bullet_act(flag)

	if (flag == PROJECTILE_BULLET)
		if (stat != 2)
			bruteloss += 60
			updatehealth()
			weakened = 10
	else if (flag == PROJECTILE_TASER)
		if (prob(75))
			stunned = 15
		else
			weakened = 15
	else if(flag == PROJECTILE_LASER)
		if (stat != 2)
			bruteloss += 20
			health = health_full - oxyloss - toxloss - fireloss - bruteloss
			if (prob(25))
				stunned = 1
	else if(flag == PROJECTILE_PULSE)
		if (stat != 2)
			bruteloss += 40
			health = health_full - oxyloss - toxloss - fireloss - bruteloss
			if (prob(25))
				stunned = min(stunned, 5)
	else if(flag == PROJECTILE_BOLT)
		toxloss += 3
		radiation += 100
		health = health_full - oxyloss - toxloss - fireloss - bruteloss
		stuttering += 5
		drowsyness += 5
	return

/mob/living/carbon/monkey/hand_p(mob/M as mob)
	if ((M.a_intent == "hurt" && !( istype(wear_mask, /obj/item/clothing/mask/muzzle) )))
		if ((prob(75) && health > 0))
			for(var/mob/O in viewers(src, null))
				O.show_message(text("\red <B>[M.name] has bit []!</B>", src), 1)
			var/damage = rand(1, 5)
			if (mutations & 8) damage += 10
			bruteloss += damage
			updatehealth()
		else
			for(var/mob/O in viewers(src, null))
				O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
	return

/mob/living/carbon/monkey/attack_paw(mob/M as mob)

	if (M.a_intent == "help")
		sleeping = 0
		resting = 0
		if (paralysis >= 3) paralysis -= 3
		if (stunned >= 3) stunned -= 3
		if (weakened >= 3) weakened -= 3
		for(var/mob/O in viewers(src, null))
			O.show_message("\blue [M.name] shakes [name] trying to wake him up!", 1)
	else
		if ((M.a_intent == "hurt" && !( istype(wear_mask, /obj/item/clothing/mask/muzzle) )))
			if ((prob(75) && health > 0))
				for(var/mob/O in viewers(src, null))
					O.show_message("\red <B>[M.name] has bit [name]!</B>", 1)
				var/damage = rand(1, 5)
				bruteloss += damage
				health = health_full - oxyloss - toxloss - fireloss - bruteloss
			else
				for(var/mob/O in viewers(src, null))
					O.show_message("\red <B>[M.name] has attempted to bite [name]!</B>", 1)
	return

/mob/living/carbon/monkey/attack_hand(mob/M as mob)

	if (M.a_intent == "help")
		sleeping = 0
		resting = 0
		if (paralysis >= 3) paralysis -= 3
		if (stunned >= 3) stunned -= 3
		if (weakened >= 3) weakened -= 3
		playsound(loc, 'thudswoosh.ogg', 50, 1, -1)
		for(var/mob/O in viewers(src, null))
			if ((O.client && !( O.blinded )))
				O.show_message(text("\blue [] shakes [name] trying to wake him up!", M), 1)
	else
		if (M.a_intent == "hurt")
			if ((prob(75) && health > 0))
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] has punched [name]!</B>", M), 1)

				playsound(loc, "punch", 25, 1, -1)
				var/damage = rand(5, 10)
				if (prob(40))
					damage = rand(10, 15)
					if (paralysis < 5)
						paralysis = rand(10, 15)
						spawn( 0 )
							for(var/mob/O in viewers(src, null))
								if ((O.client && !( O.blinded )))
									O.show_message(text("\red <B>[] has knocked out [name]!</B>", M), 1)
							return
				bruteloss += damage
				updatehealth()
			else
				playsound(loc, 'punchmiss.ogg', 25, 1, -1)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] has attempted to punch [name]!</B>", M), 1)
		else
			if (M.a_intent == "grab")
				if (M == src)
					return
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
					O.show_message(text("\red [] has grabbed [name] passively!", M), 1)
			else
				if (!( paralysis ))
					if (prob(25))
						paralysis = 2
						playsound(loc, 'thudswoosh.ogg', 50, 1, -1)
						for(var/mob/O in viewers(src, null))
							if ((O.client && !( O.blinded )))
								O.show_message(text("\red <B>[] has pushed down [name]!</B>", M), 1)
					else
						drop_item()
						playsound(loc, 'thudswoosh.ogg', 50, 1, -1)
						for(var/mob/O in viewers(src, null))
							if ((O.client && !( O.blinded )))
								O.show_message(text("\red <B>[] has disarmed [name]!</B>", M), 1)
	return


/mob/living/carbon/monkey/Stat()
	..()
	statpanel("Status")
	stat(null, text("Intent: []", a_intent))
	stat(null, text("Move Mode: []", m_intent))
	return

/mob/living/carbon/monkey/update_clothing()
	..()
	for(var/i in overlays)
		overlays -= i

	if(client && client.admin_invis)
		invisibility = 100
	else
		invisibility = 0

	if(buckled)
		if(istype(buckled, /obj/stool/bed))
			lying = 1
		else
			lying = 0

	if (!( lying ))
		icon_state = "monkey1"
	else
		icon_state = "monkey0"
	if (wear_mask)
		if (istype(wear_mask, /obj/item/clothing/mask))
			var/t1 = wear_mask.item_state
			if (!( t1 ))
				t1 = wear_mask.icon_state
			overlays += image("icon" = 'monkey.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = layer)
		wear_mask.screen_loc = ui_mask
	if (r_hand)
		overlays += image("icon" = 'items_righthand.dmi', "icon_state" = r_hand.item_state ? r_hand.item_state : r_hand.icon_state, "layer" = layer)
		r_hand.screen_loc = ui_rhand

	if (l_hand)
		overlays += image("icon" = 'items_lefthand.dmi', "icon_state" = l_hand.item_state ? l_hand.item_state : l_hand.icon_state, "layer" = layer)
		l_hand.screen_loc = ui_lhand

	if (back)
		if (!( lying ))
			overlays += image("icon" = 'monkey.dmi', "icon_state" = "back", "layer" = layer)
		else
			overlays += image("icon" = 'monkey.dmi', "icon_state" = "back2", "layer" = layer)
		back.screen_loc = ui_back
	if (handcuffed)
		pulling = null
		if (!( lying ))
			overlays += image("icon" = 'monkey.dmi', "icon_state" = "handcuff1", "layer" = layer)
		else
			overlays += image("icon" = 'monkey.dmi', "icon_state" = "handcuff2", "layer" = layer)
	if (client)
		client.screen -= contents
		client.screen += contents
		client.screen -= hud_used.m_ints
		client.screen -= hud_used.mov_int
		if (i_select)
			if (intent)
				client.screen += hud_used.m_ints

				var/list/L = dd_text2list(intent, ",")
				L[1] += ":-11"
				i_select.screen_loc = dd_list2text(L,",") //ICONS, FUCKING SHIT

			else
				i_select.screen_loc = null
		if (m_select)
			if (m_int)
				client.screen += hud_used.mov_int

				var/list/L = dd_text2list(m_int, ",")
				L[1] += ":-11"
				m_select.screen_loc = dd_list2text(L,",") //ICONS, FUCKING SHIT

			else
				m_select.screen_loc = null
	for(var/mob/M in viewers(1, src))
		if ((M.client && M.machine == src))
			spawn( 0 )
				show_inv(M)
				return
	return

/mob/living/carbon/monkey/Move()
	if ((!( buckled ) || buckled.loc != loc))
		buckled = null
	if (buckled)
		return
	if (restrained())
		pulling = null
	var/t7 = 1
	if (restrained())
		for(var/mob/M in range(src, 1))
			if ((M.pulling == src && M.stat == 0 && !( M.restrained() )))
				return 0
	if ((t7 && pulling && get_dist(src, pulling) <= 1))
		if (pulling.anchored)
			pulling = null
		var/T = loc
		. = ..()
		if (!( isturf(pulling.loc) ))
			pulling = null
			return
		if (!( restrained() ))
			var/diag = get_dir(src, pulling)
			if ((diag - 1) & diag)
			else
				diag = null
			if ((ismob(pulling) && (get_dist(src, pulling) > 1 || diag)))
				if (istype(pulling, type))
					var/mob/M = pulling
					var/mob/t = M.pulling
					M.pulling = null
					step(pulling, get_dir(pulling.loc, T))
					M.pulling = t
			else
				step(pulling, get_dir(pulling.loc, T))
	else
		pulling = null
		. = ..()
	if ((s_active && !( contents.Find(s_active) )))
		s_active.close(src)
	return

/mob/living/carbon/monkey/verb/removeinternal()
	internal = null
	return

/mob/living/carbon/monkey/ex_act(severity)
	flick("flash", flash)
	switch(severity)
		if(1.0)
			if (stat != 2)
				bruteloss += 200
				health = health_full - oxyloss - toxloss - fireloss - bruteloss
		if(2.0)
			if (stat != 2)
				bruteloss += 60
				fireloss += 60
				health = health_full - oxyloss - toxloss - fireloss - bruteloss
		if(3.0)
			if (stat != 2)
				bruteloss += 30
				health = health_full - oxyloss - toxloss - fireloss - bruteloss
			if (prob(50))
				paralysis += 10
		else
	return

/mob/living/carbon/monkey/blob_act()
	if (stat != 2)
		bruteloss += 30
		health = health_full - oxyloss - toxloss - fireloss - bruteloss
	if (prob(50))
		paralysis += 10

/obj/equip_e/monkey/process()
	if (item)
		item.add_fingerprint(source)
	if (!( item ))
		switch(place)
			if("head")
				if (!( target.wear_mask ))
					del(src)
					return
			if("l_hand")
				if (!( target.l_hand ))
					del(src)
					return
			if("r_hand")
				if (!( target.r_hand ))
					del(src)
					return
			if("back")
				if (!( target.back ))
					del(src)
					return
			if("handcuff")
				if (!( target.handcuffed ))
					del(src)
					return
			if("internal")
				if ((!( (istype(target.wear_mask, /obj/item/clothing/mask) && istype(target.back, /obj/item/weapon/tank) && !( target.internal )) ) && !( target.internal )))
					del(src)
					return

	if (item)
		for(var/mob/O in viewers(target, null))
			if ((O.client && !( O.blinded )))
				O.show_message(text("\red <B>[] is trying to put a [] on []</B>", source, item, target), 1)
	else
		var/message = null
		switch(place)
			if("l_hand")
				message = text("\red <B>[] is trying to take off a [] from []'s left hand!</B>", source, target.l_hand, target)
			if("r_hand")
				message = text("\red <B>[] is trying to take off a [] from []'s right hand!</B>", source, target.r_hand, target)
			if("back")
				message = text("\red <B>[] is trying to take off a [] from []'s back!</B>", source, target.back, target)
			if("handcuff")
				message = text("\red <B>[] is trying to unhandcuff []!</B>", source, target)
			if("internal")
				if (target.internal)
					message = text("\red <B>[] is trying to remove []'s internals</B>", source, target)
				else
					message = text("\red <B>[] is trying to set on []'s internals.</B>", source, target)
			else
		for(var/mob/M in viewers(target, null))
			M.show_message(message, 1)
	spawn( 30 )
		done()
		return
	return

/obj/equip_e/monkey/done()
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
		if("l_hand")
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
		if("r_hand")
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
					source.drop_item()
					target.handcuffed = item
					item.loc = target
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
						target.internal.add_fingerprint(source)
						for(var/mob/M in viewers(target, 1))
							if ((M.client && !( M.blinded )))
								M.show_message(text("[] is now running on internals.", target), 1)
		else
	source.update_clothing()
	target.update_clothing()
	del(src)
	return