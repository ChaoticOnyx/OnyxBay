
// Increases maximum chemicals
/datum/changeling_power/passive/engorged_glands
	name = "Engorged Chemical Glands"
	desc = "Our chemical glands swell, permitting us to store more chemicals inside of them."
	power_processing = FALSE

/datum/changeling_power/passive/engorged_glands/activate()
	changeling.chem_storage += 25

/datum/changeling_power/passive/engorged_glands/deactivate()
	changeling.chem_storage -= 25
