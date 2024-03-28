#define ASTRAL_TIME_MAX 10 SECONDS

/datum/spell/devil_astral
	name = "Astral"
	desc = "ATSRAL."
	feedback = "AST"
	school = "conjuration"
	charge_max = 2 MINUTES
	invocation_type = SPI_NONE
	need_target = FALSE

	spell_flags = 0

	smoke_amt = 1
	smoke_spread = 5

	need_target = FALSE

	cast_sound = 'sound/effects/teleport.ogg'
	icon_state = "wiz_mark"

	var/turf/enter_turf
	var/has_exited_manually = FALSE

/datum/spell/devil_astral/cast(target, mob/user, channel_duration)
	var/mob/living/deity/D = user.mind.deity
	ASSERT(D)

	enter_turf = get_turf(user)
	user.forceMove(D)
	D.eyeobj.possess(user)
	set_next_think(world.time + ASTRAL_TIME_MAX)

/datum/spell/devil_astral/think()
	var/mob/living/_holder = holder
	ASSERT(_holder)

	var/mob/living/deity/D = _holder.mind.deity
	ASSERT(D)

	if(has_exited_manually)
		return

	to_chat(holder, SPAN_DANGER("Your time is up!"))
	holder.forceMove(enter_turf)
	D.eyeobj.release(holder)
	_holder.reset_view(_holder)

/datum/spell/devil_astral/Destroy()
	enter_turf = null
	return ..()

#undef ASTRAL_TIME_MAX
