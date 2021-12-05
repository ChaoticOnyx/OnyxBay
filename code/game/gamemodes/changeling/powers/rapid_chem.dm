
// Speeds up chemical regeneration
/datum/changeling_power/passive/rapid_chem
	name = "Rapid Chemical-Synthesis"
	desc = "We evolve new pathways for producing our necessary chemicals, permitting us to naturally create them faster."
	power_processing = FALSE

/datum/changeling_power/passive/rapid_chem/activate()
	changeling.chem_recharge_rate *= 2

/datum/changeling_power/passive/rapid_chem/deactivate()
	changeling.chem_recharge_rate /= 2
