/datum/preferences
	var/med_record = ""
	var/sec_record = ""
	var/gen_record = ""
	var/nanotrasen_relation = "Neutral"
	var/memory = ""

	//Some faction information.
	var/home_system = "Unset"           //System of birth.
	var/citizenship = "None"            //Current home system.
	var/faction = "NanoTrasen"          //General associated faction.
	var/religion = "None"               //Religious association.

	var/bank_security = BANK_SECURITY_MODERATE // bank account security level
	var/bank_pin = 0 // bank account PIN, 0 gives a random PIN

/datum/category_item/player_setup_item/general/background
	name = "Background"
	sort_order = 5

/datum/category_item/player_setup_item/general/background/load_character(datum/pref_record_reader/R)
	pref.nanotrasen_relation = R.read("nanotrasen_relation")
	pref.home_system = R.read("home_system")
	pref.citizenship = R.read("citizenship")
	pref.faction = R.read("faction")
	pref.religion = R.read("religion")
	pref.bank_security = R.read("bank_security")
	pref.bank_pin = R.read("bank_pin")
	pref.med_record = R.read("med_record")
	pref.gen_record = R.read("gen_record")
	pref.sec_record = R.read("sec_record")
	pref.exploit_record = R.read("exploit_record")
	pref.memory = R.read("memory")

	// delete factions from old saves
	var/factionExist = FALSE
	for (var/faction in GLOB.using_map.faction_choices)
		if (cmptext(pref.faction, faction))
			factionExist = TRUE
			break
	if (!factionExist)
		pref.faction = "NanoTrasen"

/datum/category_item/player_setup_item/general/background/save_character(datum/pref_record_writer/W)
	W.write("nanotrasen_relation", pref.nanotrasen_relation)
	W.write("home_system", pref.home_system)
	W.write("citizenship", pref.citizenship)
	W.write("faction", pref.faction)
	W.write("religion", pref.religion)
	W.write("bank_security", pref.bank_security)
	W.write("bank_pin", pref.bank_pin)
	W.write("med_record", pref.med_record)
	W.write("gen_record", pref.gen_record)
	W.write("sec_record", pref.sec_record)
	W.write("exploit_record", pref.exploit_record)
	W.write("memory", pref.memory)

/datum/category_item/player_setup_item/general/background/sanitize_character()
	if(!pref.home_system)
		pref.home_system = "Unset"
	if(!pref.citizenship)
		pref.citizenship = "None"
	if(!pref.faction)
		pref.faction =     "NanoTrasen"
	if(!pref.religion)
		pref.religion =    "None"

	pref.bank_security = sanitize_integer(pref.bank_security, BANK_SECURITY_MINIMUM, BANK_SECURITY_MAXIMUM, initial(pref.bank_security))
	pref.bank_pin = sanitize_integer(pref.bank_pin, 1111, 9999, initial(pref.bank_pin))
	pref.nanotrasen_relation = sanitize_inlist(pref.nanotrasen_relation, COMPANY_ALIGNMENTS, initial(pref.nanotrasen_relation))

/datum/category_item/player_setup_item/general/background/content(mob/user)
	. += "<b>Background Information</b><br>"
	. += "[GLOB.using_map.company_name] Relation: <a href='?src=\ref[src];nt_relation=1'>[pref.nanotrasen_relation]</a><br/>"
	. += "Home System: <a href='?src=\ref[src];home_system=1'>[pref.home_system]</a><br/>"
	. += "Citizenship: <a href='?src=\ref[src];citizenship=1'>[pref.citizenship]</a><br/>"
	. += "Faction: <a href='?src=\ref[src];faction=1'>[pref.faction]</a><br/>"
	. += "Religion: <a href='?src=\ref[src];religion=1'>[pref.religion]</a><br/>"

	. += "<br/><b>Bank Account</b>:<br/>"
	. += "Security Level: <a href='?src=\ref[src];bank_security=1'>[pref.bank_security ? pref.bank_security == 2 ? "Maximum" : "Moderate" : "Minimum" ]</a><br>"
	. += "PIN: <a href='?src=\ref[src];bank_pin=1'>[pref.bank_pin ? pref.bank_pin : "Random"]</a><br>"

	. += "<br/><b>Records</b>:<br/>"
	if(jobban_isbanned(user, "Records"))
		. += "<span class='danger'>You are banned from using character records.</span><br>"
	else
		. += "Medical Records:<br>"
		. += "<a href='?src=\ref[src];set_medical_records=1'>[TextPreview(pref.med_record,40)]</a><br><br>"
		. += "Employment Records:<br>"
		. += "<a href='?src=\ref[src];set_general_records=1'>[TextPreview(pref.gen_record,40)]</a><br><br>"
		. += "Security Records:<br>"
		. += "<a href='?src=\ref[src];set_security_records=1'>[TextPreview(pref.sec_record,40)]</a><br><br>"
		. += "Exploitable information:<br>"
		. += "<a href='?src=\ref[src];exploitable_record=1'>[TextPreview(pref.exploit_record,40)]</a><br><br>"
		. += "Memory:<br>"
		. += "<a href='?src=\ref[src];set_memory=1'>[TextPreview(pref.memory,40)]</a><br>"

/datum/category_item/player_setup_item/general/background/OnTopic(href,list/href_list, mob/user)
	if(href_list["nt_relation"])
		var/new_relation = input(user, "Choose your relation to [GLOB.using_map.company_name]. Note that this represents what others can find out about your character by researching your background, not what your character actually thinks.", CHARACTER_PREFERENCE_INPUT_TITLE, pref.nanotrasen_relation)  as null|anything in COMPANY_ALIGNMENTS
		if(new_relation && CanUseTopic(user))
			pref.nanotrasen_relation = new_relation
			return TOPIC_REFRESH

	else if(href_list["home_system"])
		var/choice = input(user, "Please choose a home system.", CHARACTER_PREFERENCE_INPUT_TITLE, pref.home_system) as null|anything in GLOB.using_map.home_system_choices + list("Unset","Other")
		if(!choice || !CanUseTopic(user))
			return TOPIC_NOACTION
		if(choice == "Other")
			var/raw_choice = sanitize(input(user, "Please enter a home system.", CHARACTER_PREFERENCE_INPUT_TITLE)  as text|null, MAX_NAME_LEN)
			if(raw_choice && CanUseTopic(user))
				pref.home_system = raw_choice
		else
			pref.home_system = choice
		return TOPIC_REFRESH

	else if(href_list["citizenship"])
		var/choice = input(user, "Please choose your current citizenship.", CHARACTER_PREFERENCE_INPUT_TITLE, pref.citizenship) as null|anything in GLOB.using_map.citizenship_choices + list("None","Other")
		if(!choice || !CanUseTopic(user))
			return TOPIC_NOACTION
		if(choice == "Other")
			var/raw_choice = sanitize(input(user, "Please enter your current citizenship.", CHARACTER_PREFERENCE_INPUT_TITLE) as text|null, MAX_NAME_LEN)
			if(raw_choice && CanUseTopic(user))
				pref.citizenship = raw_choice
		else
			pref.citizenship = choice
		return TOPIC_REFRESH

	else if(href_list["faction"])
		var/choice = input(user, "Please choose a faction to work for.", CHARACTER_PREFERENCE_INPUT_TITLE, pref.faction) as null|anything in GLOB.using_map.faction_choices
		if(!choice || !CanUseTopic(user))
			return TOPIC_NOACTION
		pref.faction = choice
		return TOPIC_REFRESH

	else if(href_list["religion"])
		var/choice = input(user, "Please choose a religion.", CHARACTER_PREFERENCE_INPUT_TITLE, pref.religion) as null|anything in GLOB.using_map.religion_choices + list("None","Other")
		if(!choice || !CanUseTopic(user))
			return TOPIC_NOACTION
		if(choice == "Other")
			var/raw_choice = sanitize(input(user, "Please enter a religon.", CHARACTER_PREFERENCE_INPUT_TITLE)  as text|null, MAX_NAME_LEN)
			if(raw_choice)
				pref.religion = sanitize(raw_choice)
		else
			pref.religion = choice
		return TOPIC_REFRESH

	else if(href_list["bank_security"])
		var/list/sec_levels = list("Minimum", "Moderate", "Maximum")
		var/choice = input(user, "Choose your bank account's security level:", CHARACTER_PREFERENCE_INPUT_TITLE, "Moderate") as null|anything in sec_levels
		if(!choice || !CanUseTopic(user))
			return TOPIC_NOACTION
		switch(choice)
			if("Minimum")
				pref.bank_security = BANK_SECURITY_MINIMUM
			if("Moderate")
				pref.bank_security = BANK_SECURITY_MODERATE
			if("Maximum")
				pref.bank_security = BANK_SECURITY_MAXIMUM
		return TOPIC_REFRESH

	else if(href_list["bank_pin"])
		var/choice = input(user, "Set your bank account's PIN (1111-9999):\nSet to 1 to use a random PIN for each round.\nSet to 2 to generate a random PIN.", CHARACTER_PREFERENCE_INPUT_TITLE, pref.bank_pin) as num|null
		if(!choice || !CanUseTopic(user))
			return TOPIC_NOACTION
		switch(choice)
			if(1111 to 9999)
				pref.bank_pin = choice
			if(1)
				pref.bank_pin = 0
			if(2)
				pref.bank_pin = rand(1111, 9999)
		return TOPIC_REFRESH

	else if(href_list["set_medical_records"])
		var/new_medical = sanitize(input(user,"Enter medical information here.","Character Preference", html_decode(pref.med_record)) as message|null, MAX_PAPER_MESSAGE_LEN, extra = 0)
		if(!isnull(new_medical) && !jobban_isbanned(user, "Records") && CanUseTopic(user))
			pref.med_record = new_medical
		return TOPIC_REFRESH

	else if(href_list["set_general_records"])
		var/new_general = sanitize(input(user,"Enter employment information here.","Character Preference", html_decode(pref.gen_record)) as message|null, MAX_PAPER_MESSAGE_LEN, extra = 0)
		if(!isnull(new_general) && !jobban_isbanned(user, "Records") && CanUseTopic(user))
			pref.gen_record = new_general
		return TOPIC_REFRESH

	else if(href_list["set_security_records"])
		var/sec_medical = sanitize(input(user,"Enter security information here.","Character Preference", html_decode(pref.sec_record)) as message|null, MAX_PAPER_MESSAGE_LEN, extra = 0)
		if(!isnull(sec_medical) && !jobban_isbanned(user, "Records") && CanUseTopic(user))
			pref.sec_record = sec_medical
		return TOPIC_REFRESH

	else if(href_list["exploitable_record"])
		var/exploitmsg = sanitize(input(user,"Set exploitable information about you here.","Exploitable Information", html_decode(pref.exploit_record)) as message|null, MAX_PAPER_MESSAGE_LEN, extra = 0)
		if(!isnull(exploitmsg) && !jobban_isbanned(user, "Records") && CanUseTopic(user))
			pref.exploit_record = exploitmsg
			return TOPIC_REFRESH

	else if(href_list["set_memory"])
		var/memes = sanitize(input(user,"Enter memorized information here.","Character Preference", html_decode(pref.memory)) as message|null, MAX_PAPER_MESSAGE_LEN, extra = 0)
		if(!isnull(memes) && CanUseTopic(user))
			pref.memory = memes
		return TOPIC_REFRESH

	return ..()
