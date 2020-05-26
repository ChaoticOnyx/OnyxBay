/storyteller_trigger/spawn_antagonist
	name = "Spawn Unknown Antagonist"
	var/antagonist_id

/storyteller_trigger/spawn_antagonist/invoke()
	ASSERT(antagonist_id)
	var/datum/antagonist/antag = GLOB.all_antag_types_[antagonist_id]
	var/result = antag.attempt_auto_spawn(called_by_storyteller=TRUE)
	_log_debug("[capitalize(antagonist_id)] was tried to be spawned. Success: [result]")
	return result

/storyteller_trigger/spawn_antagonist/traitor/New()
	name = "Spawn Traitor"
	antagonist_id = "traitor"

/storyteller_trigger/spawn_antagonist/changeling/New()
	name = "Spawn Changeling"
	antagonist_id = "changeling"
