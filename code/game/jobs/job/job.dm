/datum/job

	//The name of the job
	var/title = "NOPE"
	//Job access. The use of minimal_access or access is determined by a config setting: config.game.jobs_have_minimal_access
	var/list/minimal_access = list()      // Useful for servers which prefer to only have access given to the places a job absolutely needs (Larger server population)
	var/list/access = list()              // Useful for servers which either have fewer players, so each person needs to fill more than one role, or servers which like to give more access, so players can't hide forever in their super secure departments (I'm looking at you, chemistry!)
	var/list/software_on_spawn = list()   // Defines the software files that spawn on tablets and labtops
	var/list/access_control = list()      // What access this job can give and withdraw via the ID modification program.
	var/department_flag = 0
	var/total_positions = 0               // How many players can be this job
	var/spawn_positions = 0               // How many players can spawn in as this job
	var/current_positions = 0             // How many players have this job
	var/availablity_chance = 100          // Percentage chance job is available each round
	var/no_latejoin = FALSE               // Disables late join for this job

	var/open_vacancies   = 0              // How many vacancies were opened by heads
	var/filled_vacancies = 0              // How many vacancies were filled
	var/can_be_hired  = TRUE              // Can the Command  open a vacancy for this role?

	var/supervisors = null                // Supervisors, who this person answers to directly
	var/selection_color = "#ffffff"       // Selection screen color
	var/list/alt_titles                   // List of alternate titles, if any and any potential alt. outfits as assoc values.
	var/req_admin_notify                  // If this is set to 1, a text is printed to the player when jobs are assigned, telling him that he should let admins know that he has to disconnect.
	var/minimal_player_age = 0            // If you have use_age_restriction_for_jobs config option enabled and the database set up, this option will add a requirement for players to be at least minimal_player_age days old. (meaning they first signed in at least that many days before.)
	var/department = null                 // Does this position have a department tag?
	var/head_position = FALSE             // Is this position Command?
	var/minimum_character_age = 0
	var/ideal_character_age = 30
	var/faction_restricted = FALSE
	var/create_record = TRUE              // Do we announce/make records for people who spawn on this job?

	var/account_allowed = TRUE            // Does this job type come with a station account?
	var/economic_modifier = 2             // With how much does this job modify the initial account amount?

	var/outfit_type                       // The outfit the employee will be dressed in, if any
	var/list/preview_override             // Overrides the preview mannequin w/ given icon. Must be formatted as 'list(icon_state, icon)'.

	var/loadout_allowed = TRUE            // Whether or not loadout equipment is allowed and to be created when joining.

	var/announced = TRUE                  //If their arrival is announced on radio
	var/latejoin_at_spawnpoints           //If this job should use roundstart spawnpoints for latejoin (offstation jobs etc)
	var/off_station = FALSE

	var/hud_icon						  //icon used for Sec HUD overlay
	var/show_in_setup = TRUE

/datum/job/New()
	..()
	if(prob(100-availablity_chance))	//Close positions, blah blah.
		total_positions = 0
		spawn_positions = 0
	if(!hud_icon)
		hud_icon = "hud[ckey(title)]"

/datum/job/dd_SortValue()
	return title

/datum/job/proc/equip(mob/living/carbon/human/H, alt_title)
	var/decl/hierarchy/outfit/outfit = get_outfit(H, alt_title)
	if(!outfit)
		return FALSE
	. = outfit.equip(H, title, alt_title)

/datum/job/proc/get_outfit(mob/living/carbon/human/H, alt_title)
	if(alt_title && alt_titles)
		. = alt_titles[alt_title]
	. = . || outfit_type
	. = outfit_by_type(.)

/datum/job/proc/setup_account(mob/living/carbon/human/H)
	if(!account_allowed || (H.mind && H.mind.initial_account))
		return

	var/loyalty = 1
	if(H.client)
		switch(H.client.prefs.nanotrasen_relation)
			if(COMPANY_LOYAL)		loyalty = 1.30
			if(COMPANY_SUPPORTATIVE)loyalty = 1.15
			if(COMPANY_NEUTRAL)		loyalty = 1
			if(COMPANY_SKEPTICAL)	loyalty = 0.85
			if(COMPANY_OPPOSED)		loyalty = 0.70

	//give them an account in the station database
	if(!(H.species && (H.species.type in economic_species_modifier)))
		return //some bizarre species like shadow, metroid, or monkey? You don't get an account.

	var/species_modifier = economic_species_modifier[H.species.type]

	var/money_amount = (rand(5,50) + rand(5, 50)) * loyalty * economic_modifier * species_modifier * GLOB.using_map.salary_modifier
	var/datum/money_account/M = create_account(H.real_name, money_amount, null, off_station)
	if(H.client)
		M.security_level = H.client.prefs.bank_security
		if(H.client.prefs.bank_pin)
			M.remote_access_pin = H.client.prefs.bank_pin
	if(H.mind)
		var/remembered_info = ""
		remembered_info += "<b>Your account:</b><br>"
		remembered_info += "<b>Number:</b> #[M.account_number]<br>"
		remembered_info += "<b>Pin:</b> [M.remote_access_pin]<br>"
		remembered_info += "<b>Funds:</b> [M.money]cr.<br>"

		if(M.transaction_log.len)
			var/datum/transaction/T = M.transaction_log[1]
			remembered_info += "<b>Your account was created:</b> [T.time], [T.date] at [T.source_terminal]<br>"
		H.mind.store_memory(remembered_info)

		H.mind.initial_account = M

	to_chat(H, SPAN("notice", "<b>Your account number is: [M.account_number], your account pin is: [M.remote_access_pin]</b>"))

// overrideable separately so AIs/borgs can have cardborg hats without unneccessary new()/qdel()
/datum/job/proc/equip_preview(mob/living/carbon/human/H, alt_title)
	var/decl/hierarchy/outfit/outfit = get_outfit(H, alt_title)
	if(!outfit)
		return FALSE
	if(!isnull(preview_override))
		if(!islist(preview_override) || length(preview_override) != 2)
			util_crash_with("Job [title] uses preview_override and it's broken. Someone's fucked things up.")
			return FALSE
		H.ClearOverlays()
		H.update_icon = FALSE
		H.icon = preview_override[2]
		H.icon_state = preview_override[1]
		return TRUE
	. = outfit.equip(H, title, alt_title, OUTFIT_ADJUSTMENT_SKIP_POST_EQUIP|OUTFIT_ADJUSTMENT_SKIP_ID_PDA)

/datum/job/proc/get_access()
	if(minimal_access.len && (!config || config.game.jobs_have_minimal_access))
		return src.minimal_access.Copy()
	else
		return src.access.Copy()

//If the configuration option is set to require players to be logged as old enough to play certain jobs, then this proc checks that they are, otherwise it just returns 1
/datum/job/proc/player_old_enough(client/C)
	return (available_in_days(C) == 0) //Available in 0 days = available right now = player is old enough to play.

/datum/job/proc/available_in_days(client/C)
	if(C && config.game.use_age_restriction_for_jobs && QDELETED(C.holder) && isnum(C.player_age) && isnum(minimal_player_age))
		return max(0, minimal_player_age - C.player_age)
	return FALSE

/datum/job/proc/apply_fingerprints(mob/living/carbon/human/target)
	if(!istype(target))
		return FALSE
	for(var/obj/item/item in target.contents)
		apply_fingerprints_to_item(target, item)
	return TRUE

/datum/job/proc/apply_fingerprints_to_item(mob/living/carbon/human/holder, obj/item/item)
	item.add_fingerprint(holder, 1)
	if(item.contents.len)
		for(var/obj/item/sub_item in item.contents)
			apply_fingerprints_to_item(holder, sub_item)

/datum/job/proc/is_position_available()
	return (current_positions < total_positions + open_vacancies) || (total_positions == -1)

/datum/job/proc/has_alt_title(mob/H, supplied_title, desired_title)
	return (supplied_title == desired_title) || (H.mind && H.mind.role_alt_title == desired_title)

/datum/job/proc/is_restricted(datum/preferences/prefs, feedback)
	var/datum/species/S = all_species[prefs.species]
	if(!is_species_allowed(S))
		to_chat(feedback, SPAN("boldannounce", "Restricted species, [S], for [title]."))
		return TRUE

	return FALSE

/datum/job/proc/is_species_allowed(datum/species/S)
	return !GLOB.using_map.is_species_job_restricted(S, src)

/datum/job/proc/set_positions(value)
	total_positions = value
	spawn_positions = value
