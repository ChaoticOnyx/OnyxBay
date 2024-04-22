/proc/get_view_size(view)
	if(isnum(view))
		var/totalviewrange = 1 + 2 * view
		return list(totalviewrange, totalviewrange)

	var/list/viewrangelist = splittext(view,"x")
	return list(text2num(viewrangelist[1]), text2num(viewrangelist[2]))
