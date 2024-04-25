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

#define UPDATE_BUTTON_NAME       (1<<0)
#define UPDATE_BUTTON_ICON       (1<<1)
#define UPDATE_BUTTON_BACKGROUND (1<<2)
#define UPDATE_BUTTON_OVERLAY    (1<<3)
#define UPDATE_BUTTON_STATUS     (1<<4)
#define UPDATE_BUTTON_ALL        (~0)


/datum/action
	var/name = "Generic Action"
	var/desc
	var/action_type = AB_ITEM
	var/procname = null
	var/atom/movable/target = null
	var/check_flags = 0
	var/processing = 0
	var/active = 0
	var/atom/movable/screen/movable/action_button/button = null
	var/mob/living/owner

	var/transparent_when_unavailable = TRUE
	/// This is the file for the BACKGROUND icon of the button
	var/background_icon = 'icons/hud/actions.dmi'
	/// This is the icon state state for the BACKGROUND icon of the button
	var/background_icon_state = "bg_default"

	/// This is the file for the icon that appears OVER the button background
	var/button_icon = 'icons/hud/actions.dmi'
	/// This is the icon state for the icon that appears OVER the button background
	var/button_icon_state

	/// This is the file for any FOREGROUND overlay icons on the button (such as borders)
	var/overlay_icon = 'icons/hud/actions.dmi'
	/// This is the icon state for any FOREGROUND overlay icons on the button (such as borders)
	var/overlay_icon_state


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

/datum/action/proc/Remove(mob/living/T)
	if(button)
		if(T.client)
			T.client.screen -= button
		qdel(button)
		button = null
	T.actions.Remove(src)
	T.update_action_buttons()
	owner = null

/datum/action/proc/Trigger()
	if(!Checks())
		return FALSE
	switch(action_type)
		if(AB_ITEM)
			if(target)
				var/obj/item/item = target
				item.ui_action_click()
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
	active = TRUE

/datum/action/proc/ActivateOnClick()
	return

/datum/action/proc/Deactivate()
	active = FALSE

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

/datum/action/proc/build_button_icon(atom/movable/screen/movable/action_button/button, update_flags = UPDATE_BUTTON_ALL, force = FALSE)
	if(!button)
		return

	if(update_flags & UPDATE_BUTTON_NAME)
		update_button_name(button, force)

	if(update_flags & UPDATE_BUTTON_BACKGROUND)
		apply_button_background(button, force)

	if(update_flags & UPDATE_BUTTON_ICON)
		apply_button_icon(button, force)

	if(update_flags & UPDATE_BUTTON_OVERLAY)
		apply_button_overlay(button, force)

	if(update_flags & UPDATE_BUTTON_STATUS)
		update_button_status(button, force)

/datum/action/proc/update_button_name(atom/movable/screen/movable/action_button/button, force = FALSE)
	button.name = name
	if(desc)
		button.desc = desc

/datum/action/proc/apply_button_background(atom/movable/screen/movable/action_button/current_button, force = FALSE)
	if(!background_icon || !background_icon_state || (current_button.active_underlay_icon_state == background_icon_state && !force))
		return

	// Determine which icon to use
	var/used_icon_key = active ? "bg_state_active" : "bg_state"

	// Make the underlay
	current_button.underlays.Cut()
	current_button.underlays += image(icon = background_icon, icon_state = background_icon_state)
	current_button.active_underlay_icon_state = used_icon_key

/datum/action/proc/apply_button_icon(atom/movable/screen/movable/action_button/current_button, force = FALSE)
	if(!button_icon || !button_icon_state || (current_button.icon_state == button_icon_state && !force))
		return

	current_button.icon = button_icon
	current_button.icon_state = button_icon_state

/datum/action/proc/apply_button_overlay(atom/movable/screen/movable/action_button/current_button, force = FALSE)
	if(!overlay_icon || (current_button.active_overlay_icon_state == overlay_icon_state && !force))
		return

	if(overlay_icon_state)
		current_button.button_overlay = mutable_appearance(icon = overlay_icon, icon_state = overlay_icon_state)
	else
		QDEL_NULL(current_button.button_overlay)

	current_button.active_overlay_icon_state = overlay_icon_state

	current_button.update_icon()

/datum/action/proc/update_button_status(atom/movable/screen/movable/action_button/current_button, force = FALSE)
	if(IsAvailable())
		current_button.color = rgb(255,255,255,255)
	else
		current_button.color = transparent_when_unavailable ? rgb(128,0,0,128) : rgb(128,0,0)

/atom/movable/screen/movable/action_button
	var/datum/action/owner
	screen_loc = "WEST,NORTH"
	/// The icon state of our active overlay, used to prevent re-applying identical overlays
	var/active_overlay_icon_state
	/// The icon state of our active underlay, used to prevent re-applying identical underlays
	var/active_underlay_icon_state
	/// The overlay we have overtop our button
	var/mutable_appearance/button_overlay

/atom/movable/screen/movable/action_button/Click(location,control,params)
	var/list/modifiers = params2list(params)
	if(modifiers["shift"])
		moved = 0
		return 1
	if(usr.next_move >= world.time) // Is this needed ?
		return
	owner.Trigger()
	return 1

/atom/movable/screen/movable/action_button/on_update_icon()
	if(!owner)
		return

	ClearOverlays()
	if(owner.action_type == AB_ITEM && owner.target)
		var/image/img
		var/list/img_overlays
		var/obj/item/I = owner.target
		img = image(I.icon, src , I.icon_state)
		img_overlays = I.overlays
		img.pixel_x = 0
		img.pixel_y = 0
		AddOverlays(img)
		AddOverlays(img_overlays)
	else if(!isnull(button_overlay))
		AddOverlays(button_overlay)

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
	update_icon()
	usr.update_action_buttons()


/atom/movable/screen/movable/action_button/hide_toggle/proc/InitialiseIcon(mob/living/user)
	if(isalien(user))
		icon_state = "bg_alien"
	else
		icon_state = "bg_default"
	update_icon()
	return

/atom/movable/screen/movable/action_button/hide_toggle/on_update_icon()
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
	/// The active icon_state of the overlay we apply
	var/active_overlay_icon_state = null
	/// The base icon_state of the overlay we apply
	var/base_overlay_icon_state = null
	check_flags = 0
	// The default cooldown applied when StartCooldown() is called
	var/cooldown_time = 0
	// The actual next time this ability can be used
	var/next_use_time = 0
	// Whether or not you want the cooldown for the ability to display in text form
	var/text_cooldown = TRUE
	// Setting for intercepting clicks before activating the ability
	var/click_to_activate = FALSE
	/// If TRUE, we will unset after using our click intercept.
	var/unset_after_click = TRUE
	// Shares cooldowns with other cooldown abilities of the same value, not active if FALSE
	var/shared_cooldown = FALSE
	/// What icon to replace our mouse cursor with when active. Optional
	var/ranged_mousepointer

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

/datum/action/cooldown/update_button_status(atom/movable/screen/movable/action_button/current_button, force = FALSE)
	if(!current_button)
		return

	var/time_left = max(next_use_time - world.time, 0)
	if(text_cooldown)
		current_button.maptext = "<b>[round(time_left/10, 0.1)]</b>"
	if(!owner || time_left == 0)
		current_button.maptext = ""
	if(IsAvailable() && owner.GetClickHandler())
		current_button.color = COLOR_GREEN

	current_button.update_icon()

/datum/action/cooldown/apply_button_overlay(atom/movable/screen/movable/action_button/current_button, force)
	if(active_overlay_icon_state)
		overlay_icon_state = is_action_active() ? active_overlay_icon_state : base_overlay_icon_state
	return ..()

/datum/action/cooldown/proc/is_action_active()
	return active || (click_to_activate && owner?.click_intercept == src)

/datum/action/cooldown/Trigger(trigger_flags, atom/target)
	if(!owner)
		return FALSE
	if(!Checks())
		return FALSE
	if(!IsAvailable())
		return FALSE

	if(click_to_activate)
		var/mob/user = usr || owner
		if(target)
			// For automatic / mob handling
			return InterceptClickOn(user, null, target)

		var/datum/action/cooldown/already_set = user.click_intercept
		if(already_set == src)
			// if we clicked ourself and we're already set, unset and return
			return unset_click_ability(user, refund_cooldown = TRUE)

		else if(istype(already_set))
			// if we have an active set already, unset it before we set our's
			already_set.unset_click_ability(user, refund_cooldown = TRUE)

		return set_click_ability(user)

	if(active)
		return Deactivate()

	return PreActivate(owner)

/// Intercepts client owner clicks to activate the ability
/datum/action/cooldown/proc/InterceptClickOn(mob/living/caller, atom/target, params)
	if(!IsAvailable())
		return FALSE

	if(!target)
		return FALSE
	// The actual action begins here
	if(!PreActivate(target))
		return FALSE

	// And if we reach here, the action was complete successfully
	if(unset_after_click)
		unset_click_ability(caller, refund_cooldown = FALSE)
	caller.next_click = world.time + 1

	return TRUE

/// Set our action as the click override on the passed mob.
/datum/action/cooldown/proc/set_click_ability(mob/on_who)
	SHOULD_CALL_PARENT(TRUE)

	on_who.click_intercept = src
	if(ranged_mousepointer)
		on_who.mouse_override_icon = ranged_mousepointer
		on_who.update_mouse_pointer()

	build_button_icon(button)
	return TRUE

/**
 * Unset our action as the click override of the passed mob.
 *
 * if refund_cooldown is TRUE, we are being unset by the user clicking the action off
 * if refund_cooldown is FALSE, we are being forcefully unset, likely by someone actually using the action
 */
/datum/action/cooldown/proc/unset_click_ability(mob/on_who, refund_cooldown = TRUE)
	SHOULD_CALL_PARENT(TRUE)

	on_who.click_intercept = null
	if(ranged_mousepointer)
		on_who.mouse_override_icon = initial(on_who.mouse_override_icon)
		on_who.update_mouse_pointer()

	build_button_icon(button)
	return TRUE

/// For signal calling
/datum/action/cooldown/proc/PreActivate(atom/target)
	. = Activate(target)

/// To be implemented by subtypes
/datum/action/cooldown/Activate(atom/target)
	return

/datum/action/cooldown/think()
	var/time_left = max(next_use_time - world.time, 0)
	if(!owner || time_left == 0)
		build_button_icon(button)
		set_next_think(0)
		return

	build_button_icon(button, UPDATE_BUTTON_STATUS)
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
