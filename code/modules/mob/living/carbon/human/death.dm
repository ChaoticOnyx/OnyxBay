/mob/living/carbon/human/death(gibbed)
	if(stat == 2)
		return
	if(healths)
		healths.icon_state = "health5"
	if(halloss > 0 && (!gibbed))
		//hallucination = 0
		halloss = 0
		// And the suffocation was a hallucination (lazy)
		oxyloss = max(oxyloss - 50,0)
		return
	if(zombifying)
		zombify()
		return
	stat = 2
	dizziness = 0
	jitteriness = 0

	if(!suiciding)
		add_stat(2,1)
		unlock_medal("Downsizing", 0, "You are no longer a profitable asset.", "easy")
	else
		add_stat(3,1)
		unlock_medal("I can't take it anymore!", 0, "Kill yourself...", "easy")
	if (!gibbed)
		emote("deathgasp") //let the world KNOW WE ARE DEAD

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

	//icon_state = "dead"

	ticker.mode.check_win()

	/*
		if (ticker.mode.name == "Corporate Restructuring" && ticker.target != src)
			unlock_medal("Expendable", 1)

		//For restructuring
		if (ticker.mode.name == "Corporate Restructuring" || ticker.mode.name == "revolution")
			ticker.check_win()

		if (ticker.mode.name == "wizard" && src == ticker.killer)
			world << "<FONT size = 3><B>Research Station Victory</B></FONT>"
			world << "<B>The Wizard has been killed!</B> The wizards federation has been taught an important lesson."
			ticker.processing = 0
			sleep(100)
			world << "\blue Rebooting due to end of game"
			world.Reboot()
	*/ //TODO: FIX

	//Traitor's dead! Oh no!
	if (ticker.mode.name == "traitor" && mind && mind.special_role == "traitor")
		message_admins("\red Traitor [key_name_admin(src)] has died.")

	return ..(gibbed)
