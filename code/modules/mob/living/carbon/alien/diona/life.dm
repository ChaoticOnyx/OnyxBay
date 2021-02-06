//Dionaea regenerate health and nutrition in light.
/mob/living/carbon/alien/diona/handle_environment(datum/gas_mixture/environment)
	if(stat == DEAD)
		return

	var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
	if(isturf(loc)) //else, there's considered to be no light
		var/turf/T = loc
		light_amount = T.get_lumcount() * 5

	nutrition += light_amount

	if(nutrition > 450)
		nutrition = 450
	if(light_amount > 2) //if there's enough light, heal
		if(getBruteLoss())
			adjustBruteLoss(-1)
		if(getFireLoss())
			adjustFireLoss(-1)
		if(getToxLoss())
			adjustToxLoss(-1)
		if(getOxyLoss())
			adjustOxyLoss(-1)

	if(!client)
		handle_npc(src)
