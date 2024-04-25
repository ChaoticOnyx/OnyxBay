/datum/action/cooldown/spell/beam/chained/devil_arc_lighting
	name = "Arc lighting"
	button_icon_state = "devil_arc_lighting"
	max_beam_bounces = 5
	beam_sound = 'sound/magic/sound_magic_lightningshock.ogg'
	cooldown_time = 30 SECONDS
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_STUNNED | AB_CHECK_RESTRAINED

/datum/action/cooldown/spell/beam/chained/devil_arc_lighting/is_valid_target(atom/cast_on)
	return ..() && isliving(cast_on)

/datum/action/cooldown/spell/beam/chained/devil_arc_lighting/damage_from_beam(mob/living/target)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.handle_tasing(20, 3, ran_zone(), src)
	else
		target.stun_effect_act(20, 3, ran_zone(), src)

	target.apply_damage(10, BURN)
