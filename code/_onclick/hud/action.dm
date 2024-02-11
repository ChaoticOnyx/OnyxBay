#define AB_ITEM 1
#define AB_SPELL 2
#define AB_INNATE 3
#define AB_GENERIC 4

#define AB_CHECK_RESTRAINED 1
#define AB_CHECK_STUNNED 2
#define AB_CHECK_LYING 4
#define AB_CHECK_ALIVE 8
#define AB_CHECK_INSIDE 16
#define AB_CHECK_CONSCIOUS 32

//Shared cooldowns for actions
#define MOB_SHARED_COOLDOWN_1 "mob_shared_cooldown_1"
#define MOB_SHARED_COOLDOWN_2 "mob_shared_cooldown_2"
#define MOB_SHARED_COOLDOWN_3 "mob_shared_cooldown_3"

/datum/action
	var/name = "Generic Action"
	var/action_type = AB_ITEM
	var/procname = null
	var/atom/movable/target = null
	var/check_flags = 0
	var/processing = 0
	var/active = 0
	var/atom/movable/screen/movable/action_button/button = null
	var/button_icon = 'icons/hud/actions.dmi'
	var/button_icon_state = "default"
	var/background_icon_state = "bg_default"
	var/transparent_when_unavailable = TRUE
	var/mob/living/owner

/datum/action/New(Target)
	target = Target

/datum/action/Destroy()
	if(owner)
		Remove(owner)
	target = null
	return ..()

/datum/action/proc/Grant(mob/living/T)
	if(owner)
		if(owner == T)
			return
		Remove(owner)
	owner = T
	owner.actions.Add(src)
	owner.update_action_buttons()
	return

/datum/action/proc/Remove(mob/living/T)
	if(button)
		if(T.client)
			T.client.screen -= button
		qdel(button)
		button = null
	T.actions.Remove(src)
	T.update_action_buttons()
	owner = null
	return

/datum/action/proc/Trigger()
	if(!Checks())
		return FALSE
	switch(action_type)
		if(AB_ITEM)
			if(target)
				var/obj/item/item = target
				item.ui_action_click()
		//if(AB_SPELL)
		//	if(target)
		//		var/obj/effect/proc_holder/spell = target
		//		spell.Click()
		if(AB_INNATE)
			if(!active)
				Activate()
			else
				Deactivate()
		if(AB_GENERIC)
			if(target && procname)
				call(target,procname)(usr)
	return TRUE

/datum/action/proc/Activate()
	return

/datum/action/proc/ActivateOnClick()
	return

/datum/action/proc/Deactivate()
	return

/datum/action/proc/ProcessAction()
	return

/datum/action/proc/CheckRemoval(mob/living/user) // 1 if action is no longer valid for this mob and should be removed
	return 0

/datum/action/proc/IsAvailable()
	return Checks()

/datum/action/proc/Checks()// returns 1 if all checks pass
	if(!owner)
		return 0
	if(check_flags & AB_CHECK_RESTRAINED)
		if(owner.restrained())
			return 0
	if(check_flags & AB_CHECK_STUNNED)
		if(owner.stunned)
			return 0
	if(check_flags & AB_CHECK_LYING)
		if(owner.lying)
			return 0
	if(check_flags & AB_CHECK_ALIVE)
		if(owner.stat)
			return 0
	if(check_flags & AB_CHECK_INSIDE)
		if(!(target in owner))
			return 0
	if(check_flags & AB_CHECK_CONSCIOUS)
		if(owner.stat != CONSCIOUS)
			return 0
	return 1

/datum/action/proc/UpdateName()
	return name

/atom/movable/screen/movable/action_button
	var/datum/action/owner
	screen_loc = "WEST,NORTH"

/atom/movable/screen/movable/action_button/Click(location,control,params)
	var/list/modifiers = params2list(params)
	if(modifiers["shift"])
		moved = 0
		return 1
	if(usr.next_move >= world.time) // Is this needed ?
		return
	owner.Trigger()
	return 1

/atom/movable/screen/movable/action_button/proc/UpdateIcon()
	if(!owner)
		return
	icon = owner.button_icon
	icon_state = owner.background_icon_state

	ClearOverlays()
	var/image/img
	var/list/img_overlays
	if(owner.action_type == AB_ITEM && owner.target)
		var/obj/item/I = owner.target
		img = image(I.icon, src , I.icon_state)
		img_overlays = I.overlays
	else if(owner.button_icon && owner.button_icon_state)
		img = image(owner.button_icon,src,owner.button_icon_state)
	img.pixel_x = 0
	img.pixel_y = 0
	AddOverlays(img)
	AddOverlays(img_overlays)

	if(!owner.IsAvailable())
		color = rgb(128,0,0,128)
	else
		color = rgb(255,255,255,255)

//Hide/Show Action Buttons ... Button
/atom/movable/screen/movable/action_button/hide_toggle
	name = "Hide Buttons"
	icon = 'icons/hud/actions.dmi'
	icon_state = "bg_default"
	var/hidden = 0

/atom/movable/screen/movable/action_button/hide_toggle/Click()
	usr.hud_used.action_buttons_hidden = !usr.hud_used.action_buttons_hidden

	hidden = usr.hud_used.action_buttons_hidden
	if(hidden)
		name = "Show Buttons"
	else
		name = "Hide Buttons"
	UpdateIcon()
	usr.update_action_buttons()


/atom/movable/screen/movable/action_button/hide_toggle/proc/InitialiseIcon(mob/living/user)
	if(isalien(user))
		icon_state = "bg_alien"
	else
		icon_state = "bg_default"
	UpdateIcon()
	return

/atom/movable/screen/movable/action_button/hide_toggle/UpdateIcon()
	ClearOverlays()
	var/image/img = image(icon,src,hidden?"show":"hide")
	AddOverlays(img)
	return

//This is the proc used to update all the action buttons. Properly defined in /mob/living/
/mob/proc/update_action_buttons()
	return

#define AB_WEST_OFFSET 4
#define AB_NORTH_OFFSET 26
#define AB_MAX_COLUMNS 10

/datum/hud/proc/ButtonNumberToScreenCoords(number) // TODO : Make this zero-indexed for readabilty
	var/row = round((number-1)/AB_MAX_COLUMNS)
	var/col = ((number - 1)%(AB_MAX_COLUMNS)) + 1
	var/coord_col = "+[col-1]"
	var/coord_col_offset = AB_WEST_OFFSET+2*col
	var/coord_row = "[-1 - row]"
	var/coord_row_offset = AB_NORTH_OFFSET
	return "WEST[coord_col]:[coord_col_offset],NORTH[coord_row]:[coord_row_offset]"

/datum/hud/proc/SetButtonCoords(atom/movable/screen/button,number)
	var/row = round((number - 1) / AB_MAX_COLUMNS)
	var/col = ((number - 1) % (AB_MAX_COLUMNS)) + 1
	button.SetTransform(
		offset_x = 32 * (col - 1) + AB_WEST_OFFSET + 2 * col,
		offset_y = -32 * (row + 1) + AB_NORTH_OFFSET
	)

//Presets for item actions
/datum/action/item_action
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_LYING|AB_CHECK_ALIVE|AB_CHECK_INSIDE

/datum/action/item_action/CheckRemoval(mob/living/user)
	return !(target in user)

/datum/action/item_action/hands_free
	check_flags = AB_CHECK_ALIVE|AB_CHECK_INSIDE

//Presets for innate actions
/datum/action/innate
	check_flags = 0
	active = 0
	action_type = AB_INNATE

#undef AB_WEST_OFFSET
#undef AB_NORTH_OFFSET
#undef AB_MAX_COLUMNS

//Preset for an action with a cooldown

/datum/action/cooldown
	check_flags = 0
	// The default cooldown applied when StartCooldown() is called
	var/cooldown_time = 0
	// The actual next time this ability can be used
	var/next_use_time = 0
	// Whether or not you want the cooldown for the ability to display in text form
	var/text_cooldown = TRUE
	// Setting for intercepting clicks before activating the ability
	var/click_to_activate = FALSE
	// Setting for your click handler for intercepted clicks, must be a type
	var/click_handler
	// Shares cooldowns with other cooldown abilities of the same value, not active if FALSE
	var/shared_cooldown = FALSE

/datum/action/cooldown/IsAvailable()

	if(..() && (next_use_time <= world.time))
		. = TRUE

	return .

/// Starts a cooldown time to be shared with similar abilities, will use default cooldown time if an override is not specified
/datum/action/cooldown/proc/StartCooldown(override_cooldown_time)
	if(shared_cooldown)
		for(var/datum/action/cooldown/shared_ability in owner.actions - src)
			if(shared_cooldown == shared_ability.shared_cooldown)
				if(isnum(override_cooldown_time))
					shared_ability.StartCooldownSelf(override_cooldown_time)
				else
					shared_ability.StartCooldownSelf(cooldown_time)
	StartCooldownSelf(override_cooldown_time)

/// Starts a cooldown time for this ability only, will use default cooldown time if an override is not specified
/datum/action/cooldown/proc/StartCooldownSelf(override_cooldown_time)
	if(isnum(override_cooldown_time))
		next_use_time = world.time + override_cooldown_time
	else
		next_use_time = world.time + cooldown_time
	owner.update_action_buttons()
	set_next_think(world.time + 1 SECONDS)

/datum/action/cooldown/Trigger(trigger_flags, atom/target)
	if(!owner)
		return FALSE
	if(!Checks())
		return FALSE
	if(!IsAvailable())
		return FALSE

	if(click_to_activate)

		if(!click_handler)
			return FALSE

		if(!(click_handler in owner.click_handlers))
			owner.PushClickHandler(click_handler)
		else
			owner.PopClickHandler()

		for(var/datum/action/cooldown/ability in owner.actions)
			ability.owner.update_action_buttons()
		return TRUE

	return PreActivate(owner)

/// For signal calling
/datum/action/cooldown/proc/PreActivate(atom/target)
	. = Activate(target)

/// To be implemented by subtypes
/datum/action/cooldown/Activate(atom/target)
	return

/datum/action/cooldown/proc/UpdateButton(/atom/movable/screen/movable/action_button/button)
	if(!button)
		return
	var/time_left = max(next_use_time - world.time, 0)
	if(text_cooldown)
		button.maptext = "<b>[round(time_left/10, 0.1)]</b>"
	if(!owner || time_left == 0)
		button.maptext = ""
	if(IsAvailable() && owner.GetClickHandler())
		button.color = COLOR_GREEN

	button.UpdateIcon()

/datum/action/cooldown/think()
	var/time_left = max(next_use_time - world.time, 0)
	if(!owner || time_left == 0)
		UpdateButton(src.button)
		set_next_think(0)
		return
	UpdateButton(src.button)
	set_next_think(world.time + 1 SECONDS)

/datum/action/cooldown/Grant(mob/M)
	..()
	if(!owner)
		return
	owner.update_action_buttons()
	if(next_use_time > world.time)
		set_next_think(world.time + 1 SECONDS)

// Mobs cooldown action
/datum/action/cooldown/mob_cooldown
	name = "Standard Mob Cooldown Ability"
	button_icon = 'icons/hud/actions.dmi'
	button_icon_state = "default"
	check_flags = AB_CHECK_CONSCIOUS
	cooldown_time = 1.5 SECONDS
	text_cooldown = TRUE
	click_to_activate = TRUE
	shared_cooldown = MOB_SHARED_COOLDOWN_1
