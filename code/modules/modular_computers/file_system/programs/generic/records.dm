/datum/computer_file/program/records
	filename = "crewrecords"
	filedesc = "Crew Records"
	extended_desc = "This program allows access to the crew's various records."
	program_icon_state = "generic"
	program_key_state = "generic_key"
	program_light_color = "#00B000"
	size = 14
	category = PROG_OFFICE
	requires_ntnet = 1
	available_on_ntnet = 1
	nanomodule_path = /datum/nano_module/records

/datum/nano_module/records
	name = "Crew Records"
	var/datum/computer_file/crew_record/active_record
	var/message = null
	var/template_file = "crew_records.tmpl"
	var/records_context = record_field_context_crew

/datum/nano_module/records/proc/generate_updated_data(mob/user)
	var/list/data = host.initial_data()
	var/list/user_access = get_record_access(user)

	data["message"] = message
	if(active_record)
		if(!isnull(active_record.photo_front))
			send_rsc(user, active_record.photo_front, "front_[active_record.uid].png")
		if(!isnull(active_record.photo_side))
			send_rsc(user, active_record.photo_side, "side_[active_record.uid].png")
		data["pic_edit"] = check_access(user, access_heads) || check_access(user, access_security)
		data["uid"] = active_record.uid
		var/list/fields = list()
		for(var/record_field/F in active_record.fields)
			if(F.can_see(user_access, records_context))
				fields.Add(list(list(
					"key" = F.type,
					"name" = F.name,
					"val" = F.get_display_value(),
					"editable" = F.can_edit(user_access, records_context),
					"large" = (F.valtype == EDIT_LONGTEXT)
				)))
		data["fields"] = fields
	else
		var/list/all_records = list()

		for(var/datum/computer_file/crew_record/R in GLOB.all_crew_records)
			all_records.Add(list(list(
				"name" = R.get_name(),
				"rank" = R.get_job(),
				"id" = R.uid
			)))
			all_records = sortByKey(all_records,"name")
		data["all_records"] = all_records
		data["creation"] = check_access(user, access_heads)
		data["dnasearch"] = check_access(user, access_medical) || check_access(user, access_forensics_lockers)
		data["fingersearch"] = check_access(user, access_security)

	return data

/datum/nano_module/records/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, state = GLOB.default_state)
	var/list/data = generate_updated_data(user)

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, template_file, name, 700, 540, state = state)
		ui.auto_update_layout = 1
		ui.set_initial_data(data)
		ui.open()


/datum/nano_module/records/proc/get_record_access(mob/user)
	var/list/user_access = using_access || user.GetAccess()

	var/obj/item/modular_computer/PC = nano_host()
	if(istype(PC) && PC.computer_emagged)
		user_access = user_access.Copy()
		user_access |= access_syndicate

	return user_access

/proc/edit_department(datum/computer_file/crew_record/R, current_department_flags_name_list, default_message)
	var/current_department_flags = "[default_message] [english_list(current_department_flags_name_list)]"
	var/list/options = list()
	options["Add ([current_department_flags])"] = 1
	options["Remove ([current_department_flags])"] = 2
	var/option = input("Select option (Cancel if Done)", "Edit Options") as null|anything in options
	switch(options[option])
		if(1)
			var/list/remain_flags = R.assigned_deparment_flags ^ GLOB.department_flags
			var/list/remain_flags_text = list()
			for(var/flag in remain_flags)
				remain_flags_text[GLOB.department_flags_to_text[num2text(flag)]] = flag
			var/selected_flag = input("Select flag", "Department Flag") as null|anything in remain_flags_text
			if(remain_flags_text[selected_flag])
				var/flag = remain_flags_text[selected_flag]
				R.assigned_deparment_flags += flag
				current_department_flags_name_list[selected_flag] = flag
			. = edit_department(R, current_department_flags_name_list, default_message)
		if(2)
			var/selected_flag = input("Select flag name", "Department Flag") as null|anything in current_department_flags_name_list
			if(selected_flag)
				var/flag = current_department_flags_name_list[selected_flag]
				R.assigned_deparment_flags -= flag
				current_department_flags_name_list -= selected_flag
			. = edit_department(R, current_department_flags_name_list, default_message)
		else
			. = current_department_flags_name_list

/datum/nano_module/records/proc/edit_field(mob/user, field)
	var/datum/computer_file/crew_record/R = active_record
	if(!R)
		return FALSE
	var/record_field/F = locate(field) in R.fields
	if(!F)
		return FALSE

	if(!F.can_edit(get_record_access(user), records_context))
		to_chat(user, "<span class='notice'>\The [nano_host()] flashes an \"Access Denied\" warning.</span>")
		return FALSE

	var/newValue
	if(F.name == "Department")
		var/default_message = "The current list of department flags:"
		var/list/current_department_flags_name_list = list()
		for(var/flag in R.assigned_deparment_flags)
			current_department_flags_name_list[GLOB.department_flags_to_text[num2text(flag)]] = flag

		newValue = english_list(edit_department(R, current_department_flags_name_list, default_message))
	else
		switch(F.valtype)
			if(EDIT_SHORTTEXT)
				newValue = sanitize(input(user, "Enter [F.name]:", "Record edit", html_decode(F.get_value())))
			if(EDIT_LONGTEXT)
				newValue = sanitize(replacetext(input(user, "Enter [F.name]. You may use HTML paper formatting tags:", "Record edit", replacetext(html_decode(F.get_value()), "\[br\]", "\n")), "\n", "\[br\]"))
			if(EDIT_NUMERIC)
				newValue = input(user, "Enter [F.name]:", "Record edit", F.get_value()) as null|num
			if(EDIT_LIST)
				var/options = F.get_options()
				newValue = input(user,"Pick [F.name]:", "Record edit", F.get_value()) as null|anything in options

	if(active_record != R)
		return FALSE
	if(!F.can_edit(get_record_access(user), records_context))
		to_chat(user, "<span class='notice'>\The [nano_host()] flashes an \"Access Denied\" warning.</span>")
		return FALSE
	if(newValue)
		return F.set_value(newValue)

/datum/nano_module/records/Topic(href, href_list)
	if(..())
		return 1
	if(href_list["clear_active"])
		active_record = null
		return 1
	if(href_list["clear_message"])
		message = null
		return 1
	if(href_list["set_active"])
		var/ID = text2num(href_list["set_active"])
		for(var/datum/computer_file/crew_record/R in GLOB.all_crew_records)
			if(R.uid == ID)
				active_record = R
				break
		return 1
	if(href_list["new_record"])
		if(!check_access(usr, access_heads))
			to_chat(usr, "Access Denied.")
			return
		active_record = new /datum/computer_file/crew_record()
		GLOB.all_crew_records.Add(active_record)
		return 1
	if(href_list["print_active"])
		if(!active_record)
			return
		print_text(record_to_html(active_record, get_record_access(usr), records_context), usr, rawhtml = TRUE)
		return 1
	if(href_list["search"])
		var/field = text2path("/record_field/"+href_list["search"])
		var/search = sanitize(input("Enter the value for search for.") as null|text)
		if(!search)
			return
		for(var/datum/computer_file/crew_record/R in GLOB.all_crew_records)
			if(lowertext(R.get_field(field)) == lowertext(search))
				active_record = R
				return 1
		message = "Unable to find record containing '[search]'"
		return 1

	var/datum/computer_file/crew_record/R = active_record
	if(!istype(R))
		return 1
	if(href_list["edit_photo_front"])
		var/photo = get_photo(usr)
		if(photo && active_record)
			active_record.photo_front = photo
		return 1
	if(href_list["edit_photo_side"])
		var/photo = get_photo(usr)
		if(photo && active_record)
			active_record.photo_side = photo
		return 1
	if(href_list["edit_field"])
		edit_field(usr, text2path(href_list["edit_field"]))
		return 1

/datum/nano_module/records/proc/get_photo(mob/user)
	if(istype(user.get_active_hand(), /obj/item/photo))
		var/obj/item/photo/photo = user.get_active_hand()
		return photo.img
	if(istype(user, /mob/living/silicon))
		var/mob/living/silicon/tempAI = usr
		var/obj/item/photo/selection = tempAI.GetPicture()
		if (selection)
			return selection.img
