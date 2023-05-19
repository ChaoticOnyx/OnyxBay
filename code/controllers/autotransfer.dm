var/datum/controller/transfer_controller/transfer_controller

/datum/controller/transfer_controller
	var/timerbuffer = 0 //buffer for time check

/datum/controller/transfer_controller/New()
	timerbuffer = config.vote.autotransfer_initial
	set_next_think(world.time + 30 SECONDS)

/datum/controller/transfer_controller/think()
	if (time_till_transfer_vote() <= 0)
		SSvote.initiate_vote(/datum/vote/transfer, automatic = 1)
		timerbuffer += config.vote.autotransfer_interval
	
	set_next_think(world.time + 30 SECONDS)

/datum/controller/transfer_controller/proc/time_till_transfer_vote()
	return timerbuffer - round_duration_in_ticks - (1 MINUTE)
