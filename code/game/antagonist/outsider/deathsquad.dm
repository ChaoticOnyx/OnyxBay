GLOBAL_DATUM_INIT(deathsquad, /datum/antagonist/deathsquad, new)

/datum/antagonist/deathsquad
	id = MODE_DEATHSQUAD
	role_text = "Death Commando"
	role_text_plural = "Death Commandos"
	welcome_text = "You are sent to blow the station sky-high to kingdom come."
	landmark_id = "Death Commando"
	flags = ANTAG_OVERRIDE_JOB | ANTAG_OVERRIDE_MOB | ANTAG_HAS_NUKE | ANTAG_HAS_LEADER | ANTAG_RANDOM_EXCEPTED
	default_access = list(access_cent_general, access_cent_specops, access_cent_living, access_cent_storage)
	antaghud_indicator = "huddeathsquad"

	hard_cap = 4
	hard_cap_round = 8
	initial_spawn_req = 4
	initial_spawn_target = 6

	valid_species = list(SPECIES_HUMAN) // NT don't like xenos.

	faction = "deathsquad"

	var/deployed = 0
	station_crew_involved = FALSE

/datum/antagonist/deathsquad/Initialize()
	. = ..()
	if(config.game.deathsquad_min_age)
		min_player_age = config.game.deathsquad_min_age

/datum/antagonist/deathsquad/attempt_spawn()
	if(..())
		deployed = 1

/datum/antagonist/deathsquad/equip(mob/living/carbon/human/player)
	if(!..())
		return

	if(player.mind == leader)
		player.equip_to_slot_or_del(new /obj/item/clothing/under/rank/centcom/officer(player), slot_w_uniform)
	else
		player.equip_to_slot_or_del(new /obj/item/clothing/under/color/green(player), slot_w_uniform)

	player.equip_to_slot_or_del(new /obj/item/clothing/shoes/swat(player), slot_shoes)
	player.equip_to_slot_or_del(new /obj/item/clothing/gloves/thick/swat(player), slot_gloves)
	player.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/shades/thermal/sunshield(player), slot_glasses)
	player.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/swat(player), slot_wear_mask)
	if(player.mind == leader)
		player.equip_to_slot_or_del(new /obj/item/pinpointer(player), slot_l_store)
		player.equip_to_slot_or_del(new /obj/item/disk/nuclear(player), slot_r_store)
	else
		player.equip_to_slot_or_del(new /obj/item/plastique(player), slot_l_store)
	player.equip_to_slot_or_del(new /obj/item/gun/projectile/revolver/mateba(player), slot_belt)
	player.equip_to_slot_or_del(new /obj/item/gun/energy/pulse_rifle(player), slot_r_hand)
	player.equip_to_slot_or_del(new /obj/item/storage/backpack/security(player), slot_back)
	player.equip_to_slot_or_del(new /obj/item/ammo_magazine/c50(player), slot_in_backpack)
	player.equip_to_slot_or_del(new /obj/item/ammo_magazine/c50(player), slot_in_backpack)
	player.equip_to_slot_or_del(new /obj/item/melee/energy/sword/one_hand(player), slot_l_hand)
	player.equip_to_slot_or_del(new /obj/item/clothing/suit/space/void/swat(player), slot_wear_suit)
	player.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/deathsquad(player), slot_head)
	player.implant_loyalty(player)

	var/obj/item/card/id/id = create_id("Death Commando", player)
	if(id)
		id.access |= get_all_station_access()
		id.icon_state = "centcom"
	create_radio(DTH_FREQ, player)

/datum/antagonist/deathsquad/update_antag_mob(datum/mind/player)

	..()

	var/syndicate_commando_rank
	if(leader && player == leader)
		syndicate_commando_rank = pick("Corporal", "Sergeant", "Staff Sergeant", "Sergeant 1st Class", "Master Sergeant", "Sergeant Major")
	else
		syndicate_commando_rank = pick("Lieutenant", "Captain", "Major")

	var/syndicate_commando_name = pick(GLOB.last_names)

	var/datum/preferences/A = new() //Randomize appearance for the commando.
	A.randomize_appearance_and_body_for(player.current)

	player.name = "[syndicate_commando_rank] [syndicate_commando_name]"
	player.current.real_name = player.name
	player.current.SetName(player.current.name)

	var/mob/living/carbon/human/H = player.current
	if(istype(H))
		H.gender = pick(MALE, FEMALE)
		H.age = rand(25,45)
		H.dna.ready_dna(H)

	return

/datum/antagonist/deathsquad/create_antagonist()
	if(..() && !deployed)
		deployed = 1
