var/list/occupations = list(
	"Engineer", "Engineer", "Engineer", "Engineer", "Engineer",
	"Security Officer", "Security Officer", "Security Officer", "Security Officer", "Security Officer",
	"Detective",
	"Geneticist",
	"Scientist",	"Scientist", "Scientist",
	"Anomalist",
	"Atmospheric Technician", "Atmospheric Technician", "Atmospheric Technician",
	"Medical Doctor", "Medical Doctor",
	"Head of Personnel",
	"Head of Security",
	"Chief Engineer",
	"Research Director",
	"Counselor",
	"Roboticist",
	"AI",
	"Barman",
	"Chef",
	"Janitor",
	"Chemist",
	"Quartermaster","Quartermaster","Quartermaster")

var/list/assistant_occupations = list(
	"Unassigned")

/proc/IsResearcher(var/job)
	switch(job)
		if("Genticist")
			return 1
		if("Scientist")
			return 1
		if("Medical Doctor")
			return 1
		if("Roboticist")
			return 1
		if("Research Director")
			return 2
		else
			return 0

/proc/GetRank(var/job)
	switch(job)
		if("Unassigned")
			return 0
		if("Engineer")
			return 1
		if("Security Officer")
			return 2
		if("Detective")
			return 2
		if("Geneticist")
			return 1
		if("Scientist")
			return 1
		if("Anomalist")
			return 1
		if("Atmospheric Technician")
			return 1
		if("Medical Doctor")
			return 1
		if("Head of Personnel")
			return 4
		if("Head of Security")
			return 3
		if("Chief Engineer")
			return 3
		if("Research Director")
			return 3
		if("Counselor")
			return 1
		if("Roboticist")
			return 1
		if("Barman")
			return 0
		if("Chef")
			return 0
		if("Janitor")
			return 0
		if("Chemist")
			return 2
		if("Quartermaster")
			return 2
		if("Captain")
			return 4
		else
			world << "[job] NOT GIVEN RANK, REPORT JOB.DM ERROR TO CODER"

/proc/IsSecurity(var/job)
	if("Security Officer")
		return 1
	if("Detective")
		return 1
	if("Head of Security")
		return 2
	else
		return 0