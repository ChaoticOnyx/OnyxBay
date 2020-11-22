obj/psychiatry/disease/schizophrenia
	attack_period = 30 SECONDS

/obj/psychiatry/disease/schizophrenia/attack()
	if(owner.chem_effects[CE_ANTIPSYHOTIC])
		return

	owner.hallucination(pick(0, 5, 15, 20, 40, 60, 70), pick(15, 30, 60, 90))

