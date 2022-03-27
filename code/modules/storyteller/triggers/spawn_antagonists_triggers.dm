/storyteller_trigger/spawn_antagonist
	name = "Spawn Unknown Antagonist"
	var/antagonist_id

/storyteller_trigger/spawn_antagonist/can_be_invoked()
	return !!antagonist_id

/storyteller_trigger/spawn_antagonist/invoke()
	ASSERT(antagonist_id)
	var/datum/antagonist/antag = GLOB.all_antag_types_[antagonist_id]
	var/result = antag.attempt_auto_spawn(called_by_storyteller=TRUE)
	_log_debug("[capitalize(antagonist_id)] was tried to be spawned. Success: [result]")
	return result

/storyteller_trigger/spawn_antagonist/traitor/New()
	name = "Spawn Traitor"
	antagonist_id = MODE_TRAITOR

/storyteller_trigger/spawn_antagonist/changeling/New()
	name = "Spawn Changeling"
	antagonist_id = MODE_CHANGELING

/storyteller_trigger/spawn_antagonist/vampire/New()
	name = "Spawn Vampire"
	antagonist_id = MODE_VAMPIRE

/storyteller_trigger/spawn_antagonist/wizard/New()
	name = "Spawn Wizard"
	antagonist_id = MODE_WIZARD

/storyteller_trigger/spawn_antagonist/ninja/New()
	name = "Spawn Ninja"
	antagonist_id = MODE_NINJA

/storyteller_trigger/spawn_antagonist/borer/New()
	name = "Spawn Borer"
	antagonist_id = MODE_BORER
