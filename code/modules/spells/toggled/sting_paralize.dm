/datum/spell/toggled/sting_paralize
	name = "Sting paralize"
	desc = "The sting paralyzes the victim if she is nearby"
	invocation = "none"
	invocation_type = SPI_NONE
	need_target = FALSE
	icon_state = "ling_sting_base"
	mana_regen_per_tick = 10
	mana_max = 100
	mana_current = 100

/datum/spell/toggled/sting_paralize/New()
	mana_current = mana_max
	charge_counter = mana_max

/datum/spell/toggled/sting_paralize/check_charge(skipcharge, mob/user)
	if(!skipcharge)
		switch(charge_type)
			if(SP_RECHARGE)
				if(mana_current < mana_max)
					to_chat(user, still_recharging_msg)
					return FALSE
	return TRUE

/datum/spell/toggled/sting_paralize/activate()
	if(mana_current < mana_max)
		toggled = FALSE
		return FALSE
	var/mob/living/H = holder
	var/datum/click_handler/wizard/little_paralyse/C = H.PushClickHandler(/datum/click_handler/wizard/little_paralyse)
	if(!istype(C))
		return FALSE
	C.set_spell(src)
	to_chat(H, SPAN("danger", "Select target!"))
	return TRUE

/datum/spell/toggled/sting_paralize/deactivate(no_message = TRUE)
	var/mob/living/H = holder
	H.PopClickHandler()
	mana_current = 0
	charge_counter = mana_current
	set_next_think(world.time + 1 SECOND)
	. = ..()
	if(!.)
		return

/datum/spell/toggled/sting_paralize/think()
	if(mana_current < mana_max)
		mana_current = min(mana_max, mana_current + mana_regen_per_tick)
		charge_counter = mana_current
		update_screen_button()
	else
		return

	set_next_think(world.time + 1 SECOND)
