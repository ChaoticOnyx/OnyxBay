/mob/living/carbon/alien/humanoid/death(gibbed)
	if(stat == 2)
		return
	if(healths)
		healths.icon_state = "health6"
	stat = 2

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
		if (istype(wear_suit, /obj/item/clothing/suit/armor/a_i_a_ptank))
			var/obj/item/clothing/suit/armor/a_i_a_ptank/A = wear_suit
			bombers += "[key] has detonated a suicide bomb. Temp = [A.part4.air_contents.temperature-T0C]."
	//		world << "Detected that [key] is wearing a bomb" debug stuff
			if(A.status && prob(90))
	//			world << "Bomb has ignited?"
				A.part4.ignite()

	return ..(gibbed)
