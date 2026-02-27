/mob/living/carbon/larva/diona/update_icons()

	if(is_ooc_dead())
		icon_state = "[initial(icon_state)]_dead"
	else if(lying || resting || stunned)
		icon_state = "[initial(icon_state)]_sleep"
	else
		icon_state = "[initial(icon_state)]"

	ClearOverlays()
	if(hat)
		AddOverlays(get_hat_icon(hat, 0, -8))
