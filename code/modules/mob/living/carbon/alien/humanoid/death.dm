/mob/living/carbon/alien/humanoid/death(gibbed)
	if(src.stat == 2)
		return
	if(src.healths)
		src.healths.icon_state = "health6"
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
		if (istype(src.wear_suit, /obj/item/clothing/suit/armor/a_i_a_ptank))
			var/obj/item/clothing/suit/armor/a_i_a_ptank/A = src.wear_suit
			bombers += "[src.key] has detonated a suicide bomb. Temp = [A.part4.air_contents.temperature-T0C]."
	//		world << "Detected that [src.key] is wearing a bomb" debug stuff
			if(A.status && prob(90))
	//			world << "Bomb has ignited?"
				A.part4.ignite()

	return ..(gibbed)
