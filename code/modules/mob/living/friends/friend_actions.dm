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
	var/new_name = sanitizeName(input("Enter Friend Name", "Friend Name"))
	if(new_name)
		owner.real_name = new_name
		owner.name = new_name
		H?.name = new_name
		H?.real_name = new_name
	friend.Show()

/datum/action/friend_ability
	var/last_time_used
	var/ability_cooldown

/datum/action/friend_ability/Trigger()
	. = FALSE
	if(last_time_used + ability_cooldown > time)
		. = TRUE

/datum/action/friend_ability/force_say
	name = "Force Say Host"
	button_icon_state = "ability_mimespeech"
	ability_cooldown = 3 SECOND

/datum/action/friend_ability/force_say/friend_ability/Trigger()
	. = ..()
	if(.)
		var/mob/living/imaginary_friend/friend = owner
		var/mob/living/carbon/human/H = friend.host
		var/message = sanitize(input("Enter message to say", "Say"))
		if(message)
			H.forcesay(list(message))
			last_time_used = time
