obj/psychiatry/disease/ocd
	attack_period = 120 SECONDS

/obj/psychiatry/disease/ocd/attack()
	if(owner.chem_effects[CE_ANTIPSYHOTIC])
		return

	to_chat(owner, SPAN_NOTICE(pick("You can feel the dirt around you", "You feel that the dirt is driving you mad", "You feel terrible dirt on you and your hands", "Everything is terribly dirty")))
	owner.emote("twitch")

	if(prob(11))
		owner.hallucination(5, 10)