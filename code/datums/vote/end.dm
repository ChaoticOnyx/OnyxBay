/datum/vote/end_round
	name = "End Round"
	default_choices = list("End the Round", "Continue Playing")

/datum/vote/end_round/can_be_initiated(mob/by_who, forced)
	. = ..()
	if(GAME_STATE !=  RUNLEVEL_GAME)
		return FALSE
	if(forced || check_rights(R_SERVER, FALSE, by_who))
		return TRUE

/datum/vote/end_round/finalize_vote(winning_option)
	if(..())
		return TRUE
	if(winning_option == "End the Round")
		SSticker.force_end = TRUE
