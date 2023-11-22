/datum/vote/restart
	name = "Restart"
	default_choices = list("Restart Round","Continue Playing")

/datum/vote/restart/can_be_initiated(mob/by_who, forced)
	if(!forced && (!config.vote.allow_vote_restart || !is_admin(by_who)))
		return FALSE // Admins and autovotes bypass the config setting.
	return ..()

/datum/vote/restart/finalize_vote(winning_option)
	if(..())
		return 1
	if(winning_option == "Restart Round")
		SSvote.restart_world()
