/datum/ghost_arena_gamemode/ffa
	name = "Free for all"
	round_duration = GA_ROUND_FFA_DURATION
	max_rounds = 1
	freezetime = 0

/datum/ghost_arena_gamemode/ffa/spawn_players()
	SSarena.change_money(SSarena.players, GA_FFA_MONEY_START)
	return ..()

/datum/ghost_arena_gamemode/ffa/on_death(client/player)
	spawn(respawn_delay)
		SSarena.create_body(player, SSarena.ghost_arena_spawns, FALSE)
	SSarena.change_player_money(player, 50)
	if(player.mob)
		QDEL_IN(player.mob, ARENA_RESPAWN_DELAY)
	return

/datum/ghost_arena_gamemode/ffa/equip_mob(mob/living/carbon/human/arenahuman/my_mob)
	my_mob.put_in_any_hand_if_possible(new /obj/item/gun/projectile/revolver/detective/saw620(src))
	return ..()

/datum/ghost_arena_gamemode/ffa/end_round()
	postend()
	return ..()

/datum/ghost_arena_gamemode/ffa/end_game()
	SSarena.play_sound(SSarena.players, "draw")
	return ..()
