var/const/ENG               =(1<<0)
var/const/SEC               =(1<<1)
var/const/MED               =(1<<2)
var/const/SCI               =(1<<3)
var/const/CIV               =(1<<4)
var/const/COM               =(1<<5)
var/const/MSC               =(1<<6)
var/const/SRV               =(1<<7)
var/const/SUP               =(1<<8)
var/const/SPT               =(1<<9)
var/const/EXP               =(1<<10)

GLOBAL_LIST_EMPTY(assistant_occupations)

GLOBAL_LIST_EMPTY(command_positions)

GLOBAL_LIST_EMPTY(engineering_positions)

GLOBAL_LIST_EMPTY(medical_positions)

GLOBAL_LIST_EMPTY(science_positions)

GLOBAL_LIST_EMPTY(civilian_positions)

GLOBAL_LIST_EMPTY(security_positions)

GLOBAL_LIST_INIT(nonhuman_positions, list("pAI"))

GLOBAL_LIST_EMPTY(service_positions)

GLOBAL_LIST_EMPTY(supply_positions)

GLOBAL_LIST_EMPTY(support_positions)

GLOBAL_LIST_EMPTY(exploration_positions)

GLOBAL_LIST_EMPTY(unsorted_positions) // for nano manifest

GLOBAL_LIST_INIT(whitejobs, list("Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Chief Medical Officer", "Research Director", "AI"))

GLOBAL_LIST_INIT(old_job_to_new_job, list(
	"Captain" = "Cocktain",
	"Assistant" = "Vagabond",
	"Technical Assistant" = "Technical Vagabond",
	"Medical Intern" = "Medical Maid",
	"Research Assistant" = "Research Vagabond",
	"Head of Personnel" = "Meister",
	"Bartender" = "NT Agent",
	"Chef" = "Monkey Killer",
	"Gardener" = "Cannabis supplier",
	"Quartermaster" = "Cigarette provider",
	"Cargo Technician" = "Assistant Cigarette Provider",
	"Chaplain" = "Heretic",
	"Chief Engineer" = "Chief Alcoholic",
	"Station Engineer" = "Station Alcoholic",
	"Maintenance Technician" = "Maintenance Alcoholic",
	"Engine Technician" = "Engine Alcoholic",
	"Electrician" = "Romanian Electrician",
	"Atmospheric Technician" = "Atmospheric Alcoholic",
	"Chief Medical Officer" = "Chief Killer Officer",
	"Medical Doctor" = "Medical Killer",
	"Surgeon" = "Surgical Killer",
	"Emergency Physician" = "Emergency Alcoholic",
	"Nurse" = "Maid",
	"Virologist" = "Chinese",
	"Chemist" = "Drugdealer",
	"Pharmacist" = "Black Market Drugdealer",
	"Psychiatrist" = "Free Funny Pills",
	"Psychologist" = "The one who was bullied at school",
	"Paramedic" = "Fast Cat",
	"Emergency Medical Technician" = "Emergency Fast Alcoholic",
	"Research Director" = "Chief Nerd",
	"Scientist" = "Nerd",
	"Xenoarcheologist" = "Nerd Miner",
	"Anomalist" = "Stone Nerd",
	"Plasma Researcher" = "Nerd Toxicomaniac",
	"Xenobiologist" = "Furry",
	"Xenobotanist" = "Tomato killer army's general",
	"Roboticist" = "Robo Alcoholic",
	"Biomechanical Engineer" = "Biomechanical Alcoholic",
	"Mechatronic Engineer" = "Mechatronic Alcoholic",
	"Head of Security" = "Head of Scum",
	"Warden" = "Fat Man",
	"Detective" = "Unfunny man",
	"Forensic Technician" = "Forensic Alcoholic",
	"Security Officer" = "Security Scum",
	"Junior Officer" = "Junior Scum",
	"AI" = "Main Iron Tin Can",
	"Cyborg" = "Brainy Tin Can",
	"Android" = "Silicon Tin Can",
	"Robot" = "Iron Tin Can",
	"Shaft Miner" = "Minecrafter",
	"Drill Technician" = "Industrial Crafter",
	"Prospector" = "FNV admirer",
	"Janitor" = "Captain",
	"Custodian" = "NT official",
	"Sanitation Technician" = "Sanitation Alcoholic",
	"Librarian" = "Book Man",
	"Journalist" = "Shoot Me At Sight",
	"Internal Affairs Agent" = "Prisoner",
	"Lawyer" = "Walking Space Law",
	"Merchant" = "Free Money",
	"Mime" = "Silent Killer",
	"Clown" = "Loud Killer"
))

GLOBAL_LIST_INIT(new_job_to_old_job, reverse_assoc_list(GLOB.old_job_to_new_job))

/proc/guest_jobbans(job)
	return (get_job_title(job, TRUE) in GLOB.whitejobs) //rot beycev ebal

/proc/get_job_title(old_name, normal_name = FALSE)
	if(!((old_name in GLOB.old_job_to_new_job) || (old_name in GLOB.new_job_to_old_job)))
		return old_name
	var/title
	if(normal_name)
		if(old_name in GLOB.old_job_to_new_job || !(old_name in GLOB.new_job_to_old_job))
			return old_name
		title = GLOB.new_job_to_old_job[old_name]
	else
		title = GLOB.old_job_to_new_job[old_name]
	if(!title)
		title = old_name
	return title

/proc/get_job_title_list(list/job_titles, normal_name = FALSE)
	var/list/output = list()
	for(var/title in job_titles)
		output.Add(get_job_title(title, normal_name))
	return output

/proc/get_job_datums()
	var/list/occupations = list()
	var/list/all_jobs = typesof(/datum/job)

	for(var/A in all_jobs)
		var/datum/job/job = new A()
		if(!job)	continue
		occupations += job

	return occupations

/proc/get_alternate_titles(job)
	var/list/jobs = get_job_datums()
	var/list/titles = list()

	for(var/datum/job/J in jobs)
		if(J.title == job)
			for(var/title in J.alt_titles)
				titles.Add(get_job_title(title))

	return titles
