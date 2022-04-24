/datum/spell/aoe_turf/knock
	name = "Knock"
	desc = "This spell opens nearby doors and does not require wizard garb."
	feedback = "KN"
	school = "transmutation"
	charge_max = 100
	cooldown_reduc = 20
	spell_flags = 0
	invocation = "Aulie Oxin Fiera."
	invocation_type = SPI_WHISPER
	range = 3
	level_max = list(SP_TOTAL = 4, SP_SPEED = 4, SP_POWER = 1)
	cooldown_min = 20 //20 deciseconds reduction per rank

	icon_state = "wiz_knock"

/datum/spell/aoe_turf/knock/cast(list/targets)
	for(var/turf/T in targets)
		for(var/obj/machinery/door/door in T.contents)
			spawn(1)
				if(istype(door,/obj/machinery/door/airlock))
					var/obj/machinery/door/airlock/AL = door //casting is important
					AL.locked = FALSE
				door.open(TRUE)
	return


/datum/spell/aoe_turf/knock/empower_spell()
	if(!..())
		return FALSE
	range *= 2

	return "You've doubled the range of [src]."
