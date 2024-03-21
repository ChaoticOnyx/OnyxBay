/datum/spell/toggled
	var/toggled = FALSE
	var/mana_current
	var/mana_max
	var/mana_drain_per_tick = FALSE
	var/mana_regen_per_tick = FALSE
	var/text_activate
	var/text_deactivate
	charge_type = SP_TOGGLED
	cast_delay = 0

/datum/spell/toggled/New()
	if(mana_drain_per_tick)
		set_next_think(world.time + 1 SECOND)

/datum/spell/toggled/cast(list/targets, mob/user)
	toggled = !toggled
	toggled ? activate() : deactivate()
	update_screen_button()

/datum/spell/toggled/proc/activate()
	if(mana_drain_per_tick && (mana_current - mana_drain_per_tick <= 0))
		toggled = FALSE
		return FALSE
	if(text_activate)
		to_chat(holder, SPAN("notice", text_activate))
	return TRUE

/datum/spell/toggled/proc/deactivate(no_message = TRUE)
	if(text_deactivate)
		to_chat(holder, SPAN("notice", text_deactivate))
	return TRUE

/datum/spell/toggled/think()
	if(toggled)
		mana_current -= mana_drain_per_tick
		if(mana_current <= 0)
			mana_current = 0
			toggled = FALSE
			deactivate()
	else if(mana_current < mana_max)
		mana_current = min(mana_max, mana_current + mana_regen_per_tick)

	update_screen_button()

	set_next_think(world.time + 1 SECOND)

/datum/spell/toggled/proc/update_screen_button()
	var/atom/movable/screen/ability/spell/S = connected_button
	if(!istype(S))
		return

	S.update_icon()
