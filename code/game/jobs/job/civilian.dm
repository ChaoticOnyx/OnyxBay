
//More or less assistants
/datum/job/librarian
	title = "Librarian"
	department = "Civilian"
	department_flag = CIV
	total_positions = 1
	spawn_positions = 1
	supervisors = "the heads of staff"
	selection_color = "#515151"
	access = list(access_library, access_maint_tunnels)
	minimal_access = list(access_library)
	alt_titles = list("Journalist")
	outfit_type = /decl/hierarchy/outfit/job/librarian

/datum/job/iaa
	title = "Internal Affairs Agent"
	department = "Support"
	department_flag = SPT
	total_positions = 2
	spawn_positions = 2
	supervisors = "company officials and Corporate Regulations"
	selection_color = "#515151"
	economic_modifier = 7
	faction_restricted = TRUE
	access = list(access_iaa, access_security, access_maint_tunnels, access_heads)
	minimal_access = list(access_iaa, access_security, access_heads)
	minimal_player_age = 14
	outfit_type = /decl/hierarchy/outfit/job/internal_affairs_agent

/datum/job/iaa/equip(mob/living/carbon/human/H)
	. = ..()
	if(.)
		H.implant_loyalty(H)

/datum/job/lawyer
	title = "Lawyer"
	department = "Civilian"
	department_flag = CIV
	total_positions = 2
	spawn_positions = 2
	supervisors = "the head of security"
	selection_color = "#515151"
	economic_modifier = 3
	access = list(access_lawyer, access_security)
	minimal_access = list(access_lawyer)
	minimal_player_age = 7
	outfit_type = /decl/hierarchy/outfit/job/lawyer

/datum/job/clown
	title = "Clown"
	department = "Civilian"
	department_flag = CIV
	total_positions = 1
	spawn_positions = 1
	supervisors = "uncommon sense"
	selection_color = "#515151"
	access = list(access_maint_tunnels, access_clown)
	minimal_access = list(access_maint_tunnels, access_clown)
	minimal_player_age = 10
	outfit_type = /decl/hierarchy/outfit/job/clown

/datum/job/clown/equip(mob/living/carbon/human/H)
	. = ..()
	if(.)
		H.add_mutation(MUTATION_CLUMSY)
		H.rename_self("clown")

/datum/job/mime
	title = "Mime"
	department = "Civilian"
	department_flag = CIV
	total_positions = 1
	spawn_positions = 1
	supervisors = "the sound of silence"
	selection_color = "#515151"
	access = list(access_maint_tunnels, access_mime)
	minimal_access = list(access_maint_tunnels, access_mime)
	minimal_player_age = 10
	outfit_type = /decl/hierarchy/outfit/job/mime

/datum/job/mime/equip(mob/living/carbon/human/H)
	. = ..()
	if(H.mind.changeling)
		return
	if(.)
		H.silent += 86400
		H.rename_self("mime")
	// Add "Invisible wall" spell
	H.add_spell(new /datum/spell/aoe_turf/conjure/forcewall/mime, "grey_spell_ready")

/datum/job/merchant
	title = "Merchant"
	department = "Civilian"
	department_flag = CIV
	total_positions = 2
	spawn_positions = 2
	availablity_chance = 40
	supervisors = "the invisible hand of the market"
	selection_color = "#515151"
	ideal_character_age = 30
	minimal_player_age = 7
	create_record = 0
	outfit_type = /decl/hierarchy/outfit/job/merchant
	latejoin_at_spawnpoints = 1
	access = list(access_merchant)
	announced = FALSE
	can_be_hired = FALSE
	off_station = TRUE
