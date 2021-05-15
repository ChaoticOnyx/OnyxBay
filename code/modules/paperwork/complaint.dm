/obj/item/weapon/paper/complaint_form
	name = "Complaint form #______"

	var/id
	var/signed = FALSE
	var/signed_ckey
	var/signed_name

/obj/item/weapon/paper/complaint_form/examine(mob/user)
	. = ..()
	if (signed)
		. += "\n[SPAN_NOTICE("It appears to be signed. It can't be modified.")]"
	else
		. += "\n[SPAN_NOTICE("It appears to be unsigned and ready for modifications.")]"


/obj/item/weapon/paper/complaint_form/get_signature(obj/item/weapon/pen/P, mob/user, signfield)
	. = ..()
	if (signfield == "finish")
		signed = TRUE
		signed_ckey = user?.client?.ckey
		if (isnull(signed_ckey))
			crash_with("THIS IS NOT AN ERROR. obj/item/weapon/paper/complaint_form got signed by mob/user with no client/ckey, if it is intended remove that `crash_with`")
		signed_name = strip_html_properly(.)
		name += ", signed by [signed_name]"
		make_readonly() //nanomachines, son

/obj/item/weapon/paper/complaint_form/rename()
	set name = "Rename paper"
	set hidden = 1
	return

/obj/item/weapon/paper/complaint_form/New(loc, id, target_name, target_occupation, noinit = FALSE)
	. = ..(loc)
	if (noinit)
		return
	appendable = FALSE
	src.id = id
	var/new_title = "Complaint form #[id]"
	if (target_name)
		new_title += ": [target_name]"
	var/new_content = "ID: [id]"
	new_content += "\[br\]Subject: [target_name ? target_name : @"[field=target_name]"]"
	new_content += "\[br\]Subject occupation: [target_occupation ? target_occupation : @"[field=target_occupation]"]"
	new_content += "\[br\]Complaint reason (brief): \[field=brief_reason\]"
	new_content += "\[br\]Complaint reason: \[field=reason\]"
	new_content += "\[br\]\[hr\]"
	new_content += "\[br\]\[right\]Name: \[field=name\]"
	new_content += "\[br\]Occupation: \[field=occupation\]"
	new_content += "\[br\]Sign: \[signfield=finish\]\[/right\]"
	set_content(new_content, new_title)

/obj/item/weapon/paper/complaint_form/copy()
	var/obj/item/weapon/paper/complaint_form/CF = ..()
	CF.id = id
	CF.signed = signed
	CF.signed_ckey = signed_ckey
	CF.signed_name = signed_name
	return CF


/obj/item/weapon/complaint_folder
	name = "Complaint #______"
	desc = "The pen is mightier than the sword."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "folder"
	w_class = ITEM_SIZE_SMALL

	var/id
	var/target_name
	var/target_occupation
	var/target_rank
	var/target_ckey
	var/signed = FALSE
	var/obj/item/weapon/paper/complaint_form/main_form

	var/finished = FALSE

/obj/item/weapon/complaint_folder/proc/copy(loc = src.loc, generate_stamps = TRUE)
	var/obj/item/weapon/complaint_folder/CFo = new src.type(loc, noinit = TRUE)
	CFo.name = name
	CFo.id = id
	CFo.target_name = target_name
	CFo.target_occupation = target_occupation
	for (var/obj/item/weapon/paper/complaint_form/CF in contents)
		if (CF != main_form)
			CF.copy(CFo, generate_stamps)
	CFo.main_form = main_form.copy(CFo, generate_stamps)
	return CFo

/obj/item/weapon/complaint_folder/proc/recolorize(saturation = 1, grayscale = FALSE, amount = 99)
	if (amount < 1)
		return 0
	main_form.recolorize(saturation, grayscale)
	for (var/obj/item/weapon/paper/complaint_form/CF in contents)
		if (CF == main_form)
			continue
		if (--amount < 0)
			qdel(CF)
		else
			CF.recolorize(saturation, grayscale)
	return amount



/obj/item/weapon/complaint_folder/New(loc, id, noinit = FALSE)
	. = ..()
	if (noinit)
		return
	src.id = id
	name = "Complaint #[id]"
	main_form = new(src, id)

/obj/item/weapon/complaint_folder/examine(mob/user)
	. = ..()
	if (main_form.signed)
		. += "\n[SPAN_NOTICE("It is signed by [main_form.signed_name]")]"
		if (length(contents) > 1)
			var/counter = 0
			for (var/obj/item/weapon/paper/complaint_form/F in contents)
				counter++
			. += "\n[SPAN_NOTICE("It has [counter - 1] complaint forms attached")]"

/obj/item/weapon/complaint_folder/proc/check_signed()
	if (signed)
		return TRUE
	if (main_form.signed)
		var/fields = main_form.parse_named_fields()
		target_name = strip_html_properly(fields["target_name"])
		target_occupation = strip_html_properly(fields["target_occupation"])
		signed = TRUE

		for(var/mob/M in SSmobs.mob_list)
			if (M.real_name != target_name || !M.ckey || !M.mind)
				continue
			if (target_occupation != (M.mind.role_alt_title ? M.mind.role_alt_title : M.mind.assigned_role))
				continue
			target_ckey = M.ckey
			target_rank = M.mind.assigned_role //screw these alt titles, need real job to ban
			break

		return TRUE

/obj/item/weapon/complaint_folder/attackby(obj/item/weapon/W, mob/user)
	if (istype(W, /obj/item/weapon/paper/complaint_form))
		var/obj/item/weapon/paper/complaint_form/CF = W
		if (!check_signed())
			to_chat(user, SPAN_WARNING("Sign [src] first!"))
			return
		if (id == CF.id)
			to_chat(user, SPAN_NOTICE("You add \the [CF] to \the [src]."))
			user.drop_item()
			CF.forceMove(src)
			return
		to_chat(user, SPAN_WARNING("IDs don't match!"))
		return

	if (istype(W, /obj/item/weapon/pen))
		main_form.attackby(W, user)
		return

	return ..()

/obj/item/weapon/complaint_folder/attack_self(mob/living/user)
	user.examinate(main_form)
	return ..()

/obj/item/weapon/complaint_folder/attack_hand(mob/user)
	if (user.get_inactive_hand() != src)
		return ..()
	if (!check_signed())
		to_chat(user, SPAN_WARNING("Sign [src] first!"))
		return
	var/list/choices_list = list()
	for (var/obj/item/weapon/paper/complaint_form/F in contents)
		if (F != main_form)
			choices_list += F
	var/const/new_form_choice = "New complaint form"
	choices_list += new_form_choice
	var/action = input(user, "Choose form to take out", name, new_form_choice) as null|anything in choices_list
	if (!action)
		return
	if (istype(action,/obj/item/weapon/paper/complaint_form))
		user.put_in_hands(action)
		to_chat(user, SPAN_NOTICE("You take [action] out of [src]."))
		return
	if (action == new_form_choice)
		var/new_form = new /obj/item/weapon/paper/complaint_form(src.loc, id, target_name, target_occupation)
		user.put_in_hands(new_form)
		to_chat(user, SPAN_NOTICE("You take [new_form] out of [src]."))
		return


#define enum_CAPTAIN 1
#define enum_HEAD 2
#define enum_CREWMEMBER 3

/proc/check_records(name, occupation)
	if (!name || !occupation)
		return 0
	var/datum/computer_file/crew_record/CR = get_crewmember_record(name)
	if (!CR)
		return 0
	var/job = CR.get_job()
	if (occupation != job)
		return 0
	var/datum/job/actual_job = job_master.GetJob(CR.get_job())
	if (!actual_job)
		return 0
	if (actual_job.title == "Captain")
		return enum_CAPTAIN
	if (actual_job.head_position)
		return enum_HEAD
	return enum_CREWMEMBER

/proc/check_requirements(target_significance, captains, heads, crewmembers)
	switch(target_significance)
		if (enum_CAPTAIN)
			return (heads + captains >= 2 && crewmembers >= 1 || crewmembers + heads + captains >= 7)
		if (enum_HEAD)
			return (captains >= 1 && crewmembers + heads >= 2 || crewmembers + heads >= 5)
		if (enum_CREWMEMBER)
			return (captains + heads >= 1 && crewmembers + heads + captains >= 2 || crewmembers + heads + captains >= 5)
		else
			EXCEPTION("Invalid target_significance")


//validation procs return reason if validation fails
//prevalidation happens before sending to admins, fail reason is shown to sender
//validation happens after sending to admins but before working with database, fail reason is relayed to admins

/obj/item/weapon/complaint_folder/proc/prevalidate()
	if (finished)
		return //no need to alert the crew

	if (!check_signed())
		return "Main form is not signed"

	var/target_significance = check_records(target_name, target_occupation)
	if (!target_significance)
		return "Main form is malformed"

	var/parsed_main_data = main_form.parse_named_fields()
	var/parsed_main_name = strip_html_properly(parsed_main_data["name"])
	var/parsed_main_occupation = strip_html_properly(parsed_main_data["occupation"])
	var/main_record = check_records(parsed_main_name, parsed_main_occupation)
	if (!main_record)
		return "Main form is malformed"

	for (var/obj/item/weapon/paper/complaint_form/CF in contents)
		if(!CF.signed)
			return "At least one of supplementary forms is not signed"
	
	var/captains = 0
	var/heads = 0
	var/crewmembers = 0

	var/list/names = list()
	names += parsed_main_name

	for (var/obj/item/weapon/paper/complaint_form/CF in contents)
		if (CF == main_form)
			continue
		var/parsed_data = CF.parse_named_fields()
		var/parsed_name = strip_html_properly(parsed_data["name"])
		var/parsed_occupation = strip_html_properly(parsed_data["occupation"])
		var/parsed_reason = strip_html_properly(parsed_data["reason"])
		var/parsed_brief_reason = strip_html_properly(parsed_data["brief_reason"])
		var/record = check_records(parsed_name, parsed_occupation)
		
		if (!record || !parsed_reason || !parsed_brief_reason || parsed_name != CF.signed_name)
			return "At least one of supplementary forms is malformed"
		if (parsed_name in names)
			return "There's at least one duplicate supplementary form"
		names += parsed_name

		switch(record)
			if(enum_CAPTAIN)
				captains++
			if(enum_HEAD)
				heads++
			if(enum_CREWMEMBER)
				crewmembers++
			else
				EXCEPTION("Invalid record")

	if (!check_requirements(target_significance, captains, heads, crewmembers))
		return "Minimal requirements on supplementary complaints weren't reached"
	return //success

/obj/item/weapon/complaint_folder/proc/validate()
	if (finished)
		return "Already finished"
	var/list/ckeys = list()
	for (var/obj/item/weapon/paper/complaint_form/CF in contents)
		if (CF.signed_ckey in ckeys)
			return "Duplicate ckey found"
		if (!CF.signed_ckey)
			return "Signed form with no ckey bound found"
		ckeys += CF.signed_ckey

	var/main_ckey = main_form.signed_ckey
	var/mob/main_mob = get_mob_by_key(main_ckey)
	if (!main_mob.mind)
		return "Sender has no mind"
	if (main_mob.mind.assigned_role != "Internal Affairs Agent")
		return "IAA wasn't assigned by Centcomm"
	return //success

/obj/item/weapon/complaint_folder/proc/postvalidate()
	if (finished)
		return "Already finished"
	if (!target_ckey)
		for(var/mob/M in SSmobs.mob_list)
			if (M.real_name != target_name || !M.ckey || !M.mind)
				continue
			if (target_occupation != (M.mind.role_alt_title ? M.mind.role_alt_title : M.mind.assigned_role))
				continue
			target_ckey = M.ckey
			target_rank = M.mind.assigned_role //screw these alt titles, need real job to ban
			break

	if (!target_ckey)
		target_ckey = "???"
	if (target_ckey == "???")
		return "Wasn't able to deduce target player ckey"

	//success
	var/list/others = list()
	var/list/reason = list()
	for(var/obj/item/weapon/paper/complaint_form/CF in contents)
		reason += "[CF.signed_name] ([CF.signed_ckey])<hr>[CF.info]"
		if (CF == main_form)
			continue
		others += CF.signed_ckey
	finished = TRUE
	IAAJ_insert_new(id, target_ckey, main_form.signed_ckey, jointext(others, ", "), jointext(reason, "<hr><hr>"), target_rank)
	return

#undef enum_CAPTAIN
#undef enum_HEAD
#undef enum_CREWMEMBER
