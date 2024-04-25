/datum/action/cooldown/expand_sight
	name = "Expand Sight"
	desc = "Boosts your sight range considerably, allowing you to see enemies from much further away."
	/// How far we expand the range to.
	var/range_expansion = 2
	cooldown_time = 1 SECOND
	action_type = AB_INNATE
	background_icon_state = "bg_spell"
	button_icon_state = "devil_expand_sight"
	overlay_icon_state = "bg_spell_border"
	active_overlay_icon_state = "bg_spell_border_active_blue"

/datum/action/cooldown/expand_sight/Activate()
	active = TRUE
	build_button_icon(button, UPDATE_BUTTON_OVERLAY)
	owner.client?.view_size.set_both(world.view + range_expansion, world.view + range_expansion)

/datum/action/cooldown/expand_sight/Deactivate()
	active = FALSE
	build_button_icon(button, UPDATE_BUTTON_OVERLAY)
	owner.client?.view_size.reset_to_default()
