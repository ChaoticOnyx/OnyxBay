#define ASTRAL_TIME_MAX 10 SECONDS

/datum/action/cooldown/spell/devil_astral
	name = "Astral"
	desc = "devil_astral."
	button_icon_state = "devil_astral"

	cooldown_time = 0 SECONDS
	smoke_amt = 2
	sound = 'sound/effects/teleport.ogg'
	var/turf/entry_turf

/datum/action/cooldown/spell/devil_astral/New()
	. = ..()
	add_think_ctx("exit_context", CALLBACK(src, nameof(.proc/time_out)), 0)

/datum/action/cooldown/spell/devil_astral/Destroy()
	entry_turf = null
	return ..()

/datum/action/cooldown/spell/devil_astral/cast()
	var/mob/living/deity/D = owner.mind?.deity
	ASSERT(D)

	entry_turf = get_turf(owner)
	owner.forceMove(D)
	owner.mind.transfer_to(D)
	owner.teleop = D
	set_next_think_ctx("exit_context", world.time + ASTRAL_TIME_MAX)

/datum/action/cooldown/spell/devil_astral/proc/time_out()
	var/mob/living/deity/D = owner.teleop
	ASSERT(D)

	to_chat(D, SPAN_DANGER("Your time is up!"))
	D.mind.transfer_to(owner)
	D.teleop = owner
	owner.teleop = null
	owner.forceMove(entry_turf)
	D.eyeobj.release(owner)
	owner.reset_view(owner)

#undef ASTRAL_TIME_MAX
