var/list/titles = list()

datum/title/
	var/jobname
	var/list/title = list()
datum/title/doctor
	jobname = "Medical Doctor"
	title = list("Medical Doctor","Surgeon")
datum/title/scientist
	jobname = "Scientist"
	title = list("Scientist","Anomalist")

datum/title/New()
	titles += src
world/New()
	setuptitles() // MOVE THIS!!!!
	..()
proc/setuptitles()
	new 	/datum/title/doctor ()

proc/HasTitles(job)
	for(var/datum/title/A in titles)
		if(A.jobname == job)
			return 1
	return 0
