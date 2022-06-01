GLOBAL_DATUM_INIT(changelings, /datum/antagonist/changeling, new)

/datum/antagonist/changeling
	id = MODE_CHANGELING
	role_text = "Changeling"
	role_text_plural = "Changelings"
	feedback_tag = "changeling_objective"
	restricted_jobs = list(/datum/job/captain, /datum/job/hos, /datum/job/hop,
							/datum/job/rd, /datum/job/chief_engineer, /datum/job/cmo,
							/datum/job/merchant, /datum/job/iaa)
	additional_restricted_jobs = list(/datum/job/officer, /datum/job/warden, /datum/job/detective)
	blacklisted_jobs = list(/datum/job/ai, /datum/job/cyborg)
	welcome_text = "Use say \",g message\" to communicate with your fellow changelings. Remember: you get all of their absorbed DNA if you absorb them."
	flags = ANTAG_SUSPICIOUS | ANTAG_RANDSPAWN | ANTAG_VOTABLE
	antaghud_indicator = "hudchangeling"

	faction = "changeling"

/datum/antagonist/changeling/Initialize()
	. = ..()
	if(config.game.changeling_min_age)
		min_player_age = config.game.changeling_min_age

	// Building purchasable powers list.
	if(!powerinstances.len)
		for(var/P in powers)
			powerinstances += new P()

/datum/antagonist/changeling/get_special_objective_text(datum/mind/player)
	var/powers_purchased = ""
	var/powers_num = 0
	for(var/datum/power/changeling/PC in player.changeling.purchasedpowers)
		if(!PC.genomecost)
			continue
		powers_num += 1
		powers_purchased += "[PC.name], "
	if(!powers_num)
		powers_purchased = "[powers_num]"
	else
		powers_purchased = "[powers_num] ([copytext(powers_purchased, 1, length(powers_purchased) - 1)])"
	return "<br><b>Changeling ID:</b> [player.changeling.changelingID].<br><b>Genomes Absorbed:</b> [player.changeling.absorbedcount]<br><b>Purchased Powers:</b> [powers_purchased]"

/datum/antagonist/changeling/update_antag_mob(datum/mind/player)
	. = ..()
	player.current.make_changeling()

/datum/antagonist/changeling/create_objectives(datum/mind/changeling)
	if(!..())
		return

	// OBJECTIVES - Always absorb 2 or 3 genomes, plus a random steal objective.
	// 20% chance they must simply survive rather than escape
	// No escape alone because changelings aren't suited for it and it'd probably just lead to rampant robusting
	// If it seems like they'd be able to do it in play, add a 10% chance to have to escape alone

	var/datum/objective/absorb/absorb_objective = new
	absorb_objective.owner = changeling
	absorb_objective.gen_amount_goal(2, 3)
	changeling.objectives += absorb_objective

	var/datum/objective/steal/steal_objective = new
	steal_objective.owner = changeling
	steal_objective.find_target()
	changeling.objectives += steal_objective

	switch(rand(1, 100))
		if(1 to 80)
			if(!(locate(/datum/objective/escape) in changeling.objectives))
				var/datum/objective/escape/changeling/escape_objective = new
				escape_objective.owner = changeling
				escape_objective.find_target()
				changeling.objectives += escape_objective
		else
			if(!(locate(/datum/objective/survive) in changeling.objectives))
				var/datum/objective/survive/changeling/survive_objective = new
				survive_objective.owner = changeling
				changeling.objectives += survive_objective
	return

/datum/antagonist/changeling/can_become_antag(datum/mind/player, ignore_role, max_stat)
	if(!..())
		return FALSE

	if(!player.current)
		return FALSE

	if(ishuman(player.current))
		var/mob/living/carbon/human/H = player.current
		if(H.isSynthetic())
			return FALSE
		if(H.species.species_flags & SPECIES_FLAG_NO_SCAN)
			return FALSE
		return TRUE

	if(isnewplayer(player.current) && player.current.client?.prefs)
		var/datum/species/S = all_species[player.current.client.prefs.species]
		if(S?.species_flags & SPECIES_FLAG_NO_SCAN)
			return FALSE
		if(player.current.client.prefs.organ_data[BP_CHEST] == "cyborg") // Full synthetic.
			return FALSE
		return TRUE

	return FALSE
