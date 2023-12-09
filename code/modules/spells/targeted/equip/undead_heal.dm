/datum/spell/targeted/heal_target/area/undead_heal
	name = "Cure Area"
	desc = "This spell heals everyone in an area."
	feedback = "HA"
	charge_max = 600
	spell_flags = INCLUDEUSER
	invocation = "Nal Di'Nath!"
	range = 2
	max_targets = 0
	level_max = list(SP_TOTAL = 0, SP_SPEED = 0, SP_POWER = 0)
	icon_state = "undead_heal"

	amt_dam_brute = -25
	amt_dam_fire = -25

/datum/spell/targeted/heal_target/area/undead_heal/choose_targets()
	var/list/targets = list()

	for(var/mob/living/target in view_or_range(range, holder, selection_type))
		if(isundead(target))
			targets += target

	return targets
