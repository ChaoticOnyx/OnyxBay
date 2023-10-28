/datum/job/cm
	title = "Colonial Marshal"
	head_position = 1
	department = "Security"
	department_flag = SEC|COM

	total_positions = 1
	spawn_positions = 1
	supervisors = "the mayor"
	selection_color = "#8e2929"
	req_admin_notify = 1
	economic_modifier = 10
	faction_restricted = TRUE
	access = list(access_security, access_eva, access_sec_doors, access_brig, access_armory,
			            access_forensics_lockers, access_morgue, access_maint_tunnels, access_all_personal_lockers,
			            access_research, access_engine, access_mining, access_medical, access_construction, access_mailsorting,
			            access_heads, access_hos, access_RC_announce, access_keycard_auth, access_gateway, access_external_airlocks, access_lawyer)
	minimal_access = list(access_security, access_eva, access_sec_doors, access_brig, access_armory,
			            access_forensics_lockers, access_morgue, access_maint_tunnels, access_all_personal_lockers,
			            access_research, access_engine, access_mining, access_medical, access_construction, access_mailsorting,
			            access_heads, access_hos, access_RC_announce, access_keycard_auth, access_gateway, access_external_airlocks, access_lawyer)
	minimal_player_age = 30
	minimum_character_age = 25
	outfit_type = /decl/hierarchy/outfit/job/security/hos

/datum/job/hos/equip(mob/living/carbon/human/H)
	. = ..()
	if(.)
		H.implant_loyalty(H)

/datum/job/sheriff
	title = "Sheriff"
	department = "Security"
	department_flag = SEC

	total_positions = 1
	spawn_positions = 1
	supervisors = "the colonial marshal"
	selection_color = "#601c1c"
	economic_modifier = 5
	access = list(access_security, access_eva, access_sec_doors, access_brig, access_armory, access_maint_tunnels, access_morgue, access_external_airlocks)
	minimal_access = list(access_security, access_eva, access_sec_doors, access_brig, access_armory, access_maint_tunnels, access_external_airlocks)
	minimal_player_age = 14
	outfit_type = /decl/hierarchy/outfit/job/security/warden


/datum/job/deputy
	title = "County Deputy"
	department = "Security"
	department_flag = SEC

	total_positions = 0
	spawn_positions = 0
	supervisors = "the sheriff"
	selection_color = "#601c1c"
	alt_titles = list("Town Deputy")
	economic_modifier = 4
	access = list(access_security, access_eva, access_sec_doors, access_brig, access_maint_tunnels, access_morgue, access_external_airlocks)
	minimal_access = list(access_security, access_eva, access_sec_doors, access_brig, access_maint_tunnels, access_external_airlocks)
	minimal_player_age = 14
	outfit_type = /decl/hierarchy/outfit/job/security/officer
