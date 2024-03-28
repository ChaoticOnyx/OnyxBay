#define TELEPORT_DELAY 5 SECONDS

/datum/spell/devil_teleport
	name = "Teleport"
	desc = "Teleport."
	feedback = "DT"
	school = "conjuration"
	charge_max = 1 MINUTE
	invocation_type = SPI_NONE
	need_target = FALSE

	spell_flags = 0

	smoke_amt = 1
	smoke_spread = 5

	cast_sound = 'sound/effects/teleport.ogg'
	icon_state = "wiz_mark"

/datum/spell/devil_teleport/choose_targets(mob/user)
	var/mob/living/target = tgui_input_list(user, "Choose a follower to whom you will teleport.", "Targeting", user.mind?.deity?.followers)
	if(!istype(target))
		return

	return target

/datum/spell/devil_teleport/cast(mob/living/target, mob/user, channel_duration)
	if(do_after(user, TELEPORT_DELAY, user))
		user.forceMove(get_turf(target))
