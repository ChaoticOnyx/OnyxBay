//If we intercept it return true else return false
/atom/proc/RelayMouseDrag(atom/src_object, atom/over_object, src_location, over_location, src_control, over_control, params, mob/user)
	return FALSE

/mob/proc/OnMouseDrag(atom/src_object, atom/over_object, src_location, over_location, src_control, over_control, params)
	if(istype(loc, /atom))
		var/atom/A = loc
		if(A.RelayMouseDrag(src_object, over_object, src_location, over_location, src_control, over_control, params, src))
			return TRUE

	var/list/click_params = params2list(params)
	var/obj/item/gun/gun = (twohanded_mode && click_params["right"]) ? get_inactive_hand() : get_active_hand()
	if(istype(gun) && istype(over_object) && (isturf(over_location) || istype(over_object, /atom/movable/screen/click_catcher)) && !incapacitated() && !click_params["shift"] && !click_params["ctrl"] && !click_params["alt"] && (twohanded_mode || !click_params["right"]))
		if(istype(over_object, /atom/movable/screen/click_catcher))
			over_object = parse_caught_click_modifiers(click_params, client, get_turf(src))
		return gun.set_autofire(over_object, src)
	return FALSE

/mob/proc/OnMouseDown(atom/object, location, control, params)
	var/list/click_params = params2list(params)
	var/obj/item/gun/gun = (twohanded_mode && click_params["right"]) ? get_inactive_hand() : get_active_hand()
	if(istype(gun) && istype(object) && (isturf(location) || istype(object, /atom/movable/screen/click_catcher)) && !incapacitated() && !click_params["shift"] && !click_params["ctrl"] && !click_params["alt"])
		if(istype(object, /atom/movable/screen/click_catcher))
			object = parse_caught_click_modifiers(click_params, client, get_turf(src))
		if(!gun.autofire_enabled && a_intent == I_HURT)
			client.Click(object, location, control, params)
			return TRUE
		else if(twohanded_mode || !click_params["right"])
			return gun.set_autofire(object, src)
	return FALSE

/mob/proc/OnMouseUp(atom/object, location, control, params)
	var/list/click_params = params2list(params)
	var/obj/item/gun/gun = (twohanded_mode && click_params["right"]) ? get_inactive_hand() : get_active_hand()
	if(istype(gun))
		return gun.clear_autofire()
	return FALSE
