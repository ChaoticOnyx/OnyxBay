/datum/reagents/proc/get_color()
	if(!reagent_list || !reagent_list.len)
		return "#ffffffff"
	if(reagent_list.len == 1) // It's pretty common and saves a lot of work
		var/datum/reagent/R = reagent_list[1]
		return R.color

	var/list/colors = list(0, 0, 0, 0)
	var/tot_w = 0
	for(var/datum/reagent/R in reagent_list)
		var/hex = uppertext(R.color)
		if(length(hex) == 7)
			hex += "FF"
		if(length(hex) != 9) // PANIC PANIC PANIC
			warning("Reagent [R.type] has an incorrect color set ([R.color])")
			hex = "#ffffffFF"
		colors[1] += hex2num(copytext(hex, 2, 4)) * R.volume * R.color_weight
		colors[2] += hex2num(copytext(hex, 4, 6)) * R.volume * R.color_weight
		colors[3] += hex2num(copytext(hex, 6, 8)) * R.volume * R.color_weight
		colors[4] += hex2num(copytext(hex, 8, 10)) * R.volume * R.color_weight
		tot_w += R.volume * R.color_weight

	return rgb(colors[1] / tot_w, colors[2] / tot_w, colors[3] / tot_w, colors[4] / tot_w)

/proc/mix_color_from_reagent_list(list/reagent_list)
	var/mixcolor
	var/vol_counter = 0
	var/vol_temp
	var/cached_color
	var/datum/reagent/raw_reagent

	for(var/reagent_type in reagent_list)
		vol_temp = reagent_list[reagent_type]
		vol_counter += vol_temp
		raw_reagent = reagent_type // Not initialized
		cached_color = initial(raw_reagent.color)

		if(!mixcolor)
			mixcolor = cached_color
		else if (length(mixcolor) >= length(cached_color))
			mixcolor = BlendRGB(mixcolor, cached_color, vol_temp/vol_counter)
		else
			mixcolor = BlendRGB(cached_color, mixcolor, vol_temp/vol_counter)

	return mixcolor
