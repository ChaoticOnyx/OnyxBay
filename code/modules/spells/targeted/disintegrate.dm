/spell/targeted/disintegrate
	name = "Disintegrate"
	desc = "This spell immediately and permanently destroys its victim."
	feedback = "DI"
	school = "conjuration"

	invocation = "Ei'Nath!"
	invocation_type = SpI_SHOUT

	level_max = list(Sp_TOTAL = 2, Sp_SPEED = 2, Sp_POWER = 0)

	spell_flags = INCLUDEUSER | SELECTABLE | NEEDSCLOTHES // Yep, you can EI NATH yourself ftw
	range = 1
	max_targets = 1

	charge_max = 1800
	cooldown_min = 900
	cooldown_reduc = 450

	compatible_mobs = list(/mob/living)

	hud_state = "wiz_disint"

	cast_sound = 'sound/effects/squelch2.ogg'

/spell/targeted/disintegrate/cast(var/list/targets, mob/user)
	for(var/mob/T in targets)
		if(!in_range(T, user))
			to_chat(user, "<span class='warning'>That was not so bright of you.</span>")
			return
		if(prob(5)) // Well why not?
			playsound(user.loc, 'sound/misc/bangindonk.ogg', 50, 1)

		T.gib()
