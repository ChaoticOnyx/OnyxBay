/datum/game_mode/blob
	name = "blob"
	round_description = "Destroy or neutralize the blob outbreak."
	extended_round_description = "Destroy or neutralize the blob outbreak."
	config_tag = "blob"

//#warn Set players
	required_players = 20
	required_enemies = 1
	antag_tags = list(MODE_BLOB)
	antag_templates = list(/datum/antagonist/blob)
	antag_scaling_coeff = 1
	latejoin_antag_tags = list(MODE_BLOB)
	end_on_antag_death = TRUE
	var/under_quarantine = FALSE

/datum/game_mode/blob/check_finished()
	var/datum/antagonist/blob/A = antag_templates[1]

	for (var/datum/objective/O in A.global_objectives)
		if (istype(O, /datum/objective/blob) && O.completed)
			return TRUE

	if (A.antags_are_dead())
		return TRUE

	if (station_was_nuked)
		return TRUE

	return FALSE

/datum/objective/blob/infest
	explanation_text = "Capture"

/datum/objective/blob/infest/check_completion()
	return (blob_tiles_grown_total >= target_amount)

/datum/objective/blob/infest/New()
	..()

	var/total_turfs = 0
	var/station_level = GLOB.using_map.station_levels[1]

	for (var/turf/simulated/T in block(locate(1, 1, station_level), locate(world.maxx, world.maxy, station_level)))
		total_turfs++

	target_amount = round(0.7 * total_turfs)
	explanation_text = "OR: Infest [target_amount] tiles of [station_name()]."
