/datum/action/imaginary_join
	name = "Join"
	desc = "Join your owner, following them from inside their mind."
	background_icon_state = "summons"
	button_icon_state = "join"

/datum/action/imaginary_join/Trigger()
	var/mob/observer/imaginary_friend/I = owner
	I.recall()

/datum/action/imaginary_hide
	name = "Hide"
	desc = "Hide yourself from your owner's sight."
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	background_icon_state = "bg_revenant"
	button_icon_state = "genetic_project"

/datum/action/imaginary_hide/proc/update_status()
	var/mob/observer/imaginary_friend/I = owner
	if(I.hidden)
		name = "Show"
		desc = "Become visible to your owner."
		button_icon_state = "genetic_view"
	else
		name = "Hide"
		desc = "Hide yourself from your owner's sight."
		button_icon_state = "genetic_incendiary"
	UpdateButtonIcon()

/datum/action/imaginary_hide/Trigger()
	var/mob/observer/imaginary_friend/I = owner
	I.hidden = !I.hidden
	I.Show()
	update_status()

/datum/action/imaginary_appearance
	name = "Show Appearance Menu"
	desc = "Edit your friend's human"
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	background_icon_state = "bg_revenant"
	button_icon_state = "genetic_project"

/datum/action/imaginary_appearance/Trigger
	var/mob/observer/imaginary_friend/IM = owner
	var/mob/living/carbon/human/H = IM.virtual_human
	if(istype(H) H.change_appearance(APPEARANCE_ALL, IM, IM)
	IM.Show()
