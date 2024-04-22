#define EYE_BLURRY_FILTER_NAME "eye_blurry"
#define EYE_BLURRY_FILTER(time) list(type="blur", size=clamp(0.08/(0.05+2.618**(-0.5*time)), 0, 1.5))

/atom
	var/list/filter_data // For handling persistent filters

/proc/cmp_filter_data_priority(list/A, list/B)
	return A["priority"] - B["priority"]

/atom/proc/add_filter(filter_name, priority, list/params)
	LAZYINITLIST(filter_data)
	var/list/p = params.Copy()
	p["priority"] = priority
	filter_data[filter_name] = p
	update_filters()

/atom/proc/update_filters()
	filters = null
	filter_data = sortTim(filter_data, /proc/cmp_filter_data_priority, TRUE)
	for(var/f in filter_data)
		var/list/data = filter_data[f]
		var/list/arguments = data.Copy()
		arguments -= "priority"
		filters += filter(arglist(arguments))

/atom/proc/get_filter(filter_name)
	if(filter_data && filter_data[filter_name])
		return filters[filter_data.Find(filter_name)]

/atom/proc/remove_filter(filter_name)
	var/thing = get_filter(filter_name)
	if(thing)
		LAZYREMOVE(filter_data, filter_name)
		filters -= thing
		update_filters()

// TODO: Find a better place to store this and above procs.
/mob/proc/set_renderer_filter(condition, renderer_name = SCENE_GROUP_RENDERER, filter_name, priority, list/params)
	if(isnull(renderers))
		return FALSE

	if(!(renderer_name in renderers))
		return FALSE

	condition?renderers[renderer_name].add_filter(filter_name, priority, params) : renderers[renderer_name].remove_filter(filter_name)
