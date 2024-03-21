/client/proc/pingfromtime(time)
	return ((world.time+world.tick_lag*TICK_USAGE/100)-time)*100

/client/verb/display_ping(time as num)
	set instant = TRUE
	set name = ".display_ping"
	to_chat(src, "<span class='notice'>Round trip ping took [round(pingfromtime(time),1)]ms</span>")

/client/verb/ping()
	set name = "Show ping"
	set category = "OOC"
	winset(src, null, "command=.display_ping+[world.time+world.tick_lag*TICK_USAGE/100]")
