/atom/movable/screen/gun
	name = "gun"
	master = null
	dir = 2

/atom/movable/screen/gun/Click(location, control, params)
	if(!usr)
		return
	return 1

/atom/movable/screen/gun/move
	name = "Allow Movement"
	icon_state = "walk_off"
	screen_loc = ui_gun2

/atom/movable/screen/gun/move/Click(location, control, params)
	if(..())
		var/mob/living/user = usr
		if(istype(user))
			if(!user.aiming) user.aiming = new(user)
			user.aiming.toggle_permission(TARGET_CAN_MOVE)
		return 1
	return 0

/atom/movable/screen/gun/item
	name = "Allow Item Use"
	icon_state = "throw_off"
	screen_loc = ui_gun1

/atom/movable/screen/gun/item/Click(location, control, params)
	if(..())
		var/mob/living/user = usr
		if(istype(user))
			if(!user.aiming) user.aiming = new(user)
			user.aiming.toggle_permission(TARGET_CAN_CLICK)
		return 1
	return 0

/atom/movable/screen/gun/mode
	name = "Toggle Gun Mode"
	icon_state = "use_off"
	screen_loc = ui_gun_select

/atom/movable/screen/gun/mode/Click(location, control, params)
	if(..())
		var/mob/living/user = usr
		if(istype(user))
			if(!user.aiming) user.aiming = new(user)
			user.aiming.toggle_active()
		return 1
	return 0

/atom/movable/screen/gun/radio
	name = "Disallow Radio Use"
	icon_state = "talk_on"
	screen_loc = ui_gun3

/atom/movable/screen/gun/radio/Click(location, control, params)
	if(..())
		var/mob/living/user = usr
		if(istype(user))
			if(!user.aiming) user.aiming = new(user)
			user.aiming.toggle_permission(TARGET_CAN_RADIO)
		return 1
	return 0
