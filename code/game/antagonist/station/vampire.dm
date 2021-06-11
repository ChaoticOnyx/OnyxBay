GLOBAL_DATUM_INIT(vampires, /datum/antagonist/vampire, new)

/proc/isvampire(mob/player)
	if(!GLOB.vampires|| !player.mind)
		return 0
	if(player.mind in GLOB.vampires.current_antagonists)
		return 1

/datum/antagonist/vampire
	id = MODE_VAMPIRE
	role_text = "Vampire"
	role_text_plural = "Vampires"
	feedback_tag = "vampire_objective"
	restricted_jobs = list(/datum/job/captain, /datum/job/hos, /datum/job/hop,
							/datum/job/rd, /datum/job/chief_engineer, /datum/job/cmo,
							/datum/job/merchant, /datum/job/lawyer)
	minimum_player_age = 7
	additional_restricted_jobs = list(/datum/job/officer, /datum/job/warden, /datum/job/detective)

	blacklisted_jobs = list(/datum/job/ai, /datum/job/cyborg, /datum/job/chaplain)
	welcome_text = "You are a Vampire! Use the \"<b>Vampire Help</b>\" command to learn about the backstory and mechanics! Stay away from the Chaplain, and use the darkness to your advantage."
	flags = ANTAG_SUSPICIOUS | ANTAG_RANDSPAWN | ANTAG_VOTABLE
	antaghud_indicator = "hudvampire"

/datum/antagonist/vampire/create_objectives(datum/mind/player)
	if(!..())
		return

	var/kill
	var/escape
	var/protect
	var/ghouls
	var/vampirize

	switch(rand(1,100))
		if(1 to 25)
			kill = 1
			escape = 1
		if(26 to 50)
			protect = 1
			escape = 1
		if(51 to 75)
			kill = 1
			vampirize = 1
		if(76 to 98)
			vampirize = 1
			escape = 1
		else
			ghouls = 1
			kill = 1
			escape = 1


	if(kill)
		var/datum/objective/assassinate/kill_objective = new
		kill_objective.owner = player
		kill_objective.find_target()
		player.objectives += kill_objective
	if(protect)
		var/datum/objective/ghouls/protect_objective = new
		protect_objective.owner = player
		protect_objective.find_target()
		player.objectives += protect_objective
	if(vampirize)
		var/datum/objective/vampirize/vampirize_objective = new
		vampirize_objective.owner = player
		vampirize_objective.find_target()
		player.objectives += vampirize_objective
	if(ghouls)
		var/datum/objective/ghouls/ghouls_objective = new
		ghouls_objective.owner = player
		player.objectives += ghouls_objective
	if(escape)
		var/datum/objective/survive/survive_objective = new
		survive_objective.owner = player
		player.objectives += survive_objective
	return

/datum/antagonist/vampire/update_antag_mob(datum/mind/player)
	..()
	player.current.make_vampire()


/datum/antagonist/vampire/can_become_antag(datum/mind/player, ignore_role)
	if(..())
		if(player.current)
			if(ishuman(player.current))
				var/mob/living/carbon/human/H = player.current
				if(H.isSynthetic())
					return 0
				if(H.species.species_flags & SPECIES_FLAG_NO_SCAN)
					return 0
				return 1
			else if(isnewplayer(player.current))
				if(player.current.client && player.current.client.prefs)
					var/datum/species/S = all_species[player.current.client.prefs.species]
					if(S && (S.species_flags & SPECIES_FLAG_NO_SCAN))
						return 0
					if(player.current.client.prefs.organ_data[BP_CHEST] == "cyborg") // Full synthetic.
						return 0
					return 1
 	return 0
