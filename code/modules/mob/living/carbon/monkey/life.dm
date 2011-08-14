/mob/living/carbon/monkey/Life()
	set background = 1

	..()

	if(!client)
		if(prob(33) && canmove && isturf(loc))
			step(src, pick(cardinal))
		if(prob(1))
			emote(pick("scratch","jump","roll","tail"))


	if(reagents.has_reagent("spaceacillin"))
		return
	if(virus2)
		var/obj/virus/V = new(src.loc)
		step_rand(V)
		step_rand(V)
		V.D = virus2.getcopy()
	if(!src.virus2)
		for(var/obj/virus/V in src.loc)
			infect_virus2(src,V.D)

/mob/living/carbon/monkey/clamp_values()
	stunned = max(stunned,0)
	paralysis = max(paralysis, 0)
	weakened = max(weakened, 0)

/mob/living/carbon/monkey/handle_regular_hud_updates()
	if (stat == 2 || mutations & 4)
		sight |= SEE_TURFS
		sight |= SEE_MOBS
		sight |= SEE_OBJS
		see_in_dark = 8
		see_invisible = 2
	else if (stat != 2)
		sight &= ~SEE_TURFS
		sight &= ~SEE_MOBS
		sight &= ~SEE_OBJS
		see_in_dark = 2
		see_invisible = 0

	if (sleep) sleep.icon_state = text("sleep[]", sleeping)
	if (rest) rest.icon_state = text("rest[]", resting)

	if (healths)
		if (stat != 2)
			switch(health)
				if(100 to INFINITY)
					healths.icon_state = "health0"
				if(80 to 100)
					healths.icon_state = "health1"
				if(60 to 80)
					healths.icon_state = "health2"
				if(40 to 60)
					healths.icon_state = "health3"
				if(20 to 40)
					healths.icon_state = "health4"
				if(0 to 20)
					healths.icon_state = "health5"
				else
					healths.icon_state = "health6"
		else
			healths.icon_state = "health7"

	if(pullin)	pullin.icon_state = "pull[pulling ? 1 : 0]"


	if (toxin)	toxin.icon_state = "tox[toxins_alert ? 1 : 0]"
	if (oxygen) oxygen.icon_state = "oxy[oxygen_alert ? 1 : 0]"
	if (fire) fire.icon_state = "fire[fire_alert ? 1 : 0]"
	//NOTE: the alerts dont reset when youre out of danger. dont blame me,
	//blame the person who coded them. Temporary fix added.

	switch(bodytemperature) //310.055 optimal body temp

		if(345 to INFINITY)
			bodytemp.icon_state = "temp4"
		if(335 to 345)
			bodytemp.icon_state = "temp3"
		if(327 to 335)
			bodytemp.icon_state = "temp2"
		if(316 to 327)
			bodytemp.icon_state = "temp1"
		if(300 to 316)
			bodytemp.icon_state = "temp0"
		if(295 to 300)
			bodytemp.icon_state = "temp-1"
		if(280 to 295)
			bodytemp.icon_state = "temp-2"
		if(260 to 280)
			bodytemp.icon_state = "temp-3"
		else
			bodytemp.icon_state = "temp-4"

	client.screen -= hud_used.blurry
	client.screen -= hud_used.druggy
	client.screen -= hud_used.vimpaired

	if ((blind && stat != 2))
		if ((blinded))
			blind.layer = 18
		else
			blind.layer = 0

			if (disabilities & 1)
				client.screen += hud_used.vimpaired

			if (eye_blurry)
				client.screen += hud_used.blurry

			if (druggy)
				client.screen += hud_used.druggy

	if (stat != 2)
		if (machine)
			if (!( machine.check_eye(src) ))
				reset_view(null)
		else
			if(!client.adminobs)
				reset_view(null)

	return 1

/mob/living/carbon/monkey/handle_chemicals_in_body()
	if(reagents) reagents.metabolize(src)

	if (drowsyness)
		drowsyness--
		eye_blurry = max(2, eye_blurry)
		if (prob(5))
			sleeping = 1
			paralysis = 5

	confused = max(0, confused - 1)
	// decrement dizziness counter, clamped to 0
	if(resting)
		dizziness = max(0, dizziness - 5)
	else
		dizziness = max(0, dizziness - 1)

	updatehealth()

	return //TODO: DEFERRED