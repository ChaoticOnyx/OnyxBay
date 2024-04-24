/// Returns view size from config in format `[width]x[height]`.
/proc/get_screen_size(widescreen)
	if(widescreen)
		return config.game.default_view_wide

	return config.game.default_view

/// Accepts view size in formats: `[number]`, `[width]x[height]` and returns it in format `list([width], [height])`.
/proc/get_view_size(view)
	if(isnum(view))
		var/totalviewrange = 1 + 2 * view
		return list(totalviewrange, totalviewrange)

	var/list/viewrangelist = splittext(view, "x")
	return list(text2num(viewrangelist[1]), text2num(viewrangelist[2]))
