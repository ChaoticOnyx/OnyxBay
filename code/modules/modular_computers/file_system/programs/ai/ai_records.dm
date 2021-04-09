/datum/computer_file/program/records/ai
	filename = "airecords"
	filedesc = "AI Records"
	extended_desc = "This program allows access to the crew's records."
	available_on_ntnet = FALSE
	nanomodule_path = /datum/nano_module/records/ai

/datum/nano_module/records/ai
	name = "AI Records"
	records_context = record_field_context_medical | record_field_context_crew | record_field_context_security
	template_file = "ai_records.tmpl"

/datum/nano_module/records/ai/generate_updated_data()
	var/list/data = ..()
	ASSERT(istype(data))
	var/static/list/med_fields = list("Major Disabilities", "Minor Disabilities", "Current Diseases",\
		"Medical Condition Details", "Important Notes", "Medical Recent Records", "Medical Background")
	var/static/list/sec_fields = list("Criminal Status", "Major Crimes", "Minor Crimes", "Crime Details", "Important Notes", "Security Recent Records", "Security Background")
	var/fields_cached = data["fields"]
	if (!fields_cached)
		return data
	for (var/field in fields_cached)
		var/name = field["name"]
		if (name in med_fields)
			med_fields[name] = field
			data["fields"] -= list(field)
		if (name in sec_fields)
			data["fields"] -= list(field)
			if (name == "Criminal Status")
				var/clr = criminal_status_color(field["val"])
				if (clr)
					field["val"] = "<font color='[clr]'>[field["val"]]</font>"
			sec_fields[name] = field

	var/list/med_fields_as_array = list()
	for (var/key in med_fields)
		if (isnull(med_fields[key]))
			med_fields_as_array.Add(list(list(editable = FALSE, name = key, val = "**INTERFACE ERROR**")))
			crash_with("Medical Records: field `[key]` missing from records data structure.") //non-crashing runtime error message
		else
			med_fields_as_array.Add(list(med_fields[key]))
	data["med_fields"] = med_fields_as_array
	var/list/sec_fields_as_array = list()
	for (var/key in sec_fields)
		if (isnull(sec_fields[key]))
			sec_fields_as_array.Add(list(list(editable = FALSE, name = key, val = "**INTERFACE ERROR**")))
			crash_with("Security Records: field `[key]` missing from records data structure.") //non-crashing runtime error message
		else
			sec_fields_as_array.Add(list(sec_fields[key]))
	data["sec_fields"] = sec_fields_as_array
	return data

/datum/nano_module/records/ai/edit_field(mob/user, field)
	var/datum/computer_file/crew_record/R = active_record
	if (!R)
		return FALSE
	var/record_field/F = locate(field) in R.fields
	if (!F)
		return FALSE

	if (!F.can_edit(get_record_access(user), records_context))
		to_chat(user, "<span class='notice'>\The [nano_host()] flashes an \"Access Denied\" warning.</span>")
		return FALSE

	if (F.name == "Medical Recent Records")

		// med...
		var/new_value = replacetext(input(user,\
			"Enter medical record data. You may use HTML paper formatting tags:",
			"Medical Record"), "\n", "\[br\]")
		if (!new_value)
			return FALSE

		var/new_entry = "\[i\]Added [stationtime2text()] [stationdate2text()] :\[/i\]\[br\] [new_value]"

		var/prev = F.get_value()
		if (F.get_value() == "None")
			return F.set_value(new_entry)
		return F.set_value("[new_entry]\[br\]\[hr\][prev]")

	if(F.name == "Security Recent Records")
		// sec...
		var/record_field/major_crimes/major_crimes = locate() in R.fields; ASSERT(istype(major_crimes))
		var/record_field/minor_crimes/minor_crimes = locate() in R.fields; ASSERT(istype(minor_crimes))
		var/record_field/crime_details/crime_details = locate() in R.fields; ASSERT(istype(crime_details))
		var/record_field/crime_notes/crime_notes = locate() in R.fields; ASSERT(istype(crime_notes))
		var/record_field/criminalStatus/criminal_status = locate() in R.fields; ASSERT(istype(criminal_status))

		var/sentence_info = replacetext(input(user,\
			"Enter information about sentence. You may use HTML paper formatting tags:",
			"Issued sentence"), "\n", "\[br\]")
		if (!sentence_info)
			return FALSE

		var/new_entry = ""
		new_entry += "\[i\]Added [stationtime2text()] [stationdate2text()] :\[/i\]\[br\]"
		new_entry += "\[b\]Major Crimes:\[/b\]\[br\] [major_crimes.get_value()]\[br\]"
		new_entry += "\[b\]Minor Crimes:\[/b\]\[br\] [minor_crimes.get_value()]\[br\]"
		new_entry += "\[b\]Crime Details:\[/b\]\[br\] [crime_details.get_value()]\[br\]"
		new_entry += "\[b\]Important Notes:\[/b\]\[br\] [crime_notes.get_value()]\[br\]"
		new_entry += "\[b\]Sentence:\[/b\]\[br\] [sentence_info]"
		new_entry = replacetext(new_entry, "\[hr\]", "\[br\]")

		major_crimes.set_value("None")
		minor_crimes.set_value("None")
		crime_details.set_value("None")
		crime_notes.set_value("None")
		criminal_status.set_value("Incarcerated")

		var/prev = F.get_value()
		if (F.get_value() == "None")
			return F.set_value(new_entry)
		return F.set_value("[new_entry]\[br\]\[hr\][prev]")


	return ..()
