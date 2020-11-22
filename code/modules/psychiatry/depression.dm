obj/psychiatry/disease/depression
	attack_period = 90 SECONDS

/obj/psychiatry/disease/depression/attack()
	if(owner.chem_effects[CE_MIND])
		return
	owner.emote("cry")
	to_chat(owner, SPAN_DEADSAY(pick("You feel empty", "You feel trapped", "You feel sad", "You feel like you want to cut yourself", "You feel the urge to drink a lot of alcohol.")))

