/proc/show_individual_logging_panel(mob/M, type = INDIVIDUAL_SAY_LOG)
	if(!M || !ismob(M))
		return
	var/dat = "<meta charset=\"utf-8\"><center><a href='?_src_=holder;individuallog=\ref[M];log_type=[INDIVIDUAL_SAY_LOG]'>Say log</a> | "
	dat += "<a href='?_src_=holder;individuallog=\ref[M];log_type=[INDIVIDUAL_OOC_LOG]'>OOC log</a> | "
	dat += "<a href='?_src_=holder;individuallog=\ref[M];log_type=[INDIVIDUAL_SHOW_ALL_LOG]'>Show all</a> | "
	dat += "<a href='?_src_=holder;individuallog=\ref[M];log_type=[type]'>Refresh</a></center>"
	dat += "<hr style='background:#000000; border:0; height:1px'>"

	if(type == INDIVIDUAL_SHOW_ALL_LOG)
		dat += "<center>Displaying all logs of [key_name(M)]</center><br><hr>"
		for(var/log_type in M.logging)
			dat += "<center>[log_type]</center><br>"
			for(var/entry in M.logging[log_type])
				dat += "<font size=2px>[entry]: [M.logging[log_type][entry]]</font><br>"
			dat += "<hr>"
	else
		dat += "<center>[type] of [key_name(M)]</center><br>"
		for(var/entry in M.logging[type])
			dat += "<font size=2px>[entry]: [M.logging[type][entry]]</font><hr>"

	show_browser(usr, dat, "window=invidual_logging;size=600x480")
