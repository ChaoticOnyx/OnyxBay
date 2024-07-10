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

/// Takes a string or num view, and converts it to pixel width/height in a list(pixel_width, pixel_height)
/proc/view_to_pixels(view)
	if(!view)
		return list(0, 0)

	var/list/viewrangelist = get_view_size(view)
	viewrangelist[1] *= world.icon_size
	viewrangelist[2] *= world.icon_size
	return viewrangelist
