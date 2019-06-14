/spell/aoe_turf/conjure/summon
	var/name_summon = 0
	cast_sound = 'sound/weapons/wave.ogg'

/spell/aoe_turf/conjure/summon/before_cast()
	..()
	if(name_summon)
		var/newName = sanitize(input("Would you like to name your summon?") as null|text, MAX_NAME_LEN)
		if(newName)
			newVars["name"] = newName

/spell/aoe_turf/conjure/summon/conjure_animation(var/atom/movable/overlay/animation, var/turf/target)
	animation.icon_state = "shield2"
	flick("shield2",animation)
	sleep(10)
	..()


/spell/aoe_turf/conjure/summon/bats
	name = "Summon Space Bats"
	desc = "This spell summons a flock of spooky space bats."
	feedback = "SB"

	charge_max = 1200 //2 minutes
	spell_flags = NEEDSCLOTHES
	invocation = "Bla'yo daya!"
	invocation_type = SpI_SHOUT
	level_max = list(Sp_TOTAL = 3, Sp_SPEED = 3, Sp_POWER = 3)
	cooldown_min = 600

	range = 1

	summon_amt = 1
	summon_type = list(/mob/living/simple_animal/hostile/scarybat)

	hud_state = "wiz_bats"

/spell/aoe_turf/conjure/summon/bats/empower_spell()
	if(!..())
		return 0

	newVars = list("maxHealth" = 20 + spell_levels[Sp_POWER]*10, "health" = 20 + spell_levels[Sp_POWER]*10, "melee_damage_lower" = 10 + spell_levels[Sp_POWER]*3, "melee_damage_upper" = 10 + spell_levels[Sp_POWER]*5)

	return "Your bats are now stronger."

/spell/aoe_turf/conjure/summon/bear
	name = "Summon Bear"
	desc = "This spell summons a permanent bear companion that will follow your orders."
	feedback = "BR"
	charge_max = 3000 //5 minutes because this is a REALLY powerful spell. May tone it down/up.
	spell_flags = NEEDSCLOTHES
	invocation = "REA'YO GOR DAYA!"
	invocation_type = SpI_SHOUT
	level_max = list(Sp_TOTAL = 4, Sp_SPEED = 0, Sp_POWER = 4)

	range = 0

	name_summon = 1

	summon_amt = 1
	summon_type = list(/mob/living/simple_animal/hostile/commanded/bear)
	newVars = list("maxHealth" = 100,
				"health" = 100,
				"melee_damage_lower" = 20,
				"melee_damage_upper" = 20,
				)

	hud_state = "wiz_bear"

/spell/aoe_turf/conjure/summon/bear/before_cast()
	..()
	newVars["master"] = holder //why not do this in the beginning? MIND SWITCHING.

/spell/aoe_turf/conjure/summon/bear/empower_spell()
	if(!..())
		return 0
	switch(spell_levels[Sp_POWER])
		if(1)
			newVars = list("maxHealth" = 150,
						"health" = 150,
						"melee_damage_lower" = 20,
						"melee_damage_upper" = 25
						)
			return "Your bear has been upgraded from a cub to a whelp."
		if(2)
			newVars = list("maxHealth" = 200,
						"health" = 200,
						"melee_damage_lower" = 30,
						"melee_damage_upper" = 30,
						"color" = "#d9d9d9" //basically we want them to look different enough that people can recognize it.
						)
			return "Your bear has been upgraded from a whelp to an adult."
		if(3)
			newVars = list("maxHealth" = 250,
						"health" = 250,
						"melee_damage_lower" = 45,
						"melee_damage_upper" = 45,
						"color" = "#8c8c8c"
						)
			return "Your bear has been upgraded from an adult to an alpha."
		if(4)
			newVars = list("maxHealth" = 300,
						"health" = 300,
						"melee_damage_lower" = 55,
						"melee_damage_upper" = 55,
						"resistance" = 10,
						"color" = "#0099ff"
						)
			return "Your bear is now worshiped as a god amongst bears."