/datum/action/cooldown/wrath_modifier
	cooldown_time = 0
	action_type = AB_INNATE
	name = "Wrath"
	check_flags = AB_CHECK_CONSCIOUS
	background_icon_state = "bg_spell"
	button_icon_state = "spell_default"
	overlay_icon_state = "bg_spell_border"
	active_overlay_icon_state = "bg_spell_border_active_blue"

/datum/action/cooldown/wrath_modifier/Activate()
	var/mob/living/living_owner = owner
	if(!istype(living_owner))
		return

	active = TRUE
	build_button_icon(button, UPDATE_BUTTON_OVERLAY)
	living_owner.add_mutation(MUTATION_STRONG)

/datum/action/cooldown/wrath_modifier/Deactivate()
	var/mob/living/living_owner = owner
	if(!istype(living_owner))
		return

	active = FALSE
	build_button_icon(button, UPDATE_BUTTON_OVERLAY)
	living_owner.remove_mutation(MUTATION_STRONG)
