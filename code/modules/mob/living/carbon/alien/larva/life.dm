/mob/living/carbon/alien/larva/handle_regular_hud_updates()
	if (src.stat == 2 || src.mutations & 4)
		src.sight |= SEE_TURFS
		src.sight |= SEE_MOBS
		src.sight |= SEE_OBJS
		src.see_in_dark = 8
		src.see_invisible = 2
	else if (src.stat != 2)
		src.sight |= SEE_MOBS
		src.sight &= ~SEE_TURFS
		src.sight &= ~SEE_OBJS
		src.see_in_dark = 4
		src.see_invisible = 2

	if (src.sleep) src.sleep.icon_state = text("sleep[]", src.sleeping)
	if (src.rest) src.rest.icon_state = text("rest[]", src.resting)

	if (src.healths)
		if (src.stat != 2)
			switch(health)
				if(25 to INFINITY)
					src.healths.icon_state = "health0"
				if(19 to 25)
					src.healths.icon_state = "health1"
				if(13 to 19)
					src.healths.icon_state = "health2"
				if(7 to 13)
					src.healths.icon_state = "health3"
				if(0 to 7)
					src.healths.icon_state = "health4"
				else
					src.healths.icon_state = "health5"
		else
			src.healths.icon_state = "health6"

	if(src.pullin)	src.pullin.icon_state = "pull[src.pulling ? 1 : 0]"


	if (src.toxin)	src.toxin.icon_state = "tox[src.toxins_alert ? 1 : 0]"
	if (src.oxygen) src.oxygen.icon_state = "oxy[src.oxygen_alert ? 1 : 0]"
	if (src.fire) src.fire.icon_state = "fire[src.fire_alert ? 1 : 0]"
	//NOTE: the alerts dont reset when youre out of danger. dont blame me,
	//blame the person who coded them. Temporary fix added.

	src.client.screen -= src.hud_used.blurry
	src.client.screen -= src.hud_used.druggy
	src.client.screen -= src.hud_used.vimpaired

	if ((src.blind && src.stat != 2))
		if ((src.blinded))
			src.blind.layer = 18
		else
			src.blind.layer = 0

			if (src.disabilities & 1)
				src.client.screen += src.hud_used.vimpaired

			if (src.eye_blurry)
				src.client.screen += src.hud_used.blurry

			if (src.druggy)
				src.client.screen += src.hud_used.druggy

	if (src.stat != 2)
		if (src.machine)
			if (!( src.machine.check_eye(src) ))
				src.reset_view(null)
		else
			if(!client.adminobs)
				reset_view(null)

	return 1

/mob/living/carbon/alien/larva/handle_disabilities()

/mob/living/carbon/alien/larva/handle_mutations_and_radiation()
	if(src.amount_grown >= 200)
		src << "\green You are growing into a beautiful alien!"
		var/mob/living/carbon/alien/humanoid/H = new /mob/living/carbon/alien/humanoid( src.loc )
		H.toxloss = src.toxloss

		if(src.client)
			src.client.mob = H

		spawn(10)
			del(src)
			return
	//grow!!
	src.amount_grown++

	..()