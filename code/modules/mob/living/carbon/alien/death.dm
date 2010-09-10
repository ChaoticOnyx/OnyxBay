/mob/living/carbon/alien/death(gibbed)
	if(stat == 2)
		return
	if(healths)
		healths.icon_state = "health6"
	stat = 2

	return ..(gibbed)