GLOBAL_DATUM_INIT(commandos, /datum/antagonist/deathsquad/syndicate, new)

/datum/antagonist/deathsquad/syndicate
	id = MODE_COMMANDO
	landmark_id = "Syndicate-Commando"
	role_text = "Syndicate Commando"
	role_text_plural = "Commandos"
	welcome_text = "You are in the employ of a criminal syndicate hostile to corporate interests."
	id_type = /obj/item/weapon/card/id/syndicate
	flags = ANTAG_RANDOM_EXCEPTED | ANTAG_CLEAR_EQUIPMENT | ANTAG_CHOOSE_NAME | ANTAG_OVERRIDE_JOB | ANTAG_SET_APPEARANCE
	antaghud_indicator = "hudoperative"

	valid_species = list(SPECIES_HUMAN) // Syndicate Comms don't like xenos.

	hard_cap = 4
	hard_cap_round = 8
	initial_spawn_req = 4
	initial_spawn_target = 6

	station_crew_involved = FALSE

/datum/antagonist/deathsquad/syndicate/equip(mob/living/carbon/human/player)

	player.equip_to_slot_or_del(new /obj/item/clothing/under/syndicate(player), slot_w_uniform)
	player.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/silenced(player), slot_belt)
	player.equip_to_slot_or_del(new /obj/item/clothing/shoes/swat(player), slot_shoes)
	player.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/standard/thermal(player), slot_glasses)
	player.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/syndicate(player), slot_wear_mask)
	player.equip_to_slot_or_del(new /obj/item/weapon/storage/box(player), slot_in_backpack)
	player.equip_to_slot_or_del(new /obj/item/ammo_magazine/box/c45(player), slot_in_backpack)
	player.equip_to_slot_or_del(new /obj/item/weapon/rig/syndi(player), slot_back)
	player.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/pulse_rifle(player), slot_r_hand)
	player.equip_to_slot_or_del(new /obj/item/weapon/melee/energy/sword/one_hand(player), slot_l_hand)

	create_id("Commando", player)
	create_radio(SYND_FREQ, player)
	return 1
