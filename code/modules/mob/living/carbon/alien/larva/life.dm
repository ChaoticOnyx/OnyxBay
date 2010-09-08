/mob/living/carbon/alien/larva/handle_regular_hud_updates()
	if (stat == 2 || mutations & 4)
		sight |= SEE_TURFS
		sight |= SEE_MOBS
		sight |= SEE_OBJS
		see_in_dark = 8
		see_invisible = 2
	else if (stat != 2)
		sight |= SEE_MOBS
		sight &= ~SEE_TURFS
		sight &= ~SEE_OBJS
		see_in_dark = 4
		see_invisible = 2

	if (sleep) sleep.icon_state = text("sleep[]", sleeping)
	if (rest) rest.icon_state = text("rest[]", resting)

	if (healths)
		if (stat != 2)
			switch(health)
				if(25 to INFINITY)
					healths.icon_state = "health0"
				if(19 to 25)
					healths.icon_state = "health1"
				if(13 to 19)
					healths.icon_state = "health2"
				if(7 to 13)
					healths.icon_state = "health3"
				if(0 to 7)
					healths.icon_state = "health4"
				else
					healths.icon_state = "health5"
		else
			healths.icon_state = "health6"

	if(pullin)	pullin.icon_state = "pull[pulling ? 1 : 0]"


	if (toxin)	toxin.icon_state = "tox[toxins_alert ? 1 : 0]"
	if (oxygen) oxygen.icon_state = "oxy[oxygen_alert ? 1 : 0]"
	if (fire) fire.icon_state = "fire[fire_alert ? 1 : 0]"
	//NOTE: the alerts dont reset when youre out of danger. dont blame me,
	//blame the person who coded them. Temporary fix added.

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

/mob/living/carbon/alien/larva/handle_disabilities()

/mob/living/carbon/alien/larva/handle_mutations_and_radiation()
	if(amount_grown >= 200)
		src << "\green You are growing into a beautiful alien!"
		var/mob/living/carbon/alien/humanoid/H = new /mob/living/carbon/alien/humanoid( loc )
		H.toxloss = toxloss

		if(client)
			client.mob = H

		spawn(10)
			del(src)
			return
	//grow!!
	amount_grown++

	..()