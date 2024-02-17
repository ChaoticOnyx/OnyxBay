#define STUN_AMOUNT 2

/datum/spell/curse_of_terror
	name = "Curse of Terror"
	desc = 1//TODO
	feedback = 1//TODO
	school = 1//TODO
	charge_max = 100
	cooldown_reduc = 20
	spell_flags = 0
	invocation = 1//TODO
	invocation_type = 1//TODO
	range = 6
	level_max = list(SP_TOTAL = 0, SP_SPEED = 0, SP_POWER = 0)
	cooldown_min = 20 //20 deciseconds reduction per rank

	icon_state = "wiz_knock"

/datum/spell/curse_of_terror/cast(list/targets)
	for(var/mob/living/M in GLOB.living_mob_list_)
		if(get_dist(holder, get_turf(M)) > range)
			continue

		if(IS_DEITYSFOLLOWER(connected_god, M))
			continue

		to_chat(M, SPAN_DANGER("Primordial fear fills you!"))
		M.emote("scream_long")
		M.Stun(STUN_AMOUNT)

#undef STUN_AMOUNT

/datum/spell/curse_of_regret
	name = "Curse of Regret"
	desc = 1//TODO
	feedback = 1//TODO
	school = 1//TODO
	charge_max = 100
	cooldown_reduc = 20
	spell_flags = 0
	invocation = 1//TODO
	invocation_type = 1//TODO
	range = 6
	level_max = list(SP_TOTAL = 0, SP_SPEED = 0, SP_POWER = 0)
	cooldown_min = 20 //20 deciseconds reduction per rank

	icon_state = "wiz_knock"

/datum/spell/curse_of_regret/cast(list/targets)
	for(var/mob/living/M in GLOB.living_mob_list_)
		if(get_dist(holder, get_turf(M)) > range)
			continue

		if(IS_DEITYSFOLLOWER(connected_god, M))
			continue

		M.emote("scream_long")

/datum/spell/vengeance
	name = "Vengeance"
	desc = 1//TODO
	feedback = 1//TODO
	school = 1//TODO
	charge_max = 100
	cooldown_reduc = 20
	spell_flags = 0
	invocation = 1//TODO
	invocation_type = 1//TODO
	range = 6
	level_max = list(SP_TOTAL = 0, SP_SPEED = 0, SP_POWER = 0)
	cooldown_min = 20 //20 deciseconds reduction per rank

	icon_state = "wiz_knock"

/datum/spell/vengeance/choose_targets(mob/user)
	return user

/datum/spell/vengeance/cast(mob/living/user)
	user.add_modifier(/datum/modifier/vengeance, 10 SECONDS)

/datum/modifier/vengeance
	hidden = TRUE
	siemens_coefficient = 0
	incoming_damage_percent = 0.3
	pain_immunity = TRUE
