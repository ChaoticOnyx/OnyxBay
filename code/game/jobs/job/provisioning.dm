
/datum/job/hop
	title = "Head of Provisioning"
	department = "Provisioning"
	head_position = 1
	department_flag = SRV|SUP|COM

	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#659191"
	req_admin_notify = 1
	minimal_player_age = 30
	minimum_character_age = 25
	economic_modifier = 10
	ideal_character_age = 45
	faction_restricted = TRUE

	access = list(access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mining, access_mining_station,
			access_bar, access_construction, access_kitchen, access_hydroponics, access_janitor, access_tech_storage,
			access_heads, access_hop, access_RC_announce, access_keycard_auth, access_sec_doors, access_eva, access_maint_tunnels, access_external_airlocks, access_change_ids, access_teleporter)
	minimal_access = list(access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mining, access_mining_station,
			access_bar, access_construction, access_kitchen, access_hydroponics, access_janitor, access_tech_storage,
			access_heads, access_hop, access_RC_announce, access_keycard_auth, access_sec_doors, access_eva, access_maint_tunnels, access_external_airlocks, access_change_ids, access_teleporter)

	outfit_type = /decl/hierarchy/outfit/job/hop

// Cargo
/datum/job/cargo_tech
	title = "Cargo Technician"
	department = "Cargo"
	department_flag = SUP
	total_positions = 2
	spawn_positions = 2
	supervisors = "the head of provisioning"
	selection_color = "#686140"
	access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mining, access_mining_station)
	minimal_access = list(access_maint_tunnels, access_cargo, access_cargo_bot, access_mailsorting)
	alt_titles = list(
		"Cargo Docker" = /decl/hierarchy/outfit/job/cargo/cargo_tech/docker
		)
	outfit_type = /decl/hierarchy/outfit/job/cargo/cargo_tech

/datum/job/mining
	title = "Shaft Miner"
	department = "Cargo"
	department_flag = SUP
	total_positions = 3
	spawn_positions = 3
	supervisors = "the head of provisioning"
	selection_color = "#686140"
	economic_modifier = 5
	access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mining, access_mining_station)
	minimal_access = list(access_mining, access_mining_station, access_mailsorting)
	alt_titles = list("Drill Technician","Prospector")
	outfit_type = /decl/hierarchy/outfit/job/cargo/mining

// Provisioning
/datum/job/bartender
	title = "Bartender"
	department = "Provisioning"
	department_flag = SRV
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of provisioning"
	selection_color = "#4E6978"
	access = list(access_hydroponics, access_bar, access_kitchen)
	minimal_access = list(access_bar)
	outfit_type = /decl/hierarchy/outfit/job/provisioning/bartender

/datum/job/bartender/equip(mob/living/carbon/human/H)
	. = ..()
	if(.)
		H.add_mutation(MUTATION_BARTENDER)

/datum/job/chef
	title = "Chef"
	department = "Provisioning"
	department_flag = SRV
	total_positions = 2
	spawn_positions = 2
	supervisors = "the head of provisioning"
	selection_color = "#4E6978"
	access = list(access_hydroponics, access_bar, access_kitchen)
	minimal_access = list(access_kitchen)
	alt_titles = list("Cook")
	outfit_type = /decl/hierarchy/outfit/job/provisioning/chef

/datum/job/barmonkey
	title = "Waiter"
	department = "Provisioning"
	department_flag = SRV
	total_positions = 1
	spawn_positions = 1
	no_latejoin = TRUE
	supervisors = "the bartender"
	selection_color = "#4E6978"
	access = list(access_hydroponics, access_bar, access_kitchen)
	minimal_access = list(access_bar)
	outfit_type = /decl/hierarchy/outfit/job/provisioning/barmonkey
	preview_override = list("preview", 'icons/mob/human_races/monkeys/r_monkey.dmi')

/datum/job/barmonkey/equip(mob/living/carbon/human/H)
	. = ..()
	if(.)
		var/new_name = (H.gender == FEMALE ? "Mrs. Deempisi" : "Mr. Deempisi")
		H.fully_replace_character_name(new_name)
		H.dna.real_name = new_name
		H.mind?.name = new_name
		H.flavor_text = ""
		H.add_mutation(MUTATION_BARTENDER)
		for(var/thing in H.flavor_texts)
			H.flavor_texts[thing] = null

/datum/job/hydro
	title = "Gardener"
	department = "Provisioning"
	department_flag = SRV
	total_positions = 2
	spawn_positions = 1
	supervisors = "the head of provisioning"
	selection_color = "#4E6978"
	access = list(access_hydroponics, access_bar, access_kitchen)
	minimal_access = list(access_hydroponics)
	alt_titles = list("Hydroponicist")
	outfit_type = /decl/hierarchy/outfit/job/provisioning/gardener

/datum/job/janitor
	title = "Janitor"
	department = "Provisioning"
	department_flag = SRV
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of provisioning"
	selection_color = "#4E6978"
	access = list(access_janitor, access_maint_tunnels, access_engine, access_research, access_sec_doors, access_medical)
	minimal_access = list(access_janitor, access_maint_tunnels, access_engine, access_research, access_sec_doors, access_medical)
	alt_titles = list("Custodian","Sanitation Technician")
	outfit_type = /decl/hierarchy/outfit/job/provisioning/janitor
