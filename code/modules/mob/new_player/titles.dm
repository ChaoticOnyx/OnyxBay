var/list/titles = list()

datum/title/
	var/jobname
	var/list/title = list()

datum/title/doctor
	jobname = "Medical Doctor"
	title = list("Medical Doctor","Virologist","Surgeon")

datum/title/scientist
	jobname = "Scientist"
	title = list("Scientist","Plasma Researcher","Anomalist")

datum/title/detective
	jobname = "Forensic Technician"
	title = list("Forensic Technician", "Detective")

datum/title/New()
	titles += src

proc/setuptitles()
	new /datum/title/doctor()
	new /datum/title/scientist()
	new /datum/title/detective()

proc/HasTitles(job)
	for(var/datum/title/A in titles)
		if(A.jobname == job)
			return 1
	return 0
