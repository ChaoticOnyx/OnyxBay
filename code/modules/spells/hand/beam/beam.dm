/datum/spell/hand/beam
	/// The radius around the caster to find a target.
	var/target_radius = 5
	/// Who's our initial beam target? Set in before cast, used in cast.
	var/atom/initial_target
	/// The maximum number of bounces the beam will go before stopping.
	var/max_beam_bounces = 1
	var/beam_duration = 0.5 SECONDS
	spell_flags = 0
	invocation_type = SPI_NONE
	icon_state = "wiz_burn"
	compatible_targets = list(/mob/living)
	level_max = list(SP_TOTAL = 0, SP_SPEED = 0, SP_POWER = 0)

/datum/spell/hand/beam/Destroy()
	initial_target = null // This like shouuld never hang references but I've seen some cursed things so let's be safe
	return ..()

/datum/spell/hand/beam/cast_hand(atom/target, mob/user)
	initial_target = target
	if(!istype(initial_target))
		return

	var/turf/origin = get_turf(user)
	if(!istype(origin))
		return

	send_beam(origin, initial_target, max_beam_bounces)
	initial_target = null

/datum/spell/hand/beam/proc/send_beam(atom/origin, atom/to_beam, bounces)
	origin.Beam(to_beam, icon_state = "lightning[rand(1,12)]", time = beam_duration)
