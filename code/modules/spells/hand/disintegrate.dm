/datum/spell/hand/disintegrate
	name = "Disintegrate"
	desc = "This spell immediately and permanently destroys its victim."
	feedback = "DI"
	school = "conjuration"
	invocation = "Ei'Nath!"
	invocation_type = SPI_SHOUT
	level_max = list(SP_TOTAL = 2, SP_SPEED = 2, SP_POWER = 0)
	hand_state = "domination_spell"
	icon_state = "wiz_disint"
	show_message = " puts his hand on target head, it's starting to glow brightly."
	spell_flags = INCLUDEUSER | SELECTABLE | NEEDSCLOTHES // Yep, you can EI NATH yourself ftw
	range = 1
	charge_max = 1800
	cooldown_min = 900
	cooldown_reduc = 450
	compatible_targets = list(/mob/living)
	cast_sound = 'sound/effects/squelch2.ogg'

/datum/spell/hand/disintegrate/cast(list/targets, mob/user, channel)
	for(var/mob/M in targets)
		if(M.get_active_hand())
			to_chat(user, SPAN_WARNING("You need an empty hand to cast this spell."))
			return
		var/obj/item/magic_hand/control_hand/H = new (src)
		if(!M.put_in_active_hand(H))
			qdel(H)
			return
	return 1

/datum/spell/hand/disintegrate/cast_hand(atom/A, mob/user)
	var/mob/living/target = A
	target.gib()