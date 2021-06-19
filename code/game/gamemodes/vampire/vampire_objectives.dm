/datum/objective/vampirize/find_target()
	var/list/possible_targets = list()
	if(!possible_targets.len)
		for(var/mob/living/carbon/human/player in GLOB.player_list)
			if(player.mind && !(player.mind in GLOB.vampires.current_antagonists))
				possible_targets += player.mind
	if(possible_targets.len > 0)
		target = pick(possible_targets)
	if(target)
		explanation_text = "Vampirize [target.current.real_name], the [target.assigned_role]."
	else
		explanation_text = "Free Objective"

/datum/objective/vampirize/check_completion()
	if(target && target.current)
		// Check if they're converted
		if(target in GLOB.vampires.current_antagonists)
			return TRUE
		return FALSE

/datum/objective/ghouls
	var/amount = 1

/datum/objective/ghouls/New()
	amount = rand(2, 7)
	explanation_text = "Ghoul at least [amount] people"

/datum/objective/ghouls/check_completion()
	if(GLOB.thralls.current_antagonists.len >= amount)
		return TRUE
	else
		return FALSE
