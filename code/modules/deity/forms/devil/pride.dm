/datum/spell/toggled/pride
	name = "Pride"
	desc = "Pride"
	feedback = "P"
	school = "inferno"
	spell_flags = INCLUDEUSER
	invocation = "none"
	invocation_type = SPI_NONE
	need_target = FALSE
	icon_state = "undead_lichform"

/datum/spell/toggled/pride/activate()
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/user = holder
	if(!istype(user))
		return FALSE

	for(var/datum/spell/toggled/pride/p_spell in user.mind?.learned_spells)
		if(p_spell == src)
			continue

		p_spell.toggled = FALSE
		p_spell.deactivate()
		p_spell.update_screen_button()

	return TRUE

/datum/spell/toggled/pride/mobility_form
	icon_state = "devil_meleeform"

/datum/spell/toggled/pride/melee_form/activate()
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/user = holder
	if(!istype(user))
		return FALSE

	ADD_TRAIT(user, /datum/modifier/pride_melee_form)
	return TRUE

/datum/spell/toggled/pride/melee_form/deactivate(no_message)
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/user = holder
	if(!istype(user))
		return FALSE

	REMOVE_TRAIT(user, /datum/modifier/pride_melee_form)
	return TRUE

/datum/spell/toggled/pride/mobility_form
	icon_state = "devil_tankform"

/datum/spell/toggled/pride/tank_form/activate()
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/user = holder
	if(!istype(user))
		return FALSE

	ADD_TRAIT(user, /datum/modifier/pride_tank_form)
	return TRUE

/datum/spell/toggled/pride/tank_form/deactivate(no_message)
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/user = holder
	if(!istype(user))
		return FALSE

	REMOVE_TRAIT(user, /datum/modifier/pride_tank_form)
	return TRUE

/datum/spell/toggled/pride/mobility_form
	icon_state = "devil_mobilityform"

/datum/spell/toggled/pride/mobility_form/activate()
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/user = holder
	if(!istype(user))
		return FALSE

	ADD_TRAIT(user, /datum/modifier/pride_speedy_form)
	return TRUE

/datum/spell/toggled/pride/mobility_form/deactivate(no_message)
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/user = holder
	if(!istype(user))
		return FALSE

	REMOVE_TRAIT(user, /datum/modifier/pride_speedy_form)
	return TRUE

/datum/spell/toggled/pride/mobility_form
	icon_state = "devil_regenform"

/datum/spell/toggled/pride/regen_form/activate()
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/user = holder
	if(!istype(user))
		return FALSE

	ADD_TRAIT(user, /datum/modifier/pride_regen_form)
	return TRUE

/datum/spell/toggled/pride/regen_form/deactivate(no_message)
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/user = holder
	if(!istype(user))
		return FALSE

	REMOVE_TRAIT(user, /datum/modifier/pride_regen_form)
	return TRUE

/datum/modifier/pride_melee_form
	outgoing_melee_damage_percent = 2
	evasion = 50

/datum/modifier/pride_tank_form
	incoming_damage_percent = 0.5
	incoming_healing_percent = 0

/datum/modifier/pride_speedy_form
	movespeed_modifier_path = /datum/movespeed_modifier/pride_speedboost

/datum/movespeed_modifier/pride_speedboost
	priority = MOVESPEED_PRIORITY_LAST
	flags = MOVESPEED_FLAG_OVERRIDING_SPEED
	slowdown = 1.5

/datum/modifier/pride_regen_form
	incoming_damage_percent = 1.5
	incoming_healing_percent = 1.5
