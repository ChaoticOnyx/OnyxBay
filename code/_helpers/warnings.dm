
SUBSYSTEM_DEF(warnings)
	name = "Warnings"
	init_order = SS_INIT_WARNINGS
	flags = SS_NO_FIRE
	var/list/shown_warnings = list()
	var/list/shown_warnings_this_round = list()
	var/data_path = "data/warnings/"
	var/warnings_path = "config/warnings/"

/datum/controller/subsystem/warnings/Initialize(timeofday)
	for (var/type in WARNINGS_ALL)
		shown_warnings_this_round[type] = list()
		shown_warnings[type] = list()
		var/savefile/S = new(data_path+type+".sav")
		if(!length(S))
			continue
		for(var/I in S)
			S[I] >> shown_warnings[type][I]

/datum/controller/subsystem/warnings/proc/show_warning(var/client/C, var/type, var/options="window=Warning;size=480x320")
	ASSERT(C)
	ASSERT(type)
	ASSERT(options)
	if (!(C.key in shown_warnings_this_round[type]) && (shown_warnings[type][C.key] < WARNINGS_REPEAT_TIMES))
		var/message = file(warnings_path+type+".html")
		show_browser(C, message, options)
		shown_warnings_this_round[type].Add(C.key)
		if(!shown_warnings[type][C.key])
			shown_warnings[type][C.key] = 1
		else
			shown_warnings[type][C.key] += 1
		__save_shown_warnings()

/datum/controller/subsystem/warnings/proc/__save_shown_warnings()
	for(var/type in WARNINGS_ALL)
		fdel(file(data_path+type+".sav"))
		var/savefile/S = new(data_path+type+".sav")
		for(var/I in shown_warnings[type])
			S[I] << shown_warnings[type][I]
