/datum/spell/aoe_turf/disable_tech
	name = "Disable Tech"
	desc = "This spell disables all weapons, cameras and most other technology in range."
	feedback = "DT"
	charge_max = 400
	spell_flags = NEEDSCLOTHES
	invocation = "NEC CANTIO"
	invocation_type = SPI_SHOUT
	selection_type = "range"
	range = 0
	inner_radius = -1
	level_max = list(SP_TOTAL = 2, SP_SPEED = 2, SP_POWER = 2)
	cooldown_min = 200 //50 deciseconds reduction per rank
	hud_state = "wiz_tech"

	var/emp_heavy = 4
	var/emp_light = 6

/datum/spell/aoe_turf/disable_tech/cast(list/targets)
	for(var/turf/target in targets)
		empulse(get_turf(target), emp_heavy, emp_light)
	return

/datum/spell/aoe_turf/disable_tech/empower_spell()
	if(!..())
		return 0
	emp_heavy += 2
	emp_light += 2

	return "You've increased the range of [src]."
