/mob/living/carbon/alien/update_canmove()
	if(paralysis || stunned || weakened || buckled) canmove = 0
	else canmove = 1

/mob/living/carbon/alien/check_if_buckled()
	if (src.buckled)
		src.lying = (istype(src.buckled, /obj/stool/bed) ? 1 : 0)
		if(src.lying)
			src.drop_item()
		src.density = 1
	else
		src.density = !src.lying

/mob/living/carbon/alien/handle_chemicals_in_body()
	if(reagents) reagents.metabolize(src)

	if(src.nutrition > 400 && !(src.mutations & 32))
		if(prob(5 + round((src.nutrition - 200) / 2)))
			src << "\red You suddenly feel blubbery!"
			src.mutations |= 32
//					update_body()
	if (src.nutrition < 100 && src.mutations & 32)
		if(prob(round((50 - src.nutrition) / 100)))
			src << "\blue You feel fit again!"
			src.mutations &= ~32
//					update_body()
	if (src.nutrition > 0)
		src.nutrition--

	if (src.drowsyness)
		src.drowsyness--
		src.eye_blurry = max(2, src.eye_blurry)
		if (prob(5))
			src.sleeping = 1
			src.paralysis = 5

	confused = max(0, confused - 1)
	// decrement dizziness counter, clamped to 0
	if(resting)
		dizziness = max(0, dizziness - 5)
		jitteriness = max(0, jitteriness - 5)
	else
		dizziness = max(0, dizziness - 1)
		jitteriness = max(0, jitteriness - 1)

	src.updatehealth()

	return //TODO: DEFERRED

/mob/living/carbon/alien/handle_virus_updates()
	..("Alien")