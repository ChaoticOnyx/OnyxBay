/mob/living/carbon/gender = MALE

/mob/living/carbon/var/co2overloadtime = null
/mob/living/carbon/var/temperature_resistance = T0C+75
/mob/living/carbon/var/obj/item/weapon/card/id/wear_id = null
/mob/living/carbon/var/list/stomach_contents = list()
/mob/living/carbon/var/brain_op_stage = 0.0

/mob/living/carbon/var/oxygen_alert = 0
/mob/living/carbon/var/toxins_alert = 0
/mob/living/carbon/var/fire_alert = 0
/mob/living/carbon/var/temperature_alert = 0
/mob/living/carbon/var/list/random_events = list() //If handle_random_events() is run, it will choose from this list. Entries are defined per type (See Monkey and Human)
/mob/living/carbon/var/oxylossparalysis = 50
/mob/living/carbon/var/species = null

/mob/living/carbon/var/datum/disease2/disease/virus2 = null
/mob/living/carbon/var/list/datum/disease2/disease/immunevirus2 = list()
/mob/living/carbon/var/list/datum/disease2/resistance/resistances2 = list()

/mob/living/carbon/Move(NewLoc, direct)
	. = ..()
	if(.)
		if(nutrition)
			nutrition--
		/*if(mutations & 32 && m_intent == "run")
			bodytemperature += 2*/

/mob/living/carbon/relaymove(var/mob/user, direction)
	if(user in stomach_contents)
		if(prob(40))
			for(var/mob/M in hearers(4, src))
				if(M.client)
					M.show_message(text("\red You hear something rumbling inside [src]'s stomach..."), 2)
			var/obj/item/I = user.equipped()
			if(I && I.force)
				var/d = rand(round(I.force / 4), I.force)
				bruteloss += d
				for(var/mob/M in viewers(user, null))
					if(M.client)
						M.show_message(text("\red <B>[user] attacks [src]'s stomach wall with the [I.name]!"), 2)
				playsound(user.loc, 'attackblob.ogg', 50, 1)

				if(prob(bruteloss - 50))
					gib()

/mob/living/carbon/gib(give_medal)
	for(var/mob/M in src)
		if(M in stomach_contents)
			stomach_contents.Remove(M)
		M.loc = loc
		for(var/mob/N in viewers(src, null))
			if(N.client)
				N.show_message(text("\red <B>[M] bursts out of [src]!</B>"), 2)
	. = ..(give_medal)

/mob/living/carbon/Stat()
	..()
	statpanel("Status")
	stat(null, "Intent: [a_intent]")
	stat(null, "Move Mode: [m_intent]")

/mob/living/carbon/bullet_act(flag, A as obj)
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
		if (stat != 2)
			bruteloss += d
			updatehealth()
			if (prob(50))
				if(weakened <= 5)	weakened = 5
		return
	else if (flag == PROJECTILE_TASER)
		if (prob(75) && stunned <= 10)
			stunned = 10
		else
			weakened = 10
		if (stuttering < 10)
			stuttering = 10
	else if(flag == PROJECTILE_LASER)
		var/d = 20

		if (!eye_blurry) eye_blurry = 4 //This stuff makes no sense but lasers need a buff.
		if (prob(25)) stunned++

		if (stat != 2)
			bruteloss += d
			updatehealth()
			if (prob(25))
				stunned = 1
	else if(flag == PROJECTILE_PULSE)
		var/d = 40

		if (stat != 2)
			bruteloss += d
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

/mob/living/carbon/Move()
	if (buckled)
		return

	if (restrained())
		pulling = null

	var/t7 = 1
	if (restrained())
		for(var/mob/M in range(src, 1))
			if ((M.pulling == src && M.stat == 0 && !( M.restrained() )))
				t7 = null

	if ((t7 && (pulling && ((get_dist_3d(src, pulling) <= 1 || pulling.loc == loc) && (client && client.moving)))))
		var/turf/T = loc
		. = ..()

		if (pulling && pulling.loc)
			if(!( isturf(pulling.loc) ))
				pulling = null
				return
			else
				if(Debug)
					check_diary()
					diary <<"pulling disappeared? at [__LINE__] in mob.dm - pulling = [pulling]"
					diary <<"REPORT THIS"

		/////
		if(pulling && pulling.anchored)
			pulling = null
			return

		if (!restrained())
			var/diag = get_dir(src, pulling)
			if ((diag - 1) & diag)
			else
				diag = null
			if ((get_dist(src, pulling) > 1 || diag))
				if (ismob(pulling))
					var/mob/M = pulling
					var/ok = 1
					if (locate(/obj/item/weapon/grab, M.grabbed_by))
						if (prob(75))
							var/obj/item/weapon/grab/G = pick(M.grabbed_by)
							if (istype(G, /obj/item/weapon/grab))
								for(var/mob/O in viewers(M, null))
									O.show_message(text("\red [] has been pulled from []'s grip by []", G.affecting, G.assailant, src), 1)
								//G = null
								del(G)
						else
							ok = 0
						if (locate(/obj/item/weapon/grab, M.grabbed_by.len))
							ok = 0
					if (ok)
						var/t = M.pulling
						M.pulling = null

						pulling.Move(T)
						M.pulling = t
				else
					if (pulling)
						if(CanReachThrough(src.loc,pulling.loc,pulling))
							step(src.pulling, get_dir(src.pulling.loc, T))
	else
		pulling = null
		. = ..()
	if ((s_active && !( s_active in contents ) ))
		s_active.close(src)
	return

/mob/living/carbon/proc/TakeDamage(zone, brute, burn)
	var/datum/organ/external/E = organs[text("[]", zone)]
	if (istype(E, /datum/organ/external))
		if (E.take_damage(brute, burn))
			UpdateDamageIcon()
		else
			UpdateDamage()
	else
		return 0
	return

/mob/living/carbon/proc/UpdateDamage()

	if (!(istype(src, /mob/living/carbon/human)))	//Added by Strumpetplaya - Invincible Monkey Fix
		return										//Possibly helps with other invincible mobs like Aliens?
	var/list/L = list(  )
	for(var/t in organs)
		if (istype(organs[text("[]", t)], /datum/organ/external))
			L += organs[text("[]", t)]
	bruteloss = 0
	fireloss = 0
	for(var/datum/organ/external/O in L)
		bruteloss += O.get_damage_brute()
		fireloss += O.get_damage_fire()
	return

/mob/living/carbon/proc/GetOrgans()
	var/list/L = list(  )
	for(var/t in organs)
		if (istype(organs[text("[]", t)], /datum/organ/external))
			L += organs[text("[]", t)]
	return L

/mob/living/carbon/proc/UpdateDamageIcon()
	return