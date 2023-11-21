/datum/spell/targeted/noremorse
	name = "No remorse"
	desc = ""
	feedback = ""
	school = "necromancy"

	invocation = "Facite vindictam!"
	invocation_type = SPI_SHOUT

	spell_flags = SELECTABLE | NEEDSCLOTHES
	range = 7
	max_targets = 1

	charge_max = 1800
	cooldown_min = 900
	cooldown_reduc = 450

	compatible_mobs = list(/mob/living)

	icon_state = "wiz_noremorse"

	cast_sound = 'sound/effects/squelch2.ogg'

/datum/spell/targeted/noremorse/cast(list/targets, mob/user)
	var/mob/living/victim = targets[1]

	ADD_TRAIT(victim, TRAIT_GHOSTATTACKABLE)

	notify_ghosts("A powerful necromancer has allowed you to exact revenge on [victim] ", null, victim, action = NOTIFY_JUMP, posses_mob = FALSE)

/datum/modifier/status_effect/ghostattackable
	duration = 10 SECONDS
