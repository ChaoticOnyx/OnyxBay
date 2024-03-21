/obj/item/proc/use_tool(atom/target, mob/living/user, delay = 0, amount = 0, volume = 0, quality = null, can_move = FALSE, datum/callback/extra_checks)
	// No delay means there is no start message, and no reason to call tool_start_check before use_tool.
	// Run the start check here so we wouldn't have to call it manually.
	if(!tool_use_check(amount))
		return

	delay *= toolspeed

	// Play tool sound at the beginning of tool usage.
	play_tool_sound(target, volume)

	if(delay)
		var/datum/callback/tool_check = CALLBACK(src, nameof(.proc/tool_check_callback), user, amount, extra_checks, target)
		if(ismob(target))
			if(!do_mob(user, target, delay, extra_checks = tool_check) || !is_tool_on())
				return

		else
			if(!do_after(user, delay, target=target, can_move = can_move, extra_checks = tool_check) || !is_tool_on())
				return

	// Use tool's fuel, stack sheets or charges if amount is set.
	if(amount && !use_tool_resources(amount, user))
		return

	// Play tool sound at the end of tool usage,
	// but only if the delay between the beginning and the end is not too small
	if(delay >= MIN_TOOL_SOUND_DELAY)
		play_tool_sound(target, volume)

	return TRUE

/// Plays tools's usesound.
/obj/item/proc/play_tool_sound(atom/target, volume = null)
	if(target && tool_sound && volume)
		var/played_sound = tool_sound

		if(islist(tool_sound))
			played_sound = pick(tool_sound)

		playsound(target, played_sound, 100, volume)

/// Depending on the item checks whether it has enough resources (e.g. fuel)
/obj/item/proc/tool_use_check(used, mob/M = null)
	return TRUE

/// Depending on the item, it uses up fuel, charges, sheets, etc.
/obj/item/proc/use_tool_resources(used, mob/M = null)
	return !used

/// Returns whether or not the tool is currently on.
/obj/item/proc/is_tool_on()
	return

/// Callback to check during doafter. Do not override. Do not call it.
/obj/item/proc/tool_check_callback(mob/living/user, amount, datum/callback/extra_checks, target)
	SHOULD_NOT_OVERRIDE(TRUE)
	return tool_use_check(user, amount, target) && (!extra_checks || extra_checks.Invoke())
