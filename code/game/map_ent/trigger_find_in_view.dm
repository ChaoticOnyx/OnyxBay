/obj/map_ent/trigger_find_in_range
	name = "trigger_find_in_range"
	icon_state = "trigger_find_in_range"

	var/ev_radius = 3
	var/exclude_center = FALSE
	var/exclude_self = TRUE
	var/ev_range_center = src
	var/ev_sort
	var/ev_verbose = FALSE
	var/list/ev_out = list()
	var/ev_tag

/obj/map_ent/trigger_find_in_range/activate()
	var/obj/map_ent/E = locate(ev_tag)

	if(!istype(E))
		crash_with("Can't locate triggerable map_ent, ev_tag isn't correct.")
		return

	if(!istype(ev_range_center, /atom))
		var/try_tag = ev_range_center
		ev_range_center = locate(try_tag)
		if(!istype(ev_range_center, /atom))
			crash_with("Can't locate object with given ev_range_center.")
			return

	if(exclude_center)
		ev_out = oview(ev_range_center, ev_radius)
	else
		ev_out = view(ev_range_center, ev_radius)

	if(exclude_self)
		ev_out.Remove(ev_range_center)

	var/multiple_finder = islist(ev_sort)
	if(multiple_finder)
		var/list/old_ev_sort = ev_sort
		ev_sort.Cut()
		for(var/path in old_ev_sort)
			if(istext(path) && path = text2path(path))
				ev_sort.Add(path)
				continue

			if(ispath(path))
				ev_sort.Add(path)
			else if(ev_verbose)
				crash_with("Can't find path ([path]) to find in.")
				return
	else
		if(istext(ev_sort))
			ev_sort = text2path(ev_sort)

		if(!ispath(ev_sort))
			crash_with("Can't find path to find in.")
			return

	for(var/object in ev_out)
		if(istype(object, /obj/map_ent))
			ev_out.Remove(object)
			continue
		if(multiple_finder)
			if(!is_type_in_list(object, ev_sort))
				ev_out.Remove(object)
		else
			if(!istype(object, ev_sort))
				ev_out.Remove(object)

	E.activate()
