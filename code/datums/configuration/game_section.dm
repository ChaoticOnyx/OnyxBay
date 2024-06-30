/datum/configuration_section/game
	name = "game"

	var/default_view
	var/default_view_wide

	var/events_preset
	var/map_switching
	var/auto_map_switching
	var/auto_map_vote
	var/assistant_maint
	var/continuous_rounds
	var/enter_allowed
	var/jobs_have_minimal_access
	var/use_age_restriction_for_jobs
	var/use_age_restriction_for_antags
	var/ghost_spawners

	var/traitor_min_age
	var/changeling_min_age
	var/ninja_min_age
	var/raider_min_age
	var/nuke_min_age
	var/wizard_min_age
	var/xeno_min_age
	var/malf_min_age
	var/cultist_min_age
	var/blob_min_age
	var/actor_min_age
	var/ert_min_age
	var/revolutionary_min_age
	var/vampire_min_age
	var/thrall_min_age
	var/renegade_min_age
	var/borer_min_age
	var/loyalist_min_age
	var/meme_min_age
	var/deathsquad_min_age
	var/commando_min_age
	var/deity_min_age
	var/godcultist_min_age
	var/loyalists_min_age

	var/disable_ooc_at_roundstart
	var/disable_looc_at_roundstart
	var/use_recursive_explosions
	var/generate_asteroid
	var/use_loyalty_implants
	var/guest_jobban
	var/guests_allowed
	var/pregame_timeleft
	var/restart_timeout

/datum/configuration_section/game/load_data(list/data)
	CONFIG_LOAD_STR(default_view, data["default_view"])
	CONFIG_LOAD_STR(default_view_wide, data["default_view_wide"])

	CONFIG_LOAD_STR(events_preset, data["events_preset"])
	CONFIG_LOAD_BOOL(map_switching, data["map_switching"])
	CONFIG_LOAD_BOOL(auto_map_switching, data["auto_map_switching"])
	CONFIG_LOAD_BOOL(auto_map_vote, data["auto_map_vote"])
	CONFIG_LOAD_BOOL(assistant_maint, data["assistant_maint"])
	CONFIG_LOAD_BOOL(continuous_rounds, data["continuous_rounds"])
	CONFIG_LOAD_BOOL(enter_allowed, data["enter_allowed"])
	CONFIG_LOAD_BOOL(jobs_have_minimal_access, data["jobs_have_minimal_access"])
	CONFIG_LOAD_BOOL(use_age_restriction_for_jobs, data["use_age_restriction_for_jobs"])
	CONFIG_LOAD_BOOL(use_age_restriction_for_antags, data["use_age_restriction_for_antags"])
	CONFIG_LOAD_BOOL(ghost_spawners, data["ghost_spawners"])

	CONFIG_LOAD_NUM(traitor_min_age, data["traitor_min_age"])
	CONFIG_LOAD_NUM(changeling_min_age, data["changeling_min_age"])
	CONFIG_LOAD_NUM(ninja_min_age, data["ninja_min_age"])
	CONFIG_LOAD_NUM(raider_min_age, data["raider_min_age"])
	CONFIG_LOAD_NUM(nuke_min_age, data["nuke_min_age"])
	CONFIG_LOAD_NUM(wizard_min_age, data["wizard_min_age"])
	CONFIG_LOAD_NUM(xeno_min_age, data["xeno_min_age"])
	CONFIG_LOAD_NUM(malf_min_age, data["malf_min_age"])
	CONFIG_LOAD_NUM(cultist_min_age, data["cultist_min_age"])
	CONFIG_LOAD_NUM(blob_min_age, data["blob_min_age"])
	CONFIG_LOAD_NUM(actor_min_age, data["actor_min_age"])
	CONFIG_LOAD_NUM(revolutionary_min_age, data["revolutionary_min_age"])
	CONFIG_LOAD_NUM(vampire_min_age, data["vampire_min_age"])
	CONFIG_LOAD_NUM(thrall_min_age, data["thrall_min_age"])
	CONFIG_LOAD_NUM(renegade_min_age, data["renegade_min_age"])
	CONFIG_LOAD_NUM(borer_min_age, data["borer_min_age"])
	CONFIG_LOAD_NUM(loyalist_min_age, data["loyalist_min_age"])
	CONFIG_LOAD_NUM(meme_min_age, data["meme_min_age"])
	CONFIG_LOAD_NUM(deathsquad_min_age, data["deathsquad_min_age"])
	CONFIG_LOAD_NUM(commando_min_age, data["commando_min_age"])
	CONFIG_LOAD_NUM(deity_min_age, data["deity_min_age"])
	CONFIG_LOAD_NUM(godcultist_min_age, data["godcultist_min_age"])
	CONFIG_LOAD_NUM(loyalists_min_age, data["loyalists_min_age"])

	CONFIG_LOAD_BOOL(disable_ooc_at_roundstart, data["disable_ooc_at_roundstart"])
	CONFIG_LOAD_BOOL(disable_looc_at_roundstart, data["disable_looc_at_roundstart"])
	CONFIG_LOAD_BOOL(use_recursive_explosions, data["use_recursive_explosions"])
	CONFIG_LOAD_BOOL(generate_asteroid, data["generate_asteroid"])
	CONFIG_LOAD_BOOL(use_loyalty_implants, data["use_loyalty_implants"])
	CONFIG_LOAD_BOOL(guest_jobban, data["guest_jobban"])
	CONFIG_LOAD_BOOL(guests_allowed, data["guests_allowed"])
	CONFIG_LOAD_NUM(pregame_timeleft, data["pregame_timeleft"])
	CONFIG_LOAD_NUM(restart_timeout, data["restart_timeout"])
