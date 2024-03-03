// Datum to simplify working with turret's settings.
// NB - not a singleton.

/datum/targeting_settings
	/// Sets whether we are authorized to use lethal force
	var/lethal_mode = FALSE
	/// Checks whether the perp has an arrest status
	var/check_arrest = TRUE	//checks if the perp is set to arrest
	/// Checks if a security record exists at all
	var/check_records = TRUE
	/// Checks for a weapon authorization
	var/check_weapons = FALSE	//checks if it can shoot people that have a weapon they aren't authorized to have
	/// Shoots everything that does not meet turret's access requirements
	var/check_access = TRUE
	/// Checks for udentified lifeforms (simple animal, xenos, e.t.c.)
	var/check_anomalies = TRUE
	/// If active - will shoot at anything that is not issilicon()
	var/check_synth = FALSE

/// Returns targeting settings, pretty straightforward
/datum/targeting_settings/tgui_data()
	var/list/data = list(
		"lethalMode" = lethal_mode,
		"checkSynth" = check_synth,
		"checkWeapon" = check_weapons,
		"checkRecords" = check_records,
		"checkAccess" = check_access,
		"checkArrests" = check_arrest,
		"checkAnomalies" = check_anomalies,
	)
	return data
