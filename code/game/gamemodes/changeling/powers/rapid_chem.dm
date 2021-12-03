
//Speeds up chemical regeneration
/mob/proc/changeling_fastchemical()
	mind.changeling.chem_recharge_rate *= 2
	return TRUE
