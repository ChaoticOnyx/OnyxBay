/datum/computer_file/program/hire_tool
	filename = "NTHiretool"
	filedesc = "Hire Management Tool"
	nanomodule_path = /datum/nano_module/program/hire_tool
	program_icon_state = "id"
	program_key_state = "id_key"
	program_menu_icon = "suitcase"
	program_light_color = "#0099FF"
	extended_desc = "The official NanoTrasen application that allows head command to hire new employees."
	required_access = access_human_resources
	requires_ntnet = 1
	size = 16
	usage_flags = PROGRAM_CONSOLE
	category = PROG_COMMAND

/datum/nano_module/program/hire_tool
	name = "Hire Management Tool"
	var/hiring_menu = FALSE
	var/hiring_job = null
	var/message = ""

/datum/nano_module/program/hire_tool/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, datum/topic_state/state = GLOB.default_state)
	var/list/data = host.initial_data()

	data["hiring_menu"] = hiring_menu
	if(hiring_menu)
		var/datum/storyteller_character/ST = SSstoryteller.character
		data["limit"] = "\[limit - [length(GLOB.vacancies)]/[ST ? ST.get_available_vacancies() : job_master.get_available_vacancies()]\]"

		if(hiring_job)
			data["hiring_job"] = hiring_job

		if(message)
			data["message"] = message

		data["security_jobs"] = correct_available_jobs(GLOB.security_positions)
		data["medical_jobs"] = correct_available_jobs(GLOB.medical_positions)
		data["engineering_jobs"] = correct_available_jobs(GLOB.engineering_positions)
		data["science_jobs"] = correct_available_jobs(GLOB.science_positions)
		data["support_jobs"] = correct_available_jobs(GLOB.support_positions)
		data["supply_jobs"] = correct_available_jobs(GLOB.supply_positions)
		data["service_jobs"] = correct_available_jobs(GLOB.service_positions)
		data["civilian_jobs"] = correct_available_jobs(GLOB.civilian_positions)

	var/list/job_vacancies = newlist()
	for(var/datum/job_vacancy/JO in GLOB.vacancies)
		job_vacancies |= vacancy_to_nanoui(JO)
	data["current_vacancies"] = job_vacancies.len ? job_vacancies : 0

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "hire_tool.tmpl", name, 600, 700, state = state)
		ui.auto_update_layout = 1
		ui.set_initial_data(data)
		ui.open()

/datum/nano_module/program/hire_tool/proc/correct_available_jobs(list/positions)
	if(!positions)
		return

	var/list/jobs = newlist()
	for(var/i in positions)
		var/datum/job/J = job_master.GetJob(i)
		if(!J)
			continue
		if(!J.can_be_hired)
			continue
		if(J.head_position)
			continue
		jobs |= J.title

	return jobs

/datum/nano_module/program/hire_tool/proc/vacancy_to_nanoui(datum/job_vacancy/JV)
	return list(list(
		"title" = JV.title,
		"status" = JV.status,
		"time" = JV.time,
		"filledby" = JV.filledby,
		"id" = JV.id
		))

/datum/nano_module/program/hire_tool/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["open_hiring_menu"])
		hiring_menu = TRUE
		return 1

	else if(href_list["close_hiring_menu"])
		hiring_menu = FALSE
		hiring_job = null
		message = ""
		return 1

	else if(href_list["vacancy_confirmation"])
		var/datum/storyteller_character/ST = SSstoryteller.character
		var/available_vacancies = ST ? ST.get_available_vacancies() : job_master.get_available_vacancies()
		if(length(GLOB.vacancies) >= available_vacancies)
			message = "You can't open new vacancies because you have reached the limit."
			hiring_job = -1
			return 1
		hiring_job = href_list["vacancy_confirmation"]
		return 1

	else if(href_list["close_message"])
		hiring_job = null
		message = ""
		return 1

	else if(href_list["open_vacancy"])
		if(job_master.open_vacancy(hiring_job))
			message = "Vacancy successfully opened for: '[hiring_job]'"
		else
			message = "Failed to open vacancy for: '[hiring_job]'"
		return 1

	else if(href_list["delete_vacancy"])
		job_master.delete_vacancy(text2num(href_list["delete_vacancy"]))
		return 1
