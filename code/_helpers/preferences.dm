/proc/zoom_pref2value(zoom_key)
	var/datum/client_preference/zoom_pref = get_client_preference_by_key("PIXEL_SIZE")

	var/zoom_index = zoom_pref.options.Find(zoom_key)
	if(zoom_index == 1)
		return 0

	return zoom_index / 2
