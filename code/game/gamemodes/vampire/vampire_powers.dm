// Contains all /mob/procs that relate to vampire.
/datum/vampire_power
	var/name = "Power"
	var/desc = "Get the Power!"
	var/text_activate = "We use some power."

	var/icon = 'icons/hud/screen_spells.dmi'
	var/icon_state = "vamp_open"

	var/blood_cost = 0 // Blood required to use the ability
	var/blood_drain = 0 // Blood drain while active
	var/power_processing = FALSE
	var/active = FALSE
	var/cooldown = 0
	var/datum/vampire_cooldown_handler/CDH = null

	var/max_stat = CONSCIOUS // In what state we can use the ability
	var/ignore_veil = FALSE

	var/mob/living/carbon/human/my_mob = null
	var/datum/vampire/vampire

/datum/vampire_power/New(mob/_M)
	..()
	if(!_M?.mind?.vampire)
		qdel(src) // Something's terribly wrong, aborting.
		return
	my_mob = _M
	vampire = _M.mind.vampire
	vampire.available_powers.Add(src)
	update()

/datum/vampire_power/Destroy()
	deactivate()
	my_mob?.ability_master.remove_ability(my_mob.ability_master.get_ability_by_vampire_power(src))
	vampire?.available_powers.Remove(src)

	my_mob = null
	vampire = null
	QDEL_NULL(CDH)
	return ..()

/datum/vampire_power/proc/update()
	if(!my_mob.ability_master.get_ability_by_vampire_power(src))
		my_mob.ability_master.add_vampire_power(src)

/datum/vampire_power/proc/update_screen_button()
	var/atom/movable/screen/ability/vampire_power/VP = my_mob.ability_master.get_ability_by_vampire_power(src)
	VP?.update_icon()

/datum/vampire_power/proc/is_usable(no_message = FALSE)
	. = FALSE

	if(!my_mob?.mind)
		return

	if(!my_mob.mind.vampire)
		to_world_log("[my_mob] has the vampire verb ([src]) but is not a vampire.")
		return

	if(!vampire)
		to_world_log("[my_mob] has the vampire verb ([src]), but it's missing a vampire reference.")
		return

	if(cooldown)
		if(!no_message)
			if(prob(95))
				to_chat(my_mob, SPAN("warning", "The ability is not ready yet..."))
			else
				if(prob(70))
					to_chat(my_mob, SPAN("danger", "I'm not ready!"))
				else
					to_chat(my_mob, SPAN("danger", "I'M. NOT! READY!!!")) // Doto Seconda referencio
		return

	if(vampire.holder && !ignore_veil)
		if(!no_message)
			to_chat(my_mob, SPAN("warning", "You cannot use this power while walking through the Veil."))
		return

	if(my_mob.stat > max_stat) // Using this instead of check_incapacitated for less overhead.
		if(!no_message)
			to_chat(my_mob, SPAN("warning", "You are incapacitated."))
		return

	if(blood_cost > vampire.blood_usable)
		if(!no_message)
			to_chat(my_mob, SPAN("warning", "You do not have enough usable blood. [blood_cost] needed."))
		return

	return TRUE

/datum/vampire_power/proc/use_blood(amount)
	if(!amount)
		amount = blood_cost
	vampire.use_blood(amount)

/datum/vampire_power/proc/use()
	activate()
	update_screen_button()
	return

/datum/vampire_power/proc/activate()
	if(!is_usable())
		return FALSE
	active = TRUE
	return TRUE

/datum/vampire_power/proc/deactivate()
	active = FALSE
	return TRUE

/datum/vampire_power/proc/set_cooldown(value)
	cooldown = value
	if(!CDH)
		CDH = new /datum/vampire_cooldown_handler(src)
	CDH.start()
	update_screen_button()
	return

// Toggle-able powers
/datum/vampire_power/toggled
	name = "Toggled Power"
	power_processing = TRUE
	var/text_deactivate = "We stop using some power."
	var/text_noblood = "We stop using some power because we run out of blood."

/datum/vampire_power/toggled/use()
	active ? deactivate(FALSE) : activate()
	update_screen_button()

/datum/vampire_power/toggled/activate()
	. = ..()
	if(!.)
		return
	if(text_activate)
		to_chat(my_mob, SPAN("notice", text_activate))
	if(power_processing)
		set_next_think(world.time)

/datum/vampire_power/toggled/deactivate(no_message = TRUE)
	. = ..()
	if(!.)
		return
	if(!no_message && text_deactivate)
		to_chat(my_mob, SPAN("notice", text_deactivate))
	if(power_processing)
		set_next_think(0)

/datum/vampire_power/toggled/think()
	if(QDELETED(my_mob) || my_mob.stat > max_stat)
		deactivate()
		return FALSE
	if(blood_drain)
		use_blood(blood_drain)
		if(vampire.blood_usable <= 0)
			if(my_mob)
				if(text_noblood)
					to_chat(my_mob, SPAN("notice", text_noblood))
				deactivate()
				update_screen_button()
				return FALSE
	set_next_think(world.time + 1 SECOND)
	return TRUE


/datum/vampire_cooldown_handler
	var/datum/vampire_power/VP = null

/datum/vampire_cooldown_handler/New(datum/vampire_power/_VP)
	..()
	VP = _VP

/datum/vampire_cooldown_handler/proc/start()
	set_next_think(world.time + VP.cooldown)

/datum/vampire_cooldown_handler/Destroy()
	VP = null
	set_next_think(0)
	return ..()

/datum/vampire_cooldown_handler/think()
	VP.cooldown = 0
	VP.update_screen_button()
