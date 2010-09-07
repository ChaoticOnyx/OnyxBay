/datum/game_mode/sandbox
	name = "Sandbox"
	config_tag = "sandbox"

/datum/game_mode/sandbox/announce()
	..()
	world << "<B>Build your own station with the sandbox-panel command!</B>"

/datum/game_mode/sandbox/post_setup()
	for(var/client/C)
		C.mob.CanBuild()

	return 1

/datum/game_mode/sandbox/check_finished()
	return 0