
// Increases maximum chemicals
/datum/changeling_power/passive/engorged_glands
	name = "Engorged Chemical Glands"
	desc = "Our chemical glands swell, permitting us to store more chemicals inside of them."

/datum/changeling_power/passive/engorged_glands/activate()
	changeling.chem_storage = 150

/datum/changeling_power/passive/engorged_glands/deactivate()
	changeling.chem_storage = initial(changeling.chem_storage)
