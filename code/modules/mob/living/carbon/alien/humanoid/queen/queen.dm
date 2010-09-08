/mob/living/carbon/alien/humanoid/queen/name = "alien queen"
/mob/living/carbon/alien/humanoid/queen/icon_state = "queen_s"
/mob/living/carbon/alien/humanoid/queen/health_full = 250
/mob/living/carbon/alien/humanoid/queen/toxgain = 20

/mob/living/carbon/alien/humanoid/queen/New()
	..()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	src.stand_icon = new /icon('alien.dmi', "queen_s")
	src.lying_icon = new /icon('alien.dmi', "queen_l")
	src.icon = src.stand_icon

//there should only be one queen
//		if(src.name == "alien") src.name = text("alien ([rand(1, 1000)])")
	src.real_name = src.name
	src << "\blue Your icons have been generated!"

	update_clothing()


/mob/living/carbon/alien/humanoid/queen
	handle_regular_hud_updates()
		if (src.stat == 2 || src.mutations & 4)
			src.sight |= SEE_TURFS
			src.sight |= SEE_MOBS
			src.sight |= SEE_OBJS
			src.see_in_dark = 8
			src.see_invisible = 2
		else if (src.stat != 2)
			src.sight |= SEE_MOBS
			src.sight |= SEE_TURFS
			src.sight &= ~SEE_OBJS
			src.see_in_dark = 8
			src.see_invisible = 2

		if (src.sleep) src.sleep.icon_state = text("sleep[]", src.sleeping)
		if (src.rest) src.rest.icon_state = text("rest[]", src.resting)

		if (src.healths)
			if (src.stat != 2)
				switch(health)
					if(250 to INFINITY)
						src.healths.icon_state = "health0"
					if(175 to 250)
						src.healths.icon_state = "health1"
					if(100 to 175)
						src.healths.icon_state = "health2"
					if(50 to 100)
						src.healths.icon_state = "health3"
					if(0 to 50)
						src.healths.icon_state = "health4"
					else
						src.healths.icon_state = "health5"
			else
				src.healths.icon_state = "health6"

//Queen verbs
/mob/living/carbon/alien/humanoid/queen/verb/lay_egg()

	set name = "Lay Egg (200)"
	set desc = "Plants an egg"
	set category = "Alien"

	if(src.stat)
		src << "You must be concious to do this"
		return
	if(src.toxloss >= 200)
		src.toxloss -= 200
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\green <B>[src] has laid an egg!</B>"), 1)
		new /obj/alien/egg(src.loc)

	else
		src << "\green Not enough plasma stored"
	return