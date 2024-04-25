/datum/action/cooldown/spell/aoe/repulse
	/// The max throw range of the repulsioon.
	var/max_throw = 5
	/// A visual effect to be spawned on people who are thrown away.
	var/obj/effect/sparkle_path = /obj/effect/gravpush

/datum/action/cooldown/spell/aoe/repulse/get_things_to_cast_on(atom/center)
	var/list/things = list()
	for(var/atom/movable/nearby_movable in view(aoe_radius, center))
		if(nearby_movable == owner || nearby_movable == center)
			continue
		if(nearby_movable.anchored)
			continue

		things += nearby_movable

	return things

/datum/action/cooldown/spell/aoe/repulse/cast_on_thing_in_aoe(atom/movable/victim, atom/caster)
	var/turf/throwtarget = get_edge_target_turf(caster, get_dir(caster, get_step_away(victim, caster)))
	var/dist_from_caster = get_dist(victim, caster)

	if(dist_from_caster == 0)
		if(isliving(victim))
			var/mob/living/victim_living = victim
			victim_living.Paralyse(10)
			victim_living.adjustBruteLoss(5)
			to_chat(victim, SPAN_DANGER("You're slammed into the floor by [caster]!"))
	else
		if(sparkle_path)
			// Created sparkles will disappear on their own
			new sparkle_path(get_turf(victim), get_dir(caster, victim))

		if(isliving(victim))
			var/mob/living/victim_living = victim
			victim_living.Paralyse(4)
			to_chat(victim, SPAN_DANGER("You're thrown back by [caster]!"))

		victim.throw_at(throwtarget, ((clamp((max_throw - (clamp(dist_from_caster - 2, 0, dist_from_caster))), 3, max_throw))), 1, caster)

/obj/effect/gravpush
	icon = 'icons/effects/effects.dmi'
	name = "gravity wave"
	icon_state = "shieldsparkles"

/obj/effect/gravpush/New()
	QDEL_IN(src, 0.5 SECONDS)
	return ..()
