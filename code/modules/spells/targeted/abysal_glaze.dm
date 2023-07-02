/datum/spell/targeted/abyssal_gaze
	name = "Abyssal Gaze"
	//desc = "This spell instills a deep terror in your target, temporarily chilling and blinding it."
	spell_flags = 0
	overlay_icon_state = "abyssal_gaze"
	range = 1
	max_targets = 1

	charge_max = 1800
	cooldown_min = 900
	cooldown_reduc = 450
	var/antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY

	/// The duration of the blind on our target
	var/blind_duration = 4 SECONDS
	/// The amount of temperature we take from our target
	var/amount_to_cool = 200

/datum/spell/targeted/abyssal_gaze/proc/is_valid_target(atom/cast_on)
	return iscarbon(cast_on)

/datum/spell/targeted/abyssal_gaze/cast(atom/target)
	if(!is_valid_target(target))
		return

	var/mob/living/carbon/cast_on = target

	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(holder, SPAN_WARNING("The spell had no effect!"))
		to_chat(cast_on, SPAN_WARNING("You feel a freezing darkness closing in on you, but it rapidly dissipates."))
		return FALSE

	to_chat(cast_on, SPAN_DANGER("A freezing darkness surrounds you..."))
	cast_on.playsound_local(get_turf(cast_on), 'sound/hallucinations/i_see_you1.ogg', 50, 1)
	if(ismob(holder))
		var/mob/M = holder
		M.playsound_local(get_turf(holder), 'sound/effects/ghost2.ogg', 50, 1)
	cast_on.eye_blind = blind_duration
	cast_on.bodytemperature += -amount_to_cool
