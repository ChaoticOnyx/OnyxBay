/mob/living/carbon/alien/humanoid/queen/name = "alien queen"
/mob/living/carbon/alien/humanoid/queen/icon_state = "queen_s"
/mob/living/carbon/alien/humanoid/queen/health_full = 250
/mob/living/carbon/alien/humanoid/queen/toxgain = 20

/mob/living/carbon/alien/humanoid/queen/New()
	..()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	stand_icon = new /icon('alien.dmi', "queen_s")
	lying_icon = new /icon('alien.dmi', "queen_l")
	icon = stand_icon

//there should only be one queen
//		if(name == "alien") name = text("alien ([rand(1, 1000)])")
	real_name = name
	src << "\blue Your icons have been generated!"

	update_clothing()


//Queen verbs
/mob/living/carbon/alien/humanoid/queen/verb/lay_egg()

	set name = "Lay Egg (200)"
	set desc = "Plants an egg"
	set category = "Alien"

	if(stat)
		src << "You must be concious to do this"
		return
	if(toxloss >= 200)
		toxloss -= 200
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\green <B>[src] has laid an egg!</B>"), 1)
		new /obj/alien/egg(loc)

	else
		src << "\green Not enough plasma stored"
	return