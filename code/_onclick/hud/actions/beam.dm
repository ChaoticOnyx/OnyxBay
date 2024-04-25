/**
 * Beam action (spell)
 *
 * A spell that launches a beam towards its target
 */
/datum/action/cooldown/spell/beam
	check_flags = EMPTY_BITFIELD
	click_to_activate = TRUE
	/// Who's our initial beam target? Set in before cast, used in cast.
	var/mob/living/initial_target
	/// The maximum number of bounces the beam will go before stopping.
	var/max_beam_bounces = 1
	//// Sound played on succeseful cast
	var/beam_sound = null

/datum/action/cooldown/spell/beam/Destroy()
	initial_target = null
	return ..()

/datum/action/cooldown/spell/beam/cast(atom/target)
	initial_target = target
	var/turf/origin = get_turf(owner)
	if(!istype(origin))
		return

	send_beam(origin, initial_target, max_beam_bounces)

/datum/action/cooldown/spell/beam/proc/send_beam(atom/origin, atom/to_beam, bounces)
	origin.Beam(to_beam, icon_state = "lightning[rand(1,12)]", time = 1)
	playsound(to_beam, beam_sound, 50, vary = TRUE, extrarange = -1)
	damage_from_beam(to_beam)

/// Override for special damaging behavior
/datum/action/cooldown/spell/beam/proc/damage_from_beam(atom/to_beam)
	pass()

/**
 * Chained beam action (spell)
 *
 * Launches a beam towards its target
 * And finds another target, repeating this process until it runs out of max_beam_bounces.
 */

/datum/action/cooldown/spell/beam/chained
	max_beam_bounces = 5
	/// Cooldown before sending another beam
	var/beam_duration = 0.5 SECONDS
	/// The radius around the caster to find a target.
	var/target_radius = 3

/datum/action/cooldown/spell/beam/chained/New()
	add_think_ctx("continue_beam", CALLBACK(src, nameof(.proc/continue_beam)), 0)

/datum/action/cooldown/spell/beam/chained/send_beam(atom/origin, atom/to_beam, bounces = max_beam_bounces)
	origin.Beam(to_beam, icon_state = "lightning[rand(1,12)]", time = beam_duration)
	if(bounces >= 1)
		playsound(to_beam, beam_sound, 50, vary = TRUE, extrarange = -1)
		set_next_think_ctx("continue_beam", world.time + beam_duration, to_beam, bounces)

/datum/action/cooldown/spell/beam/chained/proc/continue_beam(mob/living/carbon/beamed, bounces)
	var/mob/living/carbon/to_beam_next = get_target(beamed)
	if(!istype(to_beam_next))
		return

	send_beam(beamed, to_beam_next, bounces - 1)

/datum/action/cooldown/spell/beam/chained/proc/get_target(atom/center)
	var/list/possibles = list()
	var/list/priority_possibles = list()
	for(var/mob/living/carbon/to_check in view(target_radius, center))
		if(to_check == center || to_check == owner)
			continue

		possibles += to_check

	if(!length(possibles))
		return null

	return length(priority_possibles) ? pick(priority_possibles) : pick(possibles)
