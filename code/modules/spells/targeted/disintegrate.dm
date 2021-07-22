/datum/spell/targeted/disintegrate
	name = "Disintegrate"
	desc = "This spell immediately and permanently destroys its victim."
	feedback = "DI"
	school = "conjuration"

	invocation = "Ei'Nath!"
	invocation_type = SPI_SHOUT

	level_max = list(SP_TOTAL = 2, SP_SPEED = 2, SP_POWER = 0)

	spell_flags = INCLUDEUSER | SELECTABLE | NEEDSCLOTHES // Yep, you can EI NATH yourself ftw
	range = 1
	max_targets = 1

	charge_max = 1800
	cooldown_min = 900
	cooldown_reduc = 450

	compatible_mobs = list(/mob/living)

	icon_state = "wiz_disint"

	cast_sound = 'sound/effects/squelch2.ogg'

/datum/spell/targeted/disintegrate/cast(list/targets, mob/user)
	for(var/mob/T in targets)
		if(!in_range(T, user))
			to_chat(user, "<span class='warning'>That was not so bright of you.</span>")
			return
		if(prob(5)) // Well why not?
			playsound(user.loc, 'sound/misc/bangindonk.ogg', 50, 1)

		T.gib()
