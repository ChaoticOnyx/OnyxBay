/datum/wizard/undead
	var/mob/master = null
	var/mob/living/carbon/human/my_mob = null
	var/lichified = FALSE
	var/growth = 0
	can_reset_class = FALSE
	var/list/purchased_powers = list()

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
	set_next_think(world.time + 5 SECONDS)

/datum/wizard/undead/set_class()
	return

/datum/wizard/undead/proc/lichify()
	lichified = TRUE
	set_next_think(0)
	my_mob.spellremove()
	my_mob.add_spell(new /datum/spell/toggled/lich_form)
	my_mob.add_spell(new /datum/spell/aoe_turf/knock)
	my_mob.add_spell(new /datum/spell/targeted/projectile/magic_missile)
	my_mob.add_spell(new /datum/spell/hand/marsh_of_the_dead)
	my_mob.add_spell(new /datum/spell/toggled/immaterial_form)

/datum/wizard/undead/Destroy()
	my_mob = null
	master = null
	set_next_think(0)
	QDEL_NULL(undead_powerinstances)
	QDEL_NULL(purchased_powers)
	. = ..()
