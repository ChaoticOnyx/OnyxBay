/datum/event/blob
	announceWhen = 30
	endWhen = -1

	var/mob/living/carbon/antag_mob = null
	var/datum/antagonist/blob/blob_antag = null

/datum/event/blob/setup()
	blob_antag = get_antag_data("blob")

	var/mills = round_duration_in_ticks
	var/mins = round((mills % 36000) / 600)

	// Do not spawn a blob if the round is longer than 50 minutes
	if (mins > 50)
		kill()
		return

	// Do not spawn more than 1 blob
	if (blob_antag.current_antagonists.len)
		return 0

	for (var/mob/living/carbon/M in GLOB.player_list)
		if(!M.client)
			continue
		if (!M.is_dead() && ("blob" in M.client.prefs.be_special_role) && blob_antag.can_become_antag(M.mind, FALSE) && !M.mind.special_role && !player_is_antag(M.mind))
			antag_mob = M
			break

	if (!antag_mob)
		kill()
		return

	log_and_message_admins("[key_name(antag_mob)] now a blobe.", null)
	blob_antag.add_antagonist(antag_mob.mind, FALSE, TRUE, FALSE, TRUE, TRUE)

/datum/event/blob/process()
	if(activeFor > startWhen && activeFor < endWhen)
		tick()

	if(activeFor == startWhen)
		isRunning = 1
		start()

	if(activeFor == announceWhen)
		announce()

	if(activeFor == endWhen)
		isRunning = 0
		end()

	activeFor++
