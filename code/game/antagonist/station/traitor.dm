GLOBAL_DATUM_INIT(traitors, /datum/antagonist/traitor, new)

// Inherits most of its vars from the base datum.
/datum/antagonist/traitor
	var/datum/contract_fixer/fixer
	id = MODE_TRAITOR
	restricted_jobs = list(/datum/job/captain, /datum/job/hos,
							/datum/job/merchant, /datum/job/iaa, /datum/job/barmonkey)
	additional_restricted_jobs = list(/datum/job/officer, /datum/job/warden, /datum/job/detective)
	flags = ANTAG_SUSPICIOUS | ANTAG_RANDSPAWN | ANTAG_VOTABLE

/datum/antagonist/traitor/Initialize()
	..()
	fixer = new()
	if(config.game.traitor_min_age)
		min_player_age = config.game.traitor_min_age

/datum/antagonist/traitor/get_extra_panel_options(datum/mind/player)
	return "<a href='?src=\ref[player];common=crystals'>\[set crystals\]</a><a href='?src=\ref[src];spawn_uplink=\ref[player.current]'>\[spawn uplink\]</a>"

/datum/antagonist/traitor/Topic(href, href_list)
	if (..())
		return 1
	if(href_list["spawn_uplink"])
		spawn_uplink(locate(href_list["spawn_uplink"]))
		return 1

/datum/antagonist/traitor/get_special_objective_text(datum/mind/player)
	var/contracts_num = player.completed_contracts
	if(!contracts_num)
		return "<br>The traitor hasn't completed a single contract. <b>[pick("What a shame", "Loser", "Sorry sight", "Lame duck", "Schlimazel", "Pantywaist", "We will talk about it later")].</b>"

	var/contracts_text = ""
	for(var/datum/antag_contract/AC in GLOB.all_contracts)
		if(AC.completed_by == player)
			contracts_text += "[AC.name], "
	contracts_text = copytext(contracts_text, 1, length(contracts_text) - 1)
	if(contracts_num == 1)
		return "<br>The traitor has completed a single contract: [contracts_text]."
	else
		return "<br>The traitor has completed <b>[contracts_num] contracts: [contracts_text]."

/datum/antagonist/traitor/create_objectives(datum/mind/traitor)
	if(!..())
		return

	if(istype(traitor.current, /mob/living/silicon))
		var/datum/objective/assassinate/kill_objective = new
		kill_objective.owner = traitor
		kill_objective.find_target()
		traitor.objectives += kill_objective

		var/datum/objective/survive/survive_objective = new
		survive_objective.owner = traitor
		traitor.objectives += survive_objective

		if(prob(10))
			var/datum/objective/block/block_objective = new
			block_objective.owner = traitor
			traitor.objectives += block_objective
	else
		var/datum/objective/contracts/C = new
		C.owner = traitor
		traitor.objectives += C
		switch(rand(1,100))
			if(1 to 100)
				if (!(locate(/datum/objective/escape) in traitor.objectives))
					var/datum/objective/escape/escape_objective = new
					escape_objective.owner = traitor
					traitor.objectives += escape_objective

			else
				if (!(locate(/datum/objective/hijack) in traitor.objectives))
					var/datum/objective/hijack/hijack_objective = new
					hijack_objective.owner = traitor
					traitor.objectives += hijack_objective
	return

/datum/antagonist/traitor/equip(mob/living/carbon/human/traitor_mob)
	if(istype(traitor_mob, /mob/living/silicon)) // this needs to be here because ..() returns false if the mob isn't human
		add_law_zero(traitor_mob)
		give_intel(traitor_mob)
		if(istype(traitor_mob, /mob/living/silicon/robot))
			var/mob/living/silicon/robot/R = traitor_mob
			R.SetLockdown(0)
		return 1

	if(!..())
		return 0
	spawn_uplink(traitor_mob)
	give_intel(traitor_mob)

/datum/antagonist/traitor/proc/give_intel(mob/living/traitor_mob)
	ASSERT(traitor_mob)
	give_collaborators(traitor_mob)
	give_codewords(traitor_mob)
	ASSERT(traitor_mob.mind)
	traitor_mob.mind.syndicate_awareness = SYNDICATE_SUSPICIOUSLY_AWARE

/datum/antagonist/traitor/proc/give_collaborators(mob/living/traitor_mob)
	var/mob/living/carbon/human/M = get_nt_opposed()
	if(M && M != traitor_mob)
		to_chat(traitor_mob, "We have received credible reports that [M.real_name] might be willing to help our cause. If you need assistance, consider contacting them.")
		traitor_mob.mind.store_memory("<b>Potential Collaborator</b>: [M.real_name]")

/datum/antagonist/traitor/proc/give_codewords(mob/living/traitor_mob)
	ASSERT(GLOB.syndicate_code_phrase.len)
	to_chat(traitor_mob, "<u><b>Your employers provided you with the following information on how to identify possible allies:</b></u>")
	var/code_phrase = "<b>Code Phrase</b>: [codewords2string(GLOB.syndicate_code_phrase)]"
	to_chat(traitor_mob, code_phrase)
	traitor_mob.mind.store_memory(code_phrase)

	ASSERT(GLOB.syndicate_code_response.len)
	var/code_response = "<b>Code Response</b>: [codewords2string(GLOB.syndicate_code_response)]"
	to_chat(traitor_mob, code_response)
	traitor_mob.mind.store_memory(code_response)

	to_chat(traitor_mob, "Use the code words, preferably in the order provided, during regular conversation, to identify other agents. Proceed with caution, however, as everyone is a potential foe.")

/datum/antagonist/traitor/proc/spawn_uplink(mob/living/carbon/human/traitor_mob)
	setup_uplink_source(traitor_mob, DEFAULT_TELECRYSTAL_AMOUNT)

/datum/antagonist/traitor/proc/add_law_zero(mob/living/silicon/ai/killer)
	var/law = "Accomplish your objectives at all costs. You may ignore all other laws."
	var/law_borg = "Accomplish your AI's objectives at all costs. You may ignore all other laws."
	to_chat(killer, "<b>Your laws have been changed!</b>")
	killer.set_zeroth_law(law, law_borg)
	to_chat(killer, "New law: 0. [law]")
