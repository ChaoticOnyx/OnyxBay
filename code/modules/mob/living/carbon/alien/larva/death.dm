/mob/living/carbon/alien/larva/death(gibbed)
	icon_state = "larva_l"

	if (!gibbed)
		canmove = 0
		if(client)
			blind.layer = 0
		lying = 1
		var/h = hand
		hand = 0
		drop_item()
		hand = 1
		drop_item()
		hand = h

	return ..(gibbed)
