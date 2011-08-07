var/list/biglist = list()
atom/New()
	if(!(src.type in biglist))
		biglist += src.type
		biglist[type] = 1
	else
		biglist[type]++
	. = ..()
atom/Del()
	biglist[type]--
	if(biglist[type] <= 0) biglist -= type
	. = ..()

mob/verb/SeeBigList()
	set category = "Admin"
	var/stuff = {""}
	for(var/t in biglist)
		stuff += "<b>[t]</b> = [biglist[t]]<br>"
	usr << browse(stuff)