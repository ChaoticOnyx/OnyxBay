/datum/action/imaginary_join
	name = "Join"
	button_icon_state = "join"

/datum/action/imaginary_join/Trigger()
	var/mob/living/imaginary_friend/I = owner
	I.recall()

/datum/action/imaginary_hide
	name = "Hide"
	button_icon_state = "genetic_project"

/datum/action/imaginary_hide/proc/update_status()
	var/mob/living/imaginary_friend/I = owner
	if(I.hidden)
		name = "Show"
		button_icon_state = "genetic_view"
	else
		name = "Hide"
		button_icon_state = "genetic_incendiary"
	var/mob/living/cowner = owner
	Remove(cowner)
	Grant(cowner)

/datum/action/imaginary_hide/Trigger()
	var/mob/living/imaginary_friend/I = owner
	I.hidden = !I.hidden
	I.Show()
	update_status()

/datum/action/imaginary_appearance
	name = "Show Appearance Menu"
	button_icon_state = "genetic_project"

/datum/action/imaginary_appearance/Trigger()
	var/mob/living/imaginary_friend/friend = owner
	var/mob/living/carbon/human/H = friend.virtual_human
	if(istype(H)) H.change_appearance(APPEARANCE_ALL, friend, friend)
	friend.Show()
