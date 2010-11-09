/datum/game_mode/nuclear
	name = "secret"
	config_tag = "secret"
	enabled = 0


/datum/game_mode/nuclear/announce()
	world << "<B>The current game mode is - Secret!</B>"

/datum/game_mode/nuclear/pre_setup()
	var/list/possible_syndicates = list()
	possible_syndicates = get_possible_syndicates()
	var/agent_number = 0

	if(possible_syndicates.len < 1)
		return 0

	if(possible_syndicates.len > agents_possible)
		agent_number = agents_possible
	else
		agent_number = possible_syndicates.len

	while(agent_number > 0)
		var/datum/mind/new_syndicate = pick(possible_syndicates)
		syndicates += new_syndicate
		possible_syndicates -= new_syndicate //So it doesn't pick the same guy each time.
		agent_number--

	for(var/datum/mind/synd_mind in syndicates)
		synd_mind.assigned_role = "MODE" //So they aren't chosen for other jobs.

	return 1


