/mob/living/carbon/alien/larva/death(gibbed)
	if(src.stat == 2)
		return
	if(src.healths)
		src.healths.icon_state = "health6"
	src.icon_state = "larva_l"
	src.stat = 2

	if (!gibbed)

		src.canmove = 0
		if(src.client)
			src.blind.layer = 0
		src.lying = 1
		var/h = src.hand
		src.hand = 0
		drop_item()
		src.hand = 1
		drop_item()
		src.hand = h

	return ..(gibbed)
