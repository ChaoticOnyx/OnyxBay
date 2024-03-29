/datum/spell/targeted/heal_slug
	name = "Healing slug"
	desc = "Cure slug injuries."

	invocation_type = SPI_NONE

	spell_flags = SELECTABLE | INCLUDEUSER
	range = 1
	max_targets = 1

	charge_max = 50

	compatible_mobs = list(/mob/living/simple_animal/hostile/slug)

	icon_state = "vamp_touch_of_life"

	cast_sound = 'sound/effects/squelch2.ogg'

/datum/spell/targeted/heal_slug/cast(list/targets, mob/user)
	for(var/mob/living/simple_animal/hostile/slug/H in targets)
		if (H.health < 20 || H.health >= H.maxHealth)
			to_chat(user, SPAN("warning", "Looks like there's no help here."))
			return

		if(!in_range(H, user))
			to_chat(user, "<span class='warning'>That was not so bright of you.</span>")
			return

		if(do_after(user, 50, H))
			H.health = min(H.health + 50, H.maxHealth)
