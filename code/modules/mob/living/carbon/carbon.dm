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

/mob/living/carbon/Move(NewLoc, direct)
	. = ..()
	if(.)
		if(nutrition)
			nutrition--
		if(mutations & 32 && m_intent == "run")
			bodytemperature += 2

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

	var/list/L = list(  )
	for(var/t in organs)
		if (istype(organs[text("[]", t)], /datum/organ/external))
			L += organs[text("[]", t)]
	bruteloss = 0
	fireloss = 0
	for(var/datum/organ/external/O in L)
		bruteloss += O.brute_dam
		fireloss += O.burn_dam
	return

/mob/living/carbon/proc/UpdateDamageIcon()
	return