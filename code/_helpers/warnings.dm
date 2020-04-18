
/datum/warn
	var/data_path = "data/warnings/"
	var/warnings_path = "config/warnings/"

/datum/warn/proc/load_warnings(var/type)
	if(!type)
		return
	var/list/data = list()
	var/savefile/S = new(data_path+type+".sav")
	data = list()
	if(!lentext(S))
		return data
	for(var/I in S)
		data[I] = S[I]
	return data

/datum/warn/proc/save_warnings(var/list/data, var/type)
	if(!type)
		return
	fdel(file(data_path+type+".sav"))
	var/savefile/S = new(data_path+type+".sav")
	for(var/I in data)
		S[I] << data[I]

/client/proc/check_warnings(var/type)
	var/datum/warn/W = new()
	if(!type)
		return FALSE
	var/list/data = W.load_warnings(type)
	if(!data[key])
		return TRUE
	else if(data[key]<4)
		return TRUE
	else
		return FALSE

/client/proc/warned(var/type)
	var/datum/warn/W = new()
	if(!type)
		return
	var/data = W.load_warnings(type)
	if(!data[key])
		data[key] = 1
	else
		data[key] += 1
	W.save_warnings(data, type)

/client/proc/warn_player(var/type, var/options="window=Warning;size=480x320")
	if(!type)
		return
	var/datum/warn/W = new()
	var/message = file(W.warnings_path+type+".html")
	show_browser(src, message, options)
