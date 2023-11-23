/datum/wizard/undead
	var/mob/master = null
	var/mob/living/carbon/human/my_mob = null
	var/lichified = FALSE
	var/growth = 0
	can_reset_class = FALSE
	var/list/purchased_powers = list()
	var/list/available_powers = list()

	var/list/undead_powerinstances = list()

/datum/wizard/undead/New(mob/M, mob/necromancer)
	..()
	my_mob = M
	master = necromancer
	set_next_think(world.time + 5 SECONDS)
	M.add_spell(new /datum/spell/undead/undead_evolution)

	undead_powerinstances += new /datum/power/undead/armblade
	undead_powerinstances += new /datum/power/undead/heal

/datum/wizard/undead/think()
	growth += 1

/datum/wizard/undead/set_class()
	return

/datum/wizard/undead/proc/lichify()
	return

/datum/wizard/undead/Destroy()
	my_mob = null
	master = null
	QDEL_NULL(purchased_powers)
	. = ..()
