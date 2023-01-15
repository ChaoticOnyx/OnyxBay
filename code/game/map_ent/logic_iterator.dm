/obj/map_ent/logic_iterator
	name = "logic_iterator"
	icon_state = "logic_iterator"

	var/ev_out
	var/ev_list
	var/ev_tag
	var/ev_check_type

/obj/map_ent/logic_iterator/activate()
	var/obj/map_ent/E = locate(ev_tag)

	if(!istype(E))
		util_crash_with("Can't locate object with tag - [ev_tag]")
		return

	if(!islist(ev_list))
		util_crash_with("Can't iterate through ev_list.")
		return

	if(ev_check_type && !istext(ev_check_type) || !text2path(ev_check_type))
		util_crash_with("Invalid ev_check_type.")
		return

	for(var/object in ev_list)
		if(ev_check_type && !istype(object, text2path(ev_check_type)))
			continue
		ev_out = object

		E.activate()
