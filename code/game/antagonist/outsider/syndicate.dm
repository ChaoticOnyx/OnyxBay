GLOBAL_DATUM_INIT(syndies, /datum/antagonist/syndicate, new)

/datum/antagonist/syndicate
	id = MODE_NUKE
	role_text = "Syndicate Operative"
	antag_indicator = "hudsyndicate"
	role_text_plural = "Syndicate Operatives"
	landmark_id = "Syndicate Operative"
	leader_welcome_text = "You are the leader of the Syndicate Operatives; hail to the chief. Use :t to speak to your underlings."
	welcome_text = "To speak on the strike team's private channel use :t."
	flags = ANTAG_VOTABLE | ANTAG_OVERRIDE_JOB | ANTAG_CLEAR_EQUIPMENT | ANTAG_CHOOSE_NAME | ANTAG_HAS_NUKE | ANTAG_SET_APPEARANCE | ANTAG_HAS_LEADER
	antaghud_indicator = "hudoperative"

	hard_cap = 4
	hard_cap_round = 6
	initial_spawn_req = 3
	initial_spawn_target = 4

	faction = "syndicate"

	station_crew_involved = FALSE

/datum/antagonist/syndicate/Initialize()
	. = ..()
	if(config.game.nuke_min_age)
		min_player_age = config.game.nuke_min_age

/datum/antagonist/syndicate/create_global_objectives()
	if(!..())
		return 0
	global_objectives = list()
	global_objectives |= new /datum/objective/nuclear
	return 1

/datum/antagonist/syndicate/equip(mob/living/carbon/human/player)
	if(!..())
		return 0

	var/decl/hierarchy/outfit/syndicate = outfit_by_type(/decl/hierarchy/outfit/syndicate)
	syndicate.equip(player)

	var/obj/item/device/radio/uplink/U = new(get_turf(player), player.mind, NUCLEAR_TELECRYSTAL_AMOUNT)
	player.put_in_hands(U)

	return 1
