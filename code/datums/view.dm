/datum/view
	/// Extra width of client's view in tiles, use proc to modify.
	var/width
	/// Extra height of client's view in tiles, use proc to modify.
	var/height
	/// Default client's view size, can be in formats: `[number]` or `[width]x[height]`.
	var/default
	/// Client's prefered `zoom` value, see `https://www.byond.com/docs/ref/#/{skin}/param/zoom` for details.
	var/zoom
	/// Client's prefered `zoom-mode` value, see `https://www.byond.com/docs/ref/#/{skin}/param/zoom-mode` for details.
	var/zoom_mode
	/// Whether client's view is being supressed by something i.e monitors and etc.
	var/supressed = FALSE
	/// Reference to a client that owns this datum.
	var/client/owner

/datum/view/New(client/owner, default)
	src.owner = owner
	src.default = default
	apply()

/datum/view/Destroy(force)
	owner = null
	return ..()

/datum/view/proc/apply()
	owner.change_view(get_view())

	if(is_zooming())
		reset_zoom()
	else
		set_zoom()

/datum/view/proc/get_view()
	var/list/temp = get_view_size(default)

	if(supressed)
		return "[temp[1]]x[temp[2]]"

	return "[temp[1] + width]x[temp[2] + height]"

/datum/view/proc/is_zooming()
	return (width || height)

/datum/view/proc/set_zoom()
	zoom = zoom_pref2value(owner.get_preference_value("PIXEL_SIZE"))
	winset(owner, "mapwindow.map", "zoom=[zoom]")

/datum/view/proc/reset_zoom()
	winset(owner, "mapwindow.map", "zoom=0")
	zoom = 0

/datum/view/proc/set_zoom_mode()
	zoom_mode = lowertext(owner.get_preference_value("SCALING_METHOD"))
	winset(owner, "mapwindow.map", "zoom-mode=[zoom_mode]")

/datum/view/proc/set_default(default)
	src.default = default
	apply()

/datum/view/proc/set_width(width)
	src.width = width
	apply()

/datum/view/proc/set_height(height)
	src.height = height
	apply()

/datum/view/proc/set_both(width, height)
	src.width = width
	src.height = height
	apply()

/datum/view/proc/reset_to_default()
	width = 0
	height = 0
	apply()

/datum/view/proc/supress()
	supressed = TRUE
	apply()

/datum/view/proc/unsupress()
	supressed = FALSE
	apply()

view_to_pixels
