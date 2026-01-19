/datum/computer_file/program/card_mod
	filename = "cardmod"
	filedesc = "ID card modification program"
	nanomodule_path = /datum/nano_module/program/card_mod
	program_icon_state = "id"
	program_key_state = "id_key"
	program_menu_icon = "key"
	program_light_color = "#0099FF"
	extended_desc = "Program for programming crew ID cards."
	required_access = access_change_ids
	requires_ntnet = 0
	size = 8
	category = PROG_COMMAND

/datum/nano_module/program/card_mod
	name = "ID card modification program"
	var/mod_mode = 1
	var/is_centcom = 0
	var/show_assignments = 0

/datum/nano_module/program/card_mod/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, datum/topic_state/state = GLOB.default_state)
	var/list/data = host.initial_data()

	data["src"] = "\ref[src]"
	data["station_name"] = station_name()
	data["manifest"] = html_crew_manifest()
	data["assignments"] = show_assignments
	if(program && program.computer)
		data["have_id_slot"] = !!program.computer.card_slot
		data["have_printer"] = !!program.computer.nano_printer
		data["authenticated"] = program.can_run(user)
		if(!program.computer.card_slot)
			mod_mode = 0 //We can't modify IDs when there is no card reader
	else
		data["have_id_slot"] = 0
		data["have_printer"] = 0
		data["authenticated"] = 0
	data["mmode"] = mod_mode
	data["centcom_access"] = is_centcom

	if(program && program.computer && program.computer.card_slot)
		var/obj/item/card/id/id_card = program.computer.card_slot.stored_card
		data["has_id"] = !!id_card
		data["id_account_number"] = id_card ? id_card.associated_account_number : null
		data["id_rank"] = id_card && id_card.assignment ? id_card.assignment : "Unassigned"
		data["id_owner"] = id_card && id_card.registered_name ? id_card.registered_name : "-----"
		data["id_name"] = id_card ? id_card.name : "-----"
		data["sex"] = id_card ? id_card.sex : "UNSET"
		data["age"] = id_card ? id_card.age : "UNSET"
		data["dna_hash"] = id_card ? id_card.dna_hash : "UNSET"
		data["fingerprint_hash"] = id_card ? id_card.fingerprint_hash : "UNSET"
		data["blood_type"] = id_card ? id_card.blood_type : "UNSET"
		data["front_photo"] = id_card ? id_card.front : "UNSET"
		data["side_photo"] = id_card ? id_card.side : "UNSET"

	data["command_jobs"] = format_jobs(GLOB.command_positions)
	data["support_jobs"] = format_jobs(GLOB.support_positions)
	data["engineering_jobs"] = format_jobs(GLOB.engineering_positions)
	data["medical_jobs"] = format_jobs(GLOB.medical_positions)
	data["science_jobs"] = format_jobs(GLOB.science_positions)
	data["security_jobs"] = format_jobs(GLOB.security_positions)
	data["exploration_jobs"] = format_jobs(GLOB.exploration_positions)
	data["service_jobs"] = format_jobs(GLOB.service_positions)
	data["supply_jobs"] = format_jobs(GLOB.supply_positions)
	data["civilian_jobs"] = format_jobs(GLOB.civilian_positions)
	data["centcom_jobs"] = format_jobs(get_all_centcom_jobs())

	data["all_centcom_access"] = is_centcom ? get_accesses(1) : null
	data["regions"] = get_accesses()

	if(program.computer.card_slot && program.computer.card_slot.stored_card)
		var/obj/item/card/id/id_card = program.computer.card_slot.stored_card
		if(is_centcom)
			var/list/all_centcom_access = list()
			for(var/access in get_all_centcom_access())
				all_centcom_access.Add(list(list(
					"desc" = replacetext(get_centcom_access_desc(access), " ", "&nbsp"),
					"ref" = access,
					"allowed" = (access in id_card.access) ? 1 : 0)))
			data["all_centcom_access"] = all_centcom_access
		else
			var/list/regions = list()
			for(var/i = 1; i <= 7; i++)
				var/list/accesses = list()
				for(var/access in get_region_accesses(i))
					if (get_access_desc(access))
						var/obj/item/card/id/I = user.get_id_card()
						if(!ishuman(user) || (I && (access in I.access)) || (I && (access_human_resources in I.access)))
							accesses.Add(list(list(
								"desc" = replacetext(get_access_desc(access), " ", "&nbsp"),
								"ref" = access,
								"allowed" = (access in id_card.access) ? 1 : 0)))

				if(length(accesses))
					regions.Add(list(list(
						"name" = get_region_accesses_name(i),
						"accesses" = accesses)))
			data["regions"] = regions

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "identification_computer.tmpl", name, 600, 700, state = state)
		ui.auto_update_layout = 1
		ui.set_initial_data(data)
		ui.open()

/datum/nano_module/program/card_mod/proc/format_jobs(list/jobs)
	var/obj/item/card/id/id_card = program.computer.card_slot ? program.computer.card_slot.stored_card : null
	var/list/formatted = list()
	for(var/job in jobs)
		formatted.Add(list(list(
			"display_name" = replacetext(job, " ", "&nbsp"),
			"target_rank" = id_card && id_card.assignment ? id_card.assignment : "Unassigned",
			"job" = job)))

	return formatted

/datum/nano_module/program/card_mod/proc/get_accesses(is_centcom = 0)
	return null

/datum/computer_file/program/card_mod/proc/get_photo(mob/user)
	if(istype(user.get_active_hand(), /obj/item/photo))
		var/obj/item/photo/photo = user.get_active_hand()
		return photo.img
	if(istype(user, /mob/living/silicon))
		var/mob/living/silicon/tempAI = usr
		var/obj/item/photo/selection = tempAI.GetPicture()
		if (selection)
			return selection.img

/datum/computer_file/program/card_mod/proc/get_access_by_rank(rank)
	var/datum/job/jobdatum
	for(var/jobtype in typesof(/datum/job))
		var/datum/job/J = new jobtype
		if(ckey(J.title) == ckey(rank))
			jobdatum = J
			break
	if(!jobdatum)
		to_chat(usr, SPAN_WARNING("No log exists for this job: [rank]"))
		return

	return jobdatum.get_access()

/datum/computer_file/program/card_mod/Topic(href, href_list)
	if(..())
		return 1

	var/mob/user = usr
	var/obj/item/card/id/user_id_card = user.get_id_card()
	var/obj/item/card/id/id_card
	if (computer.card_slot)
		id_card = computer.card_slot.stored_card

	var/datum/nano_module/program/card_mod/module = NM
	switch(href_list["action"])
		if("switchm")
			if(href_list["target"] == "mod")
				module.mod_mode = 1
			else if (href_list["target"] == "manifest")
				module.mod_mode = 0
		if("togglea")
			if(module.show_assignments)
				module.show_assignments = 0
			else
				module.show_assignments = 1
		if("print")
			if(computer && computer.nano_printer) //This option should never be called if there is no printer
				if(module.mod_mode)
					if(can_run(user, 1))
						var/contents = {"<h4>Access Report</h4>
									<u>Prepared By:</u> [user_id_card.registered_name ? user_id_card.registered_name : "Unknown"]<br>
									<u>For:</u> [id_card.registered_name ? id_card.registered_name : "Unregistered"]<br>
									<hr>
									<u>Assignment:</u> [id_card.assignment]<br>
									<u>Account Number:</u> #[id_card.associated_account_number]<br>
									<u>Blood Type:</u> [id_card.blood_type]<br><br>
									<u>Age:</u> [id_card.age]<br><br>
									<u>Sex:</u> [id_card.sex]<br><br>
									<u>Access:</u><br>
								"}

						var/known_access_rights = get_access_ids(ACCESS_TYPE_STATION|ACCESS_TYPE_CENTCOM)
						for(var/A in id_card.access)
							if(A in known_access_rights)
								contents += "  [get_access_desc(A)]"

						if(!computer.nano_printer.print_text(contents,"access report", rawhtml = TRUE))
							to_chat(usr, "<span class='notice'>Hardware error: Printer was unable to print the file. It may be out of paper.</span>")
							return
						else
							computer.visible_message("<span class='notice'>\The [computer] prints out paper.</span>")
				else
					var/contents = {"<h4>Crew Manifest</h4>
									<br>
									[html_crew_manifest()]
									"}
					if(!computer.nano_printer.print_text(contents,text("crew manifest ([])", stationtime2text()), rawhtml = TRUE))
						to_chat(usr, "<span class='notice'>Hardware error: Printer was unable to print the file. It may be out of paper.</span>")
						return
					else
						computer.visible_message("<span class='notice'>\The [computer] prints out paper.</span>")
		if("eject")
			if(computer)
				if(computer.card_slot && computer.card_slot.stored_card)
					computer.proc_eject_id(user)
				else
					computer.attackby(user.get_active_hand(), user)
		if("terminate")
			if(computer && can_run(user, 1, access_human_resources))
				id_card.assignment = "Terminated"
				remove_nt_access(id_card)
				callHook("terminate_employee", list(id_card))
		if("edit")
			if(computer && can_run(user, 1))
				var/static/regex/hash_check = regex(@"^[0-9a-fA-F]{32}$")
				if(href_list["name"])
					var/temp_name = sanitizeName(input("Enter name.", "Name", id_card.registered_name),allow_numbers=TRUE)
					if(temp_name)
						id_card.registered_name = temp_name
					else
						computer.visible_message("<span class='notice'>[computer] buzzes rudely.</span>")
				else if(href_list["account"])
					var/account_num = text2num(input("Enter account number.", "Account", id_card.associated_account_number))
					id_card.associated_account_number = account_num
				else if(href_list["sex"])
					var/sex = input("Select gender", "Gender") as null|anything in list("Male", "Female") // I'm terf!
					if(!isnull(sex))
						id_card.sex = sex
				else if(href_list["age"])
					var/sug_age = text2num(input("Enter age.", "Age", id_card.age))
					if(sug_age > 17)
						id_card.age = sug_age
				else if(href_list["fingerprint_hash"])
					var/sug_fingerprint_hash = sanitize(input("Enter fingerprint hash.", "Fingerprint hash", id_card.fingerprint_hash), 32)
					if(hash_check.Find(sug_fingerprint_hash))
						id_card.fingerprint_hash = sug_fingerprint_hash
				else if(href_list["dna_hash"])
					var/sug_dna_hash = sanitize(input("Enter DNA hash.", "DNA hash", id_card.dna_hash), 32)
					if(hash_check.Find(sug_dna_hash))
						id_card.dna_hash = sug_dna_hash
				else if(href_list["blood_type"])
					var/sug_blood_type = input("Select blood type", "Blood type") as null|anything in GLOB.blood_types
					if(!isnull(sug_blood_type))
						id_card.blood_type = sug_blood_type
				else if(href_list["front_photo"])
					var/photo = get_photo(usr)
					if(photo)
						id_card.front = photo
				else if(href_list["side_photo"])
					var/photo = get_photo(usr)
					if(photo)
						id_card.side = photo
				else if(href_list["load_data"])
					var/list/ass_data = list()
					for(var/datum/computer_file/crew_record/CR in GLOB.all_crew_records)
						ass_data.Add(list(CR.get_name() = CR))
					var/selected_CR_name = input("Select crew record for write down to the card", "Crew record selection") as null|anything in ass_data
					var/datum/computer_file/crew_record/selected_CR = get_crewmember_record(selected_CR_name)
					if(!isnull(selected_CR))
						id_card.registered_name = selected_CR.get_name()
						id_card.assignment = selected_CR.get_job()
						id_card.dna_hash = selected_CR.get_dna()
						id_card.fingerprint_hash = selected_CR.get_fingerprint()
						id_card.sex = selected_CR.get_sex()
						id_card.age = selected_CR.get_age()
						id_card.blood_type = selected_CR.get_bloodtype()
						id_card.front = selected_CR.photo_front
						id_card.side = selected_CR.photo_side
						var/list/access = get_access_by_rank(selected_CR.get_job())
						if(isnull(access))
							SSnano.update_uis(NM)
							return 1
						remove_nt_access(id_card)
						apply_access(id_card, access)
		if("assign")
			if(computer && can_run(user, 1) && id_card)
				var/t1 = href_list["assign_target"]
				if(t1 == "Custom")
					var/temp_t = sanitize(input("Enter a custom job assignment.","Assignment", id_card.assignment), 45)
					//let custom jobs function as an impromptu alt title, mainly for sechuds
					if(temp_t)
						id_card.assignment = temp_t
				else
					var/list/access = list()
					if(module.is_centcom)
						access = get_centcom_access(t1)
					else
						access = get_access_by_rank(t1)

					if(check_assign_eligibility(id_card.access, access, user_id_card.access))
						remove_nt_access(id_card)
						apply_access(id_card, access)
						id_card.assignment = t1
						id_card.rank = t1

				callHook("reassign_employee", list(id_card))
		if("access")
			if(href_list["allowed"] && computer && can_run(user, 1))
				var/access_type = text2num(href_list["access_target"])
				var/access_allowed = text2num(href_list["allowed"])
				if(access_type in get_access_ids(ACCESS_TYPE_STATION|ACCESS_TYPE_CENTCOM))
					id_card.access -= access_type
					if(!access_allowed)
						id_card.access += access_type
	if(id_card)
		id_card.SetName(text("[id_card.registered_name]'s ID Card ([id_card.assignment])"))

	SSnano.update_uis(NM)
	return 1

/datum/computer_file/program/card_mod/proc/remove_nt_access(obj/item/card/id/id_card)
	id_card.access -= get_access_ids(ACCESS_TYPE_STATION|ACCESS_TYPE_CENTCOM)

/datum/computer_file/program/card_mod/proc/apply_access(obj/item/card/id/id_card, list/accesses)
	id_card.access |= accesses

// Checks if the assigner has the proper rights to mess with the given rank.
/datum/computer_file/program/card_mod/proc/check_assign_eligibility(list/old_accesses, list/new_accesses, list/assigner_accesses)
	var/list/res_accesses = old_accesses | new_accesses
	res_accesses -= assigner_accesses
	return !length(res_accesses)
