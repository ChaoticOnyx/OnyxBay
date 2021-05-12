/datum/computer_file/program/records/medical
	filename = "medrecords"
	filedesc = "Medical Records"
	extended_desc = "This program allows access to the crew's medical records."
	nanomodule_path = /datum/nano_module/records/medical
	category = PROG_MED

/datum/nano_module/records/medical
	name = "Medical Records"
	records_context = record_field_context_medical
	template_file = "med_records.tmpl"

/datum/nano_module/records/medical/generate_updated_data()
	var/list/data = ..()
	ASSERT(istype(data))
	var/static/list/med_fields = list("Major Disabilities", "Minor Disabilities", "Current Diseases",\
		"Medical Condition Details", "Important Notes", "Medical Recent Records", "Medical Background")
	var/fields_cached = data["fields"]
	if (!fields_cached)
		return data
	for (var/field in fields_cached)
		var/name = field["name"]
		if (name in med_fields)
			med_fields[name] = field
			data["fields"] -= list(field)

	var/list/med_fields_as_array = list()
	for (var/key in med_fields)
		if (isnull(med_fields[key]))
			med_fields_as_array.Add(list(list(editable = FALSE, name = key, val = "**INTERFACE ERROR**")))
			crash_with("Medical Records: field `[key]` missing from records data structure.") //non-crashing runtime error message
		else
			med_fields_as_array.Add(list(med_fields[key]))
	data["med_fields"] = med_fields_as_array
	return data

/datum/nano_module/records/medical/edit_field(mob/user, field)
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

		var/new_value = replacetext(input(user,\
			"Enter medical record data. You may use HTML paper formatting tags:",
			"Medical Record"), "\n", "\[br\]")
		if (!new_value)
			return FALSE

		var/new_entry = "\[i\]Added [stationtime2text()] [stationdate2text()] :\[/i\]\[br\] [new_value]"
		new_entry = replacetext(new_entry, "\[hr\]", "\[br\]")

		var/prev = F.get_value()
		if (F.get_value() == "None")
			return F.set_value(new_entry)
		return F.set_value("[new_entry]\[br\]\[hr\][prev]")

	return ..()
