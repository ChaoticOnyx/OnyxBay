mob/new_player/var/tmp/selecting_job = 0

var/global/started_jobselection = 0

mob/new_player/Stat()
	..()
	if(ticker.current_state == GAME_STATE_SELECTING_JOBS)
		statpanel("Jobs","Required Jobs")
		for(var/V in ticker.mode.required_jobs)
			var/suffx = ""
			var/right = ""
			if(ticker.mode.required_jobs[V] > 1) suffx = "([ticker.mode.required_jobs[V]])"
			for(var/datum/mind/M in ticker.mode.selected_jobs[V])
				right += M.key + " "
			statpanel("Jobs","[V][suffx]",right)
		statpanel("Jobs","Optional Jobs")
		for(var/V in ticker.mode.jobs)
			var/suffx = ""
			var/right = ""
			if(ticker.mode.jobs[V] > 1) suffx = "([ticker.mode.jobs[V]])"
			for(var/datum/mind/M in ticker.mode.selected_jobs[V])
				right += M.key + " "
			statpanel("Jobs","[V][suffx]",right)

mob/new_player/proc/change_job()
	var/result = input("Select a job you want to switch to","Switch Job") in (ticker.mode.required_jobs+ticker.mode.jobs)|null
	if(!result) return

	if(jobban_isbanned(src, result)) src << "<b>Nope, you're jobbanned!"

	if(!ticker.mode.selected_jobs[result])
		ticker.mode.selected_jobs[result] = list()

	var/list/members =  ticker.mode.selected_jobs[result]

	var/amount = ticker.mode.required_jobs[result]
	if(!amount) amount = ticker.mode.jobs[result]

	// make sure there's no null in members
	while(members.Find(null))
		members.Remove(null)

	if(members.len >= amount)
		src << "<b>That profession is already filled, you can ask someone else to swap with you."
	else
		for(var/V in ticker.mode.selected_jobs)
			var/list/L = ticker.mode.selected_jobs[V]
			if(istype(L) && L.Find(src.mind))
				L.Remove(src.mind)

		members.Add(src.mind)
		src.mind.assigned_role = result
		src << "* The position of [result] is yours!"
		ticker.mode.selected_jobs[result] = members


mob/new_player/proc/select_job_internal(result)

	if(jobban_isbanned(src, result)) return 0


	if(!ticker.mode.selected_jobs[result])
		ticker.mode.selected_jobs[result] = list()

	var/list/members =  ticker.mode.selected_jobs[result]

	var/amount = ticker.mode.required_jobs[result]
	if(!amount) amount = ticker.mode.jobs[result]

	// make sure there's no null in members
	while(members.Find(null))
		members.Remove(null)

	if(members.len >= amount)
		return 0
	else
		for(var/V in ticker.mode.selected_jobs)
			var/list/L = ticker.mode.selected_jobs[V]
			if(istype(L) && L.Find(src.mind))
				L.Remove(src.mind)

		members.Add(src.mind)
		src.mind.assigned_role = result
		ticker.mode.selected_jobs[result] = members
		return 1



proc/process_selecting_jobs()
	// give everyone the option to choose a job
	for(var/mob/new_player/player in world)
		if(player.client && player.ready && !player.mind.assigned_role && !player.selecting_job)
			player.selecting_job = 1
			player.verbs += /mob/new_player/proc/change_job

			// automatically select jobs from preferences
			if(ticker.mode.required_jobs[player.preferences.occupation1])
				if(player.select_job_internal(player.preferences.occupation1))
					continue
			if(ticker.mode.jobs[player.preferences.occupation1])
				if(player.select_job_internal(player.preferences.occupation1))
					continue
			if(ticker.mode.required_jobs[player.preferences.occupation2])
				if(player.select_job_internal(player.preferences.occupation2))
					continue
			if(ticker.mode.jobs[player.preferences.occupation2])
				if(player.select_job_internal(player.preferences.occupation2))
					continue
			if(ticker.mode.required_jobs[player.preferences.occupation3])
				if(player.select_job_internal(player.preferences.occupation3))
					continue
			if(ticker.mode.jobs[player.preferences.occupation3])
				if(player.select_job_internal(player.preferences.occupation3))
					continue

	// at least give them 30 seconds
	if(world.timeofday < started_jobselection + 300)
		return 0

	// after 4 minutes force-assign
	if(world.timeofday > started_jobselection + 10*60*4)
		for(var/V in ticker.mode.required_jobs)
			var/list/L = ticker.mode.selected_jobs[V]
			if(!L || L.len < ticker.mode.required_jobs[V])
				for(var/mob/new_player/player in world)
					if(player.client && player.selecting_job && !player.mind.assigned_role)
						world << "<b>Force-assigning [player.key] to the position of [V]!"
						player.select_job_internal(V)
						break
			L = ticker.mode.selected_jobs[V]
			if(!L || L.len < ticker.mode.required_jobs[V])
				for(var/mob/new_player/player in world)
					if(player.client && player.selecting_job && !ticker.mode.required_jobs[player.mind.assigned_role])
						world << "<b>Force-assigning [player.key] from [player.mind.assigned_role] to the position of [V]!"
						player.select_job_internal(V)
						break

	// check if we're done choosing jobs

	// CONDITION 1: all players have selected a job
	// IGNORE condition 1 if too much time has passed
	if(world.timeofday < started_jobselection + 900) for(var/mob/new_player/player in world)
		if(player.client && player.selecting_job && !player.mind.assigned_role)
			// he's selecting but hasn't selected yet, condition unmet
			return 0

	// CONDITION 2: all required positions are taken
	for(var/V in ticker.mode.required_jobs)
		var/list/L = ticker.mode.selected_jobs[V]
		if(!istype(L) || L.len < ticker.mode.required_jobs[V])
			// there's a required mode that hasn't been selected, condition unmet
			return 0

	// both conditions were met, job selection finished
	return 1

