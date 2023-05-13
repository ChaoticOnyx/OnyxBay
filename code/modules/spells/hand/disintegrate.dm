/datum/spell/hand/disintegrate
	name = "Disintegrate"
	desc = "This spell immediately and permanently destroys its victim."
	feedback = "DI"
	school = "conjuration"
	invocation = "Ei'Nath!"
	invocation_type = SPI_SHOUT
	level_max = list(SP_TOTAL = 2, SP_SPEED = 2, SP_POWER = 0)
	hand_state = "disintegrate"
	icon_state = "wiz_disint"
	show_message = " puts his hand on target head, it's starting to glow brightly."
	spell_flags = INCLUDEUSER | SELECTABLE | NEEDSCLOTHES // Yep, you can EI NATH yourself ftw
	range = 1
	charge_max = 1800
	cooldown_min = 900
	cooldown_reduc = 450
	compatible_targets = list(/mob/living)
	cast_sound = 'sound/effects/squelch2.ogg'

/datum/spell/hand/disintegrate/cast_hand(atom/A, mob/user)
	var/mob/living/target = A
	target.gib()
