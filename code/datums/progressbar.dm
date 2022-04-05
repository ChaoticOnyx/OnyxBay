#define PROGRESSBAR_HEIGHT 6
#define PROGRESSBAR_ANIMATION_TIME 5

/datum/progressbar
	var/goal = 1
	var/last_progress = 0
	var/image/bar
	var/shown = 0
	var/mob/user
	var/client/client
	var/listindex

/datum/progressbar/New(mob/User, goal_number, atom/target)
	. = ..()
	if(!target)
		target = User
	if(!istype(target))
		EXCEPTION("Invalid target given")
	if(QDELETED(User) || !istype(User))
		stack_trace("/datum/progressbar created with [isnull(User) ? "null" : "invalid"] user")
		qdel(src)
		return
	if(!isnum(goal_number))
		stack_trace("/datum/progressbar created with [isnull(User) ? "null" : "invalid"] goal_number")
		qdel(src)
		return
	goal = goal_number
	bar = image('icons/effects/progressbar.dmi', target, "prog_bar_0", HUD_BASE_LAYER)
	bar.plane = ABOVE_HUD_PLANE
	bar.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	user = User
	if(user)
		client = user.client

	LAZYINITLIST(user.progressbars)
	LAZYINITLIST(user.progressbars[bar.loc])
	var/list/bars = user.progressbars[bar.loc]
	bars.Add(src)
	listindex = bars.len
	bar.pixel_y = 0
	bar.alpha = 0
	animate(bar, pixel_y = 32 + (PROGRESSBAR_HEIGHT * (listindex - 1)), alpha = 255, time = PROGRESSBAR_ANIMATION_TIME, easing = SINE_EASING)

	if(user.client)
		client = user.client
		add_prog_bar_image_to_client()

	register_signal(user, SIGNAL_PARENT_QDELETING, .proc/on_user_delete)
	register_signal(user, SIGNAL_LOGGED_OUT, .proc/clean_user_client)
	register_signal(user, SIGNAL_LOGGED_IN, .proc/on_user_login)

/datum/progressbar/proc/shiftDown()
	--listindex
	bar.pixel_y = 32 + (PROGRESSBAR_HEIGHT * (listindex - 1))
	var/dist_to_travel = 32 + (PROGRESSBAR_HEIGHT * (listindex - 1)) - PROGRESSBAR_HEIGHT
	animate(bar, pixel_y = dist_to_travel, time = PROGRESSBAR_ANIMATION_TIME, easing = SINE_EASING)

/datum/progressbar/Destroy()
	if(user)
		for(var/pb in user.progressbars[bar.loc])
			var/datum/progressbar/progress_bar = pb
			if(progress_bar == src || progress_bar.listindex <= listindex)
				continue
			progress_bar.listindex--

			progress_bar.bar.pixel_y = 32 + (PROGRESSBAR_HEIGHT * (progress_bar.listindex - 1))
			var/dist_to_travel = 32 + (PROGRESSBAR_HEIGHT * (progress_bar.listindex - 1)) - PROGRESSBAR_HEIGHT
			animate(progress_bar.bar, pixel_y = dist_to_travel, time = PROGRESSBAR_ANIMATION_TIME, easing = SINE_EASING)

		LAZYREMOVE(user.progressbars, bar.loc)
		user = null

	if(client)
		clean_user_client()

	bar.loc = null

	if(bar)
		QDEL_NULL(bar)

	return ..()


///Called right before the user's Destroy()
/datum/progressbar/proc/on_user_delete(datum/source)
	user.progressbars = null //We can simply nuke the list and stop worrying about updating other prog bars if the user itself is gone.
	user = null
	qdel(src)


///Removes the progress bar image from the user_client and nulls the variable, if it exists.
/datum/progressbar/proc/clean_user_client(datum/source)
	if(!client) //Disconnected, already gone.
		return
	client.images -= bar
	client = null


///Called by user's Login(), it transfers the progress bar image to the new client.
/datum/progressbar/proc/on_user_login(datum/source)
	if(client)
		if(client == user.client) //If this was not client handling I'd condemn this sanity check. But clients are fickle things.
			return
		clean_user_client()
	if(!user.client) //Clients can vanish at any time, the bastards.
		return
	client = user.client
	add_prog_bar_image_to_client()


///Adds a smoothly-appearing progress bar image to the player's screen.
/datum/progressbar/proc/add_prog_bar_image_to_client()
	bar.pixel_y = 0
	bar.alpha = 0
	client.images += bar
	animate(bar, pixel_y = 32 + (PROGRESSBAR_HEIGHT * (listindex - 1)), alpha = 255, time = PROGRESSBAR_ANIMATION_TIME, easing = SINE_EASING)


///Updates the progress bar image visually.
/datum/progressbar/proc/update(progress)
	progress = clamp(progress, 0, goal)
	if(progress == last_progress)
		return
	last_progress = progress
	bar.icon_state = "prog_bar_[round(((progress / goal) * 100), 5)]"
	if(!shown)
		user.client.images += bar
		shown = TRUE

	if(user.get_preference_value(/datum/client_preference/show_progress_bar) == GLOB.PREF_SHOW)
		user.client.images += bar
		shown = TRUE

///Called on progress end, be it successful or a failure. Wraps up things to delete the datum and bar.
/datum/progressbar/proc/end_progress()
	if(last_progress != goal)
		bar.icon_state = "[bar.icon_state]_fail"

	animate(bar, alpha = 0, time = PROGRESSBAR_ANIMATION_TIME)

	QDEL_IN(src, PROGRESSBAR_ANIMATION_TIME)

/datum/progressbar/proc/remove_from_client()
	if(client)
		client.images -= bar
		client = null

#undef PROGRESSBAR_ANIMATION_TIME
#undef PROGRESSBAR_HEIGHT
