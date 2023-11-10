/datum/vote/transfer
	name = "Initiate Crew Transfer"
	override_question = "End the shift?"

/datum/vote/transfer/can_be_initiated(mob/by_who, forced)
	. = ..()
	if(!(. = ..()))
		return
	if(!evacuation_controller || !evacuation_controller.should_call_autotransfer_vote())
		return FALSE
	if(!forced && (!config.vote.allow_vote_restart || !is_admin(by_who)))
		return FALSE // Admins and autovotes bypass the config setting.
	if(check_rights(R_INVESTIGATE, 0, by_who))
		return //Mods bypass further checks.
	var/decl/security_state/security_state = decls_repository.get_decl(GLOB.using_map.security_state)
	if (!forced && security_state.current_security_level_is_same_or_higher_than(security_state.high_security_level))
		to_chat(by_who, "The current alert status is too high to call for a crew transfer!")
		return FALSE
	if(GAME_STATE <= RUNLEVEL_SETUP)
		to_chat(by_who, "The crew transfer button has been disabled!")
		return FALSE

/datum/vote/transfer/New()
	default_choices = list("Initiate Crew Transfer", "Extend the Round ([config.vote.autotransfer_interval / 600] minutes)")
	..()

/datum/vote/transfer/finalize_vote(winning_option)
	if(..())
		return 1
	if(winning_option == "Initiate Crew Transfer")
		init_autotransfer()
