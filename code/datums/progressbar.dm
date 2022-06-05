#define PROGRESSBAR_ICON_HEIGHT 7

/client
	var/list/progressbars = list()

/datum/progressbar
	var/goal = 1
	var/image/bar
	var/shown = 0
	var/mob/user
	var/client/client
	var/atom/target
	var/id

/datum/progressbar/New(mob/user, goal_number, atom/target)
	. = ..()
	if(!target)
		target = user
	if(!istype(target))
		EXCEPTION("Invalid target given")
	if(goal_number)
		goal = goal_number

	bar = image('icons/effects/progressbar.dmi', target, "prog_bar_0")
	bar.appearance_flags = DEFAULT_APPEARANCE_FLAGS | APPEARANCE_UI_IGNORE_ALPHA
	bar.plane = HUD_PLANE
	bar.layer = HUD_ABOVE_ITEM_LAYER
	src.user = user
	if(!user?.client)
		return
	client = user.client
	client.progressbars[target] = client.progressbars[target] || 0
	id = client.progressbars[target]++
	src.target = target

/datum/progressbar/Destroy()
	if(client)
		client.images -= bar
		if(target in client.progressbars)
			if(--client.progressbars[target] <= 0)
				client.progressbars -= target

	qdel(bar)
	. = ..()

/datum/progressbar/proc/update(progress)
	if(!user || !user.client)
		shown = 0
		return
	if(user.client != client)
		if(client)
			client.images -= bar
			--client.progressbars[target]
			shown = 0
		client = user.client
		id = client.progressbars[target]++

	progress = Clamp(progress, 0, goal)

	if(id > client.progressbars[target])
		id = client.progressbars[target]

	bar.icon_state = "prog_bar_[round(((progress / goal) * 100), 2.5)]"
	bar.pixel_y = WORLD_ICON_SIZE + id * PROGRESSBAR_ICON_HEIGHT

	if(user.get_preference_value(/datum/client_preference/show_progress_bar) == GLOB.PREF_SHOW)
		user.client.images += bar
		shown = 1

#undef PROGRESSBAR_ICON_HEIGHT
