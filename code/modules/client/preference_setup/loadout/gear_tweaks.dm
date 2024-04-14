/datum/gear_tweak/proc/get_contents(metadata)
	return

/datum/gear_tweak/proc/get_metadata(user, metadata)
	return

/datum/gear_tweak/proc/get_default()
	return

/datum/gear_tweak/proc/get_random()
	return get_default()

/datum/gear_tweak/proc/tweak_gear_data(metadata, datum/gear_data)
	return

/datum/gear_tweak/proc/tweak_item(obj/item/I, metadata)
	return

/datum/gear_tweak/proc/tweak_description(description, metadata)
	return description

/*
* Custom adjustment
*/

/datum/gear_tweak/custom
	var/datum/custom_item/current_data

/datum/gear_tweak/custom/New(datum/custom_item/data)
	current_data = data

/datum/gear_tweak/custom/tweak_item(obj/item/I, metadata)
	current_data.apply_to_item(I)

/datum/gear_tweak/custom/tweak_description(description, metadata)
	return current_data.item_desc ? current_data.item_desc : description

/*
* Color adjustment
*/

/datum/gear_tweak/color
	var/list/valid_colors

/datum/gear_tweak/color/New(list/valid_colors)
	src.valid_colors = valid_colors
	..()

/datum/gear_tweak/color/get_contents(metadata)
	return "Color: <font color='[metadata]'>&#9899;</font>"

/datum/gear_tweak/color/get_default()
	return valid_colors ? valid_colors[1] : COLOR_WHITE

/datum/gear_tweak/color/get_random()
	return valid_colors ? pick(valid_colors) : rgb(rand(200) + 55, rand(200) + 55, rand(200) + 55)

/datum/gear_tweak/color/get_metadata(user, metadata, title = CHARACTER_PREFERENCE_INPUT_TITLE)
	if(valid_colors)
		return input(user, "Choose a color.", title, metadata) as null|anything in valid_colors
	return tgui_color_picker(user, "Choose a color.", title, metadata)

/datum/gear_tweak/color/tweak_item(obj/item/I, metadata)
	if(valid_colors && !(metadata in valid_colors))
		return
	I.color = metadata

/*
* Path adjustment
*/

/datum/gear_tweak/path
	var/check_type = /obj/item
	var/list/valid_paths

/datum/gear_tweak/path/New(list/valid_paths)
	if(!valid_paths.len)
		CRASH("No type paths given")
	var/list/duplicate_keys = duplicates(valid_paths)
	if(duplicate_keys.len)
		CRASH("Duplicate names found: [english_list(duplicate_keys)]")
	var/list/duplicate_values = duplicates(list_values(valid_paths))
	if(duplicate_values.len)
		CRASH("Duplicate types found: [english_list(duplicate_values)]")
	// valid_paths, but with names sanitized to remove \improper
	var/list/valid_paths_san = list()
	for(var/path_name in valid_paths)
		if(!istext(path_name))
			CRASH("Expected a text key, was [log_info_line(path_name)]")
		var/selection_type = valid_paths[path_name]
		if(!ispath(selection_type, check_type))
			CRASH("Expected an [log_info_line(check_type)] path, was [log_info_line(selection_type)]")
		var/path_name_san = replacetext(path_name, "\improper", "")
		valid_paths_san[path_name_san] = selection_type
	src.valid_paths = sortAssoc(valid_paths)

/datum/gear_tweak/path/type/New(type_path)
	..(atomtype2nameassoclist(type_path))

/datum/gear_tweak/path/subtype/New(type_path)
	..(atomtypes2nameassoclist(subtypesof(type_path)))

/datum/gear_tweak/path/specified_types_list/New(type_paths)
	..(atomtypes2nameassoclist(type_paths))

/datum/gear_tweak/path/specified_types_list/atoms
	check_type = /atom

/datum/gear_tweak/path/specified_types_args/New()
	..(atomtypes2nameassoclist(args))

/datum/gear_tweak/path/get_contents(metadata)
	return "Type: [metadata]"

/datum/gear_tweak/path/get_default()
	return valid_paths[1]

/datum/gear_tweak/path/get_random()
	return pick(valid_paths)

/datum/gear_tweak/path/get_metadata(user, metadata)
	return input(user, "Choose a type.", CHARACTER_PREFERENCE_INPUT_TITLE, metadata) as null|anything in valid_paths

/datum/gear_tweak/path/tweak_gear_data(metadata, datum/gear_data/gear_data)
	if(!(metadata in valid_paths))
		return
	gear_data.path = valid_paths[metadata]

/datum/gear_tweak/path/tweak_description(description, metadata)
	if(!(metadata in valid_paths))
		return ..()
	var/obj/O = valid_paths[metadata]
	return initial(O.desc) || description

/*
* Departmental auto-adjustment
*/

/datum/gear_tweak/departmental
	var/list/jobs_to_paths

	var/datum/job/current_job
	var/list/selected_jobs

/datum/gear_tweak/departmental/New(list/jobs_to_paths)
	src.jobs_to_paths = jobs_to_paths

/datum/gear_tweak/departmental/proc/set_selected_jobs(current_job, selected_jobs)
	if(current_job && !istype(current_job,/datum/job))
		CRASH("Expected /datum/job, got [current_job]")
	if(selected_jobs && !islist(selected_jobs))
		CRASH("Expected list, got [selected_jobs]")
	src.current_job = current_job
	src.selected_jobs = selected_jobs

/datum/gear_tweak/departmental/get_contents(metadata)
	. = list()
	LAZYINITLIST(metadata)
	for(var/datum/job/job in selected_jobs)
		var/list/choices = jobs_to_paths[job.type]
		if(!(job.type in jobs_to_paths) || length(choices) < 2)
			continue

		var/choice = text2path(metadata["[job.type]"]) || choices[1]
		.["[job.title]: [get_initial_name(choice)]"] = job.type

/datum/gear_tweak/departmental/get_metadata(user, metadata, subtype)
	LAZYINITLIST(metadata)
	ASSERT(istext(subtype))
	var/job_path = text2path(subtype)
	if(!job_path || !(job_path in jobs_to_paths))
		CRASH("Expected subtype to be in the list of jobs to select gear for")
	var/default = null
	var/old_choice = text2path(metadata[subtype])
	if(old_choice)
		default = get_initial_name(old_choice)
	var/list/choices = atomtypes2nameassoclist(jobs_to_paths[job_path])
	var/choice = input(user, "Choose a type.", CHARACTER_PREFERENCE_INPUT_TITLE, default) as null|anything in choices
	if(choice)
		metadata[subtype] = "[choices[choice]]"
	return metadata

/datum/gear_tweak/departmental/tweak_gear_data(metadata, datum/gear_data/gear_data)
	LAZYINITLIST(metadata)
	var/datum/job/job = get_valid_current_job()
	if(!istype(job))
		return

	var/text_path = metadata["[job.type]"]
	gear_data.path = text2path(text_path)
	if(!gear_data.path)
		gear_data.path = jobs_to_paths[job.type][1]

/datum/gear_tweak/departmental/proc/get_valid_current_job()
	if(current_job && (current_job.type in jobs_to_paths))
		return current_job

	if(!length(selected_jobs))
		return

	for(var/datum/job/job in selected_jobs)
		if(!istype(job))
			CRASH("Expected /datum/job, got [job]")
		if(job.type in jobs_to_paths)
			return job

/*
* Content adjustment
*/

/datum/gear_tweak/contents
	var/list/valid_contents

/datum/gear_tweak/contents/New()
	valid_contents = args.Copy()
	..()

/datum/gear_tweak/contents/get_contents(metadata)
	return "Contents: [english_list(metadata, and_text = ", ")]"

/datum/gear_tweak/contents/get_default()
	. = list()
	for(var/i = 1 to valid_contents.len)
		. += "Random"

/datum/gear_tweak/contents/get_random()
	return "Random"

/datum/gear_tweak/contents/get_metadata(user, list/metadata)
	. = list()
	for(var/i = metadata.len to (valid_contents.len - 1))
		metadata += "Random"
	for(var/i = 1 to valid_contents.len)
		var/entry = input(user, "Choose an entry.", CHARACTER_PREFERENCE_INPUT_TITLE, metadata[i]) as null|anything in (valid_contents[i] + list("Random", "None"))
		if(entry)
			. += entry
		else
			return metadata

/datum/gear_tweak/contents/tweak_item(obj/item/I, list/metadata)
	if(metadata.len != valid_contents.len)
		return
	for(var/i = 1 to valid_contents.len)
		var/path
		var/list/contents = valid_contents[i]
		if(metadata[i] == "Random")
			path = pick(contents)
			path = contents[path]
		else if(metadata[i] == "None")
			continue
		else
			path = 	contents[metadata[i]]
		if(path)
			new path(I)
		else
			log_debug("Failed to tweak item: Index [i] in [json_encode(metadata)] did not result in a valid path. Valid contents: [json_encode(valid_contents)]")

/*
* Ragent adjustment
*/

/datum/gear_tweak/reagents
	var/list/valid_reagents

/datum/gear_tweak/reagents/New(list/reagents)
	valid_reagents = reagents.Copy()
	..()

/datum/gear_tweak/reagents/get_contents(metadata)
	return "Reagents: [metadata]"

/datum/gear_tweak/reagents/get_default()
	return "Random"

/datum/gear_tweak/reagents/get_metadata(user, list/metadata)
	. = input(user, "Choose an entry.", CHARACTER_PREFERENCE_INPUT_TITLE, metadata) as null|anything in (valid_reagents + list("Random", "None"))
	if(!.)
		return metadata

/datum/gear_tweak/reagents/tweak_item(obj/item/I, list/metadata)
	if(metadata == "None")
		return
	if(metadata == "Random")
		. = valid_reagents[pick(valid_reagents)]
	else
		. = valid_reagents[metadata]
	I.reagents.add_reagent(., I.reagents.get_free_space())
